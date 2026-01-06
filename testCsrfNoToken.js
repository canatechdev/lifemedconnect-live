const axios = require('axios');

const BASE_URL = 'http://localhost:5050';
const LOGIN_URL = `${BASE_URL}/api/auth/login`;

async function testCsrfNoToken() {
    console.log('Testing CSRF protection on:', LOGIN_URL);

    const res = await axios.post(
        LOGIN_URL,
        { username: 'wrong_user', password: 'wrong_password' },
        {
            // IMPORTANT: no X-CSRF-Token and no Cookie on purpose
            validateStatus: () => true,
        }
    );

    console.log('Status:', res.status);
    console.log('Response:', res.data);

    if (res.status === 403) {
        console.log('\n CSRF protection works (403 without token).');
    } else {
        console.log('\n Unexpected status, expected 403.');
    }
}

testCsrfNoToken().catch(console.error);