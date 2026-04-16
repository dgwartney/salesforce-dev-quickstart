'use strict';
/**
 * Step 1: Verify authentication with Salesforce.
 *
 * Run with:
 *   node 01_authenticate.js
 */

const { getConnection } = require('./auth');

async function main() {
    console.log('Connecting to Salesforce...');
    const conn = await getConnection();

    // conn.instanceUrl contains the org's base URL
    // conn.userInfo contains the authenticated user's details
    const userInfo = conn.userInfo;
    console.log(`Connected to Salesforce org: ${userInfo.organizationId}`);
    console.log(`Instance URL: ${conn.instanceUrl}`);
    console.log(`Authenticated as user: ${userInfo.id}`);
    console.log('Authentication successful.');
}

main().catch(err => {
    console.error('Authentication failed:', err.message);
    process.exit(1);
});
