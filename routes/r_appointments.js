/**
 * Appointment Routes - Clean Version
 * Uses validation schemas, approval helpers, and service functions
 */

const express = require('express');
const router = express.Router();
const { verifyToken } = require('../lib/auth');
const { requirePermission } = require('../lib/permissions');
const { asyncHandler } = require('../middleware/errorHandler');
const validateRequest = require('../middleware/validateRequest');
const ApiResponse = require('../lib/response');
const logger = require('../lib/logger');
const { deleteWithApproval, updateWithApproval, formatApprovalResponse, createWithApproval } = require('../lib/approvalHelper');
const { toMySqlDate, toMySqlTime, toFloat } = require('../lib/normalizers');
const { pdfUpload, imageUpload, excelUpload, mixedUpload } = require('../lib/multer');
const { processSingleFile, processMultipleFiles, handleSingleFileFromAny, handleExcelFile } = require('../lib/fileUpload');
const fs = require('fs');
const path = require('path');
const db = require('../lib/dbconnection');

//  NEW: Import security middleware
const { uploadLimiter } = require('../middleware/security');

// Import service
const service = require('../services/appointments');

// Import validation schemas
const {
    appointmentCreateSchema,
    appointmentUpdateSchema,
    appointmentDeleteSchema,
    appointmentBulkUpdateSchema,
    confirmScheduleSchema,
    rescheduleSchema,
    pushBackSchema,
    medicalStatusSchema,
    testUpdateSchema
} = require('../validation/v_appointments');

// Import new validation schemas
const {
    uploadCategorizedReportsSchema,
    deleteCategorizedReportSchema,
    submitForQCSchema
} = require('../validation/v_appointment_reports');

const {
    pushBackToReportsSchema,
    saveQCVerificationSchema
} = require('../validation/v_appointment_qc');

const {
    addDocumentSchema,
    deleteDocumentSchema,
    addCustomerImageSchema,
    deleteCustomerImageSchema,
    updateImageLabelSchema
} = require('../validation/v_appointment_documents');

// ============================================================================
// Excel Operations
// ============================================================================

