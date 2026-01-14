/**
 * Appointment Flow & Status Management
 * Handles status transitions, scheduling, and workflow operations
 */

const db = require('../../lib/dbconnection');
const logger = require('../../lib/logger');

/**
 * Status flow configuration
 */
const STATUS_FLOW = {
    pending: ['scheduled', 'cancelled'],
    scheduled: ['arrived', 'cancelled', 'rescheduled'],
    rescheduled: ['arrived', 'cancelled'],
    arrived: ['in_process'],
    in_process: ['completed', 'partially_completed']
};

/**
 * Validate status transition
 */
function isValidStatusTransition(currentStatus, newStatus) {
    if (!currentStatus) return true;
    const allowedNextStatuses = STATUS_FLOW[currentStatus] || [];
    return allowedNextStatuses.includes(newStatus) || currentStatus === newStatus;
}

/**
 * Log status changes to history table
 */
async function logStatusHistory(appointmentId, changeData, connection = null) {
    const conn = connection || db;
    try {
        const sql = `
            INSERT INTO appointment_status_history 
            (appointment_id, old_status, new_status, old_medical_status, new_medical_status, 
             changed_by, change_type, remarks, metadata, created_at)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())
        `;

        const metadata = changeData.metadata ? JSON.stringify(changeData.metadata) : null;

        const params = [
            appointmentId,
            changeData.old_status || null,
            changeData.new_status || null,
            changeData.old_medical_status || null,
            changeData.new_medical_status || null,
            changeData.changed_by,
            changeData.change_type || 'status_change',
            changeData.remarks || null,
            metadata
        ];

        if (connection) {
            await connection.query(sql, params);
        } else {
            await db.query(sql, params);
        }
    } catch (error) {
        logger.error('Error logging status history:', error);
        // Don't throw - logging failure shouldn't break the main operation
    }
}

/**
 * Center confirm schedule
 */
async function confirmSchedule(appointmentId, confirmedDate, confirmedTime, userId) {
    const connection = await db.pool.getConnection();
    try {
        await connection.beginTransaction();

        const [current] = await connection.query(
            'SELECT medical_status FROM appointments WHERE id = ?',
            [appointmentId]
        );

        await connection.query(`
            UPDATE appointments 
            SET 
                confirmed_date = ?,
                confirmed_time = ?,
                medical_status = 'scheduled',
                updated_at = NOW(),
                updated_by = ?
            WHERE id = ?
        `, [confirmedDate, confirmedTime, userId, appointmentId]);

        await logStatusHistory(appointmentId, {
            old_medical_status: current?.medical_status || null,
            new_medical_status: 'scheduled',
            changed_by: userId,
            change_type: 'schedule_confirm',
            remarks: 'Appointment schedule confirmed',
            metadata: { confirmed_date: confirmedDate, confirmed_time: confirmedTime }
        }, connection);

        await connection.commit();
        return { success: true, message: 'Schedule confirmed successfully' };
    } catch (error) {
        await connection.rollback();
        logger.error('Error in confirmSchedule:', error);
        throw error;
    } finally {
        connection.release();
    }
}

/**
 * Center reschedule appointment
 */
async function rescheduleAppointment(appointmentId, newConfirmedDate, newConfirmedTime, remarks, userId) {
    const connection = await db.pool.getConnection();
    try {
        await connection.beginTransaction();

        const [rows] = await connection.query(
            'SELECT medical_status, confirmed_date, confirmed_time FROM appointments WHERE id = ? FOR UPDATE',
            [appointmentId]
        );

        const current = Array.isArray(rows) ? rows[0] : rows;

        if (!current) {
            throw new Error('Appointment not found');
        }

        const oldDateValue = current.confirmed_date;
        const oldTime = current.confirmed_time;

        let oldDate = null;
        if (oldDateValue instanceof Date) {
            const year = oldDateValue.getFullYear();
            const month = String(oldDateValue.getMonth() + 1).padStart(2, '0');
            const day = String(oldDateValue.getDate()).padStart(2, '0');
            oldDate = `${year}-${month}-${day}`;
        } else if (typeof oldDateValue === 'string') {
            oldDate = oldDateValue.split('T')[0];
        }

        if (oldDate && oldTime && oldDate === newConfirmedDate && oldTime === newConfirmedTime) {
            throw new Error('Reschedule must be different from existing schedule date and time');
        }

        await connection.query(
            `UPDATE appointments 
             SET 
                 confirmed_date = ?,
                 confirmed_time = ?,
                 medical_status = 'rescheduled',
                 updated_at = NOW(),
                 updated_by = ?
             WHERE id = ?`,
            [newConfirmedDate, newConfirmedTime, userId, appointmentId]
        );

        await logStatusHistory(
            appointmentId,
            {
                old_medical_status: current.medical_status || null,
                new_medical_status: 'rescheduled',
                changed_by: userId,
                change_type: 'reschedule',
                remarks: remarks || null,
                metadata: {
                    old_confirmed_date: oldDate || null,
                    old_confirmed_time: oldTime || null,
                    new_confirmed_date: newConfirmedDate,
                    new_confirmed_time: newConfirmedTime,
                },
            },
            connection
        );

        await connection.commit();
        return { success: true, message: 'Appointment rescheduled successfully' };
    } catch (error) {
        await connection.rollback();
        logger.error('Error in rescheduleAppointment:', error);
        throw error;
    } finally {
        connection.release();
    }
}

