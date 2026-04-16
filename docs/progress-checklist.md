# My Salesforce Dev Quickstart Progress

> Copy this file to your own notes, or fork this repo and edit it directly on GitHub.
> Check off each item as you complete it.
>
> **Time estimates** assume careful reading and working through all examples.
> First-time users typically take 25–50% longer than listed — that is completely normal.
> You can stop at any **[Pause] Checkpoint** and safely resume in a new session.

---

## Session 1: Foundations · ~90 min

### Phase 1A: Tools & Signup · ~40 min

- [ ] Read [docs/00-required-tools.md](00-required-tools.md) — understand what is needed
- [ ] Installed curl (verify: `curl --version`)
- [ ] Installed Python 3.9+ (verify: `python3 --version`)
- [ ] Installed uv (verify: `uv --version`)
- [ ] Installed Node.js 18+ (verify: `node --version`)
- [ ] Installed jq (optional, verify: `jq --version`)
- [ ] Signed up for Salesforce Developer Edition at <https://developer.salesforce.com/signup>
- [ ] Received verification email and set password
- [ ] Logged in at <https://login.salesforce.com> — confirmed Lightning Experience is active
- [ ] Received security token by email (Setup → Personal Settings → Reset My Security Token)
- [ ] **CRITICAL:** Enabled "Allow OAuth Username-Password Flows"
      (Setup → OAuth and OpenID Connect Settings → toggle on)
- [ ] Copied `.env.example` → `.env` and filled in `SF_USERNAME`, `SF_PASSWORD`, `SF_SECURITY_TOKEN`

### Phase 1B: Users & Connected App · ~50 min

- [ ] Created User B (integration/API user): Setup → Users → New User
- [ ] Created "Integration API Access" Permission Set and assigned to User B
- [ ] Got User B's security token (reset from User B's profile)
- [ ] Updated `.env` with User B's credentials
- [ ] Created Connected App: Setup → Apps → App Manager → New Connected App
- [ ] Copied Consumer Key to `.env` as `SF_CONSUMER_KEY`
- [ ] Copied Consumer Secret to `.env` as `SF_CONSUMER_SECRET` *(only shown once — save immediately)*
- [ ] Set "Permitted Users" to "All users may self-authorize"
- [ ] Set "IP Relaxation" to "Relax IP restrictions"
- [ ] **Waited 10 minutes** after Connected App creation before testing
- [ ] Ran test curl token request — received `access_token` in JSON response
- [ ] Updated `.env` with `SF_INSTANCE_URL` from the token response

### [Pause] Session 1 Checkpoint

**Save your `.env` file.** You now have:
- A working Salesforce Developer Edition org
- Two users (Admin + Integration)
- A Connected App with OAuth credentials
- A working access token

When you resume, start [Session 2](#session-2).

---

## Session 2: Salesforce UI · ~80 min {#session-2}

### Phase 2: Accounts, Contacts, and Cases · ~80 min

- [ ] Read the [CRM data model overview](04-ui-walkthrough.md#the-crm-data-model) in docs/04
- [ ] Added Cases, Contacts, Accounts tabs to navigation (App Manager fix if needed)
- [ ] Created at least 1 Account — noted the **Record ID** from the URL bar
- [ ] Created at least 1 Contact linked to the Account
- [ ] Created at least 1 Case linked to the Account and Contact
- [ ] Updated a Case Status from "New" to "Working"
- [ ] Explored related lists on an Account record (Contacts, Cases tabs)
- [ ] Confirmed you understand what the 15/18-character Record ID looks like

**Record IDs to save for API calls (fill in your values):**

| Object | Record ID | Name/Subject |
|--------|-----------|--------------|
| Account | `001...` | |
| Contact | `003...` | |
| Case    | `500...` | |

### [Pause] Session 2 Checkpoint

**Save the Record IDs** from the table above — you will paste them into API calls in Session 3.

When you resume, choose your path in [Session 3](#session-3).

---

## Session 3: Programmatic Access · ~120 min {#session-3}

### Phase 3A: curl · ~30 min

- [ ] Exported `.env` variables to shell (`source .env` or `export $(cat .env | xargs)`)
- [ ] Got access token via `curl/authenticate.sh`
- [ ] Created an Account via POST
- [ ] Read the Account via GET (by ID)
- [ ] Updated the Account via PATCH
- [ ] Deleted the Account via DELETE
- [ ] Ran a SOQL query via `/query?q=...`

### Phase 3B: Python SDK · ~45 min

- [ ] Created Python venv: `cd python && uv venv && uv pip install -r requirements.txt`
- [ ] Ran `uv run python 01_authenticate.py` — saw org ID and instance URL
- [ ] Ran `uv run python 02_accounts.py` — saw create/read/update/delete output
- [ ] Ran `uv run python 03_contacts.py` — saw CRUD output
- [ ] Ran `uv run python 04_cases.py` — saw CRUD output
- [ ] Ran `uv run python 05_query_soql.py` — saw query results with multiple examples

### Phase 3C: JavaScript SDK · ~45 min

- [ ] Ran `cd javascript && npm install`
- [ ] Ran `node 01_authenticate.js` — saw connection info
- [ ] Ran `node 02_accounts.js` — saw CRUD output
- [ ] Ran `node 03_contacts.js` — saw CRUD output
- [ ] Ran `node 04_cases.js` — saw CRUD output
- [ ] Ran `node 05_query_soql.js` — saw query results
- [ ] Ran `npx ts-node 06_query_soql.ts` — saw typed TypeScript query output

---

## [Complete] Journey Complete

You can now:
- Stand up a Salesforce Developer Edition org from scratch
- Create and manage Accounts, Contacts, and Cases in the UI
- Authenticate programmatically via OAuth 2.0
- Perform CRUD operations using curl, Python, and JavaScript/TypeScript
- Run SOQL queries to filter and retrieve records

**What's next?**
- [docs/09-developer-edition-scope.md](09-developer-edition-scope.md) — explore Einstein, Agentforce, and AI features
- [docs/learning-resources.md](learning-resources.md) — go deeper with Trailhead and official docs
- Try adding a custom field (Setup → Object Manager → Case → Fields & Relationships → New)
