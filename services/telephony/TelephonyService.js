/**
 * Telephony Service
 * Handles integration with SparkTG Cloud Telephony System
 * Supports manual calling, call logging, and webhook processing
 */

const axios = require('axios');
const logger = require('../../lib/logger');
const { query } = require('../../lib/dbconnection');

class TelephonyService {
    constructor() {
        this.baseURL = process.env.TELEPHONY_BASE_URL || 'https://telephonycloud.co.in/api/v1';
        this.username = process.env.TELEPHONY_USERNAME;
        this.password = process.env.TELEPHONY_PASSWORD;
        this.defaultServiceId = process.env.TELEPHONY_SERVICE_ID;
        this.defaultApiToken = process.env.TELEPHONY_API_TOKEN;
    }

    /**
     * Get telephony configuration for a diagnostic center
     */
    async getCenterTelephonyConfig(centerId) {
        try {
            const sql = `
                SELECT 
                    id,
                    center_name,
                    telephony_enabled,
                    telephony_agent_number,
                    telephony_service_id,
                    telephony_config,
                    contact_number
                FROM diagnostic_centers
                WHERE id = ? AND is_deleted = 0
            `;
            
            const [center] = await query(sql, [centerId]);
            
            if (!center) {
                throw new Error('Diagnostic center not found');
            }

            // If telephony_enabled is false but env credentials exist, allow call with warning
            if (!center.telephony_enabled && (!this.username || !this.password)) {
                throw new Error('Telephony is not enabled for this center');
            }

            return {
                centerId: center.id,
                centerName: center.center_name,
                agentNumber: center.telephony_agent_number || center.contact_number,
                serviceId: center.telephony_service_id || this.defaultServiceId,
                config: center.telephony_config ? JSON.parse(center.telephony_config) : {}
            };
        } catch (error) {
            logger.error('Error getting center telephony config:', error);
            throw error;
        }
    }

