# Step 1: Sign Up for Salesforce Developer Edition

**Time:** ~20 minutes  
**What you will have when done:** A free, permanent Salesforce org with API access enabled.

---

## What is Salesforce Developer Edition?

Salesforce Developer Edition (DE) is a **free, permanent** instance of Salesforce that includes:

- Full API access (REST, SOAP, Streaming APIs)
- Lightning Platform, Apex, Flow Builder
- Agentforce and Data Cloud (as of March 2025)
- Custom objects, custom fields, automation

**Key limits to know:**

| Resource | Developer Edition |
|---|---|
| User licenses | 2 standard + 1 admin |
| Data storage | 5–256 MB |
| File storage | 20 MB |
| API calls | ~15,000 per 24-hour rolling period |
| Sandboxes | Not available (requires paid org) |
| Inactivity | Deactivated after **180 days** — log in periodically |

> **Not for production use.** Developer Edition is for learning, development, and proof-of-concept only.

---

## Sign Up

1. Go to **<https://developer.salesforce.com/signup>**
2. Fill in the form:
   - First Name, Last Name
   - **Email address** — must be globally unique across *all* Salesforce orgs (including sandboxes and other orgs). If you get an error, try adding a `+tag` (e.g., `you+sfdev@gmail.com`)
   - Company name (can be anything)
   - **Username** — auto-filled from your email but must also be globally unique. You can leave the auto-generated value.
3. Click **Sign me up**
4. Check your email for a message from Salesforce. Check your spam folder if it does not arrive within 5 minutes.
5. Click the verification link in the email.
6. Set your **password** (use alphanumeric characters — special characters in passwords can cause authentication issues later).
7. You are now logged in.

> **Important:** Passwords are case-sensitive. Write yours down or save it in a password manager.

---

## First Login

After signing up you will land in the Salesforce **Lightning Experience** — the modern web interface.

If you see an older, tab-heavy interface (Salesforce Classic), switch to Lightning:
1. Click your **user avatar** (top right)
2. Click **Switch to Lightning Experience**

**Navigating Setup:** Almost everything you configure lives in the **Setup** menu:
1. Click the **gear icon** in the top right
2. Click **Setup**

The Setup page has a **Quick Find** search box at the top left of the left sidebar. Type any menu item name to jump directly to it — you will use this constantly.

---

## Get Your Security Token

The security token is a personal credential you append to your password when making API calls from non-whitelisted IP addresses. You need it for programmatic access.

1. Click the **gear icon** → **Setup**
2. In Quick Find, type: `Reset My Security Token`
3. Click **Reset My Security Token**
4. Click the **Reset Security Token** button
5. Check your email — the token arrives within ~1 minute

**Save this token somewhere safe.** If you lose it, you can reset it again (but each reset invalidates the previous token).

> **Note:** If you later change your password, all existing security tokens are invalidated. You will need to get a new one.

---

## Enable OAuth Username-Password Flow

> **WARNING: CRITICAL STEP — do not skip this.**  
> Salesforce disabled the OAuth Username-Password flow by default in all orgs created **Summer 2023 and later**. Skipping this step causes `invalid_grant` errors on every API authentication attempt.

1. In Setup, search Quick Find for: `OAuth`
2. Click **OAuth and OpenID Connect Settings**
3. Find the toggle **"Allow OAuth Username-Password Flows"**
4. Turn it **ON**
5. Click **Save**

---

## Confirm Lightning Experience

Verify you are in Lightning Experience (not Classic):
- Your URL should look like: `https://yourorg.lightning.force.com/...`
- The top navigation bar should have the App Launcher (9-dot grid icon) on the left

---

## Verification Checklist

Before proceeding to Step 2, confirm:

- [ ] You can log in at <https://login.salesforce.com>
- [ ] You received your security token by email
- [ ] "Allow OAuth Username-Password Flows" is toggled ON in Setup
- [ ] You are viewing Lightning Experience (not Classic)

---

**Navigation:** [← Required Tools](00-required-tools.md) | [README](../README.md) | [Next → User Setup →](02-user-setup.md)

**Official Reference:**
- Salesforce Developer signup: <https://developer.salesforce.com/signup>
- Reset security token: <https://help.salesforce.com/s/articleView?id=sf.user_security_token.htm>
