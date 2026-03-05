/**
 * Appointment Pathology Data Management
 * Fetches pathology data from external API and generates PDF reports
 */

const db = require('../../lib/dbconnection');
const logger = require('../../lib/logger');
const axios = require('axios');
const path = require('path');
const fs = require('fs').promises;
const { parseApiDate, isAbnormal, getLetterheadDataUrl, safeText, unwrapRows, buildPdfHtml, generatePdfBuffer, getStandardMargins } = require('../../lib/pdfUtils');

/**
 * Generate pathology report content HTML (without header/footer wrapper)
 * This content is inserted into the standardized PDF template
 */
function generatePathologyContent(data, appointmentInfo) {
    // Group data by SubDeptName (department)
    const grouped = {};
    data.forEach(item => {
        const dept = item.SubDeptName || 'Other';
        if (!grouped[dept]) {
            grouped[dept] = {};
        }
        
        const testName = item.TestName || 'Unknown Test';
        if (!grouped[dept][testName]) {
            grouped[dept][testName] = [];
        }
        
        grouped[dept][testName].push(item);
    });
    
    const patientName = data[0]?.PatName || `${appointmentInfo.customer_first_name || ''} ${appointmentInfo.customer_last_name || ''}`.trim() || 'N/A';
    const patRegID = data[0]?.PatRegID || appointmentInfo.case_number || 'N/A';
    const reportDate = data[0]?.PatRepDate ? parseApiDate(data[0].PatRepDate) : 'N/A';
    
    let content = `
    <div class="report-title">
        <h1>PATHOLOGY REPORT</h1>
    </div>
    
    <div class="patient-info-box">
        <div class="patient-info-grid">
            <div class="patient-info-item">
                <label>Patient Name:</label>
                <span>${patientName}</span>
            </div>
            <div class="patient-info-item">
                <label>Patient ID:</label>
                <span>${patRegID}</span>
            </div>
            <div class="patient-info-item">
                <label>Report Date:</label>
                <span>${reportDate}</span>
            </div>
        </div>
    </div>
`;
    
    // Generate sections for each department
    Object.keys(grouped).sort().forEach(deptName => {
        content += `
    <div class="department-section">
        <div class="department-header">${deptName}</div>
`;
        
        // Generate sections for each test in the department
        Object.keys(grouped[deptName]).sort().forEach(testName => {
            const parameters = grouped[deptName][testName];
            
            content += `
        <div class="test-box">
            <div class="test-header-bar">${testName}</div>
            <table class="pathology-table">
                <thead>
                    <tr>
                        <th style="width: 35%;">Parameter</th>
                        <th style="width: 20%;">Result</th>
                        <th style="width: 15%;">Unit</th>
                        <th style="width: 30%;">Normal Range</th>
                    </tr>
                </thead>
                <tbody>
`;
            
            parameters.forEach(param => {
                const abnormal = isAbnormal(param.Result, param.NormalRange);
                const rowClass = abnormal ? 'abnormal' : '';
                const marker = abnormal ? '<span class="abnormal-marker">ABNORMAL</span>' : '';
                
                content += `
                    <tr class="${rowClass}">
                        <td><strong>${param.ParameterName || 'N/A'}</strong></td>
                        <td><strong>${param.Result || 'N/A'}</strong>${marker}</td>
                        <td>${param.Unit || '-'}</td>
                        <td>${param.NormalRange || '-'}</td>
                    </tr>
`;
            });
            
            content += `
                </tbody>
            </table>
        </div>
`;
        });
        
        content += `
    </div>
`;
    });
    
    content += `
    <div class="pathology-note">
        <p><strong>Note:</strong> Abnormal values are highlighted in red for easy identification.</p>
        <p style="margin-top: 5px;">Generated on ${new Date().toLocaleString('en-IN')}</p>
    </div>
`;
    
    return content;
}

/**
 * Generate additional CSS for pathology reports
 */
