require('dotenv').config();
const express = require('express');
const http = require('http');
const socketIo = require('socket.io');
const path = require('path');
const cors = require('cors');
const compression = require('compression');

// Import utilities and middleware
const { validateEnv, getConfig } = require('./lib/config');
const logger = require('./lib/logger');
const requestLogger = require('./middleware/requestLogger');
const { errorHandler, notFoundHandler } = require('./middleware/errorHandler');
const { testConnection, closePool } = require('./lib/dbconnection');

//  NEW: Import security middleware
const {
    helmetConfig,
    cookieParser,
    csrfProtection,
    conditionalCsrfProtection,
    getCsrfToken,
    csrfErrorHandler,
    sanitizeInput,
    apiLimiter
} = require('./middleware/security');

// Validate environment variables
try {
    validateEnv();
    logger.info('Environment variables validated successfully');
} catch (error) {
    logger.error('Environment validation failed:', error.message);
    process.exit(1);
}

// Test database connection and sync permission catalog
testConnection()
    .then(async () => {
        logger.info('Database connected successfully');
        // NEW: Sync permission catalog on startup
        const { ensurePermissionCatalog } = require('./lib/permissionCatalog');
        try {
            await ensurePermissionCatalog();
            logger.info('Permission catalog synchronized successfully');
        } catch (error) {
            logger.error('Failed to sync permission catalog:', error.message);
            // Don't exit - allow app to continue even if permission sync fails
        }
    })
    .catch((error) => {
        logger.error('Failed to connect to database. Exiting...');
        process.exit(1);
    });

const config = getConfig();
const app = express();
const server = http.createServer(app);

// Socket.IO configuration
const io = socketIo(server, {
    cors: {
        origin: config.corsOrigin,
        methods: ['GET', 'POST', 'PUT', 'DELETE'],
    }
});

//  SECURITY MIDDLEWARE - ORDER MATTERS!
// 1. Helmet (must be first) - Secure HTTP headers
app.use(helmetConfig);

// 2. Compression
app.use(compression());

// 3. CORS - Allow frontend access
app.use(cors({
    origin: config.corsOrigin,
    credentials: true, // Required for CSRF cookies
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
    allowedHeaders: ['Content-Type', 'Authorization', 'X-CSRF-Token']
}));

// 4. Cookie parser (required for CSRF)
app.use(cookieParser);

// 5. Body parsing middleware
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// 6.  NEW: Input sanitization (after body parsing, before routes)
app.use(sanitizeInput);

// 7. Request logging
app.use(requestLogger);

// 8.  NEW: Rate limiting for all API routes
app.use('/api/', apiLimiter);

// Static files

app.use('/uploads', express.static(path.join(__dirname, 'uploads'), {
  setHeaders: (res, path, stat) => {
    // Allow your frontend to load images cross-origin
    res.setHeader('Access-Control-Allow-Origin', config.corsOrigin || '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET,OPTIONS');
  }
}));

// Import routes
const userRoutes = require('./routes/r_user');
const clientRoutes = require('./routes/r_clients');
const centerRoutes = require('./routes/r_centers');
const insurerRoutes = require('./routes/r_insurers');
const testCategoryRoutes = require('./routes/r_test_categories');
const testRoutes = require('./routes/r_tests');
const technicianRoutes = require('./routes/r_technicians');
const appointmentRoutes = require('./routes/r_appointments');
const testRateRoutes = require('./routes/r_test_rates');
const roleRoutes = require('./routes/r_roles');
const rolePermissionRoutes = require('./routes/r_role_permissions');
const doctorRoutes = require('./routes/r_doctor');
const bulkTestRoutes = require('./routes/r_test_bulk');
const approvalRoutes = require('./routes/r_approvals');
const dashboard = require('./routes/r_dashboard')
const appAuthRoutes = require('./routes/app/auth');
const rbacRoutes = require('./routes/r_rbac');

// Health check route
app.get('/', (req, res) => {
    res.json({
        status: 'success',
        message: 'Healthcare CRM Backend API is running',
        version: '1.0.0',
        timestamp: new Date().toISOString()
    });
});

//  CSRF token endpoint (must use csrfProtection so req.csrfToken is available on GET)
app.get('/api/csrf-token', csrfProtection, getCsrfToken);

//   Detailed health check with DB status
app.get('/api/health', async (req, res) => {
    try {
        await testConnection();
        res.json({
            status: 'success',
            message: 'System healthy',
            database: 'connected',
            uptime: Math.floor(process.uptime()),
            timestamp: new Date().toISOString(),
            environment: config.nodeEnv
        });
    } catch (error) {
        res.status(503).json({
            status: 'error',
            message: 'System unhealthy',
            database: 'disconnected',
            timestamp: new Date().toISOString()
        });
    }
});

//  Apply CSRF protection to state-changing routes
// Note: GET requests don't need CSRF, only POST/PUT/DELETE/PATCH
app.use('/api/', conditionalCsrfProtection);

// Register API routes
app.use('/api', userRoutes);
app.use('/api', clientRoutes);
app.use('/api', centerRoutes);
app.use('/api', insurerRoutes);
app.use('/api', testCategoryRoutes);
app.use('/api', testRoutes);
app.use('/api', technicianRoutes);
app.use('/api', appointmentRoutes);
app.use('/api', testRateRoutes);
app.use('/api', roleRoutes);
app.use('/api', rolePermissionRoutes);
app.use('/api', doctorRoutes);
app.use('/api', bulkTestRoutes);
app.use('/api', approvalRoutes);
app.use('/api',dashboard)
app.use('/api', rbacRoutes);
// App (mobile) routes (no CSRF)
app.use('/api/app', appAuthRoutes);

// 404 handler
app.use(notFoundHandler);

// CSRF error handler (before global error handler)
app.use(csrfErrorHandler);

// Global error handler (must be last)
app.use(errorHandler);

// WebSocket connection handling
io.on('connection', (socket) => {
    logger.info('WebSocket: Client connected', { socketId: socket.id });

    socket.on('disconnect', () => {
        logger.info('WebSocket: Client disconnected', { socketId: socket.id });
    });

    socket.on('error', (error) => {
        logger.error('WebSocket error:', error);
    });
});

// Graceful shutdown
const gracefulShutdown = async () => {
    logger.info('Received shutdown signal, closing server gracefully...');

    server.close(async () => {
        logger.info('HTTP server closed');

        try {
            await closePool();
            logger.info('Database connections closed');
            process.exit(0);
        } catch (error) {
            logger.error('Error during shutdown:', error);
            process.exit(1);
        }
    });

    // Force shutdown after 10 seconds
    setTimeout(() => {
        logger.error('Forced shutdown after timeout');
        process.exit(1);
    }, 10000);
};

process.on('SIGTERM', gracefulShutdown);
process.on('SIGINT', gracefulShutdown);

// Handle unhandled promise rejections
process.on('unhandledRejection', (reason, promise) => {
    logger.error('Unhandled Rejection at:', promise, 'reason:', reason);
});

// Start server
const PORT = config.port;
server.listen(PORT, () => {
    logger.info(` Server running on port ${PORT}`);
    logger.info(` Environment: ${config.nodeEnv}`);
    logger.info(` CORS Origin: ${config.corsOrigin}`);
    logger.info(` Database: ${config.database.host}:${config.database.port}/${config.database.name}`);
});