    /**
     * Make an outbound call to agent's MOBILE phone
     * @param {Object} params - Call parameters
     * @param {number} params.appointmentId - Appointment ID
     * @param {number} params.centerId - Diagnostic center ID
     * @param {string} params.customerNumber - Customer phone number
     * @param {number} params.userId - User initiating the call
     * @param {string} params.notes - Optional notes
     */
    async makeCallMobile({ appointmentId, centerId, customerNumber, userId, notes = null }) {
        try {
            // Get center telephony configuration
            const centerConfig = await this.getCenterTelephonyConfig(centerId);

            // Validate customer number
            if (!customerNumber || customerNumber.length < 10) {
                throw new Error('Invalid customer phone number');
            }

            // Clean phone number (remove spaces, dashes, etc.)
            let cleanNumber = customerNumber.replace(/[^\d]/g, '');
            // Add country code if not present and number is 10 digits
            if (cleanNumber.length === 10 && !cleanNumber.startsWith('91')) {
                cleanNumber = '91' + cleanNumber;
            }

            // Create call attempt record (store agent_number for webhook matching)
            const attemptSql = `
                INSERT INTO call_attempts (
                    appointment_id,
                    center_id,
                    customer_number,
                    agent_number,
                    attempt_type,
                    attempt_status,
                    attempted_by,
                    attempted_at,
                    notes
                ) VALUES (?, ?, ?, ?, 'manual', 'initiated', ?, NOW(), ?)
            `;

            // Normalize agent number for storage (digits only)
            const agentNumberStored = centerConfig.agentNumber
                ? centerConfig.agentNumber.replace(/[^0-9]/g, '')
                : null;

            const attemptResult = await query(attemptSql, [
                appointmentId,
                centerId,
                cleanNumber,
                agentNumberStored,
                userId,
                notes
            ]);

            const attemptId = attemptResult.insertId;

            // Prepare API request for MOBILE calling
            // Include agent-number to route call to agent's mobile phone
            let agentNumber = centerConfig.agentNumber;
            // Add country code if not present
            if (agentNumber && !agentNumber.startsWith('+')) {
                agentNumber = '+91' + agentNumber;
            }
            
            const apiParams = {
                number: cleanNumber,
                'agent-number': agentNumber, // Route to mobile with country code
                recording: true, // Enable call recording
                'agent-dial-first': false // Dial customer first
            };

            // Include service-id only if provided
            if (centerConfig.serviceId) {
                apiParams['service-id'] = centerConfig.serviceId;
            }

            logger.info('Initiating MOBILE call via SparkTG API', {
                appointmentId,
                centerId,
                customerNumber: cleanNumber,
                agentNumber: centerConfig.agentNumber,
                attemptId,
                callType: 'mobile',
                apiParams: apiParams,
                baseURL: this.baseURL
            });

            // Make API call to SparkTG
            // Build auth header. Prefer API token, else Basic with username/password.
            const headers = {};
            if (this.defaultApiToken) {
                headers.Authorization = `Bearer ${this.defaultApiToken}`;
            } else if (this.username && this.password) {
                const basic = Buffer.from(`${this.username}:${this.password}`).toString('base64');
                headers.Authorization = `Basic ${basic}`;
            }

            logger.info('Making API request to SparkTG', {
                url: `${this.baseURL}/calls`,
                params: apiParams,
                hasAuth: !!headers.Authorization
            });

            const response = await axios.post(
                `${this.baseURL}/calls`,
                null,
                {
                    params: apiParams,
                    headers
                }
            );

            logger.info('SparkTG API response', {
                status: response.status,
                data: response.data,
                attemptId
            });

            // Update call attempt status
            await query(
                `UPDATE call_attempts 
                 SET attempt_status = 'in_progress' 
                 WHERE id = ?`,
                [attemptId]
            );

            // Update appointment last call attempt
            await query(
                `UPDATE appointments 
                 SET last_call_attempt_at = NOW(),
                     total_call_attempts = total_call_attempts + 1
                 WHERE id = ?`,
                [appointmentId]
            );

            // Extract call ID from response and save as ongoing call
            const callId = response.data?.callid || response.data?.call_id || response.data?.id;
            
            logger.info('Checking for call ID in SparkTG response', {
                callId,
                responseData: response.data
            });
            
            if (callId) {
                try {
                    // Update call_attempts with call_id
                    await query(
                        'UPDATE call_attempts SET call_id = ? WHERE id = ?',
                        [callId, attemptId]
                    );
                    
                    // Save to ongoing_calls table
                    await query(
                        `INSERT INTO ongoing_calls (
                            call_id, appointment_id, center_id, 
                            agent_number, customer_number, call_type,
                            created_by, created_at
                        ) VALUES (?, ?, ?, ?, ?, ?, ?, NOW())
                        ON DUPLICATE KEY UPDATE updated_at = NOW()`,
                        [
                            callId,
                            appointmentId,
                            centerId,
                            agentNumber || null,
                            customerNumber,
                            'outgoing',
                            userId
                        ]
                    );
                    
                    logger.info('Call ID saved successfully', { 
                        callId, 
                        attemptId,
                        appointmentId,
                        agentNumber,
                        customerNumber
                    });
                } catch (dbError) {
                    logger.error('Failed to save call ID', {
                        error: dbError.message,
                        callId,
                        appointmentId,
                        attemptId
                    });
                }
            } else {
                logger.warn('No call ID found in SparkTG response', {
                    response: response.data
                });
            }

            logger.info('Call initiated successfully', {
                appointmentId,
                attemptId,
                callId,
                response: response.data
            });

            return {
                success: true,
                attemptId,
                callId,
                message: 'Call initiated successfully',
                data: response.data
            };

        } catch (error) {
            logger.error('Error making call:', {
                appointmentId,
                centerId,
                error: error.message,
                stack: error.stack
            });

            // Update attempt status to failed if we have attemptId
            if (error.attemptId) {
                await query(
                    `UPDATE call_attempts 
                     SET attempt_status = 'failed' 
                     WHERE id = ?`,
                    [error.attemptId]
                ).catch(err => logger.error('Failed to update attempt status:', err));
            }

            throw {
                success: false,
                message: error.response?.data?.message || error.message || 'Failed to initiate call',
                error: error.response?.data || error.message
            };
        }
    }