function getPathologyStyles() {
    return `
        .report-title {
            text-align: center;
            margin: 0 0 12pt 0;
            padding: 8pt 12pt;
            background: linear-gradient(135deg, #0066cc 0%, #004999 100%);
            color: white;
            border-radius: 0;
        }
        
        .report-title h1 {
            font-size: 16pt;
            font-weight: 600;
            letter-spacing: 0.5px;
            margin: 0;
        }
        
        .patient-info-box {
            background: #f8f9fa;
            border: 1px solid #dee2e6;
            border-radius: 0;
            padding: 10pt 12pt;
            margin-bottom: 12pt;
        }
        
        .patient-info-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 6pt 16pt;
        }
        
        .patient-info-item {
            display: flex;
            align-items: baseline;
            gap: 6pt;
        }
        
        .patient-info-item label {
            font-size: 8pt;
            color: #495057;
            text-transform: uppercase;
            font-weight: 600;
            letter-spacing: 0.3px;
            min-width: 80pt;
        }
        
        .patient-info-item span {
            font-size: 10pt;
            color: #212529;
            font-weight: 600;
        }
        
        .department-section {
            margin: 10pt 0;
            page-break-inside: auto;
        }
        
        .department-header {
            background: linear-gradient(135deg, #0066cc 0%, #004999 100%);
            color: white;
            padding: 8pt 12pt;
            font-size: 11pt;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            border-left: 3px solid #003d7a;
            border-radius: 0;
            margin-bottom: 8pt;
        }
        
        .test-box {
            margin-bottom: 10pt;
            border: 1px solid #dee2e6;
            border-radius: 0;
            background: white;
            page-break-inside: auto;
        }
        
        .test-header-bar {
            background: #e7f3ff;
            padding: 6pt 10pt;
            font-weight: 600;
            font-size: 10pt;
            color: #004999;
            border-bottom: 1.5pt solid #0066cc;
            text-transform: uppercase;
            letter-spacing: 0.3px;
        }
        
        .pathology-table {
            width: 100%;
            border-collapse: collapse;
        }
        
        .pathology-table th {
            padding: 6pt 8pt;
            text-align: left;
            font-size: 8pt;
            font-weight: 700;
            color: #495057;
            text-transform: uppercase;
            background: #f1f5f9;
            border-bottom: 1.5pt solid #cbd5e1;
        }
        
        .pathology-table td {
            padding: 5pt 8pt;
            font-size: 9pt;
            border-bottom: 0.5pt solid #e2e8f0;
            color: #212529;
        }
        
        .pathology-table tbody tr:nth-child(even) {
            background: #f8fafc;
        }
        
        .pathology-table tbody tr.abnormal {
            background: #fef2f2 !important;
            border-left: 2pt solid #dc2626;
        }
        
        .pathology-table tbody tr.abnormal td {
            color: #dc2626;
            font-weight: 700;
        }
        
        .abnormal-marker {
            display: inline-block;
            background: #dc2626;
            color: white;
            padding: 1pt 4pt;
            border-radius: 0;
            font-size: 6pt;
            font-weight: 700;
            margin-left: 4pt;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        
        .pathology-note {
            margin-top: 12pt;
            padding: 8pt 12pt;
            background: #f1f5f9;
            border-radius: 0;
            border-left: 3pt solid #0066cc;
            font-size: 8pt;
            color: #475569;
        }
        
        .pathology-note strong {
            color: #dc2626;
        }
    `;
}

/**
 * Fetch pathology data from external API and generate PDF
 */