/**
 * Center push back appointment
 */
async function pushBackAppointment(appointmentId, remarks, userId) {
    const connection = await db.pool.getConnection();
    try {
        await connection.beginTransaction();

        const [current] = await connection.query(
            'SELECT medical_status FROM appointments WHERE id = ?',
            [appointmentId]
        );

        await connection.query(`
            UPDATE appointments 
            SET 
                pushed_back = 1,
                pushback_remarks = ?,
                pushed_back_by = ?,
                pushed_back_at = NOW(),
                updated_at = NOW(),
                updated_by = ?
            WHERE id = ?
        `, [remarks, userId, userId, appointmentId]);

        await connection.query(`
            INSERT INTO appointment_pushback_history 
            (appointment_id, pushed_back_by, remarks)
            VALUES (?, ?, ?)
        `, [appointmentId, userId, remarks]);

        await logStatusHistory(appointmentId, {
            old_medical_status: current?.medical_status || null,
            new_medical_status: 'pushed_back',
            changed_by: userId,
            change_type: 'push_back',
            remarks: remarks,
            metadata: { pushed_back_at: new Date() }
        }, connection);

        await connection.commit();

        return {
            success: true,
            message: 'Appointment pushed back successfully'
        };
    } catch (error) {
        await connection.rollback();
        logger.error('Error in pushBackAppointment:', error);
        throw new Error(`Failed to push back appointment: ${error.message}`);
    } finally {
        connection.release();
    }
}

/**
 * Admin restore pushed back appointment
 */
async function restoreAppointment(appointmentId, userId) {
    const connection = await db.pool.getConnection();
    try {
        await connection.beginTransaction();

        const [current] = await connection.query(
            'SELECT medical_status FROM appointments WHERE id = ?',
            [appointmentId]
        );

        await connection.query(`
            UPDATE appointments 
            SET 
                pushed_back = 0,
                pushback_remarks = NULL,
                pushed_back_by = NULL,
                pushed_back_at = NULL,
                updated_at = NOW(),
                updated_by = ?
            WHERE id = ?
        `, [userId, appointmentId]);

        await logStatusHistory(appointmentId, {
            old_medical_status: 'pushed_back',
            new_medical_status: current?.medical_status || 'scheduled',
            changed_by: userId,
            change_type: 'restore',
            remarks: 'Appointment restored from pushed back status',
            metadata: { restored_at: new Date() }
        }, connection);

        await connection.commit();
        return { success: true, message: 'Appointment restored successfully' };
    } catch (error) {
        await connection.rollback();
        logger.error('Error in restoreAppointment:', error);
        throw error;
    } finally {
        connection.release();
    }
}

/**
 * Update medical status
 */
