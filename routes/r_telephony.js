/**
 * Telephony Routes
 * Handles API endpoints for telephony integration
 */

const express = require('express');
const router = express.Router();
const { verifyToken } = require('../lib/auth');
const { requirePermission } = require('../lib/permissions');
const logger = require('../lib/logger');
const telephonyService = require('../services/telephony/TelephonyService');
const Joi = require('joi');

/**
 * Validation schemas
 */
const makeCallSchema = Joi.object({
    appointmentId: Joi.number().integer().positive().required(),
    centerId: Joi.number().integer().positive().required(),
    customerNumber: Joi.string().pattern(/^[0-9]{10,15}$/).required(),
    notes: Joi.string().max(500).allow(null, '')
});

const webhookSchema = Joi.object({
    callid: Joi.string().required(),
    'call-type': Joi.string().valid('incoming', 'outgoing').required(),
    disposition: Joi.string().valid('answered', 'missed', 'busy', 'failed', 'no_answer').required(),
    'call-duration': Joi.string().required(),
    'start-time': Joi.string().required(),
    'end-time': Joi.string().required(),
    'agent-number': Joi.string().required(),
    'customer-number': Joi.string().required(),
    'virtual-number': Joi.string().allow(null, ''),
    'service-id': Joi.string().allow(null, ''),
    'recording-url': Joi.string().uri().allow(null, ''),
    'received-by': Joi.string().allow(null, ''),
    'transfered-to': Joi.string().allow(null, ''),
    'handle-time': Joi.string().allow(null, ''),
    'hold-time': Joi.string().allow(null, ''),
    'hangup-by': Joi.string().allow(null, ''),
    'skill-id': Joi.string().allow(null, ''),
    ivr: Joi.string().allow(null, ''),
    param1: Joi.string().allow(null, '')
}).unknown(true); // Allow additional fields

/**
 * @route   POST /api/telephony/make-call
 * @desc    Initiate an outbound call to customer
 * @access  Private - Requires telephony:make_call permission
 */
router.post('/make-call', verifyToken, requirePermission('telephony.make_call'), async (req, res) => {
    try {
        // Validate request body
        const { error, value } = makeCallSchema.validate(req.body);
        if (error) {
            return res.status(400).json({
                success: false,
                message: 'Validation error',
                errors: error.details.map(d => d.message)
            });
        }

        const { appointmentId, centerId, customerNumber, notes } = value;
        const userId = req.user.id;

        // Validate call permission
        const permission = await telephonyService.validateCallPermission(appointmentId, centerId);
        if (!permission.allowed) {
            return res.status(403).json({
                success: false,
                message: permission.reason
            });
        }

        // Make the call to MOBILE
        const result = await telephonyService.makeCallMobile({
            appointmentId,
            centerId,
            customerNumber,
            userId,
            notes
        });

        logger.info('Mobile call initiated via API', {
            userId,
            appointmentId,
            centerId,
            attemptId: result.attemptId
        });

        res.status(200).json(result);

    } catch (error) {
        logger.error('Error in make-call endpoint:', error);
        res.status(500).json({
            success: false,
            message: error.message || 'Failed to initiate call',
            error: process.env.NODE_ENV === 'development' ? error : undefined
        });
    }
});

/**
 * @route   POST /api/telephony/make-call-browser
 * @desc    Initiate an outbound call to customer via BROWSER/WebRTC
 * @access  Private - Requires telephony:make_call permission
 */
router.post('/make-call-browser', verifyToken, requirePermission('telephony.make_call'), async (req, res) => {
    try {
        // Validate request body
        const { error, value } = makeCallSchema.validate(req.body);
        if (error) {
            return res.status(400).json({
                success: false,
                message: 'Validation error',
                errors: error.details.map(d => d.message)
            });
        }

        const { appointmentId, centerId, customerNumber, notes } = value;
        const userId = req.user.id;

        // Validate call permission
        const permission = await telephonyService.validateCallPermission(appointmentId, centerId);
        if (!permission.allowed) {
            return res.status(403).json({
                success: false,
                message: permission.reason
            });
        }

        // Make the call to BROWSER/WebRTC
        const result = await telephonyService.makeCallBrowser({
            appointmentId,
            centerId,
            customerNumber,
            userId,
            notes
        });

        logger.info('Browser call initiated via API', {
            userId,
            appointmentId,
            centerId,
            attemptId: result.attemptId
        });

        res.status(200).json(result);

    } catch (error) {
        logger.error('Error in make-call-browser endpoint:', error);
        res.status(500).json({
            success: false,
            message: error.message || 'Failed to initiate browser call',
            error: process.env.NODE_ENV === 'development' ? error : undefined
        });
    }
});

