# Step 1: Sign Up for Salesforce Developer Edition

**Time:** ~20 minutes  
**What you will have when done:** A free, permanent Salesforce org with API access enabled.

---

## What is Salesforce Developer Edition?

Salesforce Developer Edition (DE) is a **free** Salesforce Platform environment that includes:

- Full API access (REST, SOAP, Streaming APIs)
- Lightning Platform, Apex, Flow Builder
- Agentforce (AI agent builder) and Data 360 (unified data platform)
- Custom objects, custom fields, automation
- Autonomous and generative AI features (usage may be limited by Salesforce)

**Key limits to know:**

| Resource | Developer Edition |
|---|---|
| User licenses | 2 standard + 1 admin |
| Data storage | 5–256 MB |
| File storage | 20 MB |
| API calls | ~15,000 per 24-hour rolling period |
| Sandboxes | Not available (requires paid org) |
| Inactivity | Deactivated after **45 days** of inactivity — log in periodically |

> **Not for production use.** Developer Edition is for learning, development, and proof-of-concept only.

---

## Sign Up

1. Go to **<https://www.salesforce.com/products/free-trial/developer/>**
2. Fill in the form:
   - First Name, Last Name
   - Job Title, Company (can be anything)
   - Country/Region
   - **Work email** — must be globally unique across *all* Salesforce orgs. If you get an error, try adding a `+tag` (e.g., `you+sfdev@gmail.com`)
3. Accept the Main Services Agreement and Salesforce Program Agreement
4. Click **Sign me up**
5. Check your email for a message from Salesforce. Check your spam folder if it does not arrive within 5 minutes.
6. Click the verification link in the email.
7. Set your **password** (use alphanumeric characters — special characters in passwords can cause authentication issues later).
8. You are now logged in.

> **Important:** Passwords are case-sensitive. Write yours down or save it in a password manager.

> **Note:** Your org may be provisioned on Hyperforce, Salesforce's public cloud infrastructure. This is normal and does not affect the API or UI experience.

---

## First Login

After signing up you will receive an email with a link to set your password. Click that link — it takes you directly into your org.

> **Hyperforce orgs: do not use `login.salesforce.com` directly.** If you try to log in there with your credentials, it will fail with "Please check your username and password." Instead, use one of these methods:
>
> **Option A — Use Custom Domain (recommended):**
> 1. Go to <https://login.salesforce.com>
> 2. Click **Use Custom Domain**
> 3. Enter your org's domain — e.g. `orgfarm-e7022cb898-dev-ed.develop.my` (everything before `.salesforce.com`)
> 4. Click **Continue**, then log in normally
>
> **Option B — Bookmark your org URL directly:**
> Your org URL from the verification email looks like `https://orgfarm-XXXXXXXX-dev-ed.develop.my.salesforce.com` — bookmark it and go there directly.

After signing up you will land in the Salesforce **Lightning Experience** — the modern web interface. All new Developer Edition orgs default to Lightning Experience; you should not need to switch.

If you ever see an older, tab-heavy interface (Salesforce Classic), switch back:
1. Click your **user avatar** (top right)
2. Click **Switch to Lightning Experience**

**Navigating Setup:** Almost everything you configure lives in the **Setup** menu. There are two ways to reach it:
- Click the **gear icon** (top right) → **Setup**
- Click your **user avatar** (top right) → **Settings**

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
4. Turn it **ON** — the toggle saves automatically; there is no Save button

---

## Confirm Lightning Experience

Verify you are in Lightning Experience (not Classic):
- The top navigation bar should have the App Launcher (9-dot grid icon) on the left
- Your URL will be one of these formats:
  - **New Hyperforce orgs:** `https://orgfarm-XXXXXXXX-dev-ed.develop.my.salesforce.com/...`
  - **Older orgs:** `https://yourorg.lightning.force.com/...`

Both are normal — the format depends on how Salesforce provisioned your org.

---

## Verification Checklist

Before proceeding to Step 2, confirm:

- [ ] You can log in to your org (via the link in your verification email, or via Use Custom Domain at login.salesforce.com)
- [ ] You received your security token by email
- [ ] "Allow OAuth Username-Password Flows" is toggled ON in Setup
- [ ] You are viewing Lightning Experience (not Classic)

---

**Navigation:** [← Required Tools](00-required-tools.md) | [README](../README.md) | [Next → User Setup →](02-user-setup.md)

**Official Reference:**
- Salesforce Developer signup: <https://salesforce.com/products/free-trial/developer/>
- Reset security token: <https://help.salesforce.com/s/articleView?id=sf.user_security_token.htm>