    /**
     * Make an outbound call to agent's BROWSER/WebRTC (via WireGuard)
     * @param {Object} params - Call parameters
     * @param {number} params.appointmentId - Appointment ID
     * @param {number} params.centerId - Diagnostic center ID
     * @param {string} params.customerNumber - Customer phone number
     * @param {number} params.userId - User initiating the call
     * @param {string} params.notes - Optional notes
     */
    async makeCallBrowser({ appointmentId, centerId, customerNumber, userId, notes = null }) {
        try {
            // Get center telephony configuration
            const centerConfig = await this.getCenterTelephonyConfig(centerId);

            // Validate customer number
            if (!customerNumber || customerNumber.length < 10) {
                throw new Error('Invalid customer phone number');
            }

            // Clean phone number (remove spaces, dashes, etc.)
            const cleanNumber = customerNumber.replace(/[^\d]/g, '');

            // Create call attempt record
            const attemptSql = `
                INSERT INTO call_attempts (
                    appointment_id,
                    center_id,
                    customer_number,
                    attempt_type,
                    attempt_status,
                    attempted_by,
                    attempted_at,
                    notes
                ) VALUES (?, ?, ?, 'manual', 'initiated', ?, NOW(), ?)
            `;

            const attemptResult = await query(attemptSql, [
                appointmentId,
                centerId,
                cleanNumber,
                userId,
                notes
            ]);

            const attemptId = attemptResult.insertId;

            // Prepare API request for BROWSER/WebRTC calling
            // Do NOT include agent-number to force WebRTC routing
            const apiParams = {
                number: cleanNumber,
                param1: `appointment_${appointmentId}`, // Track appointment in webhook
                recording: true, // Enable call recording
                'agent-dial-first': false // Dial customer first
            };

            // Include service-id only if provided
            if (centerConfig.serviceId) {
                apiParams['service-id'] = centerConfig.serviceId;
            }

            logger.info('Initiating BROWSER/WebRTC call via SparkTG API', {
                appointmentId,
                centerId,
                customerNumber: cleanNumber,
                attemptId,
                callType: 'browser'
            });

            // Make API call to SparkTG
            // Build auth header. Prefer API token, else Basic with username/password.
            const headers = {};
            if (this.defaultApiToken) {
                headers.Authorization = `Bearer ${this.defaultApiToken}`;
            } else if (this.username && this.password) {
                const basic = Buffer.from(`${this.username}:${this.password}`).toString('base64');
                headers.Authorization = `Basic ${basic}`;
            }

            const response = await axios.post(
                `${this.baseURL}/calls`,
                null,
                {
                    params: apiParams,
                    headers
                }
            );

            // Update call attempt status
            await query(
                `UPDATE call_attempts 
                 SET attempt_status = 'in_progress' 
                 WHERE id = ?`,
                [attemptId]
            );

            // Update appointment last call attempt
            await query(
                `UPDATE appointments 
                 SET last_call_attempt_at = NOW(),
                     total_call_attempts = total_call_attempts + 1
                 WHERE id = ?`,
                [appointmentId]
            );

            // Extract call ID from response and save as ongoing call
            const callId = response.data?.callid || response.data?.call_id || response.data?.id;
            
            logger.info('Checking for call ID in browser call response', {
                callId,
                responseData: response.data
            });
            
            if (callId) {
                try {
                    // Update call_attempts with call_id
                    await query(
                        'UPDATE call_attempts SET call_id = ? WHERE id = ?',
                        [callId, attemptId]
                    );
                    
                    // Save to ongoing_calls table
                    await query(
                        `INSERT INTO ongoing_calls (
                            call_id, appointment_id, center_id, 
                            agent_number, customer_number, call_type,
                            created_by, created_at
                        ) VALUES (?, ?, ?, ?, ?, ?, ?, NOW())
                        ON DUPLICATE KEY UPDATE updated_at = NOW()`,
                        [
                            callId,
                            appointmentId,
                            centerId,
                            null, // Browser calls don't have agent number
                            customerNumber,
                            'outgoing',
                            userId
                        ]
                    );
                    
                    logger.info('Call ID saved for browser call', { 
                        callId, 
                        attemptId,
                        appointmentId,
                        customerNumber
                    });
                } catch (dbError) {
                    logger.error('Failed to save call ID for browser call', {
                        error: dbError.message,
                        callId,
                        appointmentId,
                        attemptId
                    });
                }
            } else {
                logger.warn('No call ID found in browser call response', {
                    response: response.data
                });
            }

            logger.info('Browser call initiated successfully', {
                appointmentId,
                attemptId,
                callId,
                response: response.data
            });

            return {
                success: true,
                attemptId,
                callId,
                message: 'Call initiated successfully',
                data: response.data
            };

        } catch (error) {
            logger.error('Error making browser call:', {
                appointmentId,
                centerId,
                error: error.message,
                stack: error.stack
            });

            // Update attempt status to failed if we have attemptId
            if (error.attemptId) {
                await query(
                    `UPDATE call_attempts 
                     SET attempt_status = 'failed' 
                     WHERE id = ?`,
                    [error.attemptId]
                ).catch(err => logger.error('Failed to update attempt status:', err));
            }

            throw {
                success: false,
                message: error.response?.data?.message || error.message || 'Failed to initiate call',
                error: error.response?.data || error.message
            };
        }
    }

