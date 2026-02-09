const db = require('../../lib/dbconnection');
const logger = require('../../lib/logger');
const nodemailer = require('nodemailer');
const { generateToken, comparePassword } = require('../../lib/auth');
const userService = require('../s_user');

const TECHNICIAN_ROLE_ID = 4; // current technician role
const OTP_EXPIRY_MINUTES = 10;

function mapUserResponse(user) {
    const baseUrl = global.BASE_URL || '';
    return {
        id: user.id,
        username: user.username,
        email: user.email,
        full_name: user.full_name,
        mobile: user.mobile,
        role_id: user.role_id,
        technician_id: user.technician_id || null,
        technician_type: user.technician_type || null,
        rate_per_appointment: user.rate_per_appointment ? Number(user.rate_per_appointment) : 0,
        profile_pic: user.profile_pic ? `${baseUrl}/${user.profile_pic.replace(/\\/g, '/')}` : null,
        diagnostic_center_id: user.diagnostic_center_id || null,
    };
}


function isOtpEmailEnabled() {
    const flag = (process.env.OTP_EMAIL_ENABLED ?? 'true').toString().toLowerCase();
    return flag === 'true' || flag === '1';
}



async function login({ username, password }) {
    const user = await userService.getUserByUsername(username);
    if (!user) {
        return { success: false, message: 'Invalid username or password' };
    }

    // Only allow technician role for now (extendable later)
    if (Number(user.role_id) !== TECHNICIAN_ROLE_ID) {
        return { success: false, message: 'Access denied for this user role' };
    }

    if (Number(user.is_active) === 0) {
        return { success: false, message: 'User is inactive' };
    }

    const isMatch = await comparePassword(password, user.password_hash);
    if (!isMatch) {
        return { success: false, message: 'Invalid username or password' };
    }

    // Update last_login
    await db.query('UPDATE users SET last_login = NOW() WHERE id = ?', [user.id]);

    const token = generateToken(user);

    return {
        success: true,
        token,
        user: mapUserResponse(user),
    };
}

async function changePassword({ userId, oldPassword, newPassword }) {
    const rows = await db.query(
        'SELECT id, role_id, is_active, password_hash FROM users WHERE id = ? AND is_deleted = 0 LIMIT 1',
        [userId]
    );
    const user = rows[0];
    if (!user) {
        throw new Error('User not found');
    }
    if (Number(user.role_id) !== TECHNICIAN_ROLE_ID) {
        return { success: false, message: 'Access denied for this user role' };
    }
    if (Number(user.is_active) === 0) {
        return { success: false, message: 'User is inactive' };
    }

    const match = await comparePassword(oldPassword, user.password_hash);
    if (!match) {
        return { success: false, message: 'Old password is incorrect' };
    }

    await userService.changePassword(userId, newPassword);
    return { success: true };
}

// OTP helpers
async function createOtpRecord(userId, purpose = 'password_reset') {
    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    await db.query(
        `INSERT INTO user_otps (user_id, otp_code, purpose, expires_at, created_at) 
         VALUES (?, ?, ?, DATE_ADD(NOW(), INTERVAL ? MINUTE), NOW())`,
        [userId, otp, purpose, OTP_EXPIRY_MINUTES]
    );
    return otp;
}

async function getActiveOtp(userId, otp, purpose = 'password_reset') {
    const rows = await db.query(
        `SELECT id, otp_code, expires_at, used_at 
         FROM user_otps 
         WHERE user_id = ? AND purpose = ? AND otp_code = ? 
           AND used_at IS NULL AND expires_at > NOW()
         ORDER BY id DESC
         LIMIT 1`,
        [userId, purpose, otp]
    );
    return rows[0];
}

async function markOtpUsed(id) {
    await db.query('UPDATE user_otps SET used_at = NOW() WHERE id = ?', [id]);
}

function getMailer() {
    const { SMTP_HOST, SMTP_PORT, SMTP_USER, SMTP_PASSWORD } = process.env;
    if (!SMTP_HOST || !SMTP_PORT || !SMTP_USER || !SMTP_PASSWORD) {
        logger.warn('SMTP configuration missing, OTP email will not be sent');
        return null;
    }
    return nodemailer.createTransport({
        host: SMTP_HOST,
        port: Number(SMTP_PORT),
        secure: false,
        auth: {
            user: SMTP_USER,
            pass: SMTP_PASSWORD
        }
    });
}

async function sendOtpEmail(to, otp) {
    if (!isOtpEmailEnabled()) {
        logger.info('OTP email sending skipped (OTP_EMAIL_ENABLED=false)', { to });
        return;
    }
    const transporter = getMailer();
    if (!transporter) return;

    const from = process.env.SMTP_FROM || process.env.SMTP_USER;
    const mailOptions = {
        from,
        to,
        subject: 'Your OTP Code',
        text: `Your OTP code is ${otp}. It expires in ${OTP_EXPIRY_MINUTES} minutes.`,
    };

    try {
        await transporter.sendMail(mailOptions);
        logger.info('OTP email sent', { to });
    } catch (error) {
        logger.error('Failed to send OTP email', { to, error: error.message });
    }
}

async function requestOtp({ username, userId }) {
    let user;
    if (userId) {
        const rows = await db.query(
            `SELECT 
                u.*, 
                t.id AS technician_id, 
                t.technician_type,
                t.rate_per_appointment,
                t.profile_pic,
                dc.id AS diagnostic_center_id 
             FROM users u 
             LEFT JOIN technicians t ON u.id = t.user_id AND t.is_deleted = 0 
             LEFT JOIN diagnostic_centers dc ON u.id = dc.user_id AND dc.is_deleted = 0 
             WHERE u.id = ? 
             LIMIT 1`,
            [userId]
        );
        user = rows[0];
    } else if (username) {
        user = await userService.getUserByUsername(username);
    }

    if (!user) {
        return { success: false, message: 'User not found' };
    }
    if (Number(user.role_id) !== TECHNICIAN_ROLE_ID) {
        return { success: false, message: 'Access denied for this user role' };
    }
    if (Number(user.is_active) === 0) {
        return { success: false, message: 'User is inactive' };
    }

    const otp = await createOtpRecord(user.id);

    // Send OTP via email if configured
    if (user.email) {
        await sendOtpEmail(user.email, otp);
    } else {
        logger.warn('User has no email, OTP not sent', { userId: user.id });
    }

    logger.info('OTP generated', { userId: user.id, username: user.username });
    return { success: true, otp_dev: otp };
}

async function resetPasswordWithOtp({ username, userId, otp, newPassword }) {
    let user;
    if (userId) {
        const rows = await db.query('SELECT * FROM users WHERE id = ? LIMIT 1', [userId]);
        user = rows[0];
    } else if (username) {
        user = await userService.getUserByUsername(username);
    }

    if (!user) {
        return { success: false, message: 'User not found' };
    }

    const otpRow = await getActiveOtp(user.id, otp);
    if (!otpRow) {
        return { success: false, message: 'Invalid or expired OTP' };
    }

    await userService.changePassword(user.id, newPassword);
    await markOtpUsed(otpRow.id);

    return { success: true };
}

module.exports = {
    login,
    changePassword,
    requestOtp,
    resetPasswordWithOtp,
};
