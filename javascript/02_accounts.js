'use strict';
/**
 * Step 2: Full CRUD operations on Salesforce Accounts.
 *
 * Run with:
 *   node 02_accounts.js
 */

const { getConnection } = require('./auth');

async function main() {
    const conn = await getConnection();
    const timestamp = new Date().toISOString().replace(/[:.]/g, '-');

    console.log('--- Account CRUD ---');

    // CREATE
    console.log('CREATE:');
    const createResult = await conn.sobject('Account').create({
        Name: `Test Corp ${timestamp}`,
        Phone: '(555) 999-0001',
        Industry: 'Technology',
    });
    const accountId = createResult.id;
    console.log(`  Created Account: ${accountId}`);

    // READ
    console.log('READ:');
    const account = await conn.sobject('Account').retrieve(accountId);
    console.log(`  Name: ${account.Name}, Phone: ${account.Phone}, Industry: ${account.Industry}`);

    // UPDATE
    console.log('UPDATE:');
    await conn.sobject('Account').update({ Id: accountId, Phone: '(555) 999-0002' });
    const updated = await conn.sobject('Account').retrieve(accountId);
    console.log(`  Updated Account: Phone is now ${updated.Phone}`);

    // DELETE — jsforce uses .destroy(), NOT .delete()
    console.log('DELETE:');
    await conn.sobject('Account').destroy(accountId);
    console.log(`  Deleted Account: ${accountId}`);

    console.log('Done.');
}

main().catch(err => {
    console.error('Error:', err.message);
    process.exit(1);
});
