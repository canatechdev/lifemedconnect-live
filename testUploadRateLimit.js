require('dotenv').config();
const axios = require('axios');
const FormData = require('form-data');
const { generateToken } = require('./lib/auth');

const BASE_URL = 'http://localhost:5050';
const UPLOAD_URL = `${BASE_URL}/api/test-bulk/upload`;

async function makeDummyForm() {
    const form = new FormData();
    // Field name must match excelUpload.single('excelFile')
    form.append('excelFile', Buffer.from('dummy content'), {
        filename: 'dummy.xlsx',
        contentType:
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    });
    return form;
}

async function testUploadRateLimit() {
    // Generate a valid JWT (verifyToken only checks signature, not DB)
    const user = { id: 1, role_id: 1 };
    const token = generateToken(user);

    const attempts = 40;
    console.log('Testing upload rate limit on:', UPLOAD_URL);
    console.log(`Sending ${attempts} upload attempts...\n`);

    for (let i = 1; i <= attempts; i++) {
        const form = await makeDummyForm();
        const headers = {
            ...form.getHeaders(),
            Authorization: `Bearer ${token}`,
        };

        const res = await axios.post(UPLOAD_URL, form, {
            headers,
            validateStatus: () => true,
        });

        console.log(
            `Attempt ${i}: status=${res.status}, message=${res.data?.message || ''}`
        );

        if (res.status === 429) {
            console.log('\n Upload rate limit triggered as expected.');
            break;
        }
    }

    console.log('\nUpload rate limit test finished.');
}

testUploadRateLimit().catch(console.error);