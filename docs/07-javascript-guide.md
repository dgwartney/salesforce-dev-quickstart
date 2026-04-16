# Step 7: Salesforce REST API with JavaScript/TypeScript

**Time:** ~45 minutes  
**What you will have when done:** Working JavaScript scripts that authenticate with Salesforce and perform CRUD operations on Accounts, Contacts, and Cases using the `jsforce` SDK. Includes a TypeScript variant.

---

## Before You Start

1. Your `.env` file must be fully populated — see [Step 3](03-connected-app.md).
2. Node.js 18+ and npm must be installed — see [Step 0](00-required-tools.md).
3. You should have at least one Account, Contact, and Case from [Step 4](04-ui-walkthrough.md).

---

## Setup: Install Dependencies

```bash
cd javascript/
npm install
```

This installs `jsforce`, `dotenv`, `typescript`, `ts-node`, and `@types/node`.

**Verify installation:**
```bash
node -e "const jsforce = require('jsforce'); console.log('OK')"
```

---

## CommonJS vs ESM — Important Note

All examples in this directory use **CommonJS** (`require()`). The `package.json` deliberately does NOT include `"type": "module"`.

**Why:** `jsforce` ships as CommonJS only. Adding `"type": "module"` to `package.json` causes module interop errors that are confusing for beginners. CommonJS with `require()` is simpler and more reliable for this tutorial.

If you need ESM for your own project, use dynamic `import()` or a bundler — but for these learning scripts, `require()` is the right choice.

---

## Step 7.1: Authenticate

```bash
node 01_authenticate.js
```

Expected output:
```
Connected to Salesforce org: 00D...
Instance URL: https://yourorg.my.salesforce.com
```

### How Authentication Works

The shared helper in `auth.js`:

```javascript
require('dotenv').config();
const jsforce = require('jsforce');

async function getConnection() {
    const conn = new jsforce.Connection({
        loginUrl: process.env.SF_INSTANCE_URL || 'https://login.salesforce.com'
    });
    await conn.login(
        process.env.SF_USERNAME,
        process.env.SF_PASSWORD + process.env.SF_SECURITY_TOKEN
    );
    return conn;
}

module.exports = { getConnection };
```

> **Important:** Unlike Python's `simple-salesforce`, jsforce requires you to manually concatenate the password and security token. `SF_PASSWORD + SF_SECURITY_TOKEN` — no separator between them.

> **Deprecation note:** `conn.login()` uses the SOAP login API, which Salesforce is deprecating in Summer '27 (API v65.0). It still works today. When you are ready to migrate, switch to OAuth 2.0 flows — see [jsforce docs](https://jsforce.github.io/document/).

---

## Step 7.2: CRUD on Accounts

```bash
node 02_accounts.js
```

### What the script does

**CREATE** — `conn.sobject('Account').create()`
```javascript
const result = await conn.sobject('Account').create({
    Name: 'Test Corp',
    Phone: '(555) 999-0001',
    Industry: 'Technology'
});
const accountId = result.id;
console.log('Created:', accountId);
// result: { id: '001...', success: true, created: true }
```

**READ** — `conn.sobject('Account').retrieve()`
```javascript
const account = await conn.sobject('Account').retrieve(accountId);
console.log('Name:', account.Name, 'Phone:', account.Phone);
```

**UPDATE** — `conn.sobject('Account').update()`
```javascript
await conn.sobject('Account').update({
    Id: accountId,
    Phone: '(555) 999-0002'
});
// Returns { id: '001...', success: true }
```

**DELETE** — `conn.sobject('Account').destroy()`
```javascript
await conn.sobject('Account').destroy(accountId);
// Note: use .destroy() — jsforce does NOT use .delete()
```

> **Gotcha:** jsforce uses `.destroy()` for DELETE operations, not `.delete()`. `.delete()` does not exist on sobject.

---

## Step 7.3: CRUD on Contacts and Cases

```bash
node 03_contacts.js
node 04_cases.js
```

**Contact linked to an Account:**
```javascript
const result = await conn.sobject('Contact').create({
    FirstName: 'Jane',
    LastName: 'Smith',           // required
    AccountId: accountId,        // link to Account
    Email: 'jane.smith@acme.example.com'
});
```

