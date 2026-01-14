/**
 * Approval Service
 * Main orchestrator for approval operations
 */

const db = require('../../lib/dbconnection');
const logger = require('../../lib/logger');
const ApprovalQueue = require('./ApprovalQueue');
const { getHandler } = require('./handlers');
const { getEntityTable, getDisallowedFields, getFieldTypeHints, GLOBAL_DISALLOWED_FIELDS } = require('./config/entityConfig');
const { normalizeValue } = require('./utils/normalizers');
const { ACTION_TYPES } = require('./config/approvalRules');

class ApprovalService {
    constructor() {
        this.queue = new ApprovalQueue();
    }

    /**
     * Approve a request and apply changes
     * @param {number} approvalId - Approval queue ID
     * @param {number} reviewedBy - Super Admin user ID
     * @returns {Promise<boolean>} Success status
     */
    async approveRequest(approvalId, reviewedBy) {
        const approval = await this.queue.getApprovalById(approvalId);

        if (!approval) {
            throw new Error('Approval request not found');
        }

        if (approval.status !== 'pending') {
            throw new Error(`Approval already ${approval.status}`);
        }

        // Start transaction
        const connection = await db.getConnection();
        await connection.beginTransaction();

        try {
            // Update approval status with idempotent guard
            const [updateResult] = await connection.execute(
                `UPDATE approval_queue 
                 SET status = 'approved', reviewed_by = ?, reviewed_at = NOW() 
                 WHERE id = ? AND status = 'pending'`,
                [reviewedBy, approvalId]
            );

            if (!updateResult || updateResult.affectedRows === 0) {
                throw new Error('Approval already processed');
            }

            // Apply the changes to the actual entity
            await this.applyApprovedChanges(connection, approval);

            // Clear pending approval flag
            await this.queue.updateEntityPendingFlag(approval.entity_type, approval.entity_id, 0, connection);

            // Close any older pending requests for the same entity to avoid stale duplicates
            await connection.execute(
                `UPDATE approval_queue 
                 SET status = 'rejected', reviewed_by = ?, reviewed_at = NOW(), rejection_reason = 'Superseded by newer approval'
                 WHERE entity_type = ? AND entity_id <=> ? AND status = 'pending' AND id <> ?`,
                [reviewedBy, approval.entity_type, approval.entity_id, approvalId]
            );

            await connection.commit();

            logger.info('Approval request approved', {
                approvalId,
                entity_type: approval.entity_type,
                entity_id: approval.entity_id,
                reviewed_by: reviewedBy
            });

            return true;
        } catch (error) {
            await connection.rollback();
            logger.error('Error approving request', { approvalId, error: error.message });
            throw error;
        } finally {
            connection.release();
        }
    }

    /**
     * Reject a request
     * @param {number} approvalId - Approval queue ID
     * @param {number} reviewedBy - Super Admin user ID
     * @param {string} rejectionReason - Reason for rejection
     * @returns {Promise<boolean>} Success status
     */
    async rejectRequest(approvalId, reviewedBy, rejectionReason) {
        const approval = await this.queue.getApprovalById(approvalId);

        if (!approval) {
            throw new Error('Approval request not found');
        }

        if (approval.status !== 'pending') {
            throw new Error(`Approval already ${approval.status}`);
        }

        await this.queue.updateApprovalStatus(approvalId, 'rejected', reviewedBy, rejectionReason);

        // Clear pending approval flag
        await this.queue.updateEntityPendingFlag(approval.entity_type, approval.entity_id, 0);

        // If it was a CREATE action, delete the temporary entity
        if (approval.action_type === ACTION_TYPES.CREATE) {
            await this.queue.deleteTemporaryEntity(approval.entity_type, approval.entity_id);
        }

        logger.info('Approval request rejected', {
            approvalId,
            entity_type: approval.entity_type,
            entity_id: approval.entity_id,
            reviewed_by: reviewedBy,
            reason: rejectionReason
        });

        return true;
    }

