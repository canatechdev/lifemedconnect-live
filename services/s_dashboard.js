const db = require('../lib/dbconnection');
const logger = require('../lib/logger');

class DashboardService {
  /**
   * Get sidebar counts for dashboard
   * @param {Object} user - User object from token
   * @returns {Promise<Object>} Object containing pushback and approval counts
   */
  async getSidebarCounts(user) {
    try {
      logger.info('Fetching sidebar counts', { 
        userId: user.id, 
        roleId: user.role_id, 
        centerId: user.diagnostic_center_id 
      });

      const counts = {
        pushback_appointments: 0,
        pending_approvals: 0
      };

      const { hasPermission } = require('../lib/permissions');
      const permissions = user.permissions || [];

      // Get pushback counts based on permissions
      if (hasPermission(permissions, 'appointments.view')) {
        if (user.diagnostic_center_id) {
          // Center user - only their center's pushbacks
          counts.pushback_appointments = await this.getCenterPushbackAppointmentsCount(user.diagnostic_center_id);
        } else {
          // Admin/TPA - all pushbacks
          counts.pushback_appointments = await this.getAllPushbackAppointmentsCount();
        }
      }

      // Get pending approval counts only for Super Admin
      // Even if other users have approvals.view permission, only Super Admin processes approvals
      const SUPER_ADMIN_ROLE_ID = parseInt(process.env.SUPER_ADMIN_ROLE_ID || '5', 10);
      if (user.role_id === SUPER_ADMIN_ROLE_ID) {
        counts.pending_approvals = await this.getPendingApprovalsCount();
      }

      logger.info('Sidebar counts fetched successfully', {
        userId: user.id,
        counts
      });

      return counts;
    } catch (error) {
      logger.error('Error fetching sidebar counts', {
        userId: user.id,
        error: error.message,
        stack: error.stack
      });
      throw new Error(`Failed to fetch sidebar counts: ${error.message}`);
    }
  }

  /**
   * Get count of all pushback appointments for admin
   * @returns {Promise<number>} Count of pushback appointments
   */
  async getAllPushbackAppointmentsCount() {
    try {
      const sql = `
        SELECT COUNT(*) as count 
        FROM appointments 
        WHERE pushed_back = 1 
        AND is_deleted = 0
      `;
           
      
      const [result] = await db.query(sql);

      return result.count || 0;
    } catch (error) {
      logger.error('Error getting all pushback appointments count', { error: error.message });
      throw error;
    }
  }

  /**
   * Get count of pushback appointments for specific center
   * @param {number} centerId - Diagnostic center ID
   * @returns {Promise<number>} Count of center pushback appointments
   */
  async getCenterPushbackAppointmentsCount(centerId) {
    try {
      const sql = `
        SELECT COUNT(*) as count 
        FROM appointments 
        WHERE pushed_back = 1 
        AND is_deleted = 0
        AND (center_id = ? OR other_center_id = ?)
      `;
 
      
      const [result] = await db.query(sql, [centerId, centerId]);

      return result.count || 0;
    } catch (error) {
      logger.error('Error getting center pushback appointments count', { 
        centerId, 
        error: error.message 
      });
      throw error;
    }
  }

  /**
   * Get count of pending approvals for super admin
   * @returns {Promise<number>} Count of pending approvals
   */
  async getPendingApprovalsCount() {
    try {
      // Count only the latest pending row per entity to avoid duplicates
      const sql = `
        SELECT COUNT(*) AS count FROM (
          SELECT 
            entity_type,
            COALESCE(entity_id, -1) AS entity_id_key,
            MAX(requested_at) AS max_requested_at
          FROM approval_queue
          WHERE status = 'pending'
          GROUP BY entity_type, COALESCE(entity_id, -1)
        ) latest_pending
      `;

      const [result] = await db.query(sql);

      return result.count || 0;
    } catch (error) {
      logger.error('Error getting pending approvals count', { error: error.message });
      throw error;
    }
  }
}

// Initialize service instance
const dashboardService = new DashboardService();

module.exports = {
  DashboardService,
  getSidebarCounts: dashboardService.getSidebarCounts.bind(dashboardService)
};