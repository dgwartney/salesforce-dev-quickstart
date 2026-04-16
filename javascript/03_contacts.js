'use strict';
/**
 * Step 3: Full CRUD operations on Salesforce Contacts.
 *
 * Creates a temporary Account to link the Contact to, then cleans up both.
 *
 * Run with:
 *   node 03_contacts.js
 */

const { getConnection } = require('./auth');

async function main() {
    const conn = await getConnection();
    const timestamp = new Date().toISOString().replace(/[:.]/g, '-');

    console.log('--- Contact CRUD ---');

    // Create a parent Account first
    console.log('Setup: Creating parent Account...');
    const accountResult = await conn.sobject('Account').create({ Name: `Acme Corp ${timestamp}` });
    const accountId = accountResult.id;
    console.log(`  Parent Account: ${accountId}`);

    // CREATE
    console.log('CREATE:');
    const createResult = await conn.sobject('Contact').create({
        FirstName: 'Jane',
        LastName: `Smith ${timestamp}`,     // LastName is required
        AccountId: accountId,
        Email: 'jane.smith@acme.example.com',
        Phone: '(555) 100-0002',
    });
    const contactId = createResult.id;
    console.log(`  Created Contact: ${contactId}`);

    // READ
    console.log('READ:');
    const contact = await conn.sobject('Contact').retrieve(contactId);
    console.log(`  Contact: ${contact.FirstName} ${contact.LastName}`);
    console.log(`  Email: ${contact.Email}, AccountId: ${contact.AccountId}`);

    // UPDATE
    console.log('UPDATE:');
    await conn.sobject('Contact').update({ Id: contactId, Phone: '(555) 100-0099' });
    const updated = await conn.sobject('Contact').retrieve(contactId);
    console.log(`  Updated Contact: Phone is now ${updated.Phone}`);

    // DELETE
    console.log('DELETE:');
    await conn.sobject('Contact').destroy(contactId);
    console.log(`  Deleted Contact: ${contactId}`);

    // Cleanup
    console.log('Cleanup: Deleting parent Account...');
    await conn.sobject('Account').destroy(accountId);
    console.log(`  Deleted Account: ${accountId}`);

    console.log('Done.');
}

main().catch(err => {
    console.error('Error:', err.message);
    process.exit(1);
});
