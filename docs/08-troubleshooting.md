# Troubleshooting

This is a reference document — come here when something is not working. Organized by error category with specific error messages, root causes, and fixes.

---

## Section 1: Authentication Errors

These are the most common errors for new users.

### `invalid_grant`

The most frequent beginner error. Has multiple root causes — work through them in order:

**Root cause 1 — "Allow OAuth Username-Password Flows" not enabled (most likely)**

All Salesforce orgs created Summer 2023 or later have this flow **disabled by default**.

Fix:
1. Log in as your Admin user (User A)
2. Setup → search Quick Find for `OAuth`
3. Click **OAuth and OpenID Connect Settings**
4. Toggle **"Allow OAuth Username-Password Flows"** to ON
5. Click **Save**
6. Try authenticating again

**Root cause 2 — Connected App "Permitted Users" not set correctly**

Fix: Setup → App Manager → find your app → dropdown → Manage → Edit Policies → Permitted Users = `All users may self-authorize` → Save

**Root cause 3 — Security token missing or wrong**

- curl and JavaScript: you must append the security token directly to the password: `"password=${SF_PASSWORD}${SF_SECURITY_TOKEN}"` — no space, no separator
- Python `simple-salesforce`: do NOT append the token; pass it as the separate `security_token=` parameter
- Reset your token: user avatar → Settings → Quick Find: `Reset My Security Token` → check email

**Root cause 4 — Connected App created less than 10 minutes ago**

New Connected Apps take 2–10 minutes to activate across Salesforce's infrastructure. Wait the full 10 minutes and try again.

**Root cause 5 — Special characters in password**

Salesforce recommends using alphanumeric passwords for API access. Special characters in passwords can cause URL-encoding issues in the `grant_type=password` flow. Change your password to alphanumeric only if this is suspected.

**Root cause 6 — Wrong login endpoint**

- Use `https://login.salesforce.com` for production and Developer Edition orgs
- Use `https://test.salesforce.com` for sandboxes only
- Check `SF_INSTANCE_URL` in your `.env` file

**Root cause 7 — Password changed recently**

Changing your password invalidates all existing security tokens. Get a new security token: user avatar → Settings → Quick Find: `Reset My Security Token`.

**Root cause 8 — MFA (Multi-Factor Authentication) required on the account**

If your Salesforce account requires MFA (phone or authenticator app verification on login), the Username-Password OAuth flow will always fail with `invalid_grant` — there is no way to pass an MFA code through this flow.

Fix — waive MFA for API access:
1. Setup → search Quick Find for `Session Settings`
2. Click **Session Settings**
3. Under **Session Security Levels**, find your Connected App in the "High Assurance" column
4. Move it to the **Standard** column
5. Click **Save**

Alternatively, use an integration user (User B) with a Standard User profile — Standard Users typically do not have MFA enforced by default in Developer Edition orgs.

**Useful diagnostic page — Connected Apps OAuth Usage:**

Setup → Connected Apps → **Connected Apps OAuth Usage** shows all Connected Apps with:
- **User Count** — active sessions (0 means no successful authentications yet)
- **Denied Attempts Due to Usage Restriction** — non-zero means the app is actively blocking attempts
- **Last Denied Attempt** — timestamp of most recent blocked authentication

If your app shows denied attempts, the issue is a usage restriction (Permitted Users policy), not credentials.

---

### `INVALID_LOGIN: Invalid username, password, security token; or user locked out`

This is different from `invalid_grant`. The credentials themselves are literally wrong.

- Double-check `SF_USERNAME` — it must be the full username (e.g., `integration.user@yourcompany.com`), not just an email
- Verify `SF_PASSWORD` is correct (copy-paste from password manager if possible)
- **Python:** security token goes in `security_token=` parameter, NOT appended to password
- **curl/JavaScript:** security token MUST be appended to password: `${SF_PASSWORD}${SF_SECURITY_TOKEN}`

---

### `OAUTH_APP_ACCESS_DENIED` / IP restriction errors

Your user's Profile has Login IP Ranges configured, and you are accessing from outside those ranges.

Fix: Setup → App Manager → your Connected App → Manage → Edit Policies → IP Relaxation = `Relax IP restrictions` → Save

---

### `invalid_client_credentials` / `invalid_client`

- **Wrong Consumer Key:** The `client_id` in your request is not a valid Consumer Key. Check `SF_CONSUMER_KEY` in your `.env`.
- **Connected App not yet active:** Wait 2–10 minutes after creating the Connected App.
- **To find your Consumer Key again:** Setup → App Manager → your app → dropdown → View → Manage Consumer Details

---

## Section 2: API Call Errors

### `401 Unauthorized` after the token was working

Access tokens expire after 2 hours by default. Re-authenticate to get a fresh token.

- curl: `source authenticate.sh` again
- Python: call `get_salesforce_connection()` again
- JavaScript: call `getConnection()` again

---

### `404 Not Found`

- **Wrong Record ID:** Record IDs are case-sensitive. Copy from the Salesforce URL exactly.
- **Record deleted:** The record was deleted. Create a new one.
- **Wrong object API name:** Object names are case-sensitive. Use `Account` not `account`, `Case` not `case`.

