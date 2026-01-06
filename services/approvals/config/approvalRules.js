/**
 * Approval Rules Configuration
 * Business rules for the approval system
 */

/**
 * Roles that bypass approval (Super Admin)
 * Uses SUPER_ADMIN_ROLE_ID env (fallback 5)
 */
const SUPER_ADMIN_ROLE_ID = parseInt(process.env.SUPER_ADMIN_ROLE_ID || '5', 10);
const BYPASS_APPROVAL_ROLES = [SUPER_ADMIN_ROLE_ID];

/**
 * Valid action types
 */
const ACTION_TYPES = {
    CREATE: 'create',
    UPDATE: 'update',
    DELETE: 'delete',
    BULK_CREATE: 'bulk_create',
    BULK_UPDATE: 'bulk_update',
    BULK_DELETE: 'bulk_delete'
};

/**
 * Valid approval statuses
 */
const APPROVAL_STATUS = {
    PENDING: 'pending',
    APPROVED: 'approved',
    REJECTED: 'rejected'
};

/**
 * Valid priority levels
 */
const PRIORITY_LEVELS = {
    URGENT: 'urgent',
    HIGH: 'high',
    MEDIUM: 'medium',
    LOW: 'low'
};

/**
 * Default priority
 */
const DEFAULT_PRIORITY = PRIORITY_LEVELS.MEDIUM;

/**
 * Check if user role bypasses approval
 * @param {number} roleId - User's role ID
 * @returns {boolean}
 */
const needsApproval = (roleId) => {
    return roleId !== SUPER_ADMIN_ROLE_ID;
};

/**
 * Validate action type
 * @param {string} actionType - Action type to validate
 * @returns {boolean}
 */
const isValidActionType = (actionType) => {
    return Object.values(ACTION_TYPES).includes(actionType);
};

/**
 * Validate approval status
 * @param {string} status - Status to validate
 * @returns {boolean}
 */
const isValidStatus = (status) => {
    return Object.values(APPROVAL_STATUS).includes(status);
};

/**
 * Validate priority level
 * @param {string} priority - Priority to validate
 * @returns {boolean}
 */
const isValidPriority = (priority) => {
    return Object.values(PRIORITY_LEVELS).includes(priority);
};

module.exports = {
    BYPASS_APPROVAL_ROLES,
    SUPER_ADMIN_ROLE_ID,
    ACTION_TYPES,
    APPROVAL_STATUS,
    PRIORITY_LEVELS,
    DEFAULT_PRIORITY,
    needsApproval,
    isValidActionType,
    isValidStatus,
    isValidPriority
};
