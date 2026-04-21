# Office Skills Pro

> 12 battle-tested skills for Claude Code that turn it into a complete office-automation specialist — covering the four core file formats (Word / Excel / PowerPoint / PDF) plus workflows for document co-authoring, meeting analysis, email, contracts, data cleaning, report building, form automation, and cross-format orchestration.

Inspired by and synthesized from:
- [anthropics/skills](https://github.com/anthropics/skills) — Anthropic's official skills (office document patterns, QA loops, design principles)
- [alirezarezvani/claude-skills](https://github.com/alirezarezvani/claude-skills) — Commercial office patterns (contracts, meeting analysis)
- Real-world usage in small-business, SaaS, and freelance contexts

All skills here are **original implementations** using open-source libraries (python-docx, openpyxl, python-pptx, pypdf, pymupdf, pandas, reportlab). MIT licensed — fork, modify, ship.

## The 12 Skills

| Skill | What it does |
|-------|--------------|
| [**docx-pro**](skills/docx-pro/SKILL.md) | Word document creation, editing, templates, tracked changes, conversion |
| [**xlsx-pro**](skills/xlsx-pro/SKILL.md) | Excel automation with financial-grade standards — formulas, color coding, zero errors |
| [**pptx-pro**](skills/pptx-pro/SKILL.md) | Presentations that look *designed*, not templated — 10 palettes, QA loops, anti-slop discipline |
| [**pdf-pro**](skills/pdf-pro/SKILL.md) | Full PDF toolkit — merge, split, OCR, forms, redaction, encryption, comparison |
| [**doc-coauthor**](skills/doc-coauthor/SKILL.md) | 3-stage structured workflow for PRDs, RFCs, specs, decision docs |
| [**email-pro**](skills/email-pro/SKILL.md) | Professional email composition, sequences, templates, anti-patterns to kill |
| [**meeting-analyzer**](skills/meeting-analyzer/SKILL.md) | Transcript analysis — speaking dynamics, hedging, fillers, coaching feedback |
| [**contract-pro**](skills/contract-pro/SKILL.md) | Jurisdiction-aware contracts, NDAs, SOWs, MSAs, DPAs (US / EU / UK / DACH) |
| [**data-cleaner**](skills/data-cleaner/SKILL.md) | Clean messy tabular data — encoding, types, dedup, validation, changelog |
| [**report-builder**](skills/report-builder/SKILL.md) | Data → narrative → polished deliverable (weekly / monthly / board) |
| [**form-automator**](skills/form-automator/SKILL.md) | Mail merge — template × data → N personalized documents (docx / pdf / xlsx) |
| [**office-orchestrator**](skills/office-orchestrator/SKILL.md) | The conductor — sequences the above skills for multi-step pipelines |

## Installation

### Option 1: Claude Code Plugin (Recommended)

Once published as a plugin marketplace, install via:

```
/plugin marketplace add huangji6693-max/office-skills-pro
/plugin install office-skills-pro
```

### Option 2: Manual install (works now)

Symlink the `skills` directory into your Claude Code skills path:

```bash
# Clone the repo
git clone https://github.com/huangji6693-max/office-skills-pro ~/office-skills-pro

# Run the install script (copies skills into ~/.claude/skills/)
cd ~/office-skills-pro && bash install.sh
```

### Option 3: Copy individual skills

```bash
cp -r skills/xlsx-pro ~/.claude/skills/
```

### Install system dependencies

```bash
# Python libraries (one command for everything)
pip install python-docx docxtpl openpyxl xlsxwriter pandas \
    python-pptx "markitdown[pptx,docx,xlsx]" \
    pypdf pdfplumber pymupdf reportlab pdfminer.six ocrmypdf img2pdf \
    python-dateutil chardet rapidfuzz jinja2 regex webvtt-py srt

# System tools
# Ubuntu / Debian:
apt install -y libreoffice poppler-utils tesseract-ocr \
    tesseract-ocr-chi-sim tesseract-ocr-chi-tra \
    ghostscript pdftk-java exiftool

# macOS:
brew install libreoffice poppler tesseract tesseract-lang ghostscript exiftool pdftk-java

# Optional: Node-based alternatives
npm install -g docx pptxgenjs
```

## How the skills compose

```
                         ┌─── office-orchestrator ───┐
                         │    (the conductor)         │
                         └──┬────┬────┬────┬────┬────┘
                            │    │    │    │    │
         ┌──────┬───────┬───┘    │    │    │    └────┬─────────┐
         ▼      ▼       ▼        ▼    ▼    ▼         ▼         ▼
    docx-pro xlsx-pro pptx-pro pdf-pro email-pro data-cleaner report-builder
       │         │       │        │                    │            │
       └─────────┴───────┴────────┼────────────────────┘            │
                                  │                                 │
                     ┌────────────┼──────────────┐                  │
                     ▼            ▼              ▼                  │
              doc-coauthor meeting-analyzer contract-pro            │
                                                                    │
              form-automator ─ uses docx-pro + pdf-pro + xlsx-pro ──┘
```

Each skill is self-contained and can be used alone. `office-orchestrator` chains them for workflows that span formats.

## Design Principles

Every skill in this library follows the same quality bar, borrowed from Anthropic's internal skills + validated in real use:

1. **Open-source stack only** — no proprietary services required
2. **Verify before claiming done** — explicit checklists, validation scripts, visual QA loops
3. **Industry-standard output** — financial models use the blue/black/green/red convention; decks use one-accent / 60-70% dominance rules; docs match existing templates
4. **Narrative > numbers** — reports always include "what / so what / now what"
5. **Anti-slop discipline** — no emoji decoration, no accent-line-under-title, no gradient-noise-filler
6. **Evidence-based feedback** — meeting analyzer cites timestamps; data cleaner emits changelog
7. **Mail merge safety** — dry run before batch; errors surfaced not swallowed
8. **Jurisdiction awareness** — contracts adapt to US / EU / UK / DACH
9. **Composable** — each skill is independent; orchestrator sequences them

## Using with Claude Code

Once installed, skills are invoked automatically when Claude detects a matching task:

```
User: "Clean up this customer list and email each of them their invoice"

Claude automatically chains:
  1. data-cleaner → clean.csv
  2. form-automator → generate N invoice PDFs
  3. pdf-pro → flatten + encrypt
  4. email-pro → dry-run drafts → (approve) → batch send
```

Or invoke explicitly:

```
User: "Use xlsx-pro to build a Q4 financial model with the standard color coding"
```

## Why these 12 and not more?

The temptation is to ship 50 skills. We limited to 12 because:
- **Every SKILL.md loads into context** when triggered — fewer, deeper skills beat many shallow ones
- **12 covers 95% of real office work** — the long tail doesn't justify the maintenance burden
- **Composition is more powerful than specialization** — `office-orchestrator` chains the 12 into thousands of workflows

If you need something specialized (e.g. `sales-deck-builder`), fork and add. The bones are here.

## Contributing

PRs welcome. Focus areas:
- Additional language support in `docx-pro` (RTL, CJK typography)
- `pdf-pro`: better XFA handling
- `pptx-pro`: more palette variants for specific industries
- `contract-pro`: additional jurisdictions (APAC, LATAM)

## License

MIT. See [LICENSE](LICENSE).

## Acknowledgments

- Anthropic's [skills](https://github.com/anthropics/skills) team — the design patterns (especially the PPTX design discipline + XLSX financial standards) are theirs; the implementations here are original re-writes with open-source libraries
- [Alireza Rezvani](https://github.com/alirezarezvani) — the contract and meeting-analysis patterns draw inspiration from the MIT-licensed `claude-skills` repo
- [Simon Willison](https://github.com/simonw) — for documenting the skills ecosystem early

---

Built for [Claude Code](https://claude.com/claude-code) — ships with zero magic, zero secrets, zero vendor lock-in.
