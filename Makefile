# Salesforce Developer Quickstart — PDF Build
# ─────────────────────────────────────────────
# Requires: pandoc, xelatex, librsvg (rsvg-convert), DejaVu fonts
# Install:  see docs/00-required-tools.md (PDF Build section)
#
# Usage:
#   make pdf    — build the complete PDF guide
#   make clean  — remove the generated PDF
#   make help   — show this help

PANDOC := pandoc
OUTPUT := salesforce-dev-quickstart.pdf

# Documents included in the PDF, in reading order
DOCS := docs/front-matter.yaml \
        docs/progress-checklist.md \
        docs/glossary.md \
        docs/00-required-tools.md \
        docs/01-signup-and-setup.md \
        docs/02-user-setup.md \
        docs/03-connected-app.md \
        docs/04-ui-walkthrough.md \
        docs/05-curl-quickstart.md \
        docs/06-python-guide.md \
        docs/07-javascript-guide.md \
        docs/08-troubleshooting.md \
        docs/09-developer-edition-scope.md \
        docs/learning-resources.md

.PHONY: all pdf clean help

## all: Build the complete offline PDF guide (default target)
all: pdf

## help: Show available make targets
help:
	@grep -E '^## ' Makefile | sed 's/## /  /'

## pdf: Build the complete offline PDF guide
pdf: $(OUTPUT)

$(OUTPUT): $(DOCS) Makefile
	$(PANDOC) \
		--from=markdown+yaml_metadata_block \
		--resource-path=docs \
		-o $@ \
		$(DOCS)
	@echo ""
	@echo "Built: $(OUTPUT)"

## clean: Remove the generated PDF
clean:
	rm -f $(OUTPUT)
	@echo "Cleaned generated files"
