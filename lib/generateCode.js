/**
 * Custom code generation utility
 * Generates sequential codes in format: PREFIX/MM/NNNN
 * Example: CASE/08/0001, CASE/08/0002, etc.
 */
const db = require('../lib/dbconnection');

/**
 * Generate a custom sequential code
 * @param {Object} params - Parameters object
 * @param {string} params.prefix - Code prefix (e.g., 'CASE', 'INV')
 * @param {string} params.table - Database table name
 * @param {string} params.column - Column name containing the code
 * @returns {Promise<string>} Generated code in format PREFIX/MM/NNNN
 */
async function generateCustomCode({ prefix, table, column }) {
    if (!prefix || !table || !column) {
        throw new Error('Missing required parameters: prefix, table, or column');
    }

    const now = new Date();
    const month = String(now.getMonth() + 1).padStart(2, '0');
    const likePattern = `${prefix}/${month}/%`;

    const sql = `
        SELECT ${column}
        FROM ${table}
        WHERE ${column} LIKE ? AND is_deleted = 0
        ORDER BY id DESC
        LIMIT 1
    `;

    const rows = await db.query(sql, [likePattern]);

    let nextNumber = 1;

    if (rows.length > 0) {
        const lastCode = rows[0][column];
        const parts = lastCode.split('/');
        const lastNum = parseInt(parts[2], 10);
        if (!isNaN(lastNum)) {
            nextNumber = lastNum + 1;
        }
    }

    const paddedNumber = String(nextNumber).padStart(4, '0');
    const generatedCode = `${prefix}/${month}/${paddedNumber}`;

    return generatedCode;
}

module.exports = { generateCustomCode };