    /**
     * Process webhook data from telephony system
     * Can be called multiple times for the same call (ongoing updates)
     */
    async processCallWebhook(webhookData) {
        try {
            logger.info('Processing call webhook', { callId: webhookData.callid });

            // Get appointment and center IDs from call_attempts table
            let appointmentId = null;
            let centerId = null;

            // First try to find by call_id if we have any attempts with that call_id
            const [attemptByCallId] = await query(
                'SELECT appointment_id, center_id FROM call_attempts WHERE call_id = ? LIMIT 1',
                [webhookData.callid]
            );
            
            if (attemptByCallId) {
                appointmentId = attemptByCallId.appointment_id;
                centerId = attemptByCallId.center_id;
                logger.info('Found attempt by call_id', { callId: webhookData.callid, appointmentId, centerId });
            } else {
                // Fallback: recent attempt by appointment (order by created_at) — no agent_number dependency
                const [recentAttempt] = await query(
                    `SELECT ca.appointment_id, ca.center_id
                     FROM call_attempts ca
                     WHERE ca.attempt_status IN ('initiated', 'in_progress')
                     ORDER BY ca.created_at DESC
                     LIMIT 1`
                );

                if (recentAttempt) {
                    appointmentId = recentAttempt.appointment_id;
                    centerId = recentAttempt.center_id;
                    logger.info('Found recent attempt (fallback)', { appointmentId, centerId });
                }
            }

            // Check if call log already exists
            const [existingCall] = await query(
                'SELECT id FROM call_logs WHERE call_id = ?',
                [webhookData.callid]
            );

            let callLogId;
            const disposition = webhookData.disposition || 'missed';
            const hasEndTime = webhookData['end-time'] && webhookData['end-time'] !== '';

            if (existingCall) {
                // Update existing call log
                // If call is answered and no end_time, it's an ongoing call
                // If call has end_time or disposition is not answered, it's completed
                const updateSql = `
                    UPDATE call_logs SET
                        disposition = ?,
                        call_duration = ?,
                        recording_url = ?,
                        end_time = ?,
                        received_by = ?,
                        transferred_to = ?,
                        handle_time = ?,
                        hold_time = ?,
                        hangup_by = ?,
                        metadata = ?,
                        updated_at = NOW()
                    WHERE call_id = ?
                `;

                const updateValues = [
                    disposition,
                    parseInt(webhookData['call-duration']) || 0,
                    webhookData['recording-url'] || null,
                    hasEndTime ? new Date(webhookData['end-time']) : null,
                    webhookData['received-by'] || null,
                    webhookData['transfered-to'] || null,
                    webhookData['handle-time'] ? parseInt(webhookData['handle-time']) : null,
                    webhookData['hold-time'] ? parseInt(webhookData['hold-time']) : null,
                    webhookData['hangup-by'] || null,
                    JSON.stringify(webhookData),
                    webhookData.callid
                ];

                await query(updateSql, updateValues);
                callLogId = existingCall.id;
            } else {
                // Insert new call log
                // If disposition is 'answered' and no end_time, it's an ongoing call
                const callLogSql = `
                    INSERT INTO call_logs (
                        call_id,
                        appointment_id,
                        center_id,
                        call_type,
                        disposition,
                        call_duration,
                        agent_number,
                        customer_number,
                        virtual_number,
                        recording_url,
                        start_time,
                        end_time,
                        received_by,
                        transferred_to,
                        handle_time,
                        hold_time,
                        hangup_by,
                        service_id,
                        skill_id,
                        ivr_inputs,
                        custom_param,
                        metadata
                    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                `;

                const callLogValues = [
                    webhookData.callid,
                    appointmentId,
                    centerId,
                    webhookData['call-type'] || 'outgoing',
                    disposition,
                    parseInt(webhookData['call-duration']) || 0,
                    webhookData['agent-number'],
                    webhookData['customer-number'],
                    webhookData['virtual-number'],
                    webhookData['recording-url'] || null,
                    webhookData['start-time'] ? new Date(webhookData['start-time']) : null,
                    hasEndTime ? new Date(webhookData['end-time']) : null,
                    webhookData['received-by'] || null,
                    webhookData['transfered-to'] || null,
                    webhookData['handle-time'] ? parseInt(webhookData['handle-time']) : null,
                    webhookData['hold-time'] ? parseInt(webhookData['hold-time']) : null,
                    webhookData['hangup-by'] || null,
                    webhookData['service-id'],
                    webhookData['skill-id'] || null,
                    webhookData.ivr || null,
                    webhookData.param1 || null,
                    JSON.stringify(webhookData)
                ];

                const result = await query(callLogSql, callLogValues);
                callLogId = result.insertId;
            }

            // Update call attempt if exists
            if (appointmentId) {
                const attemptStatus = (disposition === 'answered' && !hasEndTime) ? 'in_progress' : 'completed';
                await query(
                    `UPDATE call_attempts 
                     SET attempt_status = ?,
                         call_log_id = ?
                     WHERE appointment_id = ? 
                     AND (attempt_status = 'pending' OR attempt_status = 'in_progress')
                     ORDER BY attempted_at DESC
                     LIMIT 1`,
                    [attemptStatus, callLogId, appointmentId]
                );
            }

            // Remove from ongoing_calls table if call has ended
            if (hasEndTime || disposition !== 'answered') {
                await query(
                    'DELETE FROM ongoing_calls WHERE call_id = ?',
                    [webhookData.callid]
                );
                logger.info('Call removed from ongoing_calls', { callId: webhookData.callid });
            }

            logger.info('Call webhook processed successfully', {
                callId: webhookData.callid,
                callLogId,
                appointmentId,
                isOngoing: !hasEndTime && disposition === 'answered'
            });

            return {
                success: true,
                callLogId,
                message: 'Call webhook processed successfully'
            };

        } catch (error) {
            logger.error('Error processing call webhook:', {
                error: error.message,
                webhookData
            });
            throw error;
        }
    }

