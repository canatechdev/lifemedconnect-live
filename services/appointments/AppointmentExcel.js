/**
 * Appointment Excel Operations
 * Handles Excel template generation and bulk import
 */

const ExcelJS = require('exceljs');
const xlsx = require('xlsx');
const db = require('../../lib/dbconnection');
const logger = require('../../lib/logger');
const { appointmentCreateSchema } = require('../../validation/v_appointments');
const { createAppointment } = require('./AppointmentCRUD');

// Lazy getter to avoid circular require warnings
const getCreateWithApproval = () => {
    try {
        const approvalHelper = require('../../lib/approvalHelper');
        return approvalHelper?.createWithApproval;
    } catch (e) {
        logger.warn('createWithApproval not available (lazy load failed)', { error: e.message });
        return null;
    }
};

/**
 * Generate Excel template for appointment upload
 */
async function generateTemplate() {
    try {
        const workbook = new ExcelJS.Workbook();

        // Create main worksheet
        const worksheet = workbook.addWorksheet('Appointments Template');

        // Create Lists worksheet for dropdown options
        const listsWorksheet = workbook.addWorksheet('Lists');
        listsWorksheet.state = 'hidden';

        // Get data from database
        const clientsResult = await db.query('SELECT id, client_name FROM clients WHERE is_deleted=0');
        const insurersResult = await db.query('SELECT id, insurer_name FROM insurers WHERE is_deleted=0');

        // Extract rows
        const clients = Array.isArray(clientsResult) ? clientsResult : clientsResult?.rows || clientsResult?.[0] || [];
        const insurers = Array.isArray(insurersResult) ? insurersResult : insurersResult?.rows || insurersResult?.[0] || [];

        // Populate Lists sheet
        const listStartRow = 2;

        // Clients in column A
        listsWorksheet.getCell('A1').value = 'Clients';
        clients.forEach((c, index) => {
            listsWorksheet.getCell(`A${listStartRow + index}`).value = `${c.id} - ${c.client_name}`;
        });

        // Insurers in column B
        listsWorksheet.getCell('B1').value = 'Insurers';
        insurers.forEach((i, index) => {
            listsWorksheet.getCell(`B${listStartRow + index}`).value = `${i.id} - ${i.insurer_name}`;
        });

        // Add title
        let currentRow = 1;
        worksheet.getRow(currentRow).values = ['APPOINTMENTS UPLOAD TEMPLATE'];
        worksheet.mergeCells(`A${currentRow}:N${currentRow}`);
        worksheet.getCell(`A${currentRow}`).font = { bold: true, size: 16 };
        worksheet.getCell(`A${currentRow}`).alignment = { horizontal: 'center' };
        currentRow++;

        // Add instructions
        const instructionsStart = currentRow;
        worksheet.getRow(currentRow).values = ['Instructions:'];
        currentRow++;
        worksheet.getRow(currentRow).values = ['- Fields marked with * are mandatory'];
        currentRow++;
        worksheet.getRow(currentRow).values = ['- Use dropdowns (small arrow in cell) to select from available options'];
        currentRow++;
        worksheet.getRow(currentRow).values = ['- Date format: YYYY-MM-DD (e.g., 2024-01-15)'];
        currentRow++;
        worksheet.getRow(currentRow).values = ['- Time format: HH:MM:SS (e.g., 14:30:00)'];
        currentRow++;
        worksheet.getRow(currentRow).values = ['- For dropdown fields, please select from the list only'];
        currentRow++;

        // Style instructions
        for (let i = instructionsStart; i < currentRow; i++) {
            worksheet.getRow(i).font = { italic: true, color: { argb: 'FF0000' } };
        }

        // Add empty row
        currentRow++;

        // Add header row
        const headerRow = currentRow;
        worksheet.getRow(headerRow).values = [
            'Application Number*', 'TPA', 'Insurer', 'Customer First Name', 'Customer Last Name',
            'Gender', 'Customer Mobile', 'Customer Alt No', 'Customer Service No', 'Customer Email', 'Customer Category',
            'Appointment Date* (YYYY-MM-DD)', 'Appointment Time (HH:MM:SS)', 'Visit Type',
            'Landmark', 'State', 'City', 'Pin Code', 'Country', 'Customer Address', 'Status', 'Remarks'
        ];

        // Style the header row
        worksheet.getRow(headerRow).font = { bold: true, color: { argb: 'FFFFFF' } };
        worksheet.getRow(headerRow).fill = {
            type: 'pattern',
            pattern: 'solid',
            fgColor: { argb: '4472C4' }
        };

        // Set column widths
        const colWidths = [20, 25, 25, 20, 20, 15, 15, 15, 15, 25, 20, 20, 15, 20, 20, 20, 15, 10, 30, 20, 20, 30];
        for (let c = 1; c <= colWidths.length; c++) {
            worksheet.getColumn(c).width = colWidths[c - 1];
        }

        // Predefined dropdown options
        const genderOptions = ['Male', 'Female', 'Other'];
        const visitTypeOptions = ['Home_Visit', 'Center_Visit', 'Both'];
        const statusOptions = ['pending', 'in_process', 'completed'];

        // Calculate first data row
        const firstDataRow = headerRow + 1;

        // Add data validation (dropdowns) for 100 rows
        for (let i = 0; i < 100; i++) {
            const row = firstDataRow + i;

            // Client dropdown (Column B)
            const clientFormula = `Lists!$A$${listStartRow}:$A$${listStartRow + clients.length - 1}`;
            worksheet.getCell(`B${row}`).dataValidation = {
                type: 'list',
                allowBlank: true,
                formulae: [clientFormula],
                showErrorMessage: true,
                errorTitle: 'Invalid Selection',
                error: 'Please select from the list of clients'
            };

            // Insurer dropdown (Column C)
            const insurerFormula = `Lists!$B$${listStartRow}:$B$${listStartRow + insurers.length - 1}`;
            worksheet.getCell(`C${row}`).dataValidation = {
                type: 'list',
                allowBlank: true,
                formulae: [insurerFormula],
                showErrorMessage: true,
                errorTitle: 'Invalid Selection',
                error: 'Please select from the list of insurers'
            };

            // Gender dropdown (Column F)
            worksheet.getCell(`F${row}`).dataValidation = {
                type: 'list',
                allowBlank: true,
                formulae: [`"${genderOptions.join(',')}"`],
                showErrorMessage: true,
                errorTitle: 'Invalid Selection',
                error: 'Please select from: ' + genderOptions.join(', ')
            };

            // Customer Category dropdown (Column K)
            worksheet.getCell(`K${row}`).dataValidation = {
                type: 'list',
                allowBlank: true,
                formulae: ['"Non_HNI,SUPER_HNI,HNI"'],
                showErrorMessage: true,
                errorTitle: 'Invalid Category',
                error: 'Please select from: Non_HNI, SUPER_HNI, HNI'
            };

            // Visit Type dropdown (Column N)
            worksheet.getCell(`N${row}`).dataValidation = {
                type: 'list',
                allowBlank: true,
                formulae: [`"${visitTypeOptions.join(',')}"`],
                showErrorMessage: true,
                errorTitle: 'Invalid Selection',
                error: 'Please select from: ' + visitTypeOptions.join(', ')
            };

            // Status dropdown (Column U)
            worksheet.getCell(`U${row}`).dataValidation = {
                type: 'list',
                allowBlank: true,
                formulae: [`"${statusOptions.join(',')}"`],
                showErrorMessage: true,
                errorTitle: 'Invalid Selection',
                error: 'Please select from: ' + statusOptions.join(', ')
            };

            // Date validation (Column L)
            worksheet.getCell(`L${row}`).dataValidation = {
                type: 'custom',
                allowBlank: false,
                formulae: ['ISDATE(J' + row + ')'],
                showErrorMessage: true,
                errorTitle: 'Invalid Date',
                error: 'Please enter date in YYYY-MM-DD format'
            };
        }

        // Add sample data row
        const sampleData = [
            'APP-001',
            clients.length > 0 ? `${clients[0].id} - ${clients[0].client_name}` : '',
            insurers.length > 0 ? `${insurers[0].id} - ${insurers[0].insurer_name}` : '',
            'John', 'Doe', 'Male', '9876543210','','','john.doe@email.com', 'Non_HNI',
            '2024-01-15', '09:00:00', 'Home_Visit', 'Near Mall Road', 'Delhi', 'New Delhi',
            '110001', 'IN', '123 Main Street, XYZ Building', 'pending', 'Initial appointment'
        ];

        worksheet.getRow(firstDataRow).values = sampleData;

        // Style the sample data row
        worksheet.getRow(firstDataRow).fill = {
            type: 'pattern',
            pattern: 'solid',
            fgColor: { argb: 'F0F0F0' }
        };

        return workbook;
    } catch (error) {
        logger.error('Error generating Excel template:', error);
        throw error;
    }
}

