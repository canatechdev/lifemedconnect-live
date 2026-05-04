/**
 * Appointment Email Service
 * Handles sending appointment-related emails with PDF attachments
 */

const db = require('../../lib/dbconnection');
const logger = require('../../lib/logger');
const emailService = require('../../lib/emailService');
const AppointmentTPAPDF = require('./AppointmentComprehensivePDF');
const { logTpaEmail } = require('../s_tap_email_log');

/**
 * Check if TPA email feature is enabled
 * @returns {boolean}
 */
function isTpaEmailEnabled() {
    const enabled = process.env.TPA_EMAIL_ENABLED;
    return enabled === 'true' || enabled === '1';
}

class AppointmentEmailService {
    /**
     * Send appointment completion email with PDF attachment to client
     * @param {number} appointmentId - The appointment ID
     * @param {number} sentBy - User ID who is sending the email
     * @returns {Promise<Object>} Result with success status and message
     */
    async sendAppointmentEmailToClient(appointmentId, sentBy = null) {
        // Check if feature is enabled
        if (!isTpaEmailEnabled()) {
            logger.info('TPA email feature is disabled (TPA_EMAIL_ENABLED=false)');
            return {
                success: false,
                message: 'TPA email feature is disabled',
                statusCode: 403
            };
        }

        try {
            // Fetch appointment with client details and diagnostic center emails
            const appointments = await db.query(
                `SELECT a.*, 
                        c.client_name, c.client_code, c.email_id as client_email, c.email_id_2 as client_email_2,
                        i.insurer_name, i.insurer_code,
                        dc.center_name, dc.email as center_email,
                        odc.center_name as other_center_name, odc.email as other_center_email,
                        t.full_name as technician_name
                 FROM appointments a
                 LEFT JOIN clients c ON a.client_id = c.id
                 LEFT JOIN insurers i ON a.insurer_id = i.id
                 LEFT JOIN diagnostic_centers dc ON a.center_id = dc.id
                 LEFT JOIN diagnostic_centers odc ON a.other_center_id = odc.id
                 LEFT JOIN technicians t ON a.assigned_technician_id = t.id
                 WHERE a.id = ?`,
                [appointmentId]
            );

            if (!appointments || appointments.length === 0) {
                return {
                    success: false,
                    message: 'Appointment not found',
                    statusCode: 404
                };
            }

            const appointment = appointments[0];

            // Primary email is mandatory
            if (!appointment.client_email) {
                return {
                    success: false,
                    message: 'Client does not have a primary email address configured',
                    statusCode: 400
                };
            }

            // Build recipient list: primary required, secondary optional
            const recipients = [appointment.client_email];
            if (appointment.client_email_2) {
                recipients.push(appointment.client_email_2);
            }

            // Build CC list with diagnostic center emails based on visit type
            const ccList = [];
            
            // Always add primary center email if available
            if (appointment.center_email) {
                ccList.push(appointment.center_email);
            }
            
            // Add other center email for "Both" visit type if available
            if (appointment.visit_type === 'Both' && appointment.other_center_email) {
                ccList.push(appointment.other_center_email);
            }

            // Generate TPA PDF first
            const pdfResult = await AppointmentTPAPDF.generateTPAPDF(appointmentId);
            if (!pdfResult.success) {
                return {
                    success: false,
                    message: 'Failed to generate PDF',
                    statusCode: 500
                };
            }

            // Log email details for tracking
            logger.info('Sending appointment completion email', {
                appointmentId,
                recipients,
                ccList: ccList.length > 0 ? ccList : null,
                visitType: appointment.visit_type,
                centerEmail: appointment.center_email,
                otherCenterEmail: appointment.other_center_email
            });

            // Send email with PDF attachment and CC to diagnostic centers
            const emailResult = await emailService.sendAppointmentCompletionEmail(
                recipients,
                appointment,
                pdfResult.pdfPath,
                ccList.length > 0 ? ccList : null
            );

            if (!emailResult.success) {
                return {
                    success: false,
                    message: emailResult.message || 'Failed to send email',
                    statusCode: 500
                };
            }

            logger.info('Appointment PDF emailed to client', {
                appointmentId,
                clientEmails: recipients,
                applicationNumber: appointment.application_number || `APT-${appointmentId}`,
                caseNumber: appointment.case_number
            });

            // Log TPA email with client relationship
            try {
                await logTpaEmail(appointmentId, appointment.client_id, recipients, sentBy, 'sent');
            } catch (logError) {
                logger.error('Failed to log TPA email', {
                    appointmentId,
                    client_id: appointment.client_id,
                    error: logError.message
                });
                // Don't fail the email sending if logging fails
            }

            return {
                success: true,
                message: `Report sent successfully to ${recipients.join(', ')}`,
                sentTo: recipients,
                clientName: appointment.client_name
            };
        } catch (error) {
            logger.error('Error sending appointment email', {
                appointmentId,
                error: error.message
            });
            throw error;
        }
    }
}

const appointmentEmailService = new AppointmentEmailService();
module.exports = appointmentEmailService;