    /**
     * Get call history for an appointment
     */
    async getCallHistory(appointmentId) {
        try {
            const sql = `
                SELECT 
                    cl.*,
                    dc.center_name,
                    u.full_name as attempted_by_name
                FROM call_logs cl
                LEFT JOIN diagnostic_centers dc ON cl.center_id = dc.id
                LEFT JOIN call_attempts ca ON cl.id = ca.call_log_id
                LEFT JOIN users u ON ca.attempted_by = u.id
                WHERE cl.appointment_id = ?
                ORDER BY cl.created_at DESC
            `;

            const callLogs = await query(sql, [appointmentId]);

            return {
                success: true,
                data: callLogs
            };

        } catch (error) {
            logger.error('Error getting call history:', error);
            throw error;
        }
    }

    /**
     * Get call attempts for an appointment
     */
    async getCallAttempts(appointmentId) {
        try {
            const sql = `
                SELECT 
                    ca.*,
                    dc.center_name,
                    u.full_name as attempted_by_name,
                    cl.disposition,
                    cl.call_duration,
                    cl.recording_url
                FROM call_attempts ca
                LEFT JOIN diagnostic_centers dc ON ca.center_id = dc.id
                LEFT JOIN users u ON ca.attempted_by = u.id
                LEFT JOIN call_logs cl ON ca.call_log_id = cl.id
                WHERE ca.appointment_id = ?
                ORDER BY ca.created_at DESC
            `;

            const attempts = await query(sql, [appointmentId]);

            return {
                success: true,
                data: attempts
            };

        } catch (error) {
            logger.error('Error getting call attempts:', error);
            throw error;
        }
    }

