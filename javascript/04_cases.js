'use strict';
/**
 * Step 4: Full CRUD operations on Salesforce Cases.
 *
 * Creates a temporary Account and Contact to link the Case to, then cleans up all three.
 *
 * Run with:
 *   node 04_cases.js
 */

const { getConnection } = require('./auth');

async function main() {
    const conn = await getConnection();
    const timestamp = new Date().toISOString().replace(/[:.]/g, '-');

    console.log('--- Case CRUD ---');

    // Create parent Account and Contact
    console.log('Setup: Creating parent Account and Contact...');
    const accountResult = await conn.sobject('Account').create({ Name: `Acme Corp ${timestamp}` });
    const accountId = accountResult.id;

    const contactResult = await conn.sobject('Contact').create({
        LastName: `Smith ${timestamp}`,
        AccountId: accountId,
    });
    const contactId = contactResult.id;
    console.log(`  Account: ${accountId}`);
    console.log(`  Contact: ${contactId}`);

    // CREATE
    console.log('CREATE:');
    const createResult = await conn.sobject('Case').create({
        Subject: `Login button not working on mobile ${timestamp}`,   // Subject is required
        Status: 'New',
        Priority: 'High',
        Origin: 'Web',
        AccountId: accountId,
        ContactId: contactId,
        Description: 'Customer reports the login button on the mobile app does not respond when tapped on iOS 17.',
    });
    const caseId = createResult.id;
    console.log(`  Created Case: ${caseId}`);

    // READ
    console.log('READ:');
    const sfCase = await conn.sobject('Case').retrieve(caseId);
    console.log(`  Subject: ${sfCase.Subject}`);
    console.log(`  Status: ${sfCase.Status}, Priority: ${sfCase.Priority}`);

    // UPDATE
    console.log('UPDATE:');
    await conn.sobject('Case').update({ Id: caseId, Status: 'Working' });
    const updated = await conn.sobject('Case').retrieve(caseId);
    console.log(`  Updated Case: Status is now ${updated.Status}`);

    // DELETE
    console.log('DELETE:');
    await conn.sobject('Case').destroy(caseId);
    console.log(`  Deleted Case: ${caseId}`);

    // Cleanup
    console.log('Cleanup: Deleting Contact and Account...');
    await conn.sobject('Contact').destroy(contactId);
    await conn.sobject('Account').destroy(accountId);
    console.log('  Cleanup complete.');

    console.log('Done.');
}

main().catch(err => {
    console.error('Error:', err.message);
    process.exit(1);
});
