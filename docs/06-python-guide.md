# Step 6: Salesforce REST API with Python

**Time:** ~45 minutes  
**What you will have when done:** Working Python scripts that authenticate with Salesforce and perform CRUD operations on Accounts, Contacts, and Cases using the `simple-salesforce` SDK.

---

## Before You Start

1. Your `.env` file must be fully populated — see [Step 3](03-connected-app.md).
2. You should have at least one Account, Contact, and Case from [Step 4](04-ui-walkthrough.md).
3. Python 3.9+ and `uv` must be installed — see [Step 0](00-required-tools.md).

---

## Setup: Install Dependencies

```bash
cd python/
uv sync
```

`uv sync` reads `pyproject.toml`, creates `.venv/` if needed, and installs all dependencies in one step.

**Verify installation:**
```bash
uv run python -c "import simple_salesforce; print('OK')"
```

No manual `source .venv/bin/activate` is needed when using `uv run`. All examples below use `uv run python`.

---

## Step 6.1: Authenticate

```bash
uv run python 01_authenticate.py
```

Expected output:
```
Connected to Salesforce org: 00D...
Instance URL: https://yourorg.my.salesforce.com
```

### How Authentication Works

The shared helper in `auth.py` creates the connection:

```python
from simple_salesforce import Salesforce
from dotenv import load_dotenv
import os

def get_salesforce_connection():
    load_dotenv()
    return Salesforce(
        username=os.environ["SF_USERNAME"],
        password=os.environ["SF_PASSWORD"],
        security_token=os.environ["SF_SECURITY_TOKEN"],
        consumer_key=os.environ["SF_CONSUMER_KEY"],
        consumer_secret=os.environ["SF_CONSUMER_SECRET"],
    )
```

> **Important:** Do NOT append the security token to the password yourself. `simple-salesforce` does this internally. Manually appending it causes `INVALID_LOGIN` errors. This is the opposite of curl and JavaScript — where you must concatenate manually.

---

## Step 6.2: CRUD on Accounts

```bash
uv run python 02_accounts.py
```

### What the script does

**CREATE** — `sf.Account.create()`
```python
result = sf.Account.create({
    "Name": "Test Corp",
    "Phone": "(555) 999-0001",
    "Industry": "Technology"
})
account_id = result["id"]
print(f"Created Account: {account_id}")
# result: {'id': '001...', 'success': True, 'created': True}
```

**READ** — `sf.Account.get()`
```python
account = sf.Account.get(account_id)
print(f"Name: {account['Name']}, Phone: {account['Phone']}")
```

**UPDATE** — `sf.Account.update()`
```python
sf.Account.update(account_id, {"Phone": "(555) 999-0002"})
# Returns HTTP 204; no return value on success
```

**DELETE** — `sf.Account.delete()`
```python
sf.Account.delete(account_id)
# Returns HTTP 204; no return value on success
```

---

## Step 6.3: CRUD on Contacts and Cases

```bash
uv run python 03_contacts.py
uv run python 04_cases.py
```

These follow the same pattern. Key differences:

| Object | Required Field | SDK Object |
|--------|---------------|------------|
| Account | `Name` | `sf.Account` |
| Contact | `LastName` | `sf.Contact` |
| Case | `Subject` | `sf.Case` |

**Contact linked to an Account:**
```python
sf.Contact.create({
    "FirstName": "Jane",
    "LastName": "Smith",
    "AccountId": account_id,        # link to an Account
    "Email": "jane.smith@acme.example.com"
})
```

**Case linked to Account and Contact:**
```python
sf.Case.create({
    "Subject": "Login issue on mobile",
    "Status": "New",
    "Priority": "High",
    "AccountId": account_id,
    "ContactId": contact_id
})
```

---

## Step 6.4: SOQL Queries

```bash
uv run python 05_query_soql.py
```

### `sf.query()` — up to 2,000 records

```python
result = sf.query("SELECT Id, Name, Phone FROM Account LIMIT 10")
for record in result["records"]:
    print(record["Name"], record["Phone"])
```

> **Remember:** `SELECT * FROM Account` is not valid SOQL. You must list fields explicitly.

### `sf.query_all()` — all records (handles pagination)

```python
result = sf.query_all("SELECT Id, Name FROM Account")
print(f"Total records: {result['totalSize']}")
for record in result["records"]:
    print(record["Id"], record["Name"])
```

Use `query_all()` when you expect more than 2,000 records. It automatically follows `nextRecordsUrl` until all pages are retrieved.

### Relationship query (cross-object)

```python
# Get contacts with their Account name
result = sf.query(
    "SELECT Id, FirstName, LastName, Account.Name FROM Contact LIMIT 10"
)
for c in result["records"]:
    print(c["LastName"], "→", c["Account"]["Name"])
```

### Filter by status

```python
result = sf.query(
    "SELECT Id, Subject, Status FROM Case WHERE Status != 'Closed' LIMIT 10"
)
```

---

## Error Handling

`simple-salesforce` raises specific exceptions you can catch:

```python
from simple_salesforce.exceptions import (
    SalesforceAuthenticationFailed,
    SalesforceResourceNotFound,
    SalesforceMalformedRequest,
)

try:
    account = sf.Account.get("001DOESNOTEXIST")
except SalesforceResourceNotFound:
    print("Record not found — check the ID")

try:
    sf.Contact.create({})           # missing required LastName
except SalesforceMalformedRequest as e:
    print(f"Bad request: {e}")
```

For authentication errors, see [Troubleshooting](08-troubleshooting.md#section-1).

---

## Running All Scripts

```bash
cd python/
uv run python 01_authenticate.py
uv run python 02_accounts.py
uv run python 03_contacts.py
uv run python 04_cases.py
uv run python 05_query_soql.py
```

Each script uses a timestamp in created record names (e.g., `Test Corp 2026-04-15T10:30:00`) to avoid conflicts if you run them multiple times.

---

**Navigation:** [← curl Quickstart](05-curl-quickstart.md) | [README](../README.md) | [Next → JavaScript Guide →](07-javascript-guide.md)

**Official Reference:**
- simple-salesforce docs: <https://simple-salesforce.readthedocs.io/en/latest/>
- simple-salesforce GitHub: <https://github.com/simple-salesforce/simple-salesforce>