    /**
     * Validate if center can make calls for this appointment
     */
    async validateCallPermission(appointmentId, centerId) {
        try {
            const sql = `
                SELECT 
                    id,
                    visit_type,
                    center_id,
                    other_center_id,
                    medical_status,
                    center_medical_status,
                    home_medical_status
                FROM appointments
                WHERE id = ? AND is_deleted = 0
            `;

            const [appointment] = await query(sql, [appointmentId]);

            if (!appointment) {
                return {
                    success: true,
                    allowed: false,
                    reason: 'Appointment not found'
                };
            }

            // Check if center is authorized
            const visitType = appointment.visit_type?.toLowerCase();
            let isAuthorized = false;

            if (visitType === 'center_visit' || visitType === 'center') {
                isAuthorized = appointment.center_id === centerId;
            } else if (visitType === 'home_visit' || visitType === 'home') {
                // For home visit, center_id stores the home visit center
                isAuthorized = appointment.center_id === centerId;
            } else if (visitType === 'both') {
                // For both type: center_id = center visit, other_center_id = home visit
                isAuthorized = appointment.center_id === centerId || appointment.other_center_id === centerId;
            }

            if (!isAuthorized) {
                return {
                    success: true,
                    allowed: false,
                    reason: 'Center not authorized for this appointment'
                };
            }

            // Check if appointment is in valid status for calling (side-specific)
            const validStatuses = ['pending', 'scheduled', 'rescheduled', 'confirmed'];
            // Fall back to overall appointment.status if medical status is empty/none
            let status = (appointment.medical_status || appointment.status || '').toLowerCase();

            // logger.info('validateCallPermission: status inputs', {
            //     appointmentId,
            //     centerId,
            //     visitType,
            //     medical_status: appointment.medical_status,
            //     center_medical_status: appointment.center_medical_status,
            //     home_medical_status: appointment.home_medical_status,
            //     overall_status: appointment.status
            // });

            if (visitType === 'both') {
                if (appointment.center_id === centerId) {
                    status = appointment.center_medical_status?.toLowerCase() || status;
                } else if (appointment.other_center_id === centerId) {
                    status = appointment.home_medical_status?.toLowerCase() || status;
                }
            } else if (visitType === 'home_visit' || visitType === 'home') {
                status = appointment.home_medical_status?.toLowerCase() || status;
            } else if (visitType === 'center_visit' || visitType === 'center') {
                status = appointment.center_medical_status?.toLowerCase() || status;
            }

            // Map 'none' or empty to overall appointment.status
            if (!status || status === 'none') {
                status = appointment.status?.toLowerCase() || '';
            }

            // Treat explicit 'unknown' as empty to allow calling
            if (status === 'unknown') {
                status = '';
            }

            logger.info('validateCallPermission: resolved status', { appointmentId, centerId, visitType, status });

            // Only block when a status exists and is not in allowed list
            if (status && !validStatuses.includes(status)) {
                return {
                    success: true,
                    allowed: false,
                    reason: `Cannot make calls for appointments with status: ${status}`
                };
            }

            return {
                success: true,
                allowed: true,
                reason: 'Center authorized'
            };

        } catch (error) {
            logger.error('Error validating call permission:', error);
            throw error;
        }
    }

