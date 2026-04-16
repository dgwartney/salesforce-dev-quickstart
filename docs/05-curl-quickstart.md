# Step 5: Salesforce REST API with curl

**Time:** ~30 minutes  
**What you will have when done:** The ability to authenticate and perform CRUD operations on Accounts, Contacts, and Cases using raw HTTP calls.

---

## Before You Start

1. Your `.env` file must be fully populated (all 6 variables) — see [Step 3](03-connected-app.md).
2. You should have at least one Account, Contact, and Case created in [Step 4](04-ui-walkthrough.md).
3. All curl scripts are in the `curl/` directory.

---

## Load Your Environment Variables

The curl scripts read credentials from your `.env` file. Load them into your shell session:

```bash
# From the repo root:
export $(grep -v '^#' .env | xargs)

# Verify
echo "User: $SF_USERNAME"
echo "Instance: $SF_INSTANCE_URL"
```

Or run from the `curl/` directory — the scripts source `../.env` automatically.

---

## Step 5.1: Authenticate and Get an Access Token

```bash
cd curl
chmod +x *.sh       # make scripts executable (first time only)
source authenticate.sh
```

This script:
1. POSTs your credentials to Salesforce's token endpoint
2. Extracts `ACCESS_TOKEN` and `INSTANCE_URL` into shell variables
3. Prints a confirmation message

**What happens under the hood:**
```bash
curl -s https://login.salesforce.com/services/oauth2/token \
  -d "grant_type=password" \
  -d "client_id=$SF_CONSUMER_KEY" \
  -d "client_secret=$SF_CONSUMER_SECRET" \
  -d "username=$SF_USERNAME" \
  -d "password=${SF_PASSWORD}${SF_SECURITY_TOKEN}"
```

Note: `password` is your actual password concatenated directly with your security token (no separator).

**Verify the token is set:**
```bash
echo $ACCESS_TOKEN | head -c 20
# Should print: 00D...
```

---

## Step 5.2: Discover the API

```bash
# List available API versions
curl -s "$INSTANCE_URL/services/data/" \
  -H "Authorization: Bearer $ACCESS_TOKEN" | jq .

# List resource families in v62.0
curl -s "$INSTANCE_URL/services/data/v62.0/" \
  -H "Authorization: Bearer $ACCESS_TOKEN" | jq 'keys'

# Check your remaining API call quota
curl -s "$INSTANCE_URL/services/data/v62.0/limits" \
  -H "Authorization: Bearer $ACCESS_TOKEN" | jq '.DailyApiRequests'
```

---

## Step 5.3: CRUD on Accounts

Run the script, which executes all four operations in sequence:

```bash
bash accounts.sh
```

### What the script does

**CREATE** — POST to `/sobjects/Account/`
```bash
curl -s -X POST "$INSTANCE_URL/services/data/v62.0/sobjects/Account/" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"Name": "Test Corp", "Phone": "(555) 999-0001", "Industry": "Technology"}'
# Returns: {"id":"001...","success":true,"created":true}
# HTTP 201 Created
```

**READ** — GET `/sobjects/Account/{id}`
```bash
ACCOUNT_ID="001..."   # paste your Account ID here
curl -s "$INSTANCE_URL/services/data/v62.0/sobjects/Account/$ACCOUNT_ID" \
  -H "Authorization: Bearer $ACCESS_TOKEN" | jq '{Id, Name, Phone, Industry}'
# HTTP 200 OK
```

**UPDATE** — PATCH `/sobjects/Account/{id}`
```bash
curl -s -X PATCH "$INSTANCE_URL/services/data/v62.0/sobjects/Account/$ACCOUNT_ID" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"Phone": "(555) 999-0002"}'
# HTTP 204 No Content (success, no body)
```

**DELETE** — DELETE `/sobjects/Account/{id}`
```bash
curl -s -X DELETE "$INSTANCE_URL/services/data/v62.0/sobjects/Account/$ACCOUNT_ID" \
  -H "Authorization: Bearer $ACCESS_TOKEN"
# HTTP 204 No Content (success, no body)
```

---

## Step 5.4: CRUD on Contacts and Cases

```bash
bash contacts.sh
bash cases.sh
```

These scripts follow the same pattern with the appropriate object names (`Contact`, `Case`) and required fields (`LastName` for Contact, `Subject` for Case).

---

## Step 5.5: SOQL Queries

SOQL (Salesforce Object Query Language) is how you query records. It looks like SQL but has important differences — see the [Glossary](glossary.md) for details.

```bash
# Query all Accounts (limit 10)
curl -s -G "$INSTANCE_URL/services/data/v62.0/query" \
  --data-urlencode "q=SELECT Id, Name, Phone, Industry FROM Account LIMIT 10" \
  -H "Authorization: Bearer $ACCESS_TOKEN" | jq '.records[] | {Id, Name}'

# Query Contacts with their Account name (relationship query)
curl -s -G "$INSTANCE_URL/services/data/v62.0/query" \
  --data-urlencode "q=SELECT Id, FirstName, LastName, Email, Account.Name FROM Contact LIMIT 10" \
  -H "Authorization: Bearer $ACCESS_TOKEN" | jq '.records[]'

# Query open Cases
curl -s -G "$INSTANCE_URL/services/data/v62.0/query" \
  --data-urlencode "q=SELECT Id, Subject, Status, Priority, Account.Name FROM Case WHERE Status != 'Closed'" \
  -H "Authorization: Bearer $ACCESS_TOKEN" | jq '.records[] | {Id, Subject, Status}'
```

> **Note:** `SELECT * FROM Account` does not work in SOQL — you must list fields explicitly.

---

## HTTP Status Code Reference

| Code | Meaning | When you see it |
|------|---------|-----------------|
| `200 OK` | Success with body | GET queries, token endpoint |
| `201 Created` | Record created | POST to `/sobjects/` |
| `204 No Content` | Success, no body | PATCH (update), DELETE |
| `400 Bad Request` | Malformed request | Missing required field, wrong JSON |
| `401 Unauthorized` | Auth failed | Expired token, wrong credentials |
| `404 Not Found` | Record not found | Wrong Record ID, deleted record |
| `405 Method Not Allowed` | Wrong HTTP method | Using POST where PATCH is needed |

---

**Navigation:** [← UI Walkthrough](04-ui-walkthrough.md) | [README](../README.md) | [Next → Python Guide →](06-python-guide.md)

**Official Reference:**
- REST API Developer Guide: <https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/>
- SOQL Reference: <https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/>