// Download Excel Template
router.get('/appointments/sample-template',
    verifyToken,
    requirePermission('appointments.export'),
    asyncHandler(async (req, res) => {
    const workbook = await service.generateTemplate();

    res.setHeader('Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
    res.setHeader('Content-Disposition', 'attachment; filename=appointments_template.xlsx');

    await workbook.xlsx.write(res);
    res.end();
}));

// Upload Excel File
//  NEW: Apply upload rate limiter (30 uploads per 15 minutes)
router.post('/appointments/upload',
    verifyToken,
    requirePermission('appointments.import'),
    uploadLimiter,
    mixedUpload.single('file'),
    asyncHandler(async (req, res) => {
        // Validate user object
        if (!req.user || !req.user.id || !req.user.role_id) {
            logger.error('Excel upload failed: User not authenticated', {
                hasUser: !!req.user,
                userId: req.user?.id,
                roleId: req.user?.role_id
            });
            return ApiResponse.unauthorized(res, 'User authentication required');
        }

        logger.info('Excel upload started', {
            userId: req.user.id,
            roleId: req.user.role_id,
            filename: req.file?.originalname
        });

        // Validate file
        if (!req.file) {
            return ApiResponse.error(res, 'No file uploaded', 400);
        }

        // Save Excel file (no compression)
        const filePath = await handleExcelFile(req.file, 'appointments_excel');

        if (!filePath) {
            return ApiResponse.error(res, 'Failed to save uploaded file', 500);
        }

        try {
            // Process the Excel file
            const result = await service.processUploadedFile(filePath, req.user);

            // Clean up uploaded file after processing
            fs.unlink(filePath, (err) => {
                if (err) logger.warn('Failed to delete temp Excel file:', err.message);
            });

            logger.info('Excel upload completed', {
                userId: req.user.id,
                recordsProcessed: result.success?.length || 0
            });

            return ApiResponse.success(res, result, 'Excel file processed successfully', 201);

        } catch (error) {
            logger.error('Excel upload error:', {
                userId: req.user.id,
                error: error.message,
                stack: error.stack
            });

            // Clean up uploaded file on error
            fs.unlink(filePath, (err) => {
                if (err) logger.warn('Failed to delete temp Excel file:', err.message);
            });

            return ApiResponse.error(res, `Failed to process Excel file: ${error.message}`, 500);
        }
    })
);

// ============================================================================
// CRUD Operations (with Approval System)
// ============================================================================

// CREATE Appointment
router.post('/appointments',
    verifyToken,
    requirePermission('appointments.create'),
    uploadLimiter,
    mixedUpload.any(),
    validateRequest(appointmentCreateSchema),
    asyncHandler(async (req, res) => {
        logger.info('Creating appointment', { userId: req.user.id, hasFiles: !!req.files });

        // Handle file upload for amount_upload
        const uploadedFile = await handleSingleFileFromAny(req.files, 'amount_upload', 'appointment_amount');
        if (uploadedFile) {
            req.body.amount_upload = uploadedFile;
        } else if (req.body.amount_upload === '') {
            req.body.amount_upload = null;
        }

        // Normalize dates and times
        if (req.body.appointment_date) {
            req.body.appointment_date = toMySqlDate(req.body.appointment_date);
        }
        if (req.body.appointment_time) {
            req.body.appointment_time = toMySqlTime(req.body.appointment_time);
        }
        if (req.body.confirmed_time) {
            req.body.confirmed_time = toMySqlTime(req.body.confirmed_time);
        }

        const result = await createWithApproval({
            entity_type: 'appointment',
            data: req.body,
            user: req.user,
            createFunction: service.createAppointment
        });

        const response = formatApprovalResponse(result);
        logger.info('Appointment creation request', {
            appointmentId: response.id,
            needsApproval: response.approval_required,
            userId: req.user.id
        });
        return ApiResponse.success(res, response, response.message, 201);
    })
);

// LIST Appointments
router.get('/appointments', verifyToken, requirePermission('appointments.view'), asyncHandler(async (req, res) => {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const search = req.query.q || '';
    const sortBy = req.query.sortBy || 'id';
    const sortOrder = req.query.sortOrder || 'DESC';

    // If requester is a diagnostic center user, restrict to their appointments only
    const centerIdFromToken = req.user?.diagnostic_center_id || req.user?.center_id;
    if (centerIdFromToken) {
        const result = await service.listAppointmentsbyDiagnosticCenters({
            page,
            limit,
            search,
            centerId: centerIdFromToken,
            listType: 'all'
        });
        return ApiResponse.paginated(res, result.data, result.pagination);
    }

    // Admin/Super Admin: return all
    const result = await service.listAppointments({ page, limit, search, sortBy, sortOrder });
    return ApiResponse.paginated(res, result.data, result.pagination);
}));

// Admin - List pending appointments (pushed back)
router.get('/appointments/admin/pending', verifyToken, requirePermission('appointments.view'), asyncHandler(async (req, res) => {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const search = req.query.q || '';
    const sortBy = req.query.sortBy || 'id';
    const sortOrder = req.query.sortOrder || 'DESC';

    // Use listPendingAppointments for pushed back appointments
    const result = await service.listPendingAppointments({ 
        page, 
        limit, 
        search
    });
    return ApiResponse.paginated(res, result.data, result.pagination);
}));

// Admin - List all confirmed appointments
router.get('/appointments/confirmed', verifyToken, requirePermission('appointments.view'), asyncHandler(async (req, res) => {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 0;
    const search = req.query.q || '';
    const sortBy = req.query.sortBy || 'confirmed_date';
    const sortOrder = req.query.sortOrder || 'DESC';

    const result = await service.listAllConfirmedAppointments({ page, limit, search, sortBy, sortOrder });
    return ApiResponse.paginated(res, result.data, result.pagination);
}));

// Admin - List all appointments for report
router.get('/appointments/report', verifyToken, requirePermission('appointments.reports'), asyncHandler(async (req, res) => {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 0;
    const search = req.query.q || '';
    const sortBy = req.query.sortBy || 'confirmed_date';
    const sortOrder = req.query.sortOrder || 'DESC';
    const type = 'completed';

    const result = await service.listAllConfirmedAppointments({ page, limit, search, listType: type, sortBy, sortOrder });
    return ApiResponse.paginated(res, result.data, result.pagination);
}));

// List Appointments by Center (Generic)
router.get('/appointments/DiagnosticCenter', verifyToken, requirePermission('appointments.view'), asyncHandler(async (req, res) => {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 0;
    const search = req.query.q || '';
    const centerIdRaw = req.query.centerId;
    const centerId = centerIdRaw !== undefined ? parseInt(centerIdRaw) : undefined;
    const listType = req.query.listType || 'all';

    const result = await service.listAppointmentsbyDiagnosticCenters({ page, limit, search, centerId, listType });
    return ApiResponse.paginated(res, result.data, result.pagination);
}));

// List Appointments by Technician
router.get('/appointments/Technician', verifyToken, requirePermission('appointments.view'), asyncHandler(async (req, res) => {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 0;
    const search = req.query.q || '';
    const technicianId = parseInt(req.query.technicianId);

    const result = await service.listAppointmentsByTechnician({ page, limit, search, technicianId });
    return ApiResponse.paginated(res, result.data, result.pagination);
}));


// QC - List pending QC appointments
router.get('/appointments/qc/pending', verifyToken, requirePermission('appointments.qc'), asyncHandler(async (req, res) => {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const search = req.query.q || '';
    const sortBy = req.query.sortBy || 'id';
    const sortOrder = req.query.sortOrder || 'DESC';

    const result = await service.listQcPendingAppointments({ page, limit, search, sortBy, sortOrder });
    return ApiResponse.paginated(res, result.data, result.pagination);
}));

// Get all QC history (paginated)
router.get('/appointments/qc-history', verifyToken, requirePermission('appointments.qc_history'), asyncHandler(async (req, res) => {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const search = req.query.q || '';
    const sortBy = req.query.sortBy || 'created_at';
    const sortOrder = req.query.sortOrder || 'DESC';

    const result = await service.getAllQcHistory({ page, limit, search, sortBy, sortOrder });
    return ApiResponse.paginated(res, result.data, result.pagination);
}));

// Get QC details for appointment
router.get('/appointments/:id/qc-details', verifyToken, requirePermission('appointments.qc'), asyncHandler(async (req, res) => {
    const appointmentId = parseInt(req.params.id);
    const centerId = req.user.center_id || null;
    const qcDetails = await service.getQcDetails(appointmentId, centerId);
    
    if (!qcDetails) {
        return ApiResponse.notFound(res, 'QC details not found');
    }
    
    return ApiResponse.success(res, qcDetails);
}));

// GET Single Appointment
router.get('/appointments/:id', verifyToken, requirePermission('appointments.view'), asyncHandler(async (req, res) => {
    const row = await service.getAppointment(req.params.id);
    if (!row) {
        return ApiResponse.notFound(res, 'Appointment not found');
    }
    return ApiResponse.success(res, row);
}));

// UPDATE Appointment
router.put('/appointments/:id',
    verifyToken,
    requirePermission('appointments.update'),
    uploadLimiter,
    mixedUpload.any(),
    validateRequest(appointmentUpdateSchema),
    asyncHandler(async (req, res) => {
        logger.info('Updating appointment', { appointmentId: req.params.id, userId: req.user.id, hasFiles: !!req.files });

        // Handle file upload for amount_upload
        const uploadedFile = await handleSingleFileFromAny(req.files, 'amount_upload', 'appointment_amount');
        if (uploadedFile) {
            req.body.amount_upload = uploadedFile;
        } else if (req.body.amount_upload === '') {
            req.body.amount_upload = null;
        }

        // Normalize dates and times
        if (req.body.appointment_date) {
            req.body.appointment_date = toMySqlDate(req.body.appointment_date);
        }
        if (req.body.appointment_time) {
            req.body.appointment_time = toMySqlTime(req.body.appointment_time);
        }
        if (req.body.confirmed_time) {
            req.body.confirmed_time = toMySqlTime(req.body.confirmed_time);
        }

        req.body.updated_by = req.user.id;

        const result = await updateWithApproval({
            entity_type: 'appointment',
            action_type: 'update',
            entity_id: req.params.id,
            new_data: req.body,
            created_by: req.user.id,
            role_id: req.user.role_id,
            getFunction: service.getAppointment,
            updateFunction: service.updateAppointment,
            user: req.user
        });

        const response = formatApprovalResponse(result);
        return ApiResponse.success(res, response, response.message);
    })
);

// DELETE Appointments (Bulk)
router.delete('/appointments',
    verifyToken,
    requirePermission('appointments.delete'),
    validateRequest(appointmentDeleteSchema),
    asyncHandler(async (req, res) => {
        const ids = req.body.ids;
        const result = await deleteWithApproval({
            entity_type: 'appointment',
            action_type: 'delete',
            entity_ids: ids,
            ids: ids,
            getFunction: ids.length > 1
                ? service.getAppointmentsByIds(ids)
                : service.getAppointment(ids),
            deleteFunction: service.softDeleteAppointments
        });

        const response = formatApprovalResponse(result);
        return ApiResponse.success(res, response, response.message);
    })
);

// BULK UPDATE Appointments
router.patch('/appointments/bulk-update',
    verifyToken,
    requirePermission('appointments.update'),
    validateRequest(appointmentBulkUpdateSchema),
    asyncHandler(async (req, res) => {
        const { ids, ...updates } = req.body;
        updates.updated_by = req.user.id;

        const result = await service.bulkUpdateAppointments(ids, updates);
        return ApiResponse.success(res, { affectedRows: result }, 'Appointments updated successfully');
    })
);

// BULK UPDATE with Approval (UpdateIds)
router.post('/appointments/UpdateIds', verifyToken, requirePermission('appointments.update'), validateRequest(appointmentBulkUpdateSchema), asyncHandler(async (req, res) => {
    const value = req.body;

    const result = await updateWithApproval({
        entity_type: 'appointment',
        entity_ids: value.ids,
        getFunction: async (ids) => {
            // Fetch old data snapshot (list of all affected appointments)
            return await service.getAppointmentsByIds(ids);
        },
        updateFunction: async (ids, data) => {
            // Apply actual bulk update when Super Admin approves
            return await service.UpdateAppointmentsTechnicianDiagnosticCenters(ids, data);
        },
        new_data: {
            center_id: value.center_id,
            assigned_technician_id: value.assigned_technician_id,
            cost_type: value.cost_type,
            amount: value.amount,
            updated_by: req.user.id,
            updated_at: new Date(),
        },
        user: req.user,
        notes: req.body.approval_notes || '',
        priority: req.body.priority || 'medium'
    });

    const response = formatApprovalResponse(result);
    return ApiResponse.success(res, response, response.message);
}));

// ============================================================================
// Center-Specific Operations
// ============================================================================


// Center - Get pending (pushed back) appointments
router.get('/appointments/center/pending', verifyToken, requirePermission('appointments.view'), asyncHandler(async (req, res) => {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 0;
    const search = req.query.q || '';
    console.log("Decoded USER ->", req.user);


    // centerId comes from token (req.user)
    const centerId = req.user.diagnostic_center_id;

    if (!centerId) {
        return ApiResponse.error(res, "Center ID missing in token", 400);
    }

    const result = await service.listCenterPendingAppointments({
        page,
        limit,
        search,
        centerId
    });

    return ApiResponse.paginated(res, result.data, result.pagination);
}));


// Center - Get unconfirmed appointments (to be scheduled)
router.get('/appointments/center/unconfirmed', verifyToken, requirePermission('appointments.view'), asyncHandler(async (req, res) => {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 0;
    const search = req.query.q || '';
    const centerId = req.user.center_id || parseInt(req.query.centerId);

    if (!centerId) {
        return ApiResponse.error(res, 'Center ID is required', 400);
    }

    const result = await service.listAppointmentsbyDiagnosticCenters({
        page,
        limit,
        search,
        centerId,
        listType: 'unconfirmed'
    });
    return ApiResponse.paginated(res, result.data, result.pagination);
}));

// Center - Get confirmed appointments (scheduled with medical workflow)
router.get('/appointments/center/confirmed', verifyToken, requirePermission('appointments.view'), asyncHandler(async (req, res) => {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 0;
    const search = req.query.q || '';
    const centerId = req.user.center_id || parseInt(req.query.centerId);
    const sortBy = req.query.sortBy || 'id';
    const sortOrder = req.query.sortOrder || 'DESC';

    if (!centerId) {
        return ApiResponse.error(res, 'Center ID is required', 400);
    }

    const result = await service.listAppointmentsbyDiagnosticCenters({
        page,
        limit,
        search,
        centerId,
        listType: 'confirmed',
        sortBy,
        sortOrder
    });
    return ApiResponse.paginated(res, result.data, result.pagination);
}));

// Center - Get completed appointments for report upload
router.get('/appointments/center/report', verifyToken, requirePermission('appointments.upload_docs'), asyncHandler(async (req, res) => {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 0;
    const search = req.query.q || '';
    const centerId = req.user.center_id || parseInt(req.query.centerId);
    const sortBy = req.query.sortBy || 'id';
    const sortOrder = req.query.sortOrder || 'DESC';

    if (!centerId) {
        return ApiResponse.error(res, 'Center ID is required', 400);
    }

    const result = await service.listAppointmentsbyDiagnosticCenters({
        page,
        limit,
        search,
        centerId,
        listType: 'completed',
        sortBy,
        sortOrder
    });
    return ApiResponse.paginated(res, result.data, result.pagination);
}));

// Confirm Schedule
router.patch('/appointments/:id/confirm-schedule',
    verifyToken,
    requirePermission('appointments.assign_center'),
    validateRequest(confirmScheduleSchema),
    asyncHandler(async (req, res) => {
        const { confirmed_date, confirmed_time } = req.body;
        const centerId = req.user.center_id || null;
        const technicianId = req.user.technician_id || null;
        
        // Build actorContext for Both appointments
        let actorContext = centerId
            ? { centerId, type: 'center' }
            : (technicianId ? { technicianId, type: 'technician' } : null);

        // Fallback: if Both appointment and actorContext still null, infer side from appointment
        if (!actorContext) {
            try {
                const appt = await service.getAppointment(req.params.id);
                if (appt?.visit_type === 'Both') {
                    // If caller has centerId matching a side, use it
                    if (centerId && appt.center_id === centerId) {
                        actorContext = { centerId, type: 'center' };
                    } else if (centerId && appt.other_center_id === centerId) {
                        actorContext = { centerId, type: 'technician' };
                    } else {
                        // If no centerId from user, choose the side that is not yet confirmed
                        if (!appt.center_confirmed_at) {
                            actorContext = { centerId: appt.center_id, type: 'center' };
                        } else if (!appt.home_confirmed_at) {
                            actorContext = { centerId: appt.other_center_id, type: 'technician' };
                        }
                    }
                }
            } catch (e) {
                // swallow; fallback leaves actorContext null
            }
        }
        
        const result = await service.confirmSchedule(
            req.params.id,
            toMySqlDate(confirmed_date),
            toMySqlTime(confirmed_time),
            req.user.id,
            actorContext
        );
        return ApiResponse.success(res, result);
    })
);

// Reschedule Appointment (now goes through approval flow)
router.patch('/appointments/:id/reschedule',
    verifyToken,
    requirePermission('appointments.update'),
    validateRequest(rescheduleSchema),
    asyncHandler(async (req, res) => {
        const { confirmed_date, confirmed_time, reschedule_reason } = req.body;
        const centerId = req.user.center_id || null;
        const technicianId = req.user.technician_id || null;
        const normalizedDate = toMySqlDate(confirmed_date);
        const normalizedTime = toMySqlTime(confirmed_time);
        const appointmentId = parseInt(req.params.id, 10);

        let actorContext = centerId
            ? { centerId, type: 'center' }
            : (technicianId ? { technicianId, type: 'technician' } : null);

        // Fallback inference for Both appointments when missing
        if (!actorContext) {
            try {
                const appt = await service.getAppointment(appointmentId);
                if (appt?.visit_type === 'Both') {
                    if (centerId && appt.center_id === centerId) {
                        actorContext = { centerId, type: 'center' };
                    } else if (centerId && appt.other_center_id === centerId) {
                        actorContext = { centerId, type: 'technician' };
                    } else {
                        if (!appt.center_reschedule_remark) {
                            actorContext = { centerId: appt.center_id, type: 'center' };
                        } else if (!appt.home_reschedule_remark) {
                            actorContext = { centerId: appt.other_center_id, type: 'technician' };
                        } else {
                            // default to center side if both already have remarks
                            actorContext = { centerId: appt.center_id, type: 'center' };
                        }
                    }
                }
            } catch (e) {
                // leave actorContext null if lookup fails
            }
        }

        const result = await updateWithApproval({
            entity_type: 'appointment',
            entity_id: appointmentId,
            getFunction: async (id) => await service.getAppointment(id),
            updateFunction: async (id) => await service.rescheduleAppointment(
                id,
                normalizedDate,
                normalizedTime,
                reschedule_reason,
                req.user.id,
                actorContext
            ),
            new_data: {
                confirmed_date: normalizedDate,
                confirmed_time: normalizedTime,
                medical_status: 'rescheduled',
                _actorContext: actorContext // Store for approval
            },
            user: req.user,
            notes: actorContext ? `Reschedule by ${actorContext.type} (ID: ${actorContext.centerId}): ${reschedule_reason || 'No reason'}` : (reschedule_reason || '')
        });

        const response = formatApprovalResponse(result);
        return ApiResponse.success(res, response, response.message);
    })
);

// Update Medical Status
router.patch('/appointments/:id/medical-status',
    verifyToken,
    requirePermission('appointments.update'),
    uploadLimiter,
    mixedUpload.any(),
    validateRequest(medicalStatusSchema),
    asyncHandler(async (req, res) => {
        const { medical_status, aadhaar_number, pan_number, medical_remarks, pending_report_types } = req.body;
        const centerId = req.user.center_id || null;
        const numericUserId = req.user.id;
        const appointmentId = parseInt(req.params.id, 10);

        // Normalize pending_report_types into array
        let pendingTypesArray = [];
        if (pending_report_types) {
            if (Array.isArray(pending_report_types)) {
                pendingTypesArray = pending_report_types;
            } else if (typeof pending_report_types === 'string') {
                pendingTypesArray = pending_report_types
                    .split(',')
                    .map((s) => s.trim())
                    .filter(Boolean);
            }
        }

        // Path for COMPLETED → approval + file upload
        if (medical_status === 'completed') {
            let filesMeta = [];
            if (req.files && req.files.length > 0) {
                filesMeta = await processMultipleFiles(req.files, 'appointment_medical');
            }

            if (filesMeta.length > 0) {
                await service.saveAppointmentMedicalFiles(
                    appointmentId,
                    filesMeta,
                    numericUserId
                );
            }

            // Build actor context for center users to preserve in approval metadata
            const actorContext = centerId ? {
                centerId: centerId,
                type: 'center'
            } : null;

            const result = await updateWithApproval({
                entity_type: 'appointment',
                action_type: 'update',
                entity_id: appointmentId,
                new_data: {
                    medical_status: 'completed',
                    medical_remarks,
                    aadhaar_number,
                    pan_number,
                    updated_by: numericUserId,
                    _actorContext: actorContext // Store for later retrieval
                },
                created_by: numericUserId,
                role_id: req.user.role_id,
                getFunction: service.getAppointment,
                updateFunction: service.updateAppointment,
                user: req.user,
                notes: actorContext ? `Medical completion requested by ${actorContext.type} (ID: ${actorContext.centerId})` : 'Medical completion requested with remarks and file upload',
                priority: 'high',
            });

            const response = formatApprovalResponse(result);
            return ApiResponse.success(res, response, response.message);
        }

        // Normal path for arrived / in_process / partially_completed
        // Build actor context for center users
        let actorContext = centerId ? {
            centerId: centerId,
            type: 'center'
        } : null;

        // Fallback inference for Both appointments when actorContext missing (e.g., frontend not sending centerId)
        if (!actorContext) {
            try {
                const appt = await service.getAppointment(appointmentId);
                if (appt?.visit_type === 'Both') {
                    if (appt.center_id) {
                        actorContext = { centerId: appt.center_id, type: 'center' };
                    } else if (appt.other_center_id) {
                        // treat other_center as technician/home side
                        actorContext = { centerId: appt.other_center_id, type: 'technician' };
                    }
                }
            } catch (e) {
                // leave actorContext null if lookup fails
            }
        }

        const result = await service.updateMedicalStatus(
            appointmentId,
            medical_status,
            {
                aadhaar_number,
                pan_number,
                medical_remarks,
                pending_report_types: pendingTypesArray,
            },
            numericUserId,
            actorContext
        );

        // Fetch and return completion status for 'Both' appointments
        const completionStatus = await service.getAppointmentCompletionStatus(appointmentId);

        return ApiResponse.success(res, {
            ...result,
            completion_status: completionStatus
        });
    })
);

// Mark Appointment as Completed
router.patch('/appointments/:id/complete',
    verifyToken,
    requirePermission('appointments.update'),
    asyncHandler(async (req, res) => {
        const result = await service.completeAppointment(req.params.id, req.user.id);
        return ApiResponse.success(res, result);
    })
);

// Push Back Appointment
router.post('/appointments/:id/push-back',
    verifyToken,
    requirePermission('appointments.update'),
    validateRequest(pushBackSchema),
    asyncHandler(async (req, res) => {
        const centerId = req.user.center_id || null;
        const technicianId = req.user.technician_id || null;
        let actorContext = centerId
            ? { centerId, type: 'center' }
            : (technicianId ? { technicianId, type: 'technician' } : null);

        // Allow both field names for remarks
        const remarks = req.body.push_back_reason || req.body.pushback_remarks || null;

        // Fallback inference for Both appointments when actorContext missing
        if (!actorContext) {
            try {
                const appt = await service.getAppointment(req.params.id);
                if (appt?.visit_type === 'Both') {
                    // If user center matches a side
                    if (centerId && appt.center_id === centerId) {
                        actorContext = { centerId, type: 'center' };
                    } else if (centerId && appt.other_center_id === centerId) {
                        actorContext = { centerId, type: 'technician' };
                    } else {
                        // Choose side not yet pushed back
                        if (!appt.center_pushed_back) {
                            actorContext = { centerId: appt.center_id, type: 'center' };
                        } else if (!appt.home_pushed_back) {
                            actorContext = { centerId: appt.other_center_id, type: 'technician' };
                        }
                    }
                }
            } catch (e) {
                // leave actorContext null if lookup fails
            }
        }

        const result = await service.pushBackAppointment(
            req.params.id,
            remarks,
            req.user.id,
            actorContext
        );
        return ApiResponse.success(res, result);
    })
);

// Restore Pushed Back Appointment
router.post('/appointments/:id/restore',
    verifyToken,
    requirePermission('appointments.update'),
    asyncHandler(async (req, res) => {
        const result = await service.restoreAppointment(req.params.id, req.user.id);
        return ApiResponse.success(res, result);
    })
);

// Get Tests by Client and Insurer (URL params - for frontend compatibility)
router.get('/appointments/tests/:clientId/:insurerId',
    verifyToken,
    requirePermission('appointments.view'),
    asyncHandler(async (req, res) => {
        const clientId = parseInt(req.params.clientId);
        const insurerId = parseInt(req.params.insurerId);

        if (!clientId || !insurerId) {
            return ApiResponse.error(res, 'clientId and insurerId are required', 400);
        }

        const tests = await service.getTestsByClientAndInsurer(clientId, insurerId);
        return ApiResponse.success(res, tests);
    })
);

// Get Tests and Categories by Client and Insurer (with rates)
router.get('/appointments/tests-categories/by-client-insurer/:clientId/:insurerId',
    verifyToken,
    requirePermission('appointments.view'),
    asyncHandler(async (req, res) => {
        const clientId = parseInt(req.params.clientId);
        const insurerId = parseInt(req.params.insurerId);
        const search = req.query.search ? String(req.query.search) : '';

        if (Number.isNaN(clientId) || Number.isNaN(insurerId)) {
            return ApiResponse.error(res, 'Valid clientId and insurerId are required', 400);
        }

        const result = await service.getTestsAndCategoriesByClientAndInsurer(
            clientId,
            insurerId,
            search
        );
        return ApiResponse.success(res, result);
    })
);

// Get Appointment with Tests
router.get('/appointments/:id/with-tests',
    verifyToken,
    requirePermission('appointments.view'),
    asyncHandler(async (req, res) => {
        const row = await service.getAppointmentWithTests(req.params.id);
        if (!row) {
            return ApiResponse.notFound(res, 'Appointment not found');
        }
        return ApiResponse.success(res, row);
    })
);

// Get Appointment with Tests filtered by Center
router.get('/appointments/:id/with-tests/center/:centerId',
    verifyToken,
    requirePermission('appointments.view'),
    asyncHandler(async (req, res) => {
        const row = await service.getAppointmentWithTestsByCenter(req.params.id, req.params.centerId);
        if (!row) {
            return ApiResponse.notFound(res, 'Appointment not found');
        }
        return ApiResponse.success(res, row);
    })
);

// Get Appointment with Tests (Center-filtered) - alternative route
router.get('/appointments/:id/center/:centerId',
    verifyToken,
    requirePermission('appointments.view'),
    asyncHandler(async (req, res) => {
        const appointment = await service.getAppointmentWithTestsByCenter(req.params.id, req.params.centerId);
        if (!appointment) {
            return ApiResponse.notFound(res, 'Appointment not found');
        }
        return ApiResponse.success(res, appointment);
    })
);

// Download Proforma Invoice PDF
router.get('/appointments/:id/proforma-invoice',
    verifyToken,
    requirePermission('appointments.proforma'),
    asyncHandler(async (req, res) => {
        const appointmentId = parseInt(req.params.id);
        const result = await service.generateProformaInvoicePdf(appointmentId);

        if (!result) {
            return ApiResponse.notFound(res, 'Proforma invoice data not found');
        }

        const { pdfBuffer } = result;
        res.setHeader('Content-Type', 'application/pdf');
        res.setHeader('Content-Disposition', `attachment; filename="proforma-invoice-${appointmentId}.pdf"`);
        return res.send(pdfBuffer);
    })
);

// Get Appointment with Tests filtered by Center (for DC role)
router.get('/appointments/:id/with-tests/center/:centerId',
    verifyToken,
    requirePermission('appointments.view'),
    asyncHandler(async (req, res) => {
        const row = await service.getAppointmentWithTestsByCenter(req.params.id, req.params.centerId);
        if (!row) {
            return ApiResponse.notFound(res, 'Appointment not found');
        }
        return ApiResponse.success(res, row);
    })
);

// Update Test Assignments
router.patch('/appointments/:id/test-assignments',
    verifyToken,
    requirePermission('appointments.assign_tests'),
    validateRequest(testUpdateSchema),
    asyncHandler(async (req, res) => {
        const { testUpdates } = req.body;
        const result = await service.updateAppointmentTestAssignments(
            req.params.id,
            testUpdates,
            req.user.id
        );
        return ApiResponse.success(res, result);
    })
);

// Split Tests - Assign tests to different centers/technicians
router.post('/appointments/:id/split-tests',
    verifyToken,
    requirePermission('appointments.assign_tests'),
    asyncHandler(async (req, res) => {
        const { tests } = req.body;
        const appointmentId = req.params.id;

        const connection = await db.pool.getConnection();
        try {
            await connection.beginTransaction();

            for (const t of tests) {
                await connection.query(`
                    UPDATE appointment_tests 
                    SET assigned_center_id = ?, assigned_technician_id = ?, visit_subtype = ?, updated_by = ?
                    WHERE id = ? AND appointment_id = ?
                `, [t.assigned_center_id, t.assigned_technician_id, t.visit_subtype, req.user.id, t.id, appointmentId]);
            }

            await connection.commit();
            return ApiResponse.success(res, { appointment_id: appointmentId }, 'Tests split successfully');
        } catch (err) {
            await connection.rollback();
            throw err;
        } finally {
            connection.release();
        }
    })
);

// Bulk Mark Tests as Completed
router.post('/appointments/:id/tests/bulk-complete',
    verifyToken,
    requirePermission('appointments.update'),
    asyncHandler(async (req, res) => {
        const appointmentId = parseInt(req.params.id);
        const { testIds, remarks } = req.body;

        if (!testIds || !Array.isArray(testIds) || testIds.length === 0) {
            return ApiResponse.error(res, 'Test IDs array is required', 400);
        }

        const result = await service.bulkMarkTestsCompleted(
            appointmentId,
            testIds,
            req.user.id,
            remarks || ''
        );

        return ApiResponse.success(res, result, `${result.updatedCount} tests marked as completed`);
    })
);

// Delete document
router.delete('/appointments/:id/documents/:documentId',
    verifyToken,
    requirePermission('appointments.upload_docs'),
    validateRequest(deleteDocumentSchema),
    asyncHandler(async (req, res) => {
        const documentId = parseInt(req.params.documentId);
        const result = await service.deleteDocument(documentId, req.user.id);
        return ApiResponse.success(res, result);
    })
);

// Alternative delete document route (without appointment ID)
router.delete('/appointments/documents/:documentId',
    verifyToken,
    requirePermission('appointments.upload_docs'),
    asyncHandler(async (req, res) => {
        const documentId = parseInt(req.params.documentId);
        const result = await service.deleteDocument(documentId, req.user.id);
        return ApiResponse.success(res, result);
    })
);

// Add Document to Appointment
router.post('/appointments/:id/documents',
    verifyToken,
    requirePermission('appointments.upload_docs'),
    uploadLimiter,
    pdfUpload.single('document'),
    validateRequest(addDocumentSchema),
    asyncHandler(async (req, res) => {
        const appointmentId = parseInt(req.params.id);
        const { docType, docNumber } = req.body;

        if (!req.file) {
            return ApiResponse.error(res, 'Document file is required', 400);
        }

        const docSubfolder = path.join('appointment_documents', `appointment_${appointmentId}`, `user_${req.user.id}`);
        const filePath = await processSingleFile(req.file, docSubfolder);
        const fileName = req.file.originalname;

        const result = await service.addDocument(
            appointmentId,
            docType,
            docNumber,
            filePath,
            fileName,
            req.user.id
        );

        return ApiResponse.success(res, result);
    })
);

// Add Customer Image to Appointment
router.post('/appointments/:id/customer-images',
    verifyToken,
    requirePermission('appointments.upload_docs'),
    uploadLimiter,
    imageUpload.single('image'),
    validateRequest(addCustomerImageSchema),
    asyncHandler(async (req, res) => {
        const appointmentId = parseInt(req.params.id);
        const { imageLabel } = req.body;

        if (!req.file) {
            return ApiResponse.error(res, 'Image file is required', 400);
        }

        const imageSubfolder = path.join('appointment_customer_images', `appointment_${appointmentId}`, `user_${req.user.id}`);
        const filePath = await processSingleFile(req.file, imageSubfolder);
        const fileName = req.file.originalname;

        const result = await service.addCustomerImage(
            appointmentId,
            imageLabel,
            filePath,
            fileName,
            req.user.id
        );

        return ApiResponse.success(res, result);
    })
);

// Delete customer image
router.delete('/appointments/:id/customer-images/:imageId',
    verifyToken,
    requirePermission('appointments.upload_docs'),
    validateRequest(deleteCustomerImageSchema),
    asyncHandler(async (req, res) => {
        const imageId = parseInt(req.params.imageId);
        const result = await service.deleteCustomerImage(imageId, req.user.id);
        return ApiResponse.success(res, result);
    })
);

// Alternative delete customer image route (without appointment ID)
router.delete('/appointments/customer-images/:imageId',
    verifyToken,
    requirePermission('appointments.upload_docs'),
    asyncHandler(async (req, res) => {
        const imageId = parseInt(req.params.imageId);
        const result = await service.deleteCustomerImage(imageId, req.user.id);
        return ApiResponse.success(res, result);
    })
);

// Push back to reports
router.patch('/appointments/:id/push-back-to-reports',
    verifyToken,
    requirePermission('appointments.qc_pushback'),
    validateRequest(pushBackToReportsSchema),
    asyncHandler(async (req, res) => {
        const appointmentId = parseInt(req.params.id);
        const { remarks } = req.body;
        const result = await service.pushBackToReports(appointmentId, remarks, req.user.id);
        return ApiResponse.success(res, result);
    })
);

// Push back to reports (alternative route)
router.post('/appointments/:id/qc/push-back',
    verifyToken,
    requirePermission('appointments.qc_pushback'),
    validateRequest(pushBackToReportsSchema),
    asyncHandler(async (req, res) => {
        const appointmentId = parseInt(req.params.id);
        const { remarks } = req.body;
        const result = await service.pushBackToReports(appointmentId, remarks, req.user.id);
        return ApiResponse.success(res, result);
    })
);

// Save QC verification (alternative route)
router.post('/appointments/:id/qc/save',
    verifyToken,
    requirePermission('appointments.qc'),
    validateRequest(saveQCVerificationSchema),
    asyncHandler(async (req, res) => {
        const appointmentId = parseInt(req.params.id);
        const { checkboxes, remarks, isComplete } = req.body;
        const result = await service.saveQCVerification(
            appointmentId,
            checkboxes,
            remarks,
            isComplete,
            req.user.id
        );
        return ApiResponse.success(res, result);
    })
);

// Get QC history for specific appointment
router.get('/appointments/:id/qc-history',
    verifyToken,
    requirePermission('appointments.qc'),
    asyncHandler(async (req, res) => {
        const appointmentId = parseInt(req.params.id);
        const history = await service.getQCHistory(appointmentId);
        return ApiResponse.success(res, history);
    })
);

// Alternative update image label route (without appointment ID)
router.patch('/appointments/customer-images/:imageId/label',
    verifyToken,
    requirePermission('appointments.upload_docs'),
    validateRequest(updateImageLabelSchema),
    asyncHandler(async (req, res) => {
        const imageId = parseInt(req.params.imageId);
        const { imageLabel } = req.body;
        const result = await service.updateImageLabel(imageId, imageLabel, req.user.id);
        return ApiResponse.success(res, result);
    })
);

// ============================================================================
// GET Operations for Documents, Images, and Reports
// ============================================================================

// Get all documents for an appointment
router.get('/appointments/:id/documents',
    verifyToken,
    requirePermission('appointments.view'),
    asyncHandler(async (req, res) => {
        const appointmentId = parseInt(req.params.id);
        const documents = await service.getDocuments(appointmentId);
        return ApiResponse.success(res, documents);
    })
);

// Get all customer images for an appointment
router.get('/appointments/:id/customer-images',
    verifyToken,
    requirePermission('appointments.view'),
    asyncHandler(async (req, res) => {
        const appointmentId = parseInt(req.params.id);
        const images = await service.getCustomerImages(appointmentId);
        return ApiResponse.success(res, images);
    })
);

// Get all categorized reports for an appointment
router.get('/appointments/:id/categorized-reports',
    verifyToken,
    requirePermission('appointments.view'),
    asyncHandler(async (req, res) => {
        const appointmentId = parseInt(req.params.id);
        const centerId = req.user.center_id || null;
        const reports = await service.getCategorizedReports(appointmentId, centerId);
        return ApiResponse.success(res, reports);
    })
);

// Upload categorized reports for an appointment
router.post('/appointments/:id/categorized-reports',
    verifyToken,
    requirePermission('appointments.upload_docs'),
    uploadLimiter,
    mixedUpload.any(),
    validateRequest(uploadCategorizedReportsSchema),
    asyncHandler(async (req, res) => {
        const appointmentId = parseInt(req.params.id);
        const { reportType } = req.body;

        // Persist files from memory storage to disk and build metadata
        const savedPaths = await processMultipleFiles(req.files, 'appointment_reports');
        const filesMeta = savedPaths.map((filePath, idx) => ({
            file_path: filePath,
            file_name: req.files?.[idx]?.originalname || null,
            file_size: req.files?.[idx]?.size ?? null
        }));

        const result = await service.uploadCategorizedReports(
            appointmentId,
            reportType,
            filesMeta,
            req.user.id
        );
        return ApiResponse.success(res, result);
    })
);

// Delete a specific categorized report (without appointment ID)
router.delete('/appointments/categorized-reports/:reportId',
    verifyToken,
    requirePermission('appointments.upload_docs'),
    asyncHandler(async (req, res) => {
        const reportId = parseInt(req.params.reportId);
        const result = await service.deleteCategorizedReport(reportId, req.user.id);
        return ApiResponse.success(res, result);
    })
);

// Get Reports for Appointment (old format)
router.get('/appointments/:id/reports',
    verifyToken,
    requirePermission('appointments.view'),
    asyncHandler(async (req, res) => {
        const appointmentId = parseInt(req.params.id);
        const reports = await service.listAppointmentReports(appointmentId);
        return ApiResponse.success(res, reports);
    })
);

// Upload/Delete Reports (old format)
router.post('/appointments/:id/reports',
    verifyToken,
    requirePermission('appointments.upload_docs'),
    uploadLimiter,
    mixedUpload.any(),
    asyncHandler(async (req, res) => {
        const appointmentId = parseInt(req.params.id);
        let rawDeleteIds = req.body.deleteIds ?? req.body.delete_ids ?? [];

        let deleteIds = [];
        if (Array.isArray(rawDeleteIds)) {
            deleteIds = rawDeleteIds.map(id => Number(id)).filter(id => !isNaN(id));
        } else if (typeof rawDeleteIds === 'string' && rawDeleteIds.trim() !== '') {
            try {
                const parsed = JSON.parse(rawDeleteIds);
                if (Array.isArray(parsed)) {
                    deleteIds = parsed.map(id => Number(id)).filter(id => !isNaN(id));
                }
            } catch (e) {
                deleteIds = [];
            }
        }

        let filesMeta = [];
        if (req.files && req.files.length > 0) {
            filesMeta = await processMultipleFiles(req.files, 'appointment_reports');
        }

        const result = await service.saveAppointmentReports(
            appointmentId,
            filesMeta,
            deleteIds,
            req.user.id
        );

        return ApiResponse.success(res, result);
    })
);

// Submit reports for QC
router.post('/appointments/:id/submit-for-qc',
    verifyToken,
    requirePermission('appointments.submit_qc'),
    asyncHandler(async (req, res) => {
        const appointmentId = parseInt(req.params.id);
        const result = await service.submitReportsForQC(appointmentId, req.user.id);
        return ApiResponse.success(res, result);
    })
);

// Get report counts by type
router.get('/appointments/:id/report-counts',
    verifyToken,
    requirePermission('appointments.view'),
    asyncHandler(async (req, res) => {
        const appointmentId = parseInt(req.params.id);
        const counts = await service.getReportCounts(appointmentId);
        return ApiResponse.success(res, counts);
    })
);

module.exports = router;