    /**
     * Spy on an ongoing call
     * @param {Object} params - Spy parameters
     * @param {string} params.callId - Call ID to spy on
     * @param {string} params.agentNumber - Agent number (optional)
     */
    async spyOnCall({ callId, agentNumber }) {
        try {
            logger.info('Initiating spy on call', { callId, agentNumber });

            // Prepare API request according to SparkTG documentation
            // Format: xnid, country-code, type, number
            const formData = new URLSearchParams();
            formData.append('xnid', callId);
            formData.append('type', 'spy');
            
            if (agentNumber) {
                // Extract country code and number
                let cleanNumber = agentNumber.replace(/\+/g, '');
                let countryCode = '91';
                let number = cleanNumber;
                
                if (cleanNumber.startsWith('91') && cleanNumber.length > 10) {
                    countryCode = '91';
                    number = cleanNumber.substring(2);
                } else if (cleanNumber.length === 10) {
                    number = cleanNumber;
                }
                
                formData.append('country-code', countryCode);
                formData.append('number', number);
            }

            // Build auth header
            const headers = {
                'Content-Type': 'application/x-www-form-urlencoded'
            };
            
            if (this.defaultApiToken) {
                headers.Authorization = `Bearer ${this.defaultApiToken}`;
            } else if (this.username && this.password) {
                const basic = Buffer.from(`${this.username}:${this.password}`).toString('base64');
                headers.Authorization = `Basic ${basic}`;
            }

            // Make API call to SparkTG
            const response = await axios.post(
                `${this.baseURL}/whishper-spy`,
                formData.toString(),
                { headers }
            );

            logger.info('Spy initiated successfully', {
                callId,
                response: response.data
            });

            return response.data;

        } catch (error) {
            logger.error('Error initiating spy:', {
                message: error.message,
                status: error.response?.status,
                statusText: error.response?.statusText,
                data: error.response?.data
            });
            throw new Error(error.response?.data?.message || error.message || 'Failed to initiate spy');
        }
    }

    /**
     * Whisper during an ongoing call
     * @param {Object} params - Whisper parameters
     * @param {string} params.callId - Call ID to whisper on
     * @param {string} params.agentNumber - Agent number (optional)
     */
    async whisperToCall({ callId, agentNumber }) {
        try {
            logger.info('Initiating whisper on call', { callId, agentNumber });

            // Prepare API request according to SparkTG documentation
            // Format: xnid, country-code, type, number
            const formData = new URLSearchParams();
            formData.append('xnid', callId);
            formData.append('type', 'whisper');
            
            if (agentNumber) {
                // Extract country code and number
                let cleanNumber = agentNumber.replace(/\+/g, '');
                let countryCode = '91';
                let number = cleanNumber;
                
                if (cleanNumber.startsWith('91') && cleanNumber.length > 10) {
                    countryCode = '91';
                    number = cleanNumber.substring(2);
                } else if (cleanNumber.length === 10) {
                    number = cleanNumber;
                }
                
                formData.append('country-code', countryCode);
                formData.append('number', number);
            }

            // Build auth header
            const headers = {
                'Content-Type': 'application/x-www-form-urlencoded'
            };
            
            if (this.defaultApiToken) {
                headers.Authorization = `Bearer ${this.defaultApiToken}`;
            } else if (this.username && this.password) {
                const basic = Buffer.from(`${this.username}:${this.password}`).toString('base64');
                headers.Authorization = `Basic ${basic}`;
            }

            // Make API call to SparkTG
            const response = await axios.post(
                `${this.baseURL}/whishper-spy`,
                formData.toString(),
                { headers }
            );

            logger.info('Whisper initiated successfully', {
                callId,
                response: response.data
            });

            return response.data;

        } catch (error) {
            logger.error('Error initiating whisper:', {
                message: error.message,
                status: error.response?.status,
                statusText: error.response?.statusText,
                data: error.response?.data
            });
            throw new Error(error.response?.data?.message || error.message || 'Failed to initiate whisper');
        }
    }
}

module.exports = new TelephonyService();
