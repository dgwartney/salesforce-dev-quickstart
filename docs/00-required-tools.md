# Step 0: Required Tools

Before you touch Salesforce, verify that all required tools are installed on your machine. This document covers tools for **running the examples** and for **contributing** to this repository.

---

## Tools to Run the Examples

| Tool | Purpose | Min Version | Required? |
|------|---------|-------------|-----------|
| **curl** | REST API calls in shell scripts | any recent | Required |
| **Python 3** | Python SDK examples | 3.9+ | Required for Python section |
| **uv** | Python virtual environment + package manager | latest | Required for Python section |
| **Node.js** | JavaScript/TypeScript examples | 18 LTS+ | Required for JS section |
| **npm** | JavaScript package manager | bundled with Node.js | Required for JS section |
| **jq** | JSON pretty-printing in curl output | any | Optional but recommended |

### Install by Operating System

**macOS (recommended: Homebrew)**
```bash
# Install Homebrew if not already installed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install tools
brew install node jq
brew install python   # if not already installed
```

**Ubuntu / Debian Linux**
```bash
sudo apt update
sudo apt install python3 python3-pip nodejs npm jq curl
```

**Windows**
- Python: <https://www.python.org/downloads/>
- Node.js: <https://nodejs.org/en/download>
- curl: included with Git Bash; install Git Bash from <https://git-scm.com/downloads>
- jq: <https://jqlang.github.io/jq/download/>

---

## Installing uv (Python Environment Manager)

`uv` is a fast, modern replacement for `pip` + `venv`. All Python setup in this repo uses `uv`. It creates virtual environments, installs packages, and runs scripts — without you needing to manually activate a virtual environment.

**macOS / Linux:**
```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

**Windows (PowerShell):**
```powershell
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
```

**Via Homebrew (macOS):**
```bash
brew install uv
```

**Via pip (if you already have Python):**
```bash
pip install uv
```

Verify: `uv --version`
Official docs: <https://docs.astral.sh/uv/>

**Using uv in this project:**
```bash
cd python/
uv venv                            # creates .venv/
uv pip install -r requirements.txt # installs packages
uv run python 01_authenticate.py   # runs script (no manual activate needed)
```

---

## Verify All Tools Are Installed

Paste this into your terminal. All lines should print a version number:

```bash
python3 --version && \
uv --version && \
node --version && \
npm --version && \
curl --version | head -1 && \
echo "✓ All required tools found"
```

Optional (jq):
```bash
jq --version && echo "✓ jq found (optional)"
```

---

## Tools for Contributing to This Repository

If you want to add examples, fix documentation, or update diagrams, you also need:

| Tool | Purpose | Install |
|------|---------|---------|
| **git** | Version control | <https://git-scm.com/downloads> |
| **gh CLI** | GitHub repository management | <https://cli.github.com> |
| **npx** (via npm) | Run mermaid-cli without global install | bundled with Node.js |
| **@mermaid-js/mermaid-cli** | Generate SVG diagrams from `.mmd` files | `npx -p @mermaid-js/mermaid-cli mmdc` |
| **Chromium** | Headless browser used by mermaid-cli | Auto-installed on first `npx mmdc` run |
| **VS Code** (optional) | Recommended editor | <https://code.visualstudio.com> |

Recommended VS Code extensions:
- `bierner.markdown-mermaid` — live Mermaid diagram preview
- `davidanson.vscode-markdownlint` — markdown linting
- `ms-python.python` — Python support
- `esbenp.prettier-vscode` — code formatting

---

## Tools for Building the Offline PDF

The `make pdf` command compiles all documentation into a single typeset PDF using pandoc and XeLaTeX.

| Tool | Purpose | Install |
|------|---------|---------|
| **pandoc v3.0+** | Markdown → PDF conversion | macOS: `brew install pandoc`; Linux: `apt install pandoc` |
| **XeLaTeX** | PDF rendering engine | macOS: see below; Linux: `apt install texlive-xetex texlive-latex-extra` |
| **DejaVu Fonts** | PDF body/code fonts | macOS: `brew install font-dejavu`; Linux: `apt install fonts-dejavu-extra` |
| **rsvg-convert** | SVG → PNG conversion (for PDF) | macOS: `brew install librsvg`; Linux: `apt install librsvg2-bin` |

**macOS — lightweight install (recommended, ~150 MB):**
```bash
brew install pandoc basictex librsvg font-dejavu
sudo tlmgr update --self
sudo tlmgr install fancyhdr
```

**macOS — full MacTeX (~4 GB, use if lightweight has issues):**
```bash
brew install pandoc librsvg
brew install --cask mactex-no-gui
brew install font-dejavu
```

**Ubuntu / Debian Linux:**
```bash
sudo apt install pandoc texlive-xetex texlive-latex-extra fonts-dejavu-extra librsvg2-bin
```

**Windows:** Install MiKTeX (<https://miktex.org/>) + pandoc + rsvg-convert. DejaVu fonts from <https://dejavu-fonts.github.io/>.

**Build the PDF:**
```bash
make pdf       # builds salesforce-dev-quickstart.pdf
make clean     # removes generated PDF and PNG files
make help      # show all available targets
```

---

**Navigation:** [README](../README.md) | [Next → Sign Up & Setup](01-signup-and-setup.md)
