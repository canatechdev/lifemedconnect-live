const htmlToPdf = require('html-pdf-node');
const Handlebars = require('handlebars');
const moment = require('moment');
const path = require('path');
const fs = require('fs/promises');
const db = require('../../lib/dbconnection');
const logger = require('../../lib/logger');

function formatCurrency(value) {
    const num = parseFloat(value) || 0;
    const formatted = new Intl.NumberFormat('en-IN', {
        minimumFractionDigits: 2,
        maximumFractionDigits: 2,
    }).format(num);
    return `INR ${formatted}`;
}

function formatDate(date) {
    return date ? moment(date).format('DD/MM/YYYY') : '';
}

function safeText(value) {
    return value == null ? '' : String(value).trim();
}

async function getLetterheadDataUrl(relativePath) {
    if (!relativePath) return null;
    try {
        const baseDir = path.resolve(__dirname, '../../');
        const absolutePath = path.isAbsolute(relativePath)
            ? relativePath
            : path.join(baseDir, relativePath);
        const fileBuffer = await fs.readFile(absolutePath);

        const ext = path.extname(absolutePath).toLowerCase();
        const mimeTypes = {
            '.png': 'image/png',
            '.jpg': 'image/jpeg',
            '.jpeg': 'image/jpeg',
            '.webp': 'image/webp',
            '.gif': 'image/gif',
            '.bmp': 'image/bmp',
            '.svg': 'image/svg+xml'
        };
        const mimeType = mimeTypes[ext] || 'application/octet-stream';
        return `data:${mimeType};base64,${fileBuffer.toString('base64')}`;
    } catch (error) {
        logger.warn('Failed to load diagnostic center letterhead image', {
            relativePath,
            error: error.message
        });
        return null;
    }
}

// Helper to unwrap mysql2/promise results
function unwrapRows(result) {
    return Array.isArray(result) && result.length === 2 && Array.isArray(result[0]) ? result[0] : result;
}

// Fetch data (same logic, cleaner)
async function getProformaInvoiceData(appointmentId) {
    const appointmentResult = await db.query(
        `SELECT a.*, c.client_name, i.insurer_name,
                dc1.center_name, dc1.address AS center_address, dc1.city AS center_city,
                dc1.state AS center_state, dc1.pincode AS center_pincode,
                dc1.contact_number AS center_contact, dc1.email AS center_email,
                dc1.letterhead_path AS center_letterhead_path
         FROM appointments a
         LEFT JOIN clients c ON c.id = a.client_id
         LEFT JOIN insurers i ON i.id = a.insurer_id
         LEFT JOIN diagnostic_centers dc1 ON dc1.id = a.center_id
         WHERE a.id = ? LIMIT 1`,

        [appointmentId]
    );

    const rows = unwrapRows(appointmentResult);
    if (!rows?.length) return null;
    const appointment = rows[0];

    const itemsResult = await db.query(
        `SELECT 
            at.item_name,
            at.rate,
            at.rate_type,
            tc.description AS category_description
        FROM appointment_tests at
        LEFT JOIN test_categories tc ON tc.id = at.category_id
        WHERE at.appointment_id = ?
        ORDER BY at.id`,
        [appointmentId]
    );

    const items = unwrapRows(itemsResult) || [];

    const enrichedItems = items.map(item => ({
        name: safeText(item.item_name),
        description: item.rate_type === 'category' ? safeText(item.category_description) : '',
        rate: parseFloat(item.rate) || 0,
        type: item.rate_type || 'Test'
    }));

    const totalAmount = enrichedItems.reduce((sum, item) => sum + item.rate, 0);

    // Totals are based only on selected items. Any cost_type/amount is displayed separately.
    return {
        appointment,
        items: enrichedItems,
        totals: {
            totalAmount,
        },
    };
}