/**
 * Helper: Clean string values
 */
function cleanValue(value) {
    if (value === undefined || value === null || value === '') return null;
    return String(value).trim();
}

/**
 * Helper: Clean time values
 */
function cleanTimeValue(value) {
    if (!value) return null;
    const cleaned = String(value).trim();
    if (/^\d{2}:\d{2}:\d{2}$/.test(cleaned)) return cleaned;
    if (/^\d{2}:\d{2}$/.test(cleaned)) return cleaned + ':00';
    return null;
}

/**
 * Process uploaded Excel file and create appointments
 * @param {string} filePath - Path to uploaded Excel file
 * @param {Object} user - User object (id, role_id)
 * @returns {Promise<Object>} Result with insertedIds and failedRows
 */
async function processUploadedFile(filePath, user) {
    // Validate user object
    if (!user || !user.id || !user.role_id) {
        const error = new Error('User authentication required. Missing user.id or user.role_id');
        logger.error('Excel upload failed: Invalid user object', {
            hasUser: !!user,
            userId: user?.id,
            roleId: user?.role_id
        });
        throw error;
    }

    try {
        logger.info('Processing Excel file', { userId: user.id, roleId: user.role_id, filePath });

        const workbook = xlsx.readFile(filePath);
        const sheet = workbook.Sheets[workbook.SheetNames[0]];

        // Convert sheet to JSON, starting from the header row (row 8)
        const rows = xlsx.utils.sheet_to_json(sheet, {
            header: [
                'application_number',
                'client_id',
                'insurer_id',
                'customer_first_name',
                'customer_last_name',
                'gender',
                'customer_mobile',
                'customer_alt_mobile',
                'customer_service_no',
                'customer_email',
                'customer_category',
                'appointment_date',
                'appointment_time',
                'visit_type',
                'customer_landmark',
                'state',
                'city',
                'pincode',
                'country',
                'customer_address',
                'status',
                'remarks'
            ],
            range: 7, // Start from row 8 (0-based index: 7)
        });

        // Fetch valid IDs from database for validation
        const clientsResult = await db.query('SELECT id FROM clients WHERE is_deleted=0');
        const insurersResult = await db.query('SELECT id FROM insurers WHERE is_deleted=0');

        const validClientIds = new Set(
            (Array.isArray(clientsResult) ? clientsResult : clientsResult?.rows || clientsResult?.[0] || []).map(c => c.id)
        );
        const validInsurerIds = new Set(
            (Array.isArray(insurersResult) ? insurersResult : insurersResult?.rows || insurersResult?.[0] || []).map(i => i.id)
        );

        const insertedIds = [];
        const failedRows = [];

        // SKIP THE HEADER ROW - start from index 1 instead of 0
        for (const [index, row] of rows.entries()) {
            // Skip the first row (header row)
            if (index === 0) continue;

            // Also skip empty rows
            if (!row.application_number && !row.client_id && !row.insurer_id) {
                continue;
            }

            try {
                // Parse ID from 'id - name' format
                const parseId = (value, fieldName, validIds) => {
                    if (!value) return null;
                    const match = String(value).match(/^(\d+)\s*-\s*/);
                    if (!match) {
                        throw new Error(`Invalid ${fieldName} format: "${value}". Expected format: "id - name"`);
                    }
                    const id = parseInt(match[1], 10);
                    if (!validIds.has(id)) {
                        throw new Error(`Invalid ${fieldName} ID: ${id} does not exist`);
                    }
                    return id;
                };

                const cleanedRow = {
                    application_number: cleanValue(row.application_number),
                    client_id: parseId(row.client_id, 'client', validClientIds),
                    insurer_id: parseId(row.insurer_id, 'insurer', validInsurerIds),
                    customer_first_name: cleanValue(row.customer_first_name),
                    customer_last_name: cleanValue(row.customer_last_name),
                    gender: cleanValue(row.gender),
                    customer_mobile: cleanValue(row.customer_mobile),
                    customer_alt_mobile: cleanValue(row.customer_alt_mobile),
                    customer_service_no: cleanValue(row.customer_service_no),
                    customer_email: cleanValue(row.customer_email),
                    customer_category: cleanValue(row.customer_category) || 'Non_HNI',
                    appointment_date: cleanValue(row.appointment_date),
                    appointment_time: cleanTimeValue(row.appointment_time),
                    visit_type: cleanValue(row.visit_type) || 'Home_Visit',
                    customer_landmark: cleanValue(row.customer_landmark),
                    state: cleanValue(row.state),
                    city: cleanValue(row.city),
                    pincode: cleanValue(row.pincode),
                    country: cleanValue(row.country) || 'IN',
                    customer_address: cleanValue(row.customer_address),
                    status: cleanValue(row.status) || 'pending',
                    remarks: cleanValue(row.remarks),

                    // Optional/unavailable fields in template
                    // customer_alt_mobile: null,
                    customer_gps_latitude: null,
                    customer_gps_longitude: null,
                    test_name: null,
                    confirmed_time: null,
                    assigned_technician_id: null,
                    cost_type: null,
                    amount: null,
                    amount_upload: null,

                    created_by: user.id,
                    created_at: new Date(),
                };

                const { error, value } = appointmentCreateSchema.validate(cleanedRow, { stripUnknown: true });
                if (error) {
                    throw new Error(error.details[0].message);
                }

                // Business rule: if cost_type is Credit, amount should be null
                if (value.cost_type === 'Credit') {
                    value.amount = null;
                }

                // Check duplicate application_number BEFORE createWithApproval
                if (value.application_number) {
                    const [existing] = await db.query(
                        `SELECT id FROM appointments 
                            WHERE application_number = ? AND is_deleted = 0 
                            LIMIT 1`,
                        [value.application_number]
                    );

                    if (existing && existing.length > 0) {
                        throw new Error(
                            `Duplicate application_number: ${value.application_number}. An appointment already exists.`
                        );
                    }
                }


                if (typeof createWithApproval === 'function') {
                    const result = await createWithApproval({
                        entity_type: 'appointment_import',
                        createFunction: createAppointment,
                        data: value,
                        user
                    });
                    insertedIds.push(result.entity_id || result.id);
                } else {
                    // Fallback: create directly when approval helper is unavailable
                    logger.warn('createWithApproval not available, creating appointment directly (no approval)', {
                        userId: user.id,
                        roleId: user.role_id
                    });
                    const id = await createAppointment(value);
                    insertedIds.push(id);
                }

            } catch (error) {
                logger.error(`Error processing row ${index + 8}:`, error.message);
                failedRows.push({
                    rowNumber: index + 8,
                    row,
                    error: error.message
                });
            }
        }

        return {
            insertedIds,
            failedRows,
            message: `${insertedIds.length} appointments inserted`
        };

    } catch (error) {
        logger.error('Excel upload error:', error);
        throw error;
    }
}

module.exports = {
    generateTemplate,
    processUploadedFile
};
