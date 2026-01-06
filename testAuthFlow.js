require('dotenv').config();

const {
    hashPassword,
    comparePassword,
    generateToken,
} = require('./lib/auth')
const jwt = require('jsonwebtoken')

async function main() {
    const plainPassword = 'MyTestPassword123!'
    const wrongPassword = 'WrongPassword!'

    console.log('--- PASSWORD HASH TEST ---')
    console.log('Plain password:', plainPassword)

    const hashed = await hashPassword(plainPassword)
    console.log('Hashed password:', hashed)

    const isCorrect = await comparePassword(plainPassword, hashed)
    const isWrong = await comparePassword(wrongPassword, hashed)

    console.log('Compare correct password =>', isCorrect)
    console.log('Compare wrong password   =>', isWrong)

    console.log('\n--- JWT TOKEN TEST ---')
    const user = {
        id: 2,
        role_id: 1,
        diagnostic_center_id: 10, // adjust if you want
    }

    const token = generateToken(user)
    console.log('Token:', token)

    const decoded = jwt.decode(token)
    console.log('Decoded payload:', decoded)
    console.log('Expires at (epoch seconds):', decoded.exp)
    console.log('Current time (epoch seconds):', Math.floor(Date.now() / 1000))
}

main()
    .then(() => {
        console.log('\nAuth flow test completed.')
        process.exit(0)
    })
    .catch((err) => {
        console.error('Auth flow test error:', err)
        process.exit(1)
    })