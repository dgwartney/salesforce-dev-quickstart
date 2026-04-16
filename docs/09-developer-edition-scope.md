# Developer Edition Scope — What You Can and Cannot Do

This document describes what is and is not available in the free Salesforce Developer Edition, with emphasis on Einstein, Agentforce, and other AI/advanced features. Linked from the README's "What this repo does NOT cover" callout.

---

## Developer Edition Capabilities

| Category | Available in Free Dev Edition? | Notes |
|---|---|---|
| REST API (Accounts, Contacts, Cases) | Yes | Core scope of this repo |
| SOQL / SOSL queries | Yes | Full query support |
| Custom Fields and Objects | Yes | Up to 10 custom objects |
| Apex (server-side code) | Yes | Execution limits apply |
| Flows and Process Builder | Yes | Declarative automation |
| Lightning Web Components | Yes | Front-end framework |
| Agentforce (Agent Builder) | Yes — limited | 110 req/mo, 1.5M tokens/mo until May 2026 |
| Data Cloud | Yes | Full access since March 2025 |
| Prompt Builder | Yes | Create reusable AI prompts |
| Einstein Copilot / Agentforce Assistant | Yes | Built-in AI assistant |
| Einstein for Developers (code autocomplete) | Yes | Apex + LWC + HTML |
| Einstein Prediction Builder | Yes (1 prediction) | Machine learning model creation |
| CRM Analytics / Einstein Analytics | Special signup only | Separate org at trailhead.salesforce.com/promo/orgs/analytics-de |
| Sales Cloud Einstein | No | Requires paid Enterprise/Unlimited add-on |
| Service Cloud Einstein (Case Classification) | Special signup only | Requires 400+ closed cases |
| Einstein 1 Edition (full AI bundle) | No | $500/user/month |
| Sandboxes | No | Require a paid production org |
| User licenses beyond 3 | No | 2 standard + 1 admin — hard limit |
| Data storage upgrades | No | 5–256 MB only; no upgrade path |
| File storage upgrades | No | 20 MB only |

---

## What is Agentforce?

Agentforce is Salesforce's AI agent platform. An Agentforce agent can:
- Answer questions using your org's data
- Take actions in Salesforce (create records, send emails, run flows)
- Connect to external systems via API calls
- Use custom prompts and reasoning steps you define

**In Developer Edition (as of 2025):**
- 110 agent requests per month
- 1.5M tokens per month
- Monthly limit resets; current offer runs through May 31, 2026

Agentforce setup requires Agent Builder (in Setup) and at least one configured data source or action. This is out of scope for this repo — its setup is a multi-step process that assumes familiarity with Salesforce configuration concepts covered in Trailhead.

**Learn more:**
- Blog post: <https://developer.salesforce.com/blogs/2025/03/introducing-the-new-salesforce-developer-edition-now-with-agentforce-and-data-cloud>
- Agentforce Developer Guide: <https://developer.salesforce.com/docs/ai/agentforce/>
- Agentforce Trailhead trail: <https://trailhead.salesforce.com/content/learn/trails/build-deploy-agentforce-agents>

---

## Connecting an External LLM (Bring Your Own LLM)

When the default Salesforce LLM is not sufficient, you can connect your own LLM provider through Salesforce's Einstein Trust Layer. All requests are routed through the Trust Layer, which provides data masking and zero data retention guarantees.

**Setup path:** Setup → Einstein Setup → Models → Add External Model

| Provider | Credential Required | Where to Get It |
|---|---|---|
| OpenAI (GPT-4, GPT-4o) | API Key | <https://platform.openai.com/api-keys> |
| Anthropic (Claude) | API Key | <https://console.anthropic.com> |
| Google Vertex AI / Gemini | Service Account JSON | Google Cloud Console → IAM |
| AWS Bedrock (Claude, Llama) | Access Key + Secret Key | AWS Console → IAM |
| Azure OpenAI | API Key + Endpoint URL | Azure Portal → Azure OpenAI resource |
| Self-hosted (Ollama, LM Studio) | Local URL via connector | Requires MuleSoft or LLM Open Connector |

### Self-hosted Models (Ollama)

Running a local model (e.g., Llama 3, Mistral) with Ollama and connecting it to Salesforce requires an additional connector layer because Salesforce cannot call `localhost` directly.

Options:
1. **MuleSoft Anypoint** (enterprise) — proxies Ollama through a MuleSoft API
2. **LLM Open Connector** (open source) — lightweight proxy specifically for Ollama + Salesforce: <https://opensource.salesforce.com/einstein-platform/mulesoft-ollama>
3. **ngrok** — expose your local Ollama port temporarily (development only, not for production)

Full BYOLLM setup is out of scope for this repo, but the resources below are the right starting point:
- Salesforce BYOLLM guide: <https://developer.salesforce.com/blogs/2024/03/bring-your-own-large-language-model-in-einstein-1-studio>
- LLM Open Connector + Ollama: <https://opensource.salesforce.com/einstein-platform/mulesoft-ollama>
- Einstein Trust Layer overview: <https://help.salesforce.com/s/articleView?id=sf.generative_ai_trust_layer.htm>

---

## What This Repo Deliberately Does NOT Cover

| Topic | Why excluded |
|---|---|
| Apex | Salesforce's proprietary server-side language; requires the Salesforce DX toolchain and a separate learning track |
| Lightning Web Components | Salesforce's front-end framework; a separate discipline from REST API work |
| Salesforce DX / scratch orgs | Deployment tooling for team-based development; assumes Salesforce familiarity |
| Metadata API | For deploying configuration changes between orgs; beyond the scope of learning the REST API |
| SOSL (Salesforce Object Search Language) | Full-text search; complementary to SOQL but a separate topic |
| Flows and Process Builder | Declarative automation; no code required but separate learning track |
| Change Sets | Legacy deployment tool; superseded by Salesforce DX |
| Marketing Cloud | A separate product with its own API surface |
| Commerce Cloud | A separate product with its own API surface |
| CPQ (Configure, Price, Quote) | A separate product add-on |
| Managed Packages / AppExchange | ISV development; requires Partner Developer Edition |
| Agentforce full setup | Requires significant Salesforce admin knowledge as a prerequisite |

---

## When You Outgrow Developer Edition

Signs you need a paid org:
- You need more than 2 standard user licenses
- You need more than 256 MB of data storage
- You need sandboxes for testing before deploying to production
- You are building for production traffic

**Next steps for learning:**
- **Trailhead Playground** — another free org type, optimized for Trailhead exercises
- **Developer Pro Sandbox** (requires paid production org) — a full-copy sandbox for serious development
- **Enterprise Edition trial** — 30-day full-featured trial

**Data migration:** Configuration (custom fields, Connected Apps, etc.) can be moved between orgs using the Metadata API or Salesforce DX. Data records must be migrated manually using Data Loader or the Bulk API.

---

**Navigation:** [← Troubleshooting](08-troubleshooting.md) | [README](../README.md)

**Official Reference:**
- Developer Edition limits: <https://help.salesforce.com/s/articleView?id=sf.overview_limits_general.htm>
- Einstein AI features: <https://developer.salesforce.com/docs/einstein/genai/guide/>
- Agentforce: <https://developer.salesforce.com/docs/ai/agentforce/>