// Generate PDF using html-pdf-node
async function generateProformaInvoicePdfBuffer(data) {
    const { appointment, items, totals } = data;

    const invoiceNo = appointment.case_number
        ? `PI-${appointment.case_number.replace(/[^a-zA-Z0-9]/g, '')}`
        : `PI-${appointment.id}`;

    const appointmentDate = formatDate(appointment.appointment_date);
    const appointmentTime = appointment.appointment_time
        ? moment(String(appointment.appointment_time), ['HH:mm:ss', 'HH:mm']).format('hh:mm A')
        : '';
    const generatedOn = moment().format('DD/MM/YYYY HH:mm');

    const providerAddress = [appointment.center_address, appointment.center_city, appointment.center_state, appointment.center_pincode]
        .filter(Boolean)
        .join(', ');
    const providerContactParts = [];
    if (appointment.center_contact) providerContactParts.push(`Phone: ${safeText(appointment.center_contact)}`);
    if (appointment.center_email) providerContactParts.push(`Email: ${safeText(appointment.center_email)}`);
    const providerContact = providerContactParts.join(' | ');

    const patientName = `${safeText(appointment.customer_first_name || '')} ${safeText(appointment.customer_last_name || '')}`.trim() || safeText(appointment.customer_name) || '-';

    const letterheadDataUrl = await getLetterheadDataUrl(appointment.center_letterhead_path);

    const viewModel = {
        diagnosticCenterName: safeText(appointment.center_name) || 'Diagnostic Center',
        providerAddress: safeText(providerAddress),
        providerContact: safeText(providerContact),

        caseNo: safeText(appointment.case_number),
        applicationNo: safeText(appointment.application_number),
        date: safeText(appointmentDate),
        time: safeText(appointmentTime),
        clientName: safeText(appointment.client_name) || '-',
        tpaName: safeText(appointment.insurer_name),
        costType: safeText(appointment.cost_type),
        costAmount: appointment.amount != null && appointment.amount !== '' ? formatCurrency(appointment.amount) : '',
        patientName,
        patientMobile: safeText(appointment.customer_mobile),
        visitType: safeText(appointment.visit_type),
        letterheadDataUrl,
        items: (items || []).map((it, idx) => ({
            sr: idx + 1,

            description: safeText(it.name),
            subDescription: safeText(it.description),
            type: safeText(it.type).toUpperCase(),
            rate: formatCurrency(it.rate),
        })),
        total: formatCurrency(totals.totalAmount),
        generatedOn,
    };

    const htmlTemplate = `<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8" />
  <style>
    @page { size: A4; margin: 12mm 16mm 16mm 16mm; }
    body { font-family: Arial, Helvetica, sans-serif; font-size: 12px; color: #000; padding-top: 4px; }

    .title { text-align: center; font-size: 20px; font-weight: 700; margin: 0 0 10px 0; }
    .muted { color: #444; }
    .subdesc { font-size: 10px; color: #444; margin-top: 2px; }

    table { border-collapse: collapse; width: 100%; table-layout: fixed; }
    th, td { border: 1px solid #000; padding: 6px 8px; vertical-align: top; word-break: break-word; }
    th { background: #f2f2f2; font-weight: 700; }

    .grid td { height: 18px; }
    .label { width: 35%; font-weight: 700; }
    .value { width: 65%; }

    .right { text-align: right; }
    .center { text-align: center; }

    .section { margin-top: 10px; }
    .letterhead { margin: 4px 0 14px; }
    .letterhead img { width: 100%; height: 120px; object-fit: cover; display: block;  }

    .items thead { display: table-header-group; }
    .items tfoot { display: table-footer-group; }
    .items tr { page-break-inside: avoid; }

    .totals { width: 45%; margin-left: auto; }
    .footer { margin-top: 10px; font-size: 10px; text-align: center; }

    @page {
  size: A4;
  margin: 16mm;
  margin-bottom: 30mm; /* reserve space for footer */
}

.footer {
  position: fixed;
  bottom: 10mm;
  left: 16mm;
  right: 16mm;
  font-size: 10px;
  text-align: center;
}

  </style>
</head>
<body>

  {{#if letterheadDataUrl}}
  <div class="letterhead">
    <img src="{{letterheadDataUrl}}" alt="Diagnostic Center Letterhead" />
  </div>
  {{/if}}

  <div class="title">PROFORMA INVOICE</div>

  <table class="grid">
    <colgroup>
      <col style="width: 60%" />
      <col style="width: 40%" />
    </colgroup>
    <tr>
      <th>Assigned Diagnostic Center</th>
      <th>Details</th>
    </tr>
    <tr>
      <td>
        <div><b>{{diagnosticCenterName}}</b></div>
        <div class="muted">{{providerAddress}}</div>
        <div class="muted">{{providerContact}}</div>
      </td>
      <td>
        <table class="grid">
          <tr><td class="label">Case No</td><td class="value">{{caseNo}}</td></tr>
          <tr><td class="label">Application No</td><td class="value">{{applicationNo}}</td></tr>
          <tr><td class="label">Date</td><td class="value">{{date}}</td></tr>
          <tr><td class="label">Time</td><td class="value">{{time}}</td></tr>
        </table>
      </td>
    </tr>
  </table>

  <div class="section"></div>

  <table class="grid">
    <colgroup>
      <col style="width: 50%" />
      <col style="width: 50%" />
    </colgroup>
    <tr>
      <th>Client / TPA</th>
      <th>Patient / Appointment</th>
    </tr>
    <tr>
      <td>
        <table class="grid">
          <tr><td class="label">Client</td><td class="value">{{clientName}}</td></tr>
          <tr><td class="label">TPA</td><td class="value">{{tpaName}}</td></tr>
          <tr><td class="label">Cost Type</td><td class="value">{{costType}}</td></tr>
          {{#if costAmount}}
          <tr><td class="label">Cost Amount</td><td class="value">{{costAmount}}</td></tr>
          {{/if}}
        </table>
      </td>
      <td>
        <table class="grid">
          <tr><td class="label">Name</td><td class="value">{{patientName}}</td></tr>
          <tr><td class="label">Mobile</td><td class="value">{{patientMobile}}</td></tr>
          <tr><td class="label">Visit Type</td><td class="value">{{visitType}}</td></tr>
          <tr><td class="label">Date</td><td class="value">{{date}}</td></tr>
          <tr><td class="label">Time</td><td class="value">{{time}}</td></tr>
        </table>
      </td>
    </tr>
  </table>

  <div class="section"></div>

  <table class="items">
    <colgroup>
      <col style="width: 6%" />
      <col style="width: 62%" />
      <col style="width: 12%" />
      <col style="width: 20%" />
    </colgroup>
    <thead>
      <tr>
        <th class="center">#</th>
        <th>Description</th>
        <th class="center">Type</th>
        <th class="right">Rate</th>
      </tr>
    </thead>
    <tbody>
      {{#each items}}
      <tr>
        <td class="center">{{sr}}</td>
        <td>
          <div>{{description}}</div>
          {{#if subDescription}}
          <div class="subdesc">{{subDescription}}</div>
          {{/if}}
        </td>
        <td class="center">{{type}}</td>
        <td class="right">{{rate}}</td>
      </tr>
      {{/each}}
    </tbody>
  </table>

  <div class="section"></div>

  <table class="totals grid">
    <tr><th colspan="2">Summary</th></tr>
    <tr><td class="label"><b>Total</b></td><td class="right"><b>{{total}}</b></td></tr>
  </table>

  <div class="footer">
  <div>Note: This is a proforma invoice for estimation purposes. Final bill may vary upon confirmation.</div>
  <div class="muted">Generated on: {{generatedOn}}</div>
</div>


</body>
</html>`;

    const compiled = Handlebars.compile(htmlTemplate, { noEscape: true });
    const html = compiled(viewModel);

    const file = { content: html };
    const options = {
        format: 'A4',
        printBackground: true,
        margin: {
            top: '16mm',
            right: '16mm',
            bottom: '16mm',
            left: '16mm',
        },
    };

    return htmlToPdf.generatePdf(file, options);
}

async function generateProformaInvoicePdf(appointmentId) {
    const data = await getProformaInvoiceData(appointmentId);
    if (!data) return null;

    const pdfBuffer = await generateProformaInvoicePdfBuffer(data);
    return { pdfBuffer, invoiceData: data };
}

module.exports = {
    generateProformaInvoicePdf,
    getProformaInvoiceData
};