---

### `400 Bad Request` / `REQUIRED_FIELD_MISSING`

You are missing a required field in your CREATE or UPDATE call.

| Object | Required Fields |
|--------|----------------|
| Account | `Name` |
| Contact | `LastName` |
| Case | `Subject` |

---

### `400 Bad Request` / `INVALID_FIELD`

A field name is wrong.

- Custom fields always end in `__c`: `Customer_Impact__c` not `Customer_Impact`
- Check the exact API name in Object Manager: Setup → Object Manager → [Object] → Fields & Relationships
- Field API names are case-sensitive: `LastName` not `lastname`

---

### `403 Forbidden` / `REQUEST_LIMIT_EXCEEDED`

You have hit the daily API call limit (approximately 15,000 per day for Developer Edition).

Check remaining quota:
```bash
curl -s "$INSTANCE_URL/services/data/v62.0/limits" \
  -H "Authorization: Bearer $ACCESS_TOKEN" | jq '.DailyApiRequests'
```

The quota resets on a rolling 24-hour basis.

---

### `STORAGE_LIMIT_EXCEEDED`

Developer Edition has 5–256 MB of data storage. You have filled it.

Fix: Delete old test records to free space. There is no upgrade path for storage in Developer Edition.

Check storage: Setup → System Overview → Storage Usage

---

### `405 Method Not Allowed`

You used the wrong HTTP method.

- Use `POST` to create (`/sobjects/Account/`)
- Use `PATCH` to update (`/sobjects/Account/{id}`)
- Use `DELETE` to delete (`/sobjects/Account/{id}`)
- Do NOT use `PUT` — Salesforce does not support PUT for record updates

---

## Section 3: SOQL Query Mistakes

### `SELECT * FROM Account` — `MALFORMED_QUERY`

`SELECT *` is not valid SOQL. You must list fields explicitly:
```sql
SELECT Id, Name, Phone, Industry FROM Account LIMIT 10
```