async function fetchAndSavePathologyData(appointmentId, userId) {
    const connection = await db.pool.getConnection();
    
    try {
        await connection.beginTransaction();
        
        // Get appointment details with center/technician info
        const [appointment] = await connection.query(`
            SELECT 
                a.case_number,
                a.customer_first_name,
                a.customer_last_name,
                a.gender,
                a.customer_mobile,
                a.customer_email,
                a.customer_address,
                a.city,
                a.state,
                a.pincode,
                a.appointment_date,
                a.center_id,
                a.other_center_id,
                a.visit_type,
                c1.center_name as center_name,
                c1.letterhead_path as center_letterhead,
                c1.footer_path as center_footer,
                c1.address as center_address,
                c1.contact_number as center_contact,
                c2.center_name as other_center_name,
                c2.letterhead_path as other_center_letterhead,
                c2.footer_path as other_center_footer
            FROM appointments a
            LEFT JOIN diagnostic_centers c1 ON a.center_id = c1.id
            LEFT JOIN diagnostic_centers c2 ON a.other_center_id = c2.id
            WHERE a.id = ?
        `, [appointmentId]);
        
        if (!appointment || appointment.length === 0) {
            throw new Error('Appointment not found');
        }
        
        const appt = appointment[0];
        const caseNumber = appt.case_number;
        const customerName = `${appt.customer_first_name || ''} ${appt.customer_last_name || ''}`.trim();
        
        // Determine which letterhead and footer to use based on visit type
        let letterheadPath = null;
        let footerPath = null;
        if (appt.visit_type === 'Both') {
            // For both, prefer center_id letterhead and footer
            letterheadPath = appt.center_letterhead || appt.other_center_letterhead;
            footerPath = appt.center_footer || appt.other_center_footer;
        } else if (appt.visit_type === 'Home_Visit') {
            letterheadPath = appt.other_center_letterhead || appt.center_letterhead;
            footerPath = appt.other_center_footer || appt.center_footer;
        } else {
            letterheadPath = appt.center_letterhead;
            footerPath = appt.center_footer;
        }
        
        // Determine PID based on test mode
        const testMode = process.env.PATHOLOGY_TEST_MODE === 'true';
        const pid = testMode ? process.env.PATHOLOGY_TEST_PID : caseNumber;
        
        logger.info('Fetching pathology data', { appointmentId, caseNumber, pid, testMode });
        
        // Fetch data from external API
        const apiUrl = process.env.PATHOLOGY_API_URL;
        const response = await axios.get(apiUrl, {
            params: { pid },
            timeout: 30000
        });
        
        const pathologyData = response.data;
        
        if (!pathologyData || !Array.isArray(pathologyData) || pathologyData.length === 0) {
            throw new Error('No pathology data found for this case number');
        }
        
        // Generate content HTML using standardized template
        const content = generatePathologyContent(pathologyData, appt);
        
        // Convert header/footer paths to data URLs for reliable embedding
        const baseDir = path.resolve(__dirname, '../../');
        const headerDataUrl = letterheadPath ? await getLetterheadDataUrl(letterheadPath, baseDir, logger) : null;
        const footerDataUrl = footerPath ? await getLetterheadDataUrl(footerPath, baseDir, logger) : null;
        
        const html = buildPdfHtml({
            content,
            title: `Pathology Report - ${caseNumber}`,
            customStyles: getPathologyStyles()
        });
        
        // Create uploads directory if not exists
        const uploadsDir = path.join(__dirname, '../../uploads/pathology');
        await fs.mkdir(uploadsDir, { recursive: true });
        
        // Generate PDF filename
        const timestamp = Date.now();
        const pdfFilename = `pathology_${appointmentId}_${timestamp}.pdf`;
        const pdfPath = path.join(uploadsDir, pdfFilename);
        
        // Generate PDF (Puppeteer launched/closed inside generatePdfBuffer)
        const headerHeightMm = 38;
        const footerHeightMm = 24;

        await generatePdfBuffer({
            html,
            path: pdfPath,
            headerDataUrl,
            footerDataUrl,
            headerHeightMm,
            footerHeightMm,
            margin: getStandardMargins(headerHeightMm, footerHeightMm)
        });
        
        logger.info('PDF generated successfully', { pdfPath });
        
        // Save to database (upsert)
        const relativePdfPath = `uploads/pathology/${pdfFilename}`;
        
        // Check if record exists
        const [existing] = await connection.query(
            'SELECT id FROM appointment_pathology_data WHERE appointment_id = ?',
            [appointmentId]
        );
        
        if (existing && existing.length > 0) {
            // Update existing record
            await connection.query(
                `UPDATE appointment_pathology_data 
                SET case_number = ?, data_json = ?, pdf_path = ?, fetched_at = NOW(), fetched_by = ?, updated_at = NOW()
                WHERE appointment_id = ?`,
                [caseNumber, JSON.stringify(pathologyData), relativePdfPath, userId, appointmentId]
            );
        } else {
            // Insert new record
            await connection.query(
                `INSERT INTO appointment_pathology_data 
                (appointment_id, case_number, data_json, pdf_path, fetched_at, fetched_by)
                VALUES (?, ?, ?, ?, NOW(), ?)`,
                [appointmentId, caseNumber, JSON.stringify(pathologyData), relativePdfPath, userId]
            );
        }
        
        await connection.commit();
        
        logger.info('Pathology data saved successfully', { appointmentId });
        
        return {
            success: true,
            message: 'Pathology data fetched and PDF generated successfully',
            pdfPath: relativePdfPath,
            recordCount: pathologyData.length
        };
        
    } catch (error) {
        await connection.rollback();
        logger.error('Error fetching pathology data:', error);
        throw error;
    } finally {
        connection.release();
    }
}

/**
 * Get pathology data for an appointment
 */
async function getPathologyData(appointmentId) {
    const sql = `
        SELECT 
            id,
            appointment_id,
            case_number,
            data_json,
            pdf_path,
            fetched_at,
            fetched_by
        FROM appointment_pathology_data
        WHERE appointment_id = ?
    `;
    
    const rows = await db.query(sql, [appointmentId]);
    
    if (rows.length === 0) {
        return null;
    }
    
    const record = rows[0];
    
    return {
        id: record.id,
        appointment_id: record.appointment_id,
        case_number: record.case_number,
        data: JSON.parse(record.data_json),
        pdf_path: record.pdf_path,
        fetched_at: record.fetched_at,
        fetched_by: record.fetched_by
    };
}

/**
 * Check if pathology data exists for an appointment
 */
async function hasPathologyData(appointmentId) {
    const sql = 'SELECT COUNT(*) as count FROM appointment_pathology_data WHERE appointment_id = ?';
    const rows = await db.query(sql, [appointmentId]);
    return rows[0].count > 0;
}

module.exports = {
    fetchAndSavePathologyData,
    getPathologyData,
    hasPathologyData
};
