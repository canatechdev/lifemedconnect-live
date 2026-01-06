const express = require('express');
const router = express.Router();
const ApiResponse = require('../lib/response');
const { asyncHandler } = require('../middleware/errorHandler');
const { verifyToken } = require('../lib/auth');
const service = require('../services/s_dashboard');

// GET /dashboard/sidebar-counts - Get pushback count for sidebar
router.get('/dashboard/sidebar-counts', verifyToken, asyncHandler(async (req, res) => {
  const counts = await service.getSidebarCounts(req.user);
  return ApiResponse.success(res, counts, 'Pushback count retrieved successfully');
}));

module.exports = router;