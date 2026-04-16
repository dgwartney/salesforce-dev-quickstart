'use strict';
/**
 * Shared Salesforce connection helper.
 *
 * Usage:
 *   const { getConnection } = require('./auth');
 *   const conn = await getConnection();
 *
 * Note: jsforce requires manual concatenation of password + security token.
 * This is the opposite of Python's simple-salesforce, which handles it internally.
 */

require('dotenv').config({ path: '../.env' });
// Also try loading from the current directory (if running from javascript/)
require('dotenv').config();

const jsforce = require('jsforce');

async function getConnection() {
    const required = [
        'SF_USERNAME',
        'SF_PASSWORD',
        'SF_SECURITY_TOKEN',
        'SF_INSTANCE_URL',
    ];
    const missing = required.filter(v => !process.env[v]);
    if (missing.length > 0) {
        throw new Error(
            `Missing required environment variables: ${missing.join(', ')}\n` +
            'Copy .env.example to .env and fill in all values.'
        );
    }

    const conn = new jsforce.Connection({
        loginUrl: process.env.SF_INSTANCE_URL || 'https://login.salesforce.com',
    });

    // jsforce requires password + security_token concatenated (no separator)
    await conn.login(
        process.env.SF_USERNAME,
        process.env.SF_PASSWORD + process.env.SF_SECURITY_TOKEN
    );

    return conn;
}

module.exports = { getConnection };
