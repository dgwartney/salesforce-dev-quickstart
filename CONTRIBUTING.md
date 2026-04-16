# Contributing to salesforce-dev-quickstart

Thank you for helping improve this guide. This document covers everything you need to add examples, fix documentation, or update diagrams.

---

## Required Tools

All tool requirements are documented in [docs/00-required-tools.md](docs/00-required-tools.md). That file covers:

- **To run the examples:** curl, Python 3.9+, uv, Node.js 18+, jq
- **To build the PDF:** pandoc, XeLaTeX, DejaVu fonts, rsvg-convert
- **To update diagrams:** Node.js + npx (mermaid-cli runs without global install)
- **To contribute:** git, gh CLI, VS Code (optional)

Quick install checks:
```bash
# End users
uv --version && python3 --version && node --version && curl --version | head -1

# Contributors
git --version && gh --version
```

---

## Repository Structure

```
salesforce-dev-quickstart/
├── docs/               Markdown guides (00–09, glossary, learning-resources, progress-checklist)
│   ├── diagrams/       Mermaid source (.mmd) + generated SVG (.svg)
│   └── front-matter.yaml  pandoc PDF metadata
├── python/             Python CRUD examples (simple-salesforce)
├── javascript/         JavaScript/TypeScript CRUD examples (jsforce)
├── curl/               Shell scripts for curl-based CRUD
├── Makefile            Build PDF and diagrams
└── .env.example        Credential template
```

---

## Contribution Workflow

1. **Fork** the repo on GitHub
2. **Clone** your fork locally
3. **Create a branch**: `git checkout -b my-improvement`
4. **Make your changes** (see sections below)
5. **Test your changes** (see verification steps)
6. **Commit**: `git commit -m "brief description of change"`
7. **Push**: `git push origin my-improvement`
8. **Open a Pull Request** with a description of what you added and why

---

## Adding or Updating Documentation

- Keep documentation in the `docs/` directory
- Follow the existing document structure: each numbered doc ends with a navigation footer linking to the previous and next doc
- Link to official Salesforce documentation where it exists rather than duplicating content
- If you add a new doc, update the learning path table in `README.md`

---

## Adding Code Examples

**Python:** Add a new numbered script in `python/`. Import the shared helper:
```python
from auth import get_salesforce_connection
sf = get_salesforce_connection()
```
Update `python/requirements.txt` if you add a dependency.

**JavaScript:** Add a new numbered script in `javascript/`. Use CommonJS:
```javascript
require('dotenv').config();
const { getConnection } = require('./auth');
```
Update `javascript/package.json` if you add a dependency.

**curl:** Add a new script in `curl/`. Source the auth script at the top:
```bash
#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/authenticate.sh"
```

---

## Updating Diagrams

Diagrams have two files each: a `.mmd` Mermaid source and a `.svg` generated output. **Edit the `.mmd` source, then regenerate the SVG.**

```bash
# Regenerate a single diagram
npx -p @mermaid-js/mermaid-cli mmdc \
  -i docs/diagrams/data-model.mmd \
  -o docs/diagrams/data-model.svg \
  --backgroundColor white

# Or regenerate all (uses make)
make diagrams
```

**Commit both files** — the `.mmd` source and the regenerated `.svg`.

Mermaid syntax reference: <https://mermaid.js.org/intro/>

VS Code extension for live preview: `bierner.markdown-mermaid`

---

## Building the PDF

```bash
make pdf       # builds salesforce-dev-quickstart.pdf
make clean     # removes generated PDF and PNG files
make help      # show all available targets
```

The generated `salesforce-dev-quickstart.pdf` is excluded from git (see `.gitignore`). Do not commit it.

---

## Verifying Your Changes

Before opening a PR:

- [ ] All markdown links resolve (no broken `../` paths)
- [ ] If you updated a `.mmd` file, the corresponding `.svg` is regenerated and committed
- [ ] Code examples run without errors against a live Developer Edition org
- [ ] `make pdf` completes without errors (if you have the PDF build tools)
- [ ] No credentials or `.env` files committed

---

## Code of Conduct

Be kind, be specific, and help beginners. This guide exists to lower the barrier to Salesforce development — contributions that improve clarity for novice users are especially welcome.