async function updateMedicalStatus(appointmentId, newStatus, additionalData, userId, centerId = null) {
    const connection = await db.pool.getConnection();
    try {
        await connection.beginTransaction();

        const [current] = await connection.query(
            'SELECT status, medical_status, aadhaar_number, pan_number, medical_remarks FROM appointments WHERE id = ?',
            [appointmentId]
        );

        if (!current || current.length === 0) {
            throw new Error('Appointment not found');
        }

        const currentRow = Array.isArray(current) ? current[0] : current;

        const updateFields = ['medical_status = ?', 'updated_at = NOW()', 'updated_by = ?'];
        const updateValues = [newStatus, userId];

        let pendingTypesString = null;
        if (additionalData && additionalData.pending_report_types !== undefined) {
            const val = additionalData.pending_report_types;
            if (Array.isArray(val)) {
                pendingTypesString = val.join(',');
            } else if (typeof val === 'string') {
                pendingTypesString = val.trim() || null;
            }
        }

        // Normalize current status for safe comparison (handles 'Pending', 'pending', etc.)
        const currentStatus = (currentRow.status || '').toLowerCase();

        // Auto-transition main status: pending -> in_process when medical_status becomes 'arrived'
        let newMainStatus = currentRow.status;
        if (newStatus === 'arrived' && (!currentStatus || currentStatus === 'pending')) {
            updateFields.push('status = ?');
            updateValues.push('checked_in');
            newMainStatus = 'checked_in';
        }

        if (newStatus === 'in_process') {
            updateFields.push('status = ?');
            updateValues.push('medical_in_process');
            newMainStatus = 'medical_in_process';
        }

        if (newStatus === 'partially_completed') {
            updateFields.push('status = ?');
            updateValues.push('medical_partially_completed');
            newMainStatus = 'medical_partially_completed';

            // handle pending_report_types
            updateFields.push('pending_report_types = ?');
            updateValues.push(pendingTypesString);

        }

        if (newStatus !== 'partially_completed') {
            // For other statuses, clear pending_report_types
            updateFields.push('pending_report_types = NULL');
        }

        if (newStatus === 'completed') {
            updateFields.push('status = ?');
            updateValues.push('medical_completed');
            newMainStatus = 'medical_completed';
        }

        if (additionalData) {
            if (additionalData.aadhaar_number !== undefined) {
                updateFields.push('aadhaar_number = ?');
                updateValues.push(additionalData.aadhaar_number);
            }
            if (additionalData.pan_number !== undefined) {
                updateFields.push('pan_number = ?');
                updateValues.push(additionalData.pan_number);
            }
            if (additionalData.medical_remarks !== undefined) {
                updateFields.push('medical_remarks = ?');
                updateValues.push(additionalData.medical_remarks);
            }
        }

        // The last value is for WHERE clause
        updateValues.push(appointmentId);

        // Log the final query and values before executing
        const finalQuery = `UPDATE appointments SET ${updateFields.join(', ')} WHERE id = ?`;
        // console.log("Executing query:", finalQuery);
        // console.log("With values:", updateValues);

        await connection.query(finalQuery, updateValues);

        // Update test statuses if center is specified
        if (centerId && ['arrived', 'in_process'].includes(newStatus)) {
            await connection.query(
                `UPDATE appointment_tests 
                 SET status = ?, updated_at = NOW() 
                 WHERE appointment_id = ? 
                 AND assigned_center_id = ? 
                 AND visit_subtype = 'center'`,
                [newStatus === 'arrived' ? 'Ready' : 'In Progress', appointmentId, centerId]
            );
        }

        await logStatusHistory(appointmentId, {
            old_status: currentRow.status || null,
            new_status: newMainStatus || currentRow.status || null,
            old_medical_status: currentRow.medical_status,
            new_medical_status: newStatus,
            changed_by: userId,
            change_type: 'medical_status_update',
            remarks: additionalData?.medical_remarks || null,
            metadata: {
                ...(additionalData || {}),
                pending_report_types: pendingTypesString
            }
        }, connection);

        await connection.commit();

        return { success: true, message: 'Medical status updated successfully' };
    } catch (error) {
        await connection.rollback();
        logger.error('Error in updateMedicalStatus:', error);
        throw error;
    } finally {
        connection.release();
    }
}

/**
 * Mark test as completed
 */
async function markTestCompleted(testId, updatedBy, remarks = '') {
    const sql = `
        UPDATE appointment_tests 
        SET is_completed = 1, 
            completed_at = NOW(), 
            completed_by = ?,
            completion_remarks = ?,
            updated_at = NOW()
        WHERE id = ?
    `;

    const result = await db.query(sql, [updatedBy, remarks, testId]);

    if (result.affectedRows > 0) {
        const [test] = await db.query('SELECT appointment_id FROM appointment_tests WHERE id = ?', [testId]);
        if (test && test[0]) {
            const { updateAppointmentStatus } = require('./AppointmentCRUD');
            await updateAppointmentStatus(test[0].appointment_id);
        }
    }

    return result.affectedRows;
}

/**
 * Bulk mark tests as completed
 */
