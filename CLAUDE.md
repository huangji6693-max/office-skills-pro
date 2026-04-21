# CLAUDE.md — Office Skills Pro

This file configures how Claude Code uses the office-skills-pro library. Do not modify unless you know what you're changing — it shapes skill routing behavior.

## Skill Routing

When the user's request matches one of the skill descriptions, invoke the matching skill automatically. Description-based matching is already handled by Claude Code's skill runtime; this file just documents the decision rules.

### Format-first triggers

| Signal in user request | Skill to invoke |
|-----------------------|-----------------|
| `.docx`, "Word doc", "Word document", "memo", "letter" | `docx-pro` |
| `.xlsx`, `.csv`, "spreadsheet", "Excel", "financial model" | `xlsx-pro` |
| `.pptx`, "deck", "slides", "presentation", "pitch" | `pptx-pro` |
| `.pdf`, "PDF", "OCR", "fill this form" (PDF form) | `pdf-pro` |

### Workflow triggers

| Signal | Skill |
|--------|-------|
| "Write a PRD / RFC / decision doc / spec" | `doc-coauthor` |
| "Draft an email", "cold outreach", "email sequence" | `email-pro` |
| "Analyze my meeting", "transcript", "how did I come across" | `meeting-analyzer` |
| "Contract", "NDA", "SOW", "proposal", "MSA" | `contract-pro` |
| "Clean this data", "messy CSV", "fix the spreadsheet" | `data-cleaner` |
| "Weekly report", "monthly report", "board deck from numbers" | `report-builder` |
| "Mail merge", "bulk-fill", "generate N documents from this list" | `form-automator` |
| Multi-format pipeline ("data → deck → PDF → email") | `office-orchestrator` |

### Disambiguation rules

1. **Single format request** → use the format-specific skill directly. Don't invoke `office-orchestrator` for a one-step task.
2. **Multi-format pipeline** → invoke `office-orchestrator`, which then delegates.
3. **Content creation + specific format** → invoke the workflow skill (e.g., `doc-coauthor`) first, then the format skill (`docx-pro`) for the final render.
4. **Data analysis + presentation** → `report-builder` owns the narrative; it calls `xlsx-pro` / `pptx-pro` as needed.

## Quality Bars Every Skill Enforces

These apply to every deliverable this library produces:

1. **Verify before claiming done** — every skill has an explicit checklist; do not declare success until it's passed
2. **No hardcoded calculations in spreadsheets** — formulas always (per `xlsx-pro` standards)
3. **No accent-line-under-title, no pie charts > 5 slices, no emoji decoration** — decks and reports follow anti-slop discipline
4. **Evidence-based output** — meeting analyzer cites timestamps; data cleaner emits a changelog; reports explain not just numbers but "what / so what / now what"
5. **Mail merge dry run** — always test on 3-5 records and show the user before batch-processing
6. **Don't swallow errors** — emit `errors.csv` / changelog / warnings alongside success
7. **Match existing templates** — when editing a file with established formatting, never impose "best practices" over it

## Dependencies

Core Python stack (all open source):
- `python-docx` / `docxtpl` — Word
- `openpyxl` / `xlsxwriter` / `pandas` — Excel
- `python-pptx` — PowerPoint
- `pypdf` / `pdfplumber` / `pymupdf` / `reportlab` — PDF
- `jinja2` / `python-dateutil` / `chardet` / `rapidfuzz` — helpers

System tools:
- `libreoffice` (soffice) — cross-format conversion, Excel formula recalculation
- `pandoc` — docx ↔ md ↔ html
- `poppler-utils` (pdftoppm, pdftotext) — PDF inspection
- `tesseract-ocr` — OCR for scanned PDFs

Install everything via `install.sh`.

## File Operations Safety

- **Destructive operations** (overwrite, delete, batch-send email) require explicit confirmation unless the user has enabled auto mode for them
- **Outputs go to** `./deliverables/` by default, not in-place modifications
- **Never commit secrets** — SMTP passwords, API keys, DB URLs must come from env vars
- **PII / sensitive data** — when the user provides personal data, process locally and don't save intermediate copies to memory

## Integration with Other Claude Code Features

- **Task tracking** — for multi-step orchestrations, create explicit tasks via TaskCreate
- **Background agents** — long-running pipelines (bulk mail merge, OCR on 1000s of PDFs) should use background agents
- **Memory** — don't save transcripts / contracts / PII to the auto-memory system; process and discard
- **Subagents** — for visual QA of decks or documents, dispatch fresh subagents per the `pptx-pro` workflow

## Versioning

Each SKILL.md declares its own version in frontmatter. Breaking changes bump major. Adding a new capability bumps minor. Typo fixes / doc improvements bump patch.

Update the skill's frontmatter `version` when you change it, so users can diff against upstream.

## Getting Help

- Read the individual SKILL.md files for deep technical docs
- Issues / feature requests: file at https://github.com/huangji6693-max/office-skills-pro/issues
- Pattern not covered? Fork and add — the architecture (11 composable skills) is designed to extend
