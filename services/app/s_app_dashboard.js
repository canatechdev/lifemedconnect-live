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
                pending_appointments: 0,
                rejected_appointments: 0,
            };
        }

        const baseConditions = `
            FROM appointments a
            JOIN appointment_tests at ON a.id = at.appointment_id
            WHERE at.assigned_technician_id = ?
              AND a.is_deleted = 0
        `;

        const [totalRows, todayRows, pendingRows, rejectedRows] = await Promise.all([
            db.query(`SELECT COUNT(DISTINCT a.id) AS count ${baseConditions}`, [technicianId]),
            db.query(`
                SELECT COUNT(DISTINCT a.id) AS count ${baseConditions}
                AND DATE(COALESCE(a.confirmed_date, a.appointment_date)) = CURDATE()
            `, [technicianId]),
            db.query(`
                SELECT COUNT(DISTINCT a.id) AS count ${baseConditions}
                AND a.status NOT IN ('cancelled')
                AND (a.medical_status NOT IN ('completed', 'medical_completed') OR a.medical_status IS NULL)
            `, [technicianId]),
            db.query(`
                SELECT COUNT(DISTINCT a.id) AS count ${baseConditions}
                AND (COALESCE(a.pushed_back, 0) = 1 OR a.status IN ('pushed_back', 'qc_pushed_back'))
            `, [technicianId])
        ]);

        return {
            total_appointments: totalRows[0]?.count || 0,
            todays_appointments: todayRows[0]?.count || 0,
            pending_appointments: pendingRows[0]?.count || 0,
            rejected_appointments: rejectedRows[0]?.count || 0,
        };
    } catch (error) {
        logger.error('Error fetching technician dashboard counts', { error: error.message, userId });
        throw new Error('Failed to fetch dashboard counts');
    }
}

async function getTechnicianStats(userId) {
    try {
        const rows = await db.query(
            'SELECT id, rate_per_appointment FROM technicians WHERE user_id = ? AND is_deleted = 0 LIMIT 1',
            [userId]
        );
        const technician = rows[0];
        if (!technician) {
            return {
                rate_per_appointment: 0,
                completed_count: 0,
                total_earnings: 0
            };
        }

        const rate = technician.rate_per_appointment ? Number(technician.rate_per_appointment) : 0;

        // Count distinct appointments with completed status
        // We look at medical_status and home_medical_status
        const countQuery = `
            SELECT COUNT(DISTINCT a.id) as count
            FROM appointments a
            JOIN appointment_tests at ON a.id = at.appointment_id
            WHERE at.assigned_technician_id = ?
              AND a.is_deleted = 0
              AND (
                  a.medical_status IN ('completed', 'medical_completed') OR
                  a.home_medical_status IN ('completed', 'medical_completed')
              )
        `;

        const countResult = await db.query(countQuery, [technician.id]);
        const completedCount = countResult[0]?.count || 0;

        return {
            rate_per_appointment: rate,
            completed_count: completedCount,
            total_earnings: completedCount * rate
        };
    } catch (error) {
        logger.error('Error fetching technician stats', { error: error.message, userId });
        throw new Error('Failed to fetch technician stats');
    }
}

module.exports = {
    getTechnicianDashboardCounts,
    getTechnicianStats,
};
