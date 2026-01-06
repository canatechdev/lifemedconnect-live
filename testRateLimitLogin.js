const axios = require('axios');
require('dotenv').config();

const BASE_URL = 'http://localhost:5050';
const LOGIN_URL = `${BASE_URL}/api/auth/login`;
const CSRF_URL = `${BASE_URL}/api/csrf-token`;

async function getCsrfTokenAndCookie() {
    const res = await axios.get(CSRF_URL, {
        validateStatus: () => true,
    });

    // CSRF token from body
    const csrfToken = res.data?.csrfToken;

    // CSRF cookie from headers
    const setCookie = res.headers['set-cookie'];
    // e.g. [ '_csrf=abc123; Path=/; HttpOnly; SameSite=Strict' ]
    const cookieHeader = Array.isArray(setCookie) ? setCookie.join('; ') : '';

    return { csrfToken, cookieHeader };
}

async function testRateLimitLogin() {
    const { csrfToken, cookieHeader } = await getCsrfTokenAndCookie();

    if (!csrfToken || !cookieHeader) {
        console.error('Failed to obtain CSRF token or cookie:', {
            csrfToken,
            cookieHeader,
        });
        return;
    }

    const attempts = 15;
    console.log('Testing login rate limit on:', LOGIN_URL);
    console.log(`Sending ${attempts} failed login attempts...\n`);

    for (let i = 1; i <= attempts; i++) {
        const res = await axios.post(
            LOGIN_URL,
            { username: 'wrong_user', password: 'wrong_password' },
            {
                headers: {
                    'X-CSRF-Token': csrfToken,
                    // IMPORTANT: send back the CSRF cookie
                    Cookie: cookieHeader,
                },
                validateStatus: () => true,
            }
        );

        console.log(
            `Attempt ${i}: status=${res.status}, message=${res.data?.message || ''}`
        );

        if (res.status === 429) {
            console.log('\n Rate limit triggered as expected.');
            break;
        }
    }

    console.log('\nLogin rate limit test finished.');
}

testRateLimitLogin().catch(console.error);