    /**
     * Apply approved changes to the actual entity
     * @param {Object} connection - Database connection
     * @param {Object} approval - Approval object
     * @returns {Promise<void>}
     */
    async applyApprovedChanges(connection, approval) {
        const { entity_type, entity_id, action_type, new_data, old_data } = approval;

        // Get entity handler if available
        const handler = getHandler(entity_type);

        switch (action_type) {
            case ACTION_TYPES.CREATE:
                // For CREATE, just activate the entity (it was created with is_active=0)
                if (handler) {
                    await handler.activate(connection, entity_id);
                } else {
                    await this.activateEntity(connection, entity_type, entity_id);
                }
                break;

            case ACTION_TYPES.UPDATE:
                // For UPDATE, apply the new data
                await this.updateEntity(connection, entity_type, entity_id, new_data, { old_data, handler });
                break;

            case ACTION_TYPES.DELETE:
                // For DELETE, soft delete the entity
                if (handler) {
                    await handler.softDelete(connection, entity_id);
                } else {
                    await this.softDeleteEntity(connection, entity_type, entity_id);
                }
                break;

            case ACTION_TYPES.BULK_UPDATE:
                // For BULK UPDATE, apply changes to multiple entities
                if (Array.isArray(old_data)) {
                    if (Array.isArray(new_data)) {
                        // Array format: match by index
                        for (let i = 0; i < old_data.length; i++) {
                            const oldRecord = old_data[i];
                            const newRecord = new_data[i];
                            if (oldRecord && newRecord && oldRecord.id) {
                                await this.updateEntity(connection, entity_type, oldRecord.id, newRecord, { old_data: oldRecord, handler });
                            }
                        }
                    } else if (new_data && typeof new_data === 'object') {
                        // Single object format: apply same changes to all records
                        for (const oldRecord of old_data) {
                            if (oldRecord && oldRecord.id) {
                                await this.updateEntity(connection, entity_type, oldRecord.id, new_data, { old_data: oldRecord, handler });
                            }
                        }
                    }
                }
                break;

            case ACTION_TYPES.BULK_CREATE:
                // For BULK CREATE, activate multiple entities
                if (Array.isArray(new_data)) {
                    for (const record of new_data) {
                        if (record.id) {
                            if (handler) {
                                await handler.activate(connection, record.id);
                            } else {
                                await this.activateEntity(connection, entity_type, record.id);
                            }
                        }
                    }
                }
                break;

            case ACTION_TYPES.BULK_DELETE:
                // For BULK DELETE, soft delete multiple entities
                if (Array.isArray(old_data)) {
                    for (const record of old_data) {
                        if (record.id) {
                            if (handler) {
                                await handler.softDelete(connection, record.id);
                            } else {
                                await this.softDeleteEntity(connection, entity_type, record.id);
                            }
                        }
                    }
                }
                break;

            default:
                throw new Error(`Unknown action type: ${action_type}`);
        }
    }

    /**
     * Activate an entity (set is_active = 1)
     * @param {Object} connection - Database connection
     * @param {string} entityType - Entity type
     * @param {number} entityId - Entity ID
     * @returns {Promise<void>}
     */
    async activateEntity(connection, entityType, entityId) {
        const table = getEntityTable(entityType);
        if (!table) {
            throw new Error(`Unknown entity type: ${entityType}`);
        }

        await connection.execute(
            `UPDATE ${table} SET is_active = 1, has_pending_approval = 0 WHERE id = ?`,
            [entityId]
        );
    }

    /**
     * Soft delete entity
     * @param {Object} connection - Database connection
     * @param {string} entityType - Entity type
     * @param {number} entityId - Entity ID
     * @returns {Promise<void>}
     */
    async softDeleteEntity(connection, entityType, entityId) {
        const table = getEntityTable(entityType);
        if (!table) {
            throw new Error(`Unknown entity type: ${entityType}`);
        }

        await connection.execute(
            `UPDATE ${table} SET is_deleted = 1, updated_at = NOW() WHERE id = ?`,
            [entityId]
        );
    }

    /**
     * Update entity with new data
     * @param {Object} connection - Database connection
     * @param {string} entityType - Entity type
     * @param {number} entityId - Entity ID
     * @param {Object} newData - New data to apply
     * @param {Object} context - Additional context (old_data, handler)
     * @returns {Promise<void>}
     */
    async updateEntity(connection, entityType, entityId, newData, context = {}) {
        const table = getEntityTable(entityType);
        if (!table) {
            throw new Error(`Unknown entity type: ${entityType}`);
        }

        const { handler, old_data } = context;

        // If entity has custom handler, use it
        if (handler) {
            await handler.update(connection, entityId, newData, { old_data });
        }

        // Build UPDATE query dynamically with per-table and global filtering
        const tableDisallowed = getDisallowedFields(table);
        const fields = Object.keys(newData).filter((f) => 
            !GLOBAL_DISALLOWED_FIELDS.has(f) && !tableDisallowed.has(f)
        );

        const fieldTypeHints = getFieldTypeHints(table);

        if (fields.length > 0) {
            const setClause = fields.map(field => `${field} = ?`).join(', ');
            const values = fields.map(field => normalizeValue(table, field, newData[field], fieldTypeHints));
            
            await connection.execute(
                `UPDATE ${table} SET ${setClause}, updated_at = NOW() WHERE id = ?`,
                [...values, entityId]
            );
        }
    }
}

module.exports = ApprovalService;
