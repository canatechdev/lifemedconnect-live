const db = require('../../lib/dbconnection');
const logger = require('../../lib/logger');
const { getTechnicianIdByUser } = require('./s_app_appointments');

/**
 * Dashboard counts for technician (mobile app)
 * total, today, assigned (active), rejected (pushed back)
 */
async function getTechnicianDashboardCounts(userId) {
    try {
        const technicianId = await getTechnicianIdByUser(userId);
        if (!technicianId) {
            return {
                total_appointments: 0,
                todays_appointments: 0,
                assigned_appointments: 0,
                rejected_appointments: 0,
            };
        }

        const baseConditions = `
            FROM appointments a
            JOIN appointment_tests at ON a.id = at.appointment_id
            WHERE at.assigned_technician_id = ?
              AND a.is_deleted = 0
        `;

        const [totalRows, todayRows, assignedRows, rejectedRows] = await Promise.all([
            db.query(`SELECT COUNT(DISTINCT a.id) AS count ${baseConditions}`, [technicianId]),
            db.query(`
                SELECT COUNT(DISTINCT a.id) AS count ${baseConditions}
                AND DATE(COALESCE(a.confirmed_date, a.appointment_date)) = CURDATE()
            `, [technicianId]),
            db.query(`
                SELECT COUNT(DISTINCT a.id) AS count ${baseConditions}
                AND COALESCE(a.pushed_back, 0) = 0
                AND a.status NOT IN ('cancelled')
            `, [technicianId]),
            db.query(`
                SELECT COUNT(DISTINCT a.id) AS count ${baseConditions}
                AND (COALESCE(a.pushed_back, 0) = 1 OR a.status IN ('pushed_back', 'qc_pushed_back'))
            `, [technicianId])
        ]);

        return {
            total_appointments: totalRows[0]?.count || 0,
            todays_appointments: todayRows[0]?.count || 0,
            assigned_appointments: assignedRows[0]?.count || 0,
            rejected_appointments: rejectedRows[0]?.count || 0,
        };
    } catch (error) {
        logger.error('Error fetching technician dashboard counts', { error: error.message, userId });
        throw new Error('Failed to fetch dashboard counts');
    }
}

module.exports = {
    getTechnicianDashboardCounts,
};
