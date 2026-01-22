const db = require('../../lib/dbconnection');
const logger = require('../../lib/logger');

function parseTestsData(tests) {
    try {
        if (!tests) return [];
        if (Array.isArray(tests)) return tests;
        if (typeof tests === 'object') return [tests];
        if (typeof tests === 'string') {
            const trimmed = tests.trim();
            if (!trimmed) return [];
            const parsed = JSON.parse(trimmed);
            return Array.isArray(parsed) ? parsed : [parsed];
        }
        return [];
    } catch (error) {
        logger.error('Error parsing tests data (app technician)', { error: error.message });
        return [];
    }
}

async function getTechnicianIdByUser(userId) {
    const rows = await db.query(
        'SELECT id FROM technicians WHERE user_id = ? AND is_deleted = 0 LIMIT 1',
        [userId]
    );
    return rows[0]?.id || null;
}

async function listTechnicianAppointments({ userId, page = 1, limit = 10, search = '', upcomingOnly = false }) {
    const technicianId = await getTechnicianIdByUser(userId);
    if (!technicianId) {
        return { data: [], pagination: { total: 0, page, limit, pages: 0 } };
    }

    const searchParams = [technicianId];
    const conditions = ['at.assigned_technician_id = ?'];

    if (search) {
        conditions.push(`(
            a.case_number LIKE ? OR 
            a.customer_first_name LIKE ? OR 
            a.customer_last_name LIKE ?
        )`);
        const like = `%${search}%`;
        searchParams.push(like, like, like);
    }

    if (upcomingOnly) {
        conditions.push(`a.confirmed_date IS NOT NULL`);
        conditions.push(`a.confirmed_date > CURDATE()`); // tomorrow onwards
    }

    conditions.push('a.is_deleted = 0');

    const whereClause = `WHERE ${conditions.join(' AND ')}`;

    const countSql = `
        SELECT COUNT(DISTINCT a.id) as total 
        FROM appointments a
        JOIN appointment_tests at ON a.id = at.appointment_id
        ${whereClause}
    `;

    const dataSql = `
        SELECT 
            a.id,
            a.case_number,
            a.application_number,
            a.client_id,
            a.center_id,
            dc.center_name AS center_name,
            a.other_center_id,
            odc.center_name AS other_center_name,
            a.insurer_id,
            i.insurer_name,
            a.visit_type,
            a.appointment_date,
            a.appointment_time,
            a.confirmed_date,
            a.confirmed_time,
            a.medical_status,
            a.split_type,
            a.status AS appointment_status,
            a.customer_first_name,
            a.customer_last_name,
            a.customer_mobile,
            a.customer_address,
            a.customer_landmark,
            a.city,
            a.state,
            a.pincode,
            a.pushed_back,
            c.client_name,
            JSON_ARRAYAGG(
                JSON_OBJECT(
                    'id', at.id,
                    'test_id', at.test_id,
                    'category_id', at.category_id,
                    'rate_type', at.rate_type,
                    'item_name', at.item_name,
                    'rate', at.rate,
                    'visit_subtype', at.visit_subtype,
                    'assigned_center_id', at.assigned_center_id,
                    'assigned_technician_id', at.assigned_technician_id,
                    'status', at.status,
                    'is_completed', at.is_completed
                )
            ) as tests
        FROM appointments a
        JOIN appointment_tests at ON a.id = at.appointment_id
        LEFT JOIN diagnostic_centers dc ON a.center_id = dc.id
        LEFT JOIN diagnostic_centers odc ON a.other_center_id = odc.id
        LEFT JOIN clients c ON a.client_id = c.id
        LEFT JOIN insurers i ON a.insurer_id = i.id
        ${whereClause}
        GROUP BY a.id
        ORDER BY a.id DESC
    `;

    const countRows = await db.query(countSql, searchParams);
    const total = countRows[0]?.total || 0;

    const numericLimit = Number(limit);
    const numericPage = Number(page);
    const offset = numericLimit > 0 ? (numericPage - 1) * numericLimit : 0;

    let paginatedSql = dataSql;
    if (numericLimit > 0) {
        paginatedSql += ` LIMIT ${numericLimit} OFFSET ${offset}`;
    }

    let rows = await db.query(paginatedSql, searchParams);
    rows = rows.map(row => ({
        ...row,
        tests: parseTestsData(row.tests)
    }));

    return {
        data: rows,
        pagination: {
            total,
            page: numericPage,
            limit: numericLimit,
            pages: numericLimit > 0 ? Math.ceil(total / numericLimit) : 1,
        },
    };
}

async function getTechnicianAppointmentDetails({ userId, appointmentId }) {
    const technicianId = await getTechnicianIdByUser(userId);
    if (!technicianId) {
        return null;
    }

    const rows = await db.query(
        `
        SELECT 
            a.id,
            a.case_number,
            a.application_number,
            a.client_id,
            c.client_name,
            a.center_id,
            dc.center_name AS center_name,
            a.other_center_id,
            odc.center_name AS other_center_name,
            a.insurer_id,
            i.insurer_name,
            a.visit_type,
            a.appointment_date,
            a.appointment_time,
            a.confirmed_date,
            a.confirmed_time,
            a.medical_status,
            a.split_type,
            a.status AS appointment_status,
            a.customer_first_name,
            a.customer_last_name,
            a.customer_mobile,
            a.customer_address,
            a.customer_landmark,
            a.city,
            a.state,
            a.pincode,
            a.customer_gps_latitude,
            a.customer_gps_longitude,
            a.pushed_back,
            a.pending_report_types,
            a.medical_remarks,
            JSON_ARRAYAGG(
                JSON_OBJECT(
                    'id', at.id,
                    'test_id', at.test_id,
                    'category_id', at.category_id,
                    'rate_type', at.rate_type,
                    'item_name', at.item_name,
                    'rate', at.rate,
                    'visit_subtype', at.visit_subtype,
                    'assigned_center_id', at.assigned_center_id,
                    'assigned_technician_id', at.assigned_technician_id,
                    'status', at.status,
                    'is_completed', at.is_completed
                )
            ) as tests
        FROM appointments a
        JOIN appointment_tests at 
            ON a.id = at.appointment_id 
            AND at.assigned_technician_id = ?
        LEFT JOIN diagnostic_centers dc ON a.center_id = dc.id
        LEFT JOIN diagnostic_centers odc ON a.other_center_id = odc.id
        LEFT JOIN clients c ON a.client_id = c.id
        LEFT JOIN insurers i ON a.insurer_id = i.id
        WHERE a.id = ? AND a.is_deleted = 0
        GROUP BY a.id
        LIMIT 1
        `,
        [technicianId, appointmentId]
    );

    if (!rows.length) return null;

    return {
        ...rows[0],
        tests: parseTestsData(rows[0].tests)
    };
}

async function getTechnicianContextForAppointment(appointmentId, userId) {
    const technicianId = await getTechnicianIdByUser(userId);
    if (!technicianId) {
        return { technicianId: null, owns: false };
    }

    const rows = await db.query(
        `SELECT 1 
         FROM appointment_tests at 
         JOIN appointments a ON a.id = at.appointment_id 
         WHERE at.appointment_id = ? 
           AND at.assigned_technician_id = ? 
           AND a.is_deleted = 0
         LIMIT 1`,
        [appointmentId, technicianId]
    );

    return { technicianId, owns: rows.length > 0 };
}

module.exports = {
    listTechnicianAppointments,
    getTechnicianIdByUser,
    getTechnicianAppointmentDetails,
    getTechnicianContextForAppointment,
};
