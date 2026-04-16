/**
 * Step 6: Typed SOQL queries using TypeScript.
 *
 * Demonstrates interface definitions for Salesforce records and typed query results.
 * Uses CommonJS require() via ts-node — no "type": "module" needed.
 *
 * Run with:
 *   npx ts-node 06_query_soql.ts
 */

require('dotenv').config({ path: '../.env' });
require('dotenv').config();

const jsforce = require('jsforce');

// TypeScript interfaces for Salesforce record shapes

interface Account {
    Id: string;
    Name: string;
    Phone: string | null;
    Industry: string | null;
}

interface Contact {
    Id: string;
    FirstName: string | null;
    LastName: string;
    Email: string | null;
    Account: { Name: string } | null;
}

interface Case {
    Id: string;
    Subject: string;
    Status: string;
    Priority: string;
    Account: { Name: string } | null;
}

interface QueryResult<T> {
    totalSize: number;
    done: boolean;
    records: T[];
}

async function queryAccounts(conn: typeof jsforce.Connection.prototype): Promise<void> {
    console.log('--- Typed Query: Accounts ---');
    const result: QueryResult<Account> = await conn.query(
        'SELECT Id, Name, Phone, Industry FROM Account LIMIT 10'
    );
    console.log(`  Total: ${result.totalSize}, Retrieved: ${result.records.length}`);
    result.records.forEach((account: Account) => {
        console.log(`  ${account.Name} | Industry: ${account.Industry ?? 'N/A'} | Phone: ${account.Phone ?? 'N/A'}`);
    });
}

async function queryContacts(conn: typeof jsforce.Connection.prototype): Promise<void> {
    console.log('--- Typed Query: Contacts with Account name ---');
    const result: QueryResult<Contact> = await conn.query(
        'SELECT Id, FirstName, LastName, Email, Account.Name FROM Contact LIMIT 10'
    );
    result.records.forEach((contact: Contact) => {
        const name = [contact.FirstName, contact.LastName].filter(Boolean).join(' ');
        const accountName = contact.Account?.Name ?? 'No Account';
        console.log(`  ${name} | ${contact.Email ?? 'N/A'} | Account: ${accountName}`);
    });
}

async function queryCases(conn: typeof jsforce.Connection.prototype): Promise<void> {
    console.log('--- Typed Query: Open Cases ---');
    const result: QueryResult<Case> = await conn.query(
        "SELECT Id, Subject, Status, Priority, Account.Name FROM Case WHERE Status != 'Closed' LIMIT 10"
    );
    console.log(`  Open cases: ${result.records.length}`);
    result.records.forEach((sfCase: Case) => {
        const accountName = sfCase.Account?.Name ?? 'No Account';
        console.log(`  [${sfCase.Priority}] ${sfCase.Subject} | ${sfCase.Status} | ${accountName}`);
    });
}

async function main(): Promise<void> {
    const conn = new jsforce.Connection({
        loginUrl: process.env.SF_INSTANCE_URL || 'https://login.salesforce.com',
    });

    await conn.login(
        process.env.SF_USERNAME as string,
        (process.env.SF_PASSWORD as string) + (process.env.SF_SECURITY_TOKEN as string)
    );

    console.log(`Connected: ${conn.instanceUrl}`);
    console.log();

    await queryAccounts(conn);
    console.log();
    await queryContacts(conn);
    console.log();
    await queryCases(conn);

    console.log('\nDone.');
}

main().catch((err: Error) => {
    console.error('Error:', err.message);
    process.exit(1);
});