Use the [Object Reference](https://developer.salesforce.com/docs/atlas.en-us.object_reference.meta/object_reference/) to see all available fields for an object.

---

### Child-to-parent relationship query (dot notation)

Get the Account Name on a Contact record:
```sql
SELECT Id, LastName, Account.Name FROM Contact LIMIT 10
```

The related object's name is singular and uses dot notation.

---

### Parent-to-child subquery (plural relationship name)

Get all Contacts for each Account:
```sql
SELECT Name, (SELECT LastName FROM Contacts) FROM Account LIMIT 10
```

The child relationship name is **plural** (`Contacts`, not `Contact`). Find the relationship name in Setup → Object Manager → Account → Fields & Relationships → Contacts related list.

---

### Custom object relationship names use `__r`

```sql
SELECT Id, MyCustomObject__r.Name FROM ChildObject__c LIMIT 10
```

Custom relationship fields use `__r` (not `__c`) when traversing the relationship in SOQL.

---

### NULL comparisons use lowercase `null`

```sql
-- Correct
SELECT Id, Name FROM Account WHERE Industry = null

-- Wrong (SQL-style IS NULL does not work in SOQL)
SELECT Id, Name FROM Account WHERE Industry IS NULL
```

---

### Pagination with `nextRecordsUrl`

A single `query()` call returns at most 2,000 records. If there are more, the response includes `nextRecordsUrl`.

- Python: use `sf.query_all()` — it handles pagination automatically
- JavaScript: use `conn.queryAll()` — it handles pagination automatically
- curl: manually fetch `$INSTANCE_URL$nextRecordsUrl` until `done: true`

---

## Section 4: Python `simple-salesforce` Issues

### `ImportError` or `ModuleNotFoundError` on Python 3.12

Upgrade `simple-salesforce` to the latest version:
```bash
uv add simple-salesforce@latest
uv sync
```

If the issue persists, use Python 3.11:
```bash
uv sync --python 3.11
```

---

### `SalesforceAuthenticationFailed`

Authentication failed. See [Section 1](#section-1-authentication-errors) for root causes.

Common cause in Python: accidentally appending the security token to the password. Use:
```python
Salesforce(
    username=...,
    password=...,        # password only — no token
    security_token=...,  # token separately
)
```

---

### `SalesforceResourceNotFound`

The Record ID does not exist or the record was deleted.

```python
from simple_salesforce.exceptions import SalesforceResourceNotFound
try:
    account = sf.Account.get("001INVALID")
except SalesforceResourceNotFound:
    print("Record not found")
```

---

### `SalesforceMalformedRequest`

A field name is wrong or a required field is missing. The exception message includes the Salesforce error details.

---

### `uv run` not found

Bootstrap `uv` first — see [Step 0](00-required-tools.md#bootstrapping-uv).

---

## Section 5: jsforce JavaScript Issues

### SOAP login deprecation warning

`conn.login()` (SOAP API) will be retired in Summer '27 (API v65.0). You may see a deprecation warning in newer jsforce versions. Your code still works today. When you are ready to migrate, switch to the `jsforce.Connection` with OAuth 2.0 JWT Bearer or Client Credentials flow — see [jsforce docs](https://jsforce.github.io/document/).

---

### `Error: connect ECONNREFUSED`

The `SF_INSTANCE_URL` in your `.env` is wrong or unreachable.

- For Developer Edition: `SF_INSTANCE_URL` should be your org's domain (e.g., `https://yourorg.my.salesforce.com`) after initial setup, or `https://login.salesforce.com` to let Salesforce redirect during login
- Check that your org is active (log in at login.salesforce.com)

---

### `.delete()` does not exist on sobject

jsforce uses `.destroy()` for DELETE operations:
```javascript
// Correct
await conn.sobject('Account').destroy(accountId);

// Wrong — .delete() does not exist
await conn.sobject('Account').delete(accountId);
```

---

### `require('jsforce')` fails — module not found

Run `npm install` in the `javascript/` directory first.

---

### Mixing `require()` and `import` causes errors

All files in this guide use `require()` (CommonJS). Do not add `"type": "module"` to `package.json` — jsforce is CommonJS-only and this causes interop failures.

If you must use ESM, use dynamic `import()`:
```javascript
const jsforce = await import('jsforce');
```

---

## Section 6: Org and Setup Issues

### "Please check your username and password" on login.salesforce.com

Hyperforce-provisioned Developer Edition orgs (URL format: `orgfarm-XXXXXXXX-dev-ed.develop.my.salesforce.com`) cannot be accessed directly via `login.salesforce.com`. The credentials are correct — the routing is wrong.

Fix — use either method:

**Option A: Use Custom Domain**
1. Go to <https://login.salesforce.com>
2. Click **Use Custom Domain**
3. Enter your org domain (e.g. `orgfarm-e7022cb898-dev-ed.develop.my`)
4. Click **Continue** and log in

**Option B: Go to your org URL directly**
Navigate to `https://orgfarm-XXXXXXXX-dev-ed.develop.my.salesforce.com` (your full org URL from the signup verification email) and log in there.

> **Note:** For API authentication (OAuth token requests), `https://login.salesforce.com/services/oauth2/token` still works correctly for Hyperforce orgs — this issue only affects the UI login.

---

### Org deactivated after 45-day inactivity

Developer Edition orgs are permanently deactivated after 45 days of inactivity. There is no recovery. Start fresh: sign up for a new Developer Edition at <https://salesforce.com/products/free-trial/developer/>.

---

### Email address already in use

Salesforce usernames and email addresses must be globally unique across ALL Salesforce orgs. If you see "This email is already in use", add a `+tag` variant:
- `you+sfdev@gmail.com`
- `you+sfdev2@yourcompany.com`

---

### "Setup" menu item not visible

You are in Salesforce Classic. Switch to Lightning Experience:
- Click your user avatar (top right) → Switch to Lightning Experience

---

### Tabs missing from navigation (Accounts, Cases, Contacts)

Tabs are per-App. Add them:
1. Setup → App Manager → find your current app → dropdown → Edit
2. Navigation Items → Add Items → select the missing objects → Save

Or use the App Launcher (9-dot grid icon, top left) → search for the object name.

---

### Cannot edit the "System Administrator" Profile

The System Administrator Profile is read-only. To customize it: Setup → Profiles → System Administrator → Clone → edit the clone.

---

### Custom field cannot be renamed (API name)

Only the Label of a custom field can be changed after creation. The API name (ending in `__c`) is permanent. Plan your API names carefully before creating fields.

---

## Section 7: Data Model Confusion

### Lead vs Contact

- **Lead** = an unqualified prospect; NOT linked to an Account; has its own fields (Company, LeadSource, etc.)
- **Contact** = a qualified person, linked to an Account

**Converting a Lead** creates three records: Contact + Account + Opportunity. It does NOT create just a Contact.

This guide uses Contacts only. Leads belong to sales funnel workflows and are out of scope.

---

### "Private contacts" not visible to other users

A Contact without an `AccountId` is a "private contact" — visible only to the record owner and administrators. Always link Contacts to an Account for proper visibility.

---

### Case fields: Account vs Contact vs both

A Case can be linked to:
- An Account only
- A Contact only (the Contact's Account becomes the Case Account automatically)
- Both an Account and a Contact explicitly

For best results in this guide, explicitly set both `AccountId` and `ContactId` when creating Cases.

---

## Get More Help

- **Salesforce Stack Exchange** (best for specific technical questions): <https://salesforce.stackexchange.com>
- **Trailblazer Community**: <https://trailhead.salesforce.com/trailblazer-community>
- **simple-salesforce issues**: <https://github.com/simple-salesforce/simple-salesforce/issues>
- **jsforce issues**: <https://github.com/jsforce/jsforce/issues>
- **Official REST API docs**: <https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/>

---

**Navigation:** [← JavaScript Guide](07-javascript-guide.md) | [README](../README.md) | [Next → Developer Edition Scope →](09-developer-edition-scope.md)
