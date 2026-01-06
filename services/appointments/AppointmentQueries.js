/**
 * Appointment Queries
 * Specialized queries for center, technician, and admin views
 */

const db = require('../../lib/dbconnection');
const logger = require('../../lib/logger');


// helper 

async function saveAppointmentMedicalFiles(appointmentId, filesMeta, userId) {
    const sql = `
        INSERT INTO appointment_medical_files
        (appointment_id, file_path, file_name, file_size, uploaded_by, uploaded_at, is_deleted)
        VALUES (?, ?, ?, ?, ?, NOW(), 0)
    `;

    for (const file of filesMeta) {
        const filePath = typeof file === 'string' ? file : file.file_path;
        const fileName = typeof file === 'string'
            ? (filePath ? filePath.split('/').pop() : null)
            : (file.file_name || (filePath ? filePath.split('/').pop() : null));
        const fileSize = typeof file === 'string'
            ? null
            : (file.file_size !== undefined ? file.file_size : null);

        await db.query(sql, [appointmentId, filePath, fileName, fileSize, userId]);
    }

    return { success: true, count: filesMeta.length };
}


/**
 * Parse tests data safely
 */
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
        logger.error('Error parsing tests data:', error);
        return [];
    }
}

/**
 * List appointments by diagnostic center
 */