async function bulkMarkTestsCompleted(appointmentId, testIds, updatedBy, remarks = '') {
    const connection = await db.pool.getConnection();
    try {
        await connection.beginTransaction();

        if (!testIds || testIds.length === 0) {
            throw new Error('No test IDs provided');
        }

        // Update all tests in bulk
        const placeholders = testIds.map(() => '?').join(',');
        const updateSql = `
            UPDATE appointment_tests 
            SET is_completed = 1, 
                completed_at = NOW(), 
                completed_by = ?,
                completion_remarks = ?,
                status = 'Completed',
                updated_at = NOW()
            WHERE appointment_id = ? AND id IN (${placeholders})
        `;

        await connection.execute(updateSql, [updatedBy, remarks, appointmentId, ...testIds]);

        // Check if all tests for this appointment are completed
        const [allTests] = await connection.execute(
            'SELECT COUNT(*) as total, SUM(is_completed) as completed FROM appointment_tests WHERE appointment_id = ?',
            [appointmentId]
        );

        // If all tests completed, update appointment status
        if (allTests[0] && allTests[0].total === allTests[0].completed) {
            await connection.execute(
                `UPDATE appointments 
                 SET status = 'Completed', 
                     medical_completed_at = NOW(),
                     updated_at = NOW()
                 WHERE id = ?`,
                [appointmentId]
            );
        }

        await connection.commit();
        return { success: true, updatedCount: testIds.length };
    } catch (error) {
        await connection.rollback();
        throw error;
    } finally {
        connection.release();
    }
}

/**
 * Mark appointment as completed (final confirmation from reports)
 */
async function completeAppointment(appointmentId, userId) {
    const connection = await db.pool.getConnection();
    try {
        await connection.beginTransaction();

        const [rows] = await connection.query(
            'SELECT status, medical_status FROM appointments WHERE id = ? FOR UPDATE',
            [appointmentId]
        );

        const current = Array.isArray(rows) ? rows[0] : rows;

        if (!current) {
            throw new Error('Appointment not found');
        }

        await connection.query(
            `UPDATE appointments 
             SET status = 'completed', updated_at = NOW(), updated_by = ?
             WHERE id = ?`,
            [userId, appointmentId]
        );

        await logStatusHistory(appointmentId, {
            old_status: current.status || null,
            new_status: 'completed',
            old_medical_status: current.medical_status || null,
            new_medical_status: current.medical_status || null,
            changed_by: userId,
            change_type: 'status_complete',
            remarks: 'Appointment marked completed via report confirmation',
            metadata: {}
        }, connection);

        await connection.commit();
        return { success: true, message: 'Appointment marked as completed' };
    } catch (error) {
        await connection.rollback();
        logger.error('Error in completeAppointment:', error);
        throw error;
    } finally {
        connection.release();
    }
}

/**
 * Update test assignments
 */
async function updateAppointmentTestAssignments(appointmentId, testUpdates, updatedBy) {
    const connection = await db.pool.getConnection();
    try {
        await connection.beginTransaction();

        for (const update of testUpdates) {
            const fields = [];
            const values = [];

            if (update.assigned_center_id !== undefined) {
                fields.push('assigned_center_id = ?');
                values.push(update.assigned_center_id);
            }
            if (update.assigned_technician_id !== undefined) {
                fields.push('assigned_technician_id = ?');
                values.push(update.assigned_technician_id);
            }
            if (update.visit_subtype !== undefined) {
                fields.push('visit_subtype = ?');
                values.push(update.visit_subtype);
            }

            if (fields.length > 0) {
                fields.push('updated_at = NOW()');
                values.push(update.test_id, appointmentId);

                await connection.query(
                    `UPDATE appointment_tests 
                     SET ${fields.join(', ')} 
                     WHERE id = ? AND appointment_id = ?`,
                    values
                );
            }
        }

        await connection.commit();
        return { success: true, message: 'Test assignments updated successfully' };
    } catch (error) {
        await connection.rollback();
        logger.error('Error updating test assignments:', error);
        throw error;
    } finally {
        connection.release();
    }
}

module.exports = {
    confirmSchedule,
    rescheduleAppointment,
    pushBackAppointment,
    restoreAppointment,
    updateMedicalStatus,
    markTestCompleted,
    bulkMarkTestsCompleted,
    updateAppointmentTestAssignments,
    completeAppointment,
    logStatusHistory
};
