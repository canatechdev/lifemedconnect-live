const express = require('express');
const router = express.Router();
const { verifyToken } = require('../lib/auth');
const { requirePermission } = require('../lib/permissions');
const service = require('../services/s_technicians');
const Joi = require('joi');
const { asyncHandler } = require('../middleware/errorHandler');
const validateRequest = require('../middleware/validateRequest');
const ApiResponse = require('../lib/response');
const logger = require('../lib/logger');
const { parsePaginationParams } = require('../lib/helpers');

const technicianSchema = Joi.object({
  user_id: Joi.number().integer().optional().allow(null),
  center_id: Joi.number().integer().required(),
  technician_code: Joi.string().max(50).required(),
  full_name: Joi.string().max(255).required(),
  mobile: Joi.string().max(20).required(),
  email: Joi.string().email().max(255).optional().allow(null, ''),
  home_gps_latitude: Joi.number().precision(8).optional().allow(null),
  home_gps_longitude: Joi.number().precision(8).optional().allow(null),
  home_address: Joi.string().optional().allow(null, ''),
  qualification: Joi.string().max(255).optional().allow(null, ''),
  experience_years: Joi.number().integer().min(0).optional().allow(null),
  is_active: Joi.number().optional()
});

const technicianUpdateSchema = technicianSchema.fork(Object.keys(technicianSchema.describe().keys), field => field.optional());

const deleteTechniciansSchema = Joi.object({
  ids: Joi.array().items(Joi.number().integer().positive()).min(1).required()
});



router.get('/technicians', verifyToken, asyncHandler(async (req, res) => {
  const { page, limit, search, sortBy, sortOrder } = parsePaginationParams(req.query);

  const result = await service.listTechnicians({ 
    page, 
    limit, 
    search,
    sortBy,
    sortOrder
  });
  return ApiResponse.paginated(res, result.data, result.pagination);
}));








router.get('/technicians/:id', verifyToken, asyncHandler(async (req, res) => {
  const row = await service.getTechnician(req.params.id);
  if (!row) {
    return ApiResponse.notFound(res, 'Technician not found');
  }
  return ApiResponse.success(res, row);
}));
router.post('/technicians', verifyToken, requirePermission('technicians.create'), validateRequest(technicianSchema), asyncHandler(async (req, res) => {
  const id = await service.createTechnician(req.body);
  logger.info('Technician created', { technicianId: id, createdBy: req.user.id });
  
  return ApiResponse.success(res, { id }, 'Technician created successfully', 201);
}));



router.put('/technicians/:id', verifyToken, requirePermission('technicians.update'), validateRequest(technicianUpdateSchema), asyncHandler(async (req, res) => {
  const affected = await service.updateTechnician(req.params.id, req.body);
  if (!affected) {
    return ApiResponse.notFound(res, 'Technician not found or no changes made');
  }

  logger.info('Technician updated', { technicianId: req.params.id, updatedBy: req.user.id });
  return ApiResponse.success(res, { updated: affected }, 'Technician updated successfully');
}));


router.post('/technicians/delete', verifyToken, requirePermission('technicians.delete'), validateRequest(deleteTechniciansSchema), asyncHandler(async (req, res) => {
  const affected = await service.softDeleteTechnician(req.body.ids);
  if (!affected) {
    return ApiResponse.notFound(res, 'No technicians were found or already deleted');
  }

  logger.info('Technicians soft deleted', { count: affected, deletedBy: req.user.id });
  return ApiResponse.success(res, { updated: affected }, 'Technicians deleted successfully');
}));



router.delete('/technicians/:id', verifyToken, requirePermission('technicians.delete'), asyncHandler(async (req, res) => {
  const affected = await service.deleteTechnician(req.params.id);
  if (!affected) {
    return ApiResponse.notFound(res, 'Technician not found');
  }

  logger.info('Technician deleted', { technicianId: req.params.id, deletedBy: req.user.id });
  return ApiResponse.success(res, { deleted: affected }, 'Technician deleted successfully');
}));

module.exports = router;


