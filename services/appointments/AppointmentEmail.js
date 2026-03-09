/**
 * Appointment Email Service
 * Handles sending appointment-related emails with PDF attachments
 */

const db = require('../../lib/dbconnection');
const logger = require('../../lib/logger');
const emailService = require('../../lib/emailService');
const AppointmentTPAPDF = require('./AppointmentComprehensivePDF');

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
     * @returns {Promise<Object>} Result with success status and message
     */
    async sendAppointmentEmailToClient(appointmentId) {
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
            // Fetch appointment with client details
            const appointments = await db.query(
                `SELECT a.*, 
                        c.client_name, c.client_code, c.email_id as client_email,
                        i.insurer_name, i.insurer_code,
                        dc.center_name,
                        t.full_name as technician_name
                 FROM appointments a
                 LEFT JOIN clients c ON a.client_id = c.id
                 LEFT JOIN insurers i ON a.insurer_id = i.id
                 LEFT JOIN diagnostic_centers dc ON a.center_id = dc.id
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

            // Check if client has email
            if (!appointment.client_email) {
                return {
                    success: false,
                    message: 'Client does not have an email address configured',
                    statusCode: 400
                };
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

            // Send email with PDF attachment
            const emailResult = await emailService.sendAppointmentCompletionEmail(
                appointment.client_email,
                appointment,
                pdfResult.pdfPath
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
                clientEmail: appointment.client_email,
                caseNumber: appointment.case_number
            });

            return {
                success: true,
                message: `Report sent successfully to ${appointment.client_email}`,
                sentTo: appointment.client_email,
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
