# Salesforce Developer Quickstart — PDF Build
# ─────────────────────────────────────────────
# Requires: pandoc, xelatex, rsvg-convert, DejaVu fonts
# Install:  see docs/00-required-tools.md (PDF Build section)
#
# Usage:
#   make pdf       — build the complete PDF guide
#   make diagrams  — convert SVG diagrams to PNG for PDF embedding
#   make clean     — remove generated PDF and PNG files
#   make help      — show this help

PANDOC     := pandoc
PDF_ENGINE := xelatex
OUTPUT     := salesforce-dev-quickstart.pdf

# SVG sources → PNG targets (XeLaTeX cannot embed SVG directly)
DIAGRAM_SVGS := docs/diagrams/journey-map.svg \
                docs/diagrams/data-model.svg \
                docs/diagrams/user-architecture.svg

DIAGRAM_PNGS := $(DIAGRAM_SVGS:.svg=.png)

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

.PHONY: pdf diagrams clean help

## help: Show available make targets
help:
	@grep -E '^## ' Makefile | sed 's/## /  /'

## pdf: Build the complete offline PDF guide
pdf: diagrams $(OUTPUT)

$(OUTPUT): $(DOCS) $(DIAGRAM_PNGS)
	$(PANDOC) \
		--pdf-engine=$(PDF_ENGINE) \
		--from=markdown+yaml_metadata_block \
		--toc \
		--toc-depth=2 \
		--number-sections \
		--highlight-style=tango \
		-o $@ \
		$(DOCS)
	@echo ""
	@echo "✓ Built: $(OUTPUT)"

## diagrams: Convert SVG diagrams to PNG for PDF embedding (300 DPI)
diagrams: $(DIAGRAM_PNGS)

docs/diagrams/%.png: docs/diagrams/%.svg
	rsvg-convert -f png -d 300 -p 300 -o $@ $<

## clean: Remove generated PDF and PNG files
clean:
	rm -f $(OUTPUT) $(DIAGRAM_PNGS)
	@echo "✓ Cleaned generated files"
