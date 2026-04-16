# Step 4: Salesforce UI Walkthrough — Accounts, Contacts, and Cases

**Time:** ~80 minutes  
**What you will have when done:** Real data in your org (at least one Account, Contact, and Case) and a solid understanding of the CRM data model — which you will need for the API sections.

---

## The CRM Data Model

Before creating anything, take 5 minutes to understand how the three core objects relate to each other.

![Data Model](diagrams/data-model.svg)

| Object | What It Represents | Salesforce Name | Required Field |
|--------|-------------------|-----------------|----------------|
| Company | A business or organization | **Account** | Name |
| Person | An individual contact at a company | **Contact** | Last Name |
| Support Ticket | A customer issue or request | **Case** | Subject |

> **Lead vs. Contact:** A Lead is an *unqualified* prospect not linked to an Account. This guide uses Contacts only — Leads belong to sales funnel workflows outside our scope.

### Relationships

- An **Account** can have many **Contacts** (1-to-many)
- An **Account** can have many **Cases** (1-to-many)
- A **Contact** can be linked to many **Cases** (1-to-many)
- A **Case** is linked to one Account and one Contact (optional but recommended)

### Record IDs

Every record in Salesforce has a unique **Record ID** — a 15 or 18-character alphanumeric string (e.g., `0010g00001mbqU4AAI`). You will see it in the browser URL when viewing a record. **Write down the Record IDs** of records you create — you will use them in the API examples.

---

## Part A: Accounts (Companies) · ~25 min

### Add Accounts to Navigation

If you do not see an **Accounts** tab in the top navigation:
1. Click the **App Launcher** (9-dot grid icon, top left)
2. Search for `Accounts` and click it

Or add it permanently:
1. Setup → App Manager → find your current app → dropdown → Edit
2. Navigation Items → Add Item → select Accounts → Save

### Create an Account

1. Click the **Accounts** tab
2. Click **New**
3. Fill in:
   - **Account Name:** `Acme Corporation` (required)
   - **Phone:** `(555) 100-0001`
   - **Industry:** `Technology`
   - **Billing City:** `San Francisco`
   - **Billing State:** `CA`
4. Click **Save**

You are now on the Account detail page. **Copy the Record ID from the URL bar.** It looks like: `https://yourorg.lightning.force.com/lightning/r/Account/0010g00001mbqU4AAI/view`
The ID is the part after `/Account/` and before `/view`.

### Explore the Account Detail Page

- **Related lists** at the bottom: Contacts, Cases, Opportunities, etc.
- **Activity Timeline** on the right: log calls, emails, tasks
- **Inline edit**: click any field value to edit it directly

Create a second Account with a different name so you have multiple records to query.

---

## Part B: Contacts (People) · ~25 min

### Create a Contact

1. Click the **Contacts** tab (add it via App Launcher if missing)
2. Click **New**
3. Fill in:
   - **First Name:** `Jane`
   - **Last Name:** `Smith` (required)
   - **Account Name:** `Acme Corporation` (type to search, then select)
   - **Email:** `jane.smith@acme.example.com`
   - **Phone:** `(555) 100-0002`
4. Click **Save**

**Copy the Contact Record ID** from the URL.

### Understanding the Contact ↔ Account Relationship

After saving, click on the Account Name link to return to Acme Corporation. Scroll down to the **Contacts** related list — Jane Smith should appear there. This demonstrates the relationship: Contact is a "child" of Account.

> **Private Contacts:** A Contact without an Account Name is a "private contact" — only visible to the owner and admins. Always link Contacts to Accounts for proper visibility.

Create a second Contact linked to the same Account.

---

## Part C: Cases (Support Tickets) · ~25 min

### Add Cases to Navigation

Cases may not appear in the default Sales app navigation. To add it:
1. Click the **App Launcher** → search `Service Console` → click it
2. Cases will be in the navigation

Or add Cases to your current app (Setup → App Manager → Edit → Navigation Items → Add Cases).

### Create a Case

1. Click the **Cases** tab
2. Click **New**
3. Fill in:
   - **Subject:** `Login button not working on mobile` (required)
   - **Status:** `New`
   - **Priority:** `High`
   - **Origin:** `Web`
   - **Account Name:** `Acme Corporation` (lookup)
   - **Contact Name:** `Jane Smith` (lookup)
   - **Description:** `Customer reports the login button on the mobile app does not respond when tapped on iOS 17.`
4. Click **Save**

**Copy the Case Record ID** from the URL (starts with `500`).

### Update a Case

1. On the Case detail page, click **Edit** (or click the Status field directly for inline edit)
2. Change **Status** from `New` to `Working`
3. Click **Save**

### Add a Custom Field to Cases (optional, ~5 min)

Custom fields let you capture data specific to your use case. Here is how to add one:

1. Setup → Object Manager → Case → **Fields & Relationships** → New
2. Select **Text** → Next
3. Field Label: `Customer Impact` | Field Name: `Customer_Impact` (auto-filled)
4. Length: `255`
5. Click Next → Next → Save

Your new field `Customer_Impact__c` (note the `__c` suffix — all custom fields have it) now appears on the Case form.

---

## Summary

You now have:

| Object | Count | Record IDs to save |
|--------|-------|--------------------|
| Accounts | 2 | Copy from URL: `001...` |
| Contacts | 2 | Copy from URL: `003...` |
| Cases | 1 | Copy from URL: `500...` |

These Record IDs are used in every API example in Steps 5–7. **Record them in [progress-checklist.md](progress-checklist.md)** before continuing.

---

**Navigation:** [← Connected App](03-connected-app.md) | [README](../README.md) | [Next → curl Quickstart →](05-curl-quickstart.md)

**Official Reference:**
- Work with Accounts: <https://help.salesforce.com/s/articleView?id=sf.accounts.htm>
- Work with Cases: <https://help.salesforce.com/s/articleView?id=sf.cases_overview.htm>
- Custom fields: <https://help.salesforce.com/s/articleView?id=sf.customize_customfields.htm>