async function listAppointmentsByCenter({ page = 1, limit = 0, search = '', centerId, listType = 'all', sortBy = 'id',sortOrder = 'DESC' }) {
     const allowedSortColumns = [
        'id', 'case_number', 'customer_first_name', 'customer_last_name',
        'confirmed_date', 'confirmed_time', 'medical_status'
    ];
    const validSortBy = allowedSortColumns.includes(sortBy) ? sortBy : 'id';
    const validSortOrder = sortOrder.toUpperCase() === 'ASC' ? 'ASC' : 'DESC';
    
    const searchParams = [];

    const conditions = [
        `(a.center_id = ? OR a.other_center_id = ? OR at.assigned_center_id = ?)`
    ];
    searchParams.push(centerId, centerId, centerId);

    // Filter by list type
    if (listType === 'unconfirmed') {
        conditions.push(`(a.confirmed_date IS NULL OR a.confirmed_time IS NULL)`);
        conditions.push(`a.pushed_back = 0`);
    } else if (listType === 'confirmed') {
        conditions.push(`a.confirmed_date IS NOT NULL`);
        conditions.push(`a.confirmed_time IS NOT NULL`);
        conditions.push(`a.pushed_back = 0`);
        conditions.push(`a.medical_status != 'completed'`);
    } else if (listType === 'completed') {
        conditions.push(`a.medical_status = 'completed'`);
    }

    if (search) {
        conditions.push(`(
            a.case_number LIKE ? OR 
            a.customer_first_name LIKE ? OR 
            a.customer_last_name LIKE ? OR
            a.application_number LIKE ?
        )`);
        const like = `%${search}%`;
        searchParams.push(like, like, like,like);
    }

    conditions.push(`a.is_deleted = 0`);

    const whereClause = `WHERE ${conditions.join(' AND ')}`;

    const countSql = `
        SELECT COUNT(DISTINCT a.id) as total 
        FROM appointments a
        JOIN appointment_tests at ON a.id = at.appointment_id
        ${whereClause}
    `;

    const dataSql = `
        SELECT 
            a.*, 
            COALESCE(
                (SELECT 
                    JSON_ARRAYAGG(
                        JSON_OBJECT(
                            'id', at2.id,
                            'test_id', at2.test_id,
                            'category_id', at2.category_id,
                            'rate_type', at2.rate_type,
                            'item_name', at2.item_name,
                            'rate', at2.rate,
                            'visit_subtype', at2.visit_subtype,
                            'assigned_center_id', at2.assigned_center_id,
                            'assigned_technician_id', at2.assigned_technician_id,
                            'status', at2.status,
                            'is_completed', at2.is_completed
                        )
                    )
                FROM appointment_tests at2 
                WHERE at2.appointment_id = a.id
                GROUP BY at2.appointment_id),
                JSON_ARRAY()
            ) as tests
        FROM appointments a
        JOIN appointment_tests at ON a.id = at.appointment_id
        ${whereClause}
        GROUP BY a.id
        ORDER BY a.${validSortBy} ${validSortOrder} 
    `;

    const countRows = await db.query(countSql, searchParams);
    const total = countRows[0]?.total || 0;

    const numericLimit = Number(limit);
    const numericPage = Number(page);
    const offset = numericLimit > 0 ? (numericPage - 1) * numericLimit : 0;

       let finalSql = dataSql;
    if (numericLimit > 0) {
        finalSql += ` LIMIT ${numericLimit} OFFSET ${offset}`;
    }

    let rows = await db.query(dataSql, searchParams);
    rows = rows.map(row => {
        row.tests = parseTestsData(row.tests);
        return row;
    });

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

/**
 * List appointments by technician
 */
async function listAppointmentsByTechnician({ page = 1, limit = 0, search = '', technicianId }) {
    const searchParams = [];
    const conditions = [`at.assigned_technician_id = ?`];
    searchParams.push(technicianId);

    if (search) {
        conditions.push(`(
            a.case_number LIKE ? OR 
            a.customer_first_name LIKE ? OR 
            a.customer_last_name LIKE ?
        )`);
        const like = `%${search}%`;
        searchParams.push(like, like, like);
    }

    conditions.push(`a.is_deleted = 0`);

    const whereClause = `WHERE ${conditions.join(' AND ')}`;

    const countSql = `
        SELECT COUNT(DISTINCT a.id) as total 
        FROM appointments a
        JOIN appointment_tests at ON a.id = at.appointment_id
        ${whereClause}
    `;

    const dataSql = `
        SELECT 
            a.*, 
            GROUP_CONCAT(
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
        ${whereClause}
        GROUP BY a.id
        ORDER BY a.id DESC
    `;

    const countRows = await db.query(countSql, searchParams);
    const total = countRows[0]?.total || 0;

    const numericLimit = Number(limit);
    const numericPage = Number(page);

    let rows = await db.query(dataSql, searchParams);
    rows = rows.map(row => {
        row.tests = parseTestsData(row.tests);
        return row;
    });

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

/**
 * List pending (pushed back) appointments - Center view
 */
async function listCenterPendingAppointments({ page = 1, limit = 0, search = '', centerId }) {
    // console.log(centerId,'kk')
    const searchParams = [];
    const conditions = [
        'a.pushed_back = 1',
        'a.is_deleted = 0',
        '(a.center_id = ? OR a.other_center_id = ?)'
    ];

    // Push centerId twice for the OR condition
    searchParams.push(centerId, centerId);

    if (search) {
        conditions.push(`(
            a.case_number LIKE ? OR 
            a.customer_first_name LIKE ? OR 
            a.customer_last_name LIKE ?
        )`);
        const like = `%${search}%`;
        searchParams.push(like, like, like);
    }

    const whereClause = `WHERE ${conditions.join(' AND ')}`;

    // Count total
    const countSql = `SELECT COUNT(*) as total FROM appointments a ${whereClause}`;
    const countRows = await db.query(countSql, searchParams);
    const total = countRows[0]?.total || 0;

    // Fetch rows
    const dataSql = `
        SELECT a.*, 
               u.full_name as pushed_back_by_name
        FROM appointments a
        LEFT JOIN users u ON a.pushed_back_by = u.id
        ${whereClause}
        ORDER BY a.pushed_back_at DESC
    `;

    const rows = await db.query(dataSql, searchParams);

    const numericLimit = Number(limit);
    const numericPage = Number(page);

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



/**
 * List pending (pushed back) appointments - Admin view
 */
async function listPendingAppointments({ page = 1, limit = 0, search = '' }) {
    const searchParams = [];
    const conditions = ['a.pushed_back = 1', 'a.is_deleted = 0'];

    if (search) {
        conditions.push(`(
            a.case_number LIKE ? OR 
            a.customer_first_name LIKE ? OR 
            a.customer_last_name LIKE ?
        )`);
        const like = `%${search}%`;
        searchParams.push(like, like, like);
    }

    const whereClause = `WHERE ${conditions.join(' AND ')}`;

    const countSql = `SELECT COUNT(*) as total FROM appointments a ${whereClause}`;
    const countRows = await db.query(countSql, searchParams);
    const total = countRows[0]?.total || 0;

    const dataSql = `
        SELECT a.*, 
               u.full_name as pushed_back_by_name
        FROM appointments a
        LEFT JOIN users u ON a.pushed_back_by = u.id
        ${whereClause}
        ORDER BY a.pushed_back_at DESC
    `;

    const numericLimit = Number(limit);
    const numericPage = Number(page);

    const rows = await db.query(dataSql, searchParams);

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

/**
 * List all confirmed appointments - Admin view
 */
async function listAllConfirmedAppointments({ page = 1, limit = 0, search = '', listType = '',sortBy = 'confirmed_date',sortOrder = 'DESC' }) {

     const allowedSortColumns = [
        'confirmed_date',
        'confirmed_time',
        'case_number',
        'application_number',
        'customer_first_name',
        'customer_last_name',
        'medical_status',
        'center_id',
        'client_id'
    ];

    const validSortBy = allowedSortColumns.includes(sortBy) ? sortBy : 'confirmed_date';
    const validSortOrder = sortOrder.toUpperCase() === 'ASC' ? 'ASC' : 'DESC';

    const conditions = [
        `a.confirmed_date IS NOT NULL`,
        `a.confirmed_time IS NOT NULL`,
        `a.is_deleted = 0`,
        `(a.pushed_back = 0 OR a.status = 'qc_pushed_back')`

    ];

    const searchParams = [];

    if (listType === 'completed') {
        conditions.push(`a.medical_status = 'completed'`);
    } else if (listType === '') {
        conditions.push(`a.medical_status != 'completed'`);
    }

    if (search) {
        conditions.push(`(
            a.case_number LIKE ? OR 
            a.application_number LIKE ? OR
            a.customer_first_name LIKE ? OR 
            a.customer_last_name LIKE ? OR
            a.medical_status LIKE ? 
        )`);
        const like = `%${search}%`;
        searchParams.push(like, like, like, like, like);
    }

    const whereClause = `WHERE ${conditions.join(' AND ')}`;

    const countSql = `SELECT COUNT(*) as total FROM appointments a ${whereClause}`;
    const countRows = await db.query(countSql, searchParams);
    const total = countRows[0]?.total || 0;

    const dataSql = `SELECT a.*, c.center_name, cl.client_name FROM appointments a LEFT JOIN diagnostic_centers c ON a.center_id = c.id LEFT JOIN clients cl ON a.client_id = cl.id ${whereClause} ORDER BY a.${validSortBy} ${validSortOrder}`;

    const numericLimit = Number(limit);
    const numericPage = Number(page);
    const offset = numericLimit > 0 ? (numericPage - 1) * numericLimit : 0;

    let rows;
    if (numericLimit > 0) {
        // const limitParam = Number(numericLimit);
        // const offsetParam = Number(offset);
        // Build SQL with LIMIT and OFFSET as literals to avoid parameter binding issues
        // const sqlWithLimit = `${dataSql} LIMIT ${limitParam} OFFSET ${offsetParam}`;
        // rows = await db.query(sqlWithLimit, searchParams);
        rows = await db.query(`${dataSql} LIMIT ${numericLimit} OFFSET ${offset}`, searchParams);
    } else {
        rows = await db.query(dataSql, searchParams);
    }

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

/**
 * Get tests by client and insurer
 */
async function getTestsByClientAndInsurer(clientId, insurerId) {
    const query = `
        SELECT 
            t.id AS test_id,
            t.test_name,
            t.description,
            btr.rate
        FROM tests t
        INNER JOIN bulk_test_rates btr ON t.id = btr.test_id
        WHERE btr.client_id = ? 
          AND btr.insurer_id = ? 
          AND btr.item_type = 'test'
          AND t.is_active = 1
          AND t.is_deleted = 0
        ORDER BY t.test_name ASC
    `;

    const rows = await db.query(query, [clientId, insurerId]);
    return rows;
}

/**
 * Get tests and categories by client and insurer
 */
async function getTestsAndCategoriesByClientAndInsurer(clientId, insurerId, searchQuery = '') {
    let searchCondition = '';
    let queryParams = [clientId, insurerId];

    if (searchQuery) {
        searchCondition = `AND (t.test_name LIKE ? OR t.description LIKE ?)`;
        queryParams.push(`%${searchQuery}%`, `%${searchQuery}%`);
    }

    const testsQuery = `
        SELECT 
            t.id,
            t.test_name AS name,
            t.description,
            btr.rate,
            'test' AS type
        FROM tests t
        INNER JOIN bulk_test_rates btr ON t.id = btr.test_id
        WHERE btr.client_id = ? 
          AND btr.insurer_id = ? 
          AND btr.item_type = 'test'
          AND t.is_active = 1
          AND t.is_deleted = 0
          AND btr.is_deleted = 0
          ${searchCondition}
        ORDER BY t.test_name ASC
    `;

    const categoriesQuery = `
        SELECT 
            tc.id,
            tc.category_name AS name,
            tc.description,
            btr.rate,
            'category' AS type
        FROM test_categories tc
        INNER JOIN bulk_test_rates btr ON tc.id = btr.category_id
        WHERE btr.client_id = ? 
          AND btr.insurer_id = ? 
          AND btr.item_type = 'category'
          AND tc.is_active = 1
          AND tc.is_deleted = 0
          ${searchCondition}
        ORDER BY tc.category_name ASC
    `;

    const [tests, categories] = await Promise.all([
        db.query(testsQuery, queryParams),
        db.query(categoriesQuery, queryParams)
    ]);

    return {
        tests,
        categories,
        combined: [...tests, ...categories]
    };
}

/**
 * Get appointment with tests
 */
async function getAppointmentWithTests(id) {
    const appointmentSql = 'SELECT * FROM appointments WHERE id = ?';
    const appointmentRows = await db.query(appointmentSql, [id]);

    if (!appointmentRows || appointmentRows.length === 0) {
        return null;
    }

    const appointment = appointmentRows[0];

    const testsSql = `
        SELECT 
            at.id,
            at.test_id,
            at.category_id,
            at.rate_type,
            at.item_name,
            at.rate,
            at.assigned_center_id,
            at.assigned_technician_id,
            at.visit_subtype,
            at.status,
            at.is_completed
        FROM appointment_tests at
        WHERE at.appointment_id = ?
        ORDER BY at.id ASC
    `;

    const tests = await db.query(testsSql, [id]);

    const selected_items = tests.map(row => ({
        id: row.rate_type === 'test' ? row.test_id : row.category_id,
        type: row.rate_type,
        name: row.item_name,
        rate: row.rate,
        assigned_center_id: row.assigned_center_id,
        assigned_technician_id: row.assigned_technician_id,
        visit_subtype: row.visit_subtype,
        status: row.status,
        is_completed: row.is_completed,
        appointment_test_id: row.id
    }));

    return {
        ...appointment,
        selected_items
    };
}

/**
 * Get appointment with tests filtered by center
 */
async function getAppointmentWithTestsByCenter(id, centerId) {
    console.log(' [QUERIES] Getting appointment with tests for center:', { id, centerId });

    const appointmentSql = 'SELECT * FROM appointments WHERE id = ?';
    const appointmentRows = await db.query(appointmentSql, [id]);

    if (!appointmentRows || appointmentRows.length === 0) {
        return null;
    }

    const appointment = appointmentRows[0];
    console.log(' [QUERIES] Appointment details:', {
        appointmentId: id,
        centerId,
        appointmentCenterId: appointment.center_id,
        appointmentOtherCenterId: appointment.other_center_id
    });

    const testsSql = `
        SELECT 
            at.id,
            at.test_id,
            at.category_id,
            at.rate_type,
            at.item_name,
            at.rate,
            at.assigned_center_id,
            at.assigned_technician_id,
            at.visit_subtype,
            at.status,
            at.is_completed
        FROM appointment_tests at
        WHERE at.appointment_id = ? AND at.assigned_center_id = ?
        ORDER BY at.id ASC
    `;

    const tests = await db.query(testsSql, [id, centerId]);

    console.log(' [QUERIES] Tests found for center:', {
        appointmentId: id,
        centerId,
        totalTests: tests.length,
        tests: tests.map(t => ({
            id: t.id,
            name: t.item_name,
            assigned_center_id: t.assigned_center_id
        }))
    });

    // Also check all tests for this appointment without center filter
    const allTestsSql = `
        SELECT 
            at.id,
            at.test_id,
            at.category_id,
            at.rate_type,
            at.item_name,
            at.rate,
            at.assigned_center_id,
            at.assigned_technician_id,
            at.visit_subtype,
            at.status,
            at.is_completed
        FROM appointment_tests at
        WHERE at.appointment_id = ?
        ORDER BY at.id ASC
    `;

    const allTests = await db.query(allTestsSql, [id]);

    console.log(' [QUERIES] ALL tests for appointment:', {
        appointmentId: id,
        totalAllTests: allTests.length,
        allTests: allTests.map(t => ({
            id: t.id,
            name: t.item_name,
            assigned_center_id: t.assigned_center_id
        }))
    });

    const selected_items = tests.map(row => ({
        id: row.rate_type === 'test' ? row.test_id : row.category_id,
        type: row.rate_type,
        name: row.item_name,
        rate: row.rate,
        assigned_center_id: row.assigned_center_id,
        assigned_technician_id: row.assigned_technician_id,
        visit_subtype: row.visit_subtype,
        status: row.status,
        is_completed: row.is_completed,
        appointment_test_id: row.id
    }));

    // After fetching appointment
    const rescheduleSql = `
            SELECT remarks
            FROM appointment_status_history
            WHERE appointment_id = ?
            AND change_type = 'reschedule'
            ORDER BY created_at DESC
            LIMIT 1
        `;
    const rescheduleRows = await db.query(rescheduleSql, [id]);
    const reschedule_remark = rescheduleRows.length > 0 ? rescheduleRows[0].remarks : null;

    return {
        ...appointment,
        selected_items,
        reschedule_remark
    };
}

/**
 * List appointment reports
 */
async function listAppointmentReports(appointmentId) {
    const sql = `
        SELECT 
            id,
            appointment_id,
            file_path,
            file_name,
            file_size,
            uploaded_by,
            uploaded_at,
            is_deleted
        FROM appointment_reports
        WHERE appointment_id = ? AND is_deleted = 0
        ORDER BY uploaded_at DESC
    `;

    const rows = await db.query(sql, [appointmentId]);
    return rows;
}

/**
 * Save appointment reports
 */
async function saveAppointmentReports(appointmentId, filesMeta, deleteIds, userId) {
    const connection = await db.pool.getConnection();
    try {
        await connection.beginTransaction();

        // Soft delete specified reports
        if (deleteIds && deleteIds.length > 0) {
            const placeholders = deleteIds.map(() => '?').join(',');
            await connection.query(
                `UPDATE appointment_reports 
                 SET is_deleted = 1 
                 WHERE id IN (${placeholders}) AND appointment_id = ?`,
                [...deleteIds, appointmentId]
            );
        }

        // Insert new reports
        if (filesMeta && filesMeta.length > 0) {
            const insertSql = `
                INSERT INTO appointment_reports 
                (appointment_id, file_path, file_name, file_size, uploaded_by, uploaded_at)
                VALUES (?, ?, ?, ?, ?, NOW())
            `;

            for (const file of filesMeta) {
                // Support both plain path strings and metadata objects
                const filePath = typeof file === 'string' ? file : file.file_path;
                const fileName = typeof file === 'string'
                    ? (filePath ? filePath.split('/').pop() : null)
                    : (file.file_name || (filePath ? filePath.split('/').pop() : null));
                const fileSize = typeof file === 'string'
                    ? null
                    : (file.file_size !== undefined ? file.file_size : null);

                await connection.query(insertSql, [
                    appointmentId,
                    filePath,
                    fileName,
                    fileSize,
                    userId
                ]);
            }
        }

        await connection.commit();
        return { success: true, message: 'Reports saved successfully' };
    } catch (error) {
        await connection.rollback();
        logger.error('Error saving appointment reports:', error);
        throw error;
    } finally {
        connection.release();
    }
}

/**
 * Get specific test details for an appointment
 * @param {number} appointmentId 
 * @param {number} appointmentTestId - The ID from appointment_tests table (junction table)
 */
async function getAppointmentTest(appointmentId, appointmentTestId) {
    const sql = `
        SELECT 
            at.*,
            t.test_name,
            t.test_code,
            tc.category_name,
            dc.center_name,
            dc.center_code
        FROM appointment_tests at
        LEFT JOIN tests t ON at.test_id = t.id
        LEFT JOIN test_categories tc ON t.category_id = tc.id
        LEFT JOIN diagnostic_centers dc ON at.assigned_center_id = dc.id
        WHERE at.appointment_id = ? AND at.id = ?
    `;
    const rows = await db.query(sql, [appointmentId, appointmentTestId]);
    return rows[0] || null;
}

module.exports = {
    listAppointmentsByCenter,
    listAppointmentsByTechnician,
    listCenterPendingAppointments,
    listPendingAppointments,
    listAllConfirmedAppointments,
    getTestsByClientAndInsurer,
    getTestsAndCategoriesByClientAndInsurer,
    getAppointmentWithTests,
    getAppointmentWithTestsByCenter,
    listAppointmentReports,
    saveAppointmentReports,
    saveAppointmentMedicalFiles,
    getAppointmentTest
};
