/**
 * App (Technician) Dashboard Routes
 */

const express = require('express');
const router = express.Router();

const { verifyToken } = require('../../lib/auth');
const ApiResponse = require('../../lib/response');
const logger = require('../../lib/logger');
const { getTechnicianDashboardCounts } = require('../../services/app/s_app_dashboard');

// GET /api/app/dashboard/counts
router.get('/dashboard/counts', verifyToken, async (req, res) => {
    try {
        const counts = await getTechnicianDashboardCounts(req.user.id);
        return ApiResponse.appSuccess(res, 'Dashboard counts fetched', counts);
    } catch (error) {
        logger.error('App dashboard counts failed', { error: error.message, userId: req.user?.id });
        return ApiResponse.appError(res, 'Failed to fetch dashboard counts', 500);
    }
});

module.exports = router;