/**
 * @route   GET /api/telephony/ongoing-calls
 * @desc    Get list of ongoing/active calls
 * @access  Private - Requires telephony:spy_call or telephony:whisper_call permission
 */
router.get('/ongoing-calls', verifyToken, async (req, res) => {
    try {
        const query = require('../lib/dbconnection').query;
        
        // Get active calls from ongoing_calls table
        const calls = await query(
            `SELECT 
                oc.call_id,
                oc.appointment_id,
                oc.center_id,
                oc.agent_number,
                oc.customer_number,
                oc.call_type,
                oc.created_at as start_time,
                oc.created_by,
                a.case_number,
                a.customer_first_name,
                a.customer_last_name,
                c.center_name as center_name,
                u.full_name as agent_name
            FROM ongoing_calls oc
            LEFT JOIN appointments a ON oc.appointment_id = a.id
            LEFT JOIN diagnostic_centers c ON oc.center_id = c.id
            LEFT JOIN users u ON oc.created_by = u.id
            WHERE oc.created_at >= DATE_SUB(NOW(), INTERVAL 2 HOUR)
            ORDER BY oc.created_at DESC
            LIMIT 50`
        );

        res.json({
            success: true,
            data: calls || [],
            count: calls ? calls.length : 0
        });
    } catch (error) {
        logger.error('Error fetching ongoing calls:', error);
        res.status(500).json({
            success: false,
            message: error.message || 'Failed to fetch ongoing calls',
            error: process.env.NODE_ENV === 'development' ? error : undefined
        });
    }
});

/**
 * @route   POST /api/telephony/spy
 * @desc    Spy on an ongoing call
 * @access  Private - Requires telephony:spy_call permission
 */
router.post('/spy', verifyToken, requirePermission('telephony.spy_call'), async (req, res) => {
    try {
        const { callId } = req.body;
        const userId = req.user.id;

        // Validate required fields
        if (!callId) {
            return res.status(400).json({
                success: false,
                message: 'Call ID is required'
            });
        }

        // Get user mobile number from database
        const query = require('../lib/dbconnection').query;
        const users = await query('SELECT mobile FROM users WHERE id = ?', [userId]);
        
        if (!users || users.length === 0 || !users[0].mobile) {
            return res.status(400).json({
                success: false,
                message: 'User mobile number not found. Please update your profile.'
            });
        }

        const agentNumber = users[0].mobile;

        // Get telephony service
        const telephonyService = require('../services/telephony/TelephonyService');

        // Make spy request to SparkTG
        const result = await telephonyService.spyOnCall({ callId, agentNumber });

        res.json({
            success: true,
            message: 'Spy initiated successfully. Call will ring on your mobile.',
            data: result
        });
    } catch (error) {
        logger.error('Error in spy endpoint:', error);
        res.status(500).json({
            success: false,
            message: error.message || 'Failed to initiate spy',
            error: process.env.NODE_ENV === 'development' ? error : undefined
        });
    }
});

/**
 * @route   POST /api/telephony/whisper
 * @desc    Whisper during an ongoing call
 * @access  Private - Requires telephony:whisper_call permission
 */
router.post('/whisper', verifyToken, requirePermission('telephony.whisper_call'), async (req, res) => {
    try {
        const { callId } = req.body;
        const userId = req.user.id;

        // Validate required fields
        if (!callId) {
            return res.status(400).json({
                success: false,
                message: 'Call ID is required'
            });
        }

        // Get user mobile number from database
        const query = require('../lib/dbconnection').query;
        const users = await query('SELECT mobile FROM users WHERE id = ?', [userId]);
        
        if (!users || users.length === 0 || !users[0].mobile) {
            return res.status(400).json({
                success: false,
                message: 'User mobile number not found. Please update your profile.'
            });
        }

        const agentNumber = users[0].mobile;

        // Get telephony service
        const telephonyService = require('../services/telephony/TelephonyService');

        // Make whisper request to SparkTG
        const result = await telephonyService.whisperToCall({ callId, agentNumber });

        res.json({
            success: true,
            message: 'Whisper initiated successfully. Call will ring on your mobile.',
            data: result
        });
    } catch (error) {
        logger.error('Error in whisper endpoint:', error);
        res.status(500).json({
            success: false,
            message: error.message || 'Failed to initiate whisper',
            error: process.env.NODE_ENV === 'development' ? error : undefined
        });
    }
});

/**
 * @route   POST /api/telephony/webhook/call-data
 * @desc    Webhook endpoint to receive call data from SparkTG
 * @access  Public (but should be IP restricted in production)
 */
