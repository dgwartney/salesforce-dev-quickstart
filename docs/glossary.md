# Salesforce Glossary for Developers

This glossary covers Salesforce-specific terms that may be unfamiliar to developers coming from non-CRM backgrounds. Terms are organized by category.

**Existing reference glossaries** (linked here because they complement this one):
- [Salesforce Ben: Key Terminology for Beginners](https://www.salesforceben.com/key-salesforce-terminology-for-beginners/) — business and admin terms
- [Lightning Platform Developer Glossary](https://developer.salesforce.com/docs/atlas.en-us.salesforce_platform_glossary.meta/salesforce_platform_glossary) — official technical terms
- [Salesforce Ben: Apex Glossary](https://www.salesforceben.com/salesforce-apex-glossary/) — advanced developer terms

The glossary below focuses on terms you will encounter in this quickstart guide that the above resources do not explain clearly for a REST API developer.

---

## Org and Instance Concepts

**Org (Organization)**
A single Salesforce tenant — your isolated environment with its own data, users, configuration, and custom code. When someone says "your org", they mean your specific Salesforce instance. Multiple orgs can exist under one company (e.g., development org, sandbox, production).

**Developer Edition**
A free, permanent Org intended for learning and development. Includes full API access but has hard limits: 2 standard user licenses, ~15,000 API calls/day, and 5–256 MB data storage. Cannot be upgraded to a paid tier — it is a separate product.

**Sandbox**
A copy of a production Org used for testing before deploying changes to production. Requires a paid production Org. Sandboxes use `test.salesforce.com` as the login endpoint (not `login.salesforce.com`).

**Instance**
The physical server cluster hosting your Org (e.g., NA91, EU15). The instance name appears in your login URL. You rarely need to care about this directly.

**My Domain**
A custom subdomain for your Org. Required for several features including SSO, connected apps, and Lightning components. Developer Edition orgs get a My Domain automatically. Hyperforce-provisioned orgs use a generated domain like `orgfarm-XXXXXXXX-dev-ed.develop.my.salesforce.com`.

**Trailhead**
Salesforce's free gamified online learning platform. Separate from a production Org. Trailhead has its own "playground" orgs for hands-on exercises. Link: <https://trailhead.salesforce.com>

**Trailblazer**
A member of the Salesforce community. Also the name of the community platform (<https://trailhead.salesforce.com/trailblazer-community>). Unrelated to technical functionality.

---

## Data Model Concepts

**sObject (Standard Object)**
A built-in Salesforce database table — Account, Contact, Case, Lead, Opportunity, etc. The "s" stands for Salesforce, not Standard. In the REST API, sObjects are accessed via `/services/data/v62.0/sobjects/Account/`.

**Custom Object**
A user-defined database table created in Setup → Object Manager. Custom object API names always end in `__c` (e.g., `Support_Ticket__c`). Developer Edition supports up to 10 custom objects.

**Record**
A single row in an sObject table. Equivalent to a database row. Every record has a unique Record ID.

**Field**
A column in an sObject table — stores one piece of data per record. Equivalent to a database column.

**Custom Field**
A user-defined field added to a standard or custom object. Custom field API names always end in `__c` (e.g., `Customer_Impact__c`). The label (display name) can be changed; the API name cannot.

**Record ID**
A unique 15 or 18-character alphanumeric string identifying a record. The 15-character ID is case-sensitive; the 18-character ID (used in APIs) is case-insensitive. Record IDs appear in the Salesforce UI URL: `.../Account/0010g00001mbqU4AAI/view`. The first three characters identify the object type (e.g., `001` = Account, `003` = Contact, `500` = Case).

**Relationship Field**
A field that links one record to another — like a foreign key in a relational database. There are two types: Lookup and Master-Detail.

**Lookup (Relationship)**
A non-required relationship field. A Contact has a Lookup to Account via `AccountId`. The child record (Contact) can exist without the parent (Account). Deleting the parent does not cascade-delete the children.

**Master-Detail (Relationship)**
A required, tightly coupled relationship. The child record cannot exist without the parent. Deleting the parent cascades to delete all children. Roll-up summary fields (count, sum, min, max) are only available on Master-Detail relationships.

**External ID**
A custom field designated as unique and marked as an External ID. Used for upsert operations (`UPSERT` in bulk loading, or `sf.Account.upsert()` in Python). Essential for data migration when you need to match records by your own system's ID rather than Salesforce's Record ID.

---

## Core CRM Objects

**Account**
Represents a company or organization. Called "Account" in Salesforce — not "Company", "Organization", or "Client". Required field: `Name`. Record IDs start with `001`.

**Contact**
Represents an individual person, typically an employee of an Account. Required field: `LastName`. Linked to Account via `AccountId` (Lookup). Record IDs start with `003`. A Contact without an AccountId is a "private contact" — only visible to the owner and admins.

**Case**
A customer support ticket or inquiry. The core object of Service Cloud. Required field: `Subject`. Linked to Account via `AccountId` and optionally to a Contact via `ContactId`. Record IDs start with `500`.

**Lead**
An unqualified prospect who is NOT yet linked to an Account. Has its own fields (`Company`, `LeadSource`, `Rating`). Converting a Lead creates three new records: Contact + Account + Opportunity. This guide uses Contacts only — Leads belong to sales funnel workflows.

**Opportunity**
A potential sales deal linked to an Account. Has a stage (`Prospecting`, `Closed Won`, etc.) and a close date. Out of scope for this guide but commonly encountered in real orgs.

**Task / Event**
Activities — a phone call, email, or meeting. Logged on Account, Contact, or Case records. Appear in the Activity Timeline on record detail pages.

---

## API and Query Concepts

**REST API**
Salesforce's HTTP-based API for CRUD operations on records. What this guide uses. Base URL: `https://yourorg.my.salesforce.com/services/data/v62.0/`. Standard HTTP verbs apply: POST (create), GET (read), PATCH (update), DELETE (delete).

**SOAP API**
An older XML-based API. Being deprecated for authentication purposes in Summer '27 (API v65.0). The `jsforce` library currently uses SOAP for `conn.login()` — this will need to migrate to OAuth 2.0 flows before deprecation.

**Bulk API**
An API for loading or exporting large volumes of records (thousands to millions). Uses asynchronous jobs. Not covered in this guide but important for data migration.

**Streaming API**
An API for subscribing to real-time data change notifications (e.g., "notify me when any Case status changes"). Uses long-polling or Bayeux protocol. Not covered in this guide.

**SOQL (Salesforce Object Query Language)**
Salesforce's SQL-like query language for querying records. Key differences from SQL:
- `SELECT *` is NOT supported — you must list fields explicitly
- No `JOIN` keyword — use relationship traversal dot notation instead
- `NULL` comparisons use lowercase `null` (not `IS NULL`)
- `LIMIT` applies globally, not per-page

Example: `SELECT Id, Name, Phone FROM Account WHERE Industry = 'Technology' LIMIT 10`

**SOSL (Salesforce Object Search Language)**
Full-text search across multiple objects simultaneously. Different from SOQL. Example: `FIND {Acme} IN ALL FIELDS RETURNING Account(Id, Name), Contact(Id, Name)`. Not covered in this guide.

**API Version**
Salesforce releases 3 times per year (Spring, Summer, Winter). Each release has a version number: Spring '26 = v62.0. New features require newer API versions. This guide uses v62.0. Features do not disappear between versions — older API versions remain available.

**Governor Limits**
Hard execution limits enforced per API transaction in Apex (e.g., maximum 100 SOQL queries per transaction). Governor limits protect multi-tenant infrastructure from resource abuse. Governor limits apply inside Apex code — REST API calls you make externally are not subject to them, but each REST API call counts against your daily API call quota.

---

## Authentication and Security

**Connected App**
An OAuth 2.0 application registration in Salesforce — equivalent to registering an app with Google or GitHub to get a client ID and secret. Required for programmatic API access. Issues a Consumer Key (client_id) and Consumer Secret (client_secret).

**Consumer Key**
The OAuth `client_id` for a Connected App. Public — safe to log. Changes if you reset it.

**Consumer Secret**
The OAuth `client_secret` for a Connected App. Treat like a password — never commit to source control. Shown only once when created; reset generates a new one.

**Security Token**
A personal authentication token generated by Salesforce for each user. Required for API access from IP addresses not on your trusted IP list. Appended directly to the password (no separator) in curl and JavaScript. Passed as a separate parameter in Python's `simple-salesforce`. Reset via: user avatar → Settings → Quick Find: Reset My Security Token.

**OAuth 2.0**
The authentication protocol Salesforce uses for API access. This guide uses the **Username-Password flow** (`grant_type=password`) — the simplest flow for learning and automation. Production systems often use JWT Bearer or Client Credentials flows instead.

**Access Token**
A short-lived Bearer token returned by the OAuth token endpoint. Used in the `Authorization: Bearer {token}` HTTP header on all API calls. Expires after 2 hours by default.

**Instance URL**
The base URL for your specific org returned in the OAuth token response: `https://yourorg.my.salesforce.com`. Use this (not `login.salesforce.com`) for all API calls after authentication.

**Einstein Trust Layer**
Salesforce's data security layer for AI/LLM API calls. Provides data masking (replaces PII with anonymized placeholders before sending to the LLM) and zero data retention guarantees (LLM providers cannot store or train on your data). All Salesforce AI features route through the Trust Layer automatically.

**Named Credential**
A stored, encrypted external service credential in Salesforce. Avoids hardcoding secrets in Apex code or Flow configurations. Used by developers building Salesforce integrations from within the platform. Out of scope for this guide but commonly seen in enterprise configurations.

---

## Admin and Setup Concepts

**Setup**
Salesforce's administrative configuration area. Accessed via the gear icon -> Setup. Contains Quick Find search for navigating to any configuration page. Virtually everything you configure lives here.

**Object Manager**
The section of Setup for managing sObject fields, page layouts, and relationships. Setup → Object Manager → select an object.

**Profile**
A base permission template. Every Salesforce user has exactly one Profile. Controls what a user can see and do at a baseline level. The System Administrator Profile is read-only — clone it to customize. Salesforce is moving away from Profiles toward Permission Sets.

**Permission Set**
Additional permissions granted on top of a user's Profile. A user can have zero or many Permission Sets. Best practice: use the most restrictive Profile possible, then grant specific access via Permission Sets.

**Page Layout**
Controls which fields appear on a record detail page and in what order. Users with different Profiles or Record Types can see different page layouts. Configured in Setup → Object Manager → [Object] → Page Layouts.

**App**
A collection of tabs and navigation items grouped for a specific use case (e.g., Sales app, Service Console). Configured in Setup → App Manager. Users can switch between Apps using the App Launcher (9-dot grid icon).

**Lightning Experience**
The modern Salesforce web UI, introduced in 2016. Default for all new orgs. Your URL will look like `yourorg.lightning.force.com` or, for newer Hyperforce-provisioned orgs, `orgfarm-XXXXXXXX-dev-ed.develop.my.salesforce.com`. Contrast with Salesforce Classic, the older UI that still exists for legacy reasons.

**API Name**
The programmatic identifier for an object or field. Immutable after creation. Custom items end in `__c`. Used in REST API calls, SOQL queries, and code. The display Label can be changed; the API Name cannot.

---

## AI and Ecosystem Terms

**Einstein**
Salesforce's umbrella brand for AI features. Includes Einstein Prediction Builder (ML models), Einstein Copilot/Agentforce (conversational AI agents), Einstein for Developers (code autocomplete), and more.

**Agentforce**
Salesforce's AI agent platform. Enables AI agents that can reason, take actions in Salesforce, and connect to external systems. Available in Developer Edition with monthly usage limits. Requires Agent Builder setup.

**Prompt Builder**
A low-code tool in Salesforce for creating reusable AI prompts. Prompts can reference record data and be used in flows, Einstein features, and Agentforce agents.

**Data Cloud**
Salesforce's real-time data platform for unifying customer data from multiple sources (Salesforce, marketing tools, web analytics, etc.) into a single customer profile. Available in Developer Edition as of March 2025.

**BYOLLM (Bring Your Own LLM)**
Salesforce feature allowing you to connect an external LLM (OpenAI, Anthropic, Google Vertex AI, AWS Bedrock, or self-hosted Ollama) to Einstein features. Requests route through the Einstein Trust Layer. See [Developer Edition Scope](09-developer-edition-scope.md) for required credentials.

---

**Navigation:** [README](../README.md)
