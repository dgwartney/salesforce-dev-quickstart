# Step 3: Create a Connected App

**Time:** ~25 minutes  
**What you will have when done:** An OAuth 2.0 Connected App with Consumer Key and Secret; a working access token via the Username-Password flow.

---

## What is a Connected App?

A Connected App is an OAuth 2.0 application registration in Salesforce — similar to registering an app with Google or GitHub to get a client ID and secret. It is the mechanism that allows external code to securely identify itself and authenticate with your org.

Your code presents:
- `client_id` = **Consumer Key** (from the Connected App)
- `client_secret` = **Consumer Secret** (from the Connected App)
- `username` + `password` + `security_token` (User B's credentials)

Salesforce verifies all of the above and returns an `access_token` you use for subsequent API calls.

---

## Create the Connected App

1. In Setup, search Quick Find for: `App Manager`
2. Click **App Manager** (under Apps — not "Lightning Out 2.0 App Manager")
3. Click **New External Client App** (top right)

> **Note:** Older Salesforce documentation refers to a "New Connected App" button. On Hyperforce-provisioned orgs the button is now labeled **New External Client App** — this creates the same OAuth Connected App.

The form is a single page with a **Create** button at the bottom.

### Basic Information

| Field | Value |
|---|---|
| External Client App Name | `My API Integration` (or any name) |
| API Name | Auto-filled when you tab out of the name field |
| Contact Email | Your email address |
| Distribution State | `Local` (default — leave as-is) |

### API (Enable OAuth Settings)

Scroll down to the **API (Enable OAuth Settings)** section on the same page and expand it.

4. Check **Enable OAuth Settings**
5. **Callback URL:** `https://localhost` *(required by Salesforce even if unused)*
6. **Selected OAuth Scopes** — double-click each to move it from Available to Selected:
   - `Manage user data via APIs (api)`
   - `Perform requests at any time (refresh_token, offline_access)` — scroll down in the Available list to find it
7. Leave all other settings at their defaults
8. Click **Create**

---

## Retrieve Consumer Key and Secret

After creating, you land on the app detail page. Click the **Settings** tab, then expand **OAuth Settings**.

1. Click **Consumer Key and Secret** — Salesforce will send a verification code to your email; check your inbox, enter the code, and click **Verify**
2. Copy **Consumer Key** → paste into `.env` as `SF_CONSUMER_KEY`
3. Copy **Consumer Secret** → paste into `.env` as `SF_CONSUMER_SECRET`

> **WARNING:** Copy both values before navigating away. If you lose the Consumer Secret, click **Reset Consumer Secret** to generate a new one (the old one stops working immediately).

---

## Configure App Policies

On the app detail page, click the **Policies** tab. **Permitted Users** is already set to `All users can self-authorize` by default — no change needed.

If you encounter IP restriction errors when testing, click **Edit** on the Policies tab and set **IP Relaxation** to `Relax IP restrictions`.

---

## Wait for Activation

> **Wait 2–10 minutes.** New Connected Apps take time to propagate across Salesforce's infrastructure. If you test immediately, you will get an `invalid_client` error even with correct credentials.

Set a timer and proceed to update your `.env` file while you wait.

---

## Update Your .env File

Your `.env` should now have all six values:

```bash
SF_USERNAME=userb@yourcompany.com
SF_PASSWORD=userbpassword
SF_SECURITY_TOKEN=userBsecurityToken
SF_CONSUMER_KEY=3MVG9...yourConsumerKey
SF_CONSUMER_SECRET=ABC123...yourConsumerSecret
SF_INSTANCE_URL=https://yourorg.develop.my.salesforce.com
SF_API_VERSION=v62.0
```

**Finding your instance URL:** Look at your browser's address bar when logged into Salesforce. For Hyperforce orgs it looks like `https://orgfarm-XXXXXXXX-dev-ed.develop.my.salesforce.com` — use that exact URL (not the `-setup.` variant used in Setup pages).

This URL is used for both the OAuth token request and all subsequent API calls.

---

## Test: Get an Access Token

After the 10-minute wait, run this curl command to verify everything works. Replace values with your actual credentials:

```bash
curl -s "${SF_INSTANCE_URL}/services/oauth2/token" \
  -d "grant_type=password" \
  -d "client_id=${SF_CONSUMER_KEY}" \
  -d "client_secret=${SF_CONSUMER_SECRET}" \
  -d "username=${SF_USERNAME}" \
  -d "password=${SF_PASSWORD}${SF_SECURITY_TOKEN}"
```

**Expected response:**
```json
{
  "access_token": "00D...!AQ...",
  "instance_url": "https://yourorg.my.salesforce.com",
  "id": "https://login.salesforce.com/id/...",
  "token_type": "Bearer",
  "issued_at": "1234567890000",
  "signature": "..."
}
```

If you see an `access_token`, everything is working. Copy the `instance_url` value and update `SF_INSTANCE_URL` in your `.env`.

**Common errors at this step:**
- `invalid_grant` → most likely "Allow OAuth Username-Password Flows" is not enabled. See [Step 1](01-signup-and-setup.md#enable-oauth-username-password-flow) or [Troubleshooting](08-troubleshooting.md).
- `invalid_client` → Connected App not yet active; wait a few more minutes.
- `INVALID_LOGIN` → wrong username, password, or security token.

---

## Verification Checklist

- [ ] Connected App created with OAuth enabled
- [ ] Consumer Key and Consumer Secret saved in `.env`
- [ ] "Permitted Users" set to "All users may self-authorize"
- [ ] "IP Relaxation" set to "Relax IP restrictions"
- [ ] Waited at least 10 minutes after creation
- [ ] Test curl command returns an `access_token`
- [ ] `SF_INSTANCE_URL` in `.env` updated with value from token response

---

**Navigation:** [← User Setup](02-user-setup.md) | [README](../README.md) | [Next → UI Walkthrough →](04-ui-walkthrough.md)

**Official Reference:**
- Create a Connected App: <https://help.salesforce.com/s/articleView?id=sf.connected_app_create.htm>
- Username-Password OAuth flow: <https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/intro_understanding_username_password_oauth_flow.htm>