router.post('/webhook/call-data', async (req, res) => {
    try {
        // Validate webhook data
        const { error, value } = webhookSchema.validate(req.body);
        if (error) {
            logger.warn('Invalid webhook data received', {
                errors: error.details.map(d => d.message),
                body: req.body
            });
            return res.status(400).json({
                success: false,
                message: 'Invalid webhook data',
                errors: error.details.map(d => d.message)
            });
        }

        // Optional: IP whitelist check (configure in production)
        const allowedIPs = process.env.TELEPHONY_WEBHOOK_IPS?.split(',') || [];
        if (allowedIPs.length > 0 && !allowedIPs.includes(req.ip)) {
            logger.warn('Webhook request from unauthorized IP', { ip: req.ip });
            return res.status(403).json({
                success: false,
                message: 'Unauthorized'
            });
        }

        // Process webhook
        const result = await telephonyService.processCallWebhook(value);

        // Respond quickly to telephony system
        res.status(200).json({
            status: 'success',
            callId: value.callid,
            message: 'Webhook received and processed'
        });

    } catch (error) {
        logger.error('Error processing webhook:', error);
        // Still return 200 to prevent retries for processing errors
        res.status(200).json({
            status: 'error',
            message: 'Webhook received but processing failed'
        });
    }
});

/**
 * @route   GET /api/telephony/call-history/:appointmentId
 * @desc    Get call history for an appointment
 * @access  Private - Requires telephony:view_call_logs permission
 */
router.get('/call-history/:appointmentId', verifyToken, requirePermission('telephony.view_call_logs'), async (req, res) => {
    try {
        const appointmentId = parseInt(req.params.appointmentId);

        if (isNaN(appointmentId)) {
            return res.status(400).json({
                success: false,
                message: 'Invalid appointment ID'
            });
        }

        const result = await telephonyService.getCallHistory(appointmentId);
        res.status(200).json(result);

    } catch (error) {
        logger.error('Error getting call history:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to retrieve call history',
            error: process.env.NODE_ENV === 'development' ? error.message : undefined
        });
    }
});

/**
 * @route   GET /api/telephony/call-attempts/:appointmentId
 * @desc    Get call attempts for an appointment
 * @access  Private - Requires telephony:view_call_logs permission
 */
router.get('/call-attempts/:appointmentId', verifyToken, requirePermission('telephony.view_call_logs'), async (req, res) => {
    try {
        const appointmentId = parseInt(req.params.appointmentId);

        if (isNaN(appointmentId)) {
            return res.status(400).json({
                success: false,
                message: 'Invalid appointment ID'
            });
        }

        const result = await telephonyService.getCallAttempts(appointmentId);
        res.status(200).json(result);

    } catch (error) {
        logger.error('Error getting call attempts:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to retrieve call attempts',
            error: process.env.NODE_ENV === 'development' ? error.message : undefined
        });
    }
});

/**
 * @route   GET /api/telephony/center-config/:centerId
 * @desc    Get telephony configuration for a center
 * @access  Private - Requires telephony:manage_config permission
 */
router.get('/center-config/:centerId', verifyToken, requirePermission('telephony.manage_config'), async (req, res) => {
    try {
        const centerId = parseInt(req.params.centerId);

        if (isNaN(centerId)) {
            return res.status(400).json({
                success: false,
                message: 'Invalid center ID'
            });
        }

        const config = await telephonyService.getCenterTelephonyConfig(centerId);
        
        res.status(200).json({
            success: true,
            data: config
        });

    } catch (error) {
        logger.error('Error getting center config:', error);
        res.status(500).json({
            success: false,
            message: error.message || 'Failed to retrieve center configuration',
            error: process.env.NODE_ENV === 'development' ? error.message : undefined
        });
    }
});

/**
 * @route   GET /api/telephony/validate-permission/:appointmentId/:centerId
 * @desc    Validate if center can make calls for appointment
 * @access  Private
 */
router.get('/validate-permission/:appointmentId/:centerId', verifyToken, async (req, res) => {
    try {
        const appointmentId = parseInt(req.params.appointmentId);
        const centerId = parseInt(req.params.centerId);

        if (isNaN(appointmentId) || isNaN(centerId)) {
            return res.status(400).json({
                success: false,
                message: 'Invalid appointment or center ID'
            });
        }

        const result = await telephonyService.validateCallPermission(appointmentId, centerId);
        
        res.status(200).json({
            success: true,
            ...result
        });

    } catch (error) {
        logger.error('Error validating call permission:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to validate permission',
            error: process.env.NODE_ENV === 'development' ? error.message : undefined
        });
    }
});

module.exports = router;
