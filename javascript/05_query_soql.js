'use strict';
/**
 * Step 5: SOQL queries using jsforce.
 *
 * Demonstrates conn.query() (up to 2000 records) and conn.queryAll() (full pagination),
 * plus relationship queries across objects.
 *
 * Run with:
 *   node 05_query_soql.js
 */

const { getConnection } = require('./auth');

async function queryAccounts(conn) {
    console.log('--- Query: Accounts (LIMIT 10) ---');
    const result = await conn.query(
        'SELECT Id, Name, Phone, Industry FROM Account LIMIT 10'
    );
    console.log(`  Records returned: ${result.records.length} of ${result.totalSize} total`);
    result.records.forEach(r => {
        console.log(`  ${r.Id} | ${r.Name} | ${r.Industry || 'N/A'}`);
    });
}

async function queryContactsWithAccount(conn) {
    console.log('--- Query: Contacts with Account name (relationship query) ---');
    const result = await conn.query(
        'SELECT Id, FirstName, LastName, Email, Account.Name FROM Contact LIMIT 10'
    );
    console.log(`  Records returned: ${result.records.length}`);
    result.records.forEach(r => {
        const name = [r.FirstName, r.LastName].filter(Boolean).join(' ');
        const accountName = r.Account ? r.Account.Name : 'No Account';
        console.log(`  ${name} | ${r.Email || 'N/A'} | Account: ${accountName}`);
    });
}

async function queryOpenCases(conn) {
    console.log('--- Query: Open Cases ---');
    const result = await conn.query(
        "SELECT Id, Subject, Status, Priority, Account.Name FROM Case WHERE Status != 'Closed' LIMIT 10"
    );
    console.log(`  Open cases: ${result.records.length}`);
    result.records.forEach(r => {
        const accountName = r.Account ? r.Account.Name : 'No Account';
        console.log(`  [${r.Priority}] ${r.Subject} | ${r.Status} | ${accountName}`);
    });
}

async function queryAllAccounts(conn) {
    console.log('--- Query All: Accounts (handles pagination automatically) ---');
    // queryAll() follows nextRecordsUrl automatically until all records are retrieved.
    // Use this when you expect more than 2,000 records.
    const result = await conn.queryAll('SELECT Id, Name FROM Account');
    console.log(`  Total accounts in org: ${result.totalSize}`);
    console.log(`  Records retrieved: ${result.records.length}`);
}

async function main() {
    const conn = await getConnection();

    await queryAccounts(conn);
    console.log();
    await queryContactsWithAccount(conn);
    console.log();
    await queryOpenCases(conn);
    console.log();
    await queryAllAccounts(conn);

    console.log('\nDone.');
}

main().catch(err => {
    console.error('Error:', err.message);
    process.exit(1);
});