**Case linked to Account and Contact:**
```javascript
const result = await conn.sobject('Case').create({
    Subject: 'Login issue on mobile',   // required
    Status: 'New',
    Priority: 'High',
    AccountId: accountId,
    ContactId: contactId
});
```

---

## Step 7.4: SOQL Queries

```bash
node 05_query_soql.js
```

### `conn.query()` — up to 2,000 records

```javascript
const result = await conn.query(
    'SELECT Id, Name, Phone FROM Account LIMIT 10'
);
result.records.forEach(r => {
    console.log(r.Name, r.Phone);
});
```

> **Remember:** `SELECT * FROM Account` is not valid SOQL. You must list fields explicitly.

### `conn.queryAll()` — all records (handles pagination)

```javascript
const result = await conn.queryAll(
    'SELECT Id, Name FROM Account'
);
console.log('Total:', result.totalSize);
result.records.forEach(r => console.log(r.Id, r.Name));
```

Use `queryAll()` when you expect more than 2,000 records. It follows all pagination pages automatically.

### Streaming large result sets

```javascript
conn.query('SELECT Id, Name FROM Account')
    .on('record', record => {
        console.log(record.Name);
    })
    .on('end', () => console.log('Done'))
    .on('error', err => console.error(err))
    .run({ autoFetch: true, maxFetch: 10000 });
```

### Relationship query (cross-object)

```javascript
const result = await conn.query(
    'SELECT Id, LastName, Account.Name FROM Contact LIMIT 10'
);
result.records.forEach(c => {
    console.log(c.LastName, '→', c.Account.Name);
});
```

---

## Step 7.5: TypeScript Variant

```bash
npx ts-node 06_query_soql.ts
```

The TypeScript file demonstrates typed queries using interfaces:

```typescript
require('dotenv').config();
const jsforce = require('jsforce');

interface Account {
    Id: string;
    Name: string;
    Phone: string | null;
    Industry: string | null;
}

interface QueryResult {
    totalSize: number;
    done: boolean;
    records: Account[];
}

async function queryAccounts(): Promise<void> {
    const conn = new jsforce.Connection({
        loginUrl: process.env.SF_INSTANCE_URL
    });
    await conn.login(
        process.env.SF_USERNAME as string,
        (process.env.SF_PASSWORD as string) + (process.env.SF_SECURITY_TOKEN as string)
    );

    const result: QueryResult = await conn.query(
        'SELECT Id, Name, Phone, Industry FROM Account LIMIT 10'
    );
    result.records.forEach((account: Account) => {
        console.log(`${account.Name} | ${account.Industry ?? 'N/A'}`);
    });
}

queryAccounts().catch(console.error);
```

**Note:** TypeScript files use `require()` (CommonJS) via ts-node's CommonJS mode. This works because `tsconfig.json` targets CommonJS module output and `package.json` has no `"type": "module"`. You do not need `import` syntax.

---

## Running All Scripts

```bash
cd javascript/
node 01_authenticate.js
node 02_accounts.js
node 03_contacts.js
node 04_cases.js
node 05_query_soql.js
npx ts-node 06_query_soql.ts
```

---

## When to Use `@salesforce/core` Instead

This guide uses `jsforce` directly, which is best for:
- General scripting and automation
- Non-DX projects
- Simple REST API access from Node.js

If you are building Salesforce DX plugins, scratch org automation, or CLI tooling, consider `@salesforce/core`:
- GitHub: <https://github.com/forcedotcom/sfdx-core>
- It uses `jsforce` internally but adds org management, config files, and DX-specific features

For this guide, `jsforce` is the right choice.

---

**Navigation:** [← Python Guide](06-python-guide.md) | [README](../README.md) | [Next → Troubleshooting →](08-troubleshooting.md)

**Official Reference:**
- jsforce docs: <https://jsforce.github.io/document/>
- jsforce GitHub: <https://github.com/jsforce/jsforce>
- jsforce SOAP login deprecation: <https://developer.salesforce.com/blogs/2022/11/oauth-2-0-client-credentials-flow-on-the-salesforce-platform>
