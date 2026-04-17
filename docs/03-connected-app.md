# Step 3: Create a Connected App

**Time:** ~25 minutes  
**What you will have when done:** An OAuth 2.0 Connected App with Consumer Key and Secret; a working access token via the Username-Password flow.

---

## What is a Connected App?

A Connected App is an OAuth 2.0 application registration in Salesforce — similar to registering an app with Google or GitHub to get a client ID and secret. It is the mechanism that allows external code to securely identify itself and authenticate with your org.

Your code presents:
- `client_id` = **Consumer Key** (from the Connected App)
- `client_secret` = **Consumer Secret** (from the Connected App)
- `username` + `password` + `security_token` (your credentials)

Salesforce verifies all of the above and returns an `access_token` you use for subsequent API calls.

---

## Spring '26 Context: Connected Apps vs. External Client Apps

Salesforce introduced **External Client Apps (ECAs)** as the new standard for OAuth integrations. On Hyperforce-provisioned orgs, App Manager now defaults to ECAs. **ECAs do not support the Username-Password OAuth flow** (`grant_type=password`) — they only support Authorization Code, Client Credentials, and JWT Bearer flows.

This guide uses the **traditional Connected App**, which still supports the Username-Password flow. As of Spring '26, new Connected App creation is disabled by default but can be re-enabled via a settings page.

> **Future direction:** Salesforce is progressively deprecating the Username-Password flow. No hard removal date has been announced for existing Connected Apps, but new integrations should consider the Client Credentials or JWT Bearer flow instead.

---

## Create a Traditional Connected App

### Step 1: Enable Connected App Creation

On newer Hyperforce orgs, the "New Connected App" button is hidden by default. Re-enable it:

1. In Setup, search Quick Find for: `External Client App`
2. Click **External Client App Manager**
3. In the left sidebar, click **Settings**
4. Under the **Connected Apps** section, click **New Connected App**

This opens the traditional Connected App creation form directly.

### Step 2: Fill in Basic Information

Scroll to the top of the form and fill in:

| Field | Value |
|---|---|
| Connected App Name | `My API Integration` (or any name) |
| API Name | Auto-filled |
| Contact Email | Your email address |

### Step 3: Configure OAuth Settings

Check **Enable OAuth Settings**, then:

- **Callback URL:** `https://localhost` *(required even if unused)*
- **Selected OAuth Scopes** — add both:
  - `Manage user data via APIs (api)`
  - `Perform requests at any time (refresh_token, offline_access)`

The **Enable Username-Password Flow** checkbox may or may not appear depending on your org version. If it appears, check it. If it does not appear, the flow is controlled solely by the org-level toggle set in Step 1.

### Step 4: Save

Click **Save** at the bottom of the form, then click **Continue** on the confirmation page.

---

## Retrieve Consumer Key and Secret

On the Connected App detail page:

1. Click **Manage Consumer Details** (may require an email verification code)
2. Copy **Consumer Key** → paste into `.env` as `SF_CONSUMER_KEY`
3. Copy **Consumer Secret** → paste into `.env` as `SF_CONSUMER_SECRET`

> **WARNING:** Copy both values before navigating away. If you lose the Consumer Secret, click **Reset Consumer Secret** — the old one stops working immediately.

---

## Configure App Policies

1. Go back to Setup → App Manager → find your app → dropdown → **Manage**
2. Click **Edit Policies**
3. Set:
   - **Permitted Users:** `All users may self-authorize`
   - **IP Relaxation:** `Relax IP restrictions`
4. Click **Save**

---

## Wait for Activation

> **Wait 2–10 minutes.** New Connected Apps take time to propagate. Testing immediately will return `invalid_client` even with correct credentials.

---

## Update Your .env File

```bash
SF_USERNAME=youruser@example.com
SF_PASSWORD=yourpassword
SF_SECURITY_TOKEN=yourSecurityToken
SF_CONSUMER_KEY=3MVG9...yourConsumerKey
SF_CONSUMER_SECRET=ABC123...yourConsumerSecret
SF_INSTANCE_URL=https://orgfarm-XXXXXXXX-dev-ed.develop.my.salesforce.com
SF_API_VERSION=v62.0
```

**Finding your instance URL:** Your browser address bar when logged into Salesforce shows it — e.g. `https://orgfarm-XXXXXXXX-dev-ed.develop.my.salesforce.com`. Use that URL (not the `-setup.` variant used in Setup pages).

---

## Test: Get an Access Token

```bash
cd curl && source authenticate.sh
```

**Expected response:**
```json
{
  "access_token": "00D...!AQ...",
  "instance_url": "https://yourorg.my.salesforce.com",
  "token_type": "Bearer"
}
```

**Common errors:**
- `invalid_grant` → see [Troubleshooting](08-troubleshooting.md#section-1-authentication-errors)
- `invalid_client` → wait a few more minutes for activation
- `INVALID_LOGIN` → wrong username, password, or security token

---

## Verification Checklist

- [ ] Traditional Connected App created (not External Client App)
- [ ] Consumer Key and Consumer Secret saved in `.env`
- [ ] "Permitted Users" set to "All users may self-authorize"
- [ ] "IP Relaxation" set to "Relax IP restrictions"
- [ ] Waited at least 10 minutes after creation
- [ ] `source authenticate.sh` returns an `access_token`

---

**Navigation:** [← User Setup](02-user-setup.md) | [README](../README.md) | [Next → UI Walkthrough →](04-ui-walkthrough.md)

**Official Reference:**
- Connected Apps overview: <https://help.salesforce.com/s/articleView?id=sf.connected_app_overview.htm>
- Username-Password OAuth flow: <https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/intro_understanding_username_password_oauth_flow.htm>
- External Client Apps: <https://help.salesforce.com/s/articleView?id=sf.external_client_app_overview.htm>
