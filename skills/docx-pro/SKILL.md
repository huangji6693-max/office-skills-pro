---
name: docx-pro
description: Use this skill whenever the user works with Microsoft Word documents (.docx, .doc). Triggers include any mention of "Word doc", ".docx", "Word file", or requests to create, read, edit, convert, or format Word documents — including reports, memos, letters, proposals, contracts, templates, letterheads, tables of contents, page numbers, headers/footers, tracked changes, comments, find-and-replace, style application, image insertion, or conversion to/from PDF/Markdown/HTML. Use whenever the deliverable is a polished Word file. Do NOT use for Google Docs, plain-text, or PDF-only tasks.
license: MIT
metadata:
  version: 1.0.0
  category: office-automation
  stack: python-docx, pandoc, libreoffice, docx (npm)
---

# Word Document Automation

Complete toolkit for creating, reading, editing, and converting `.docx` files using open-source libraries.

## Quick Reference

| Task | Tool |
|------|------|
| Read / extract text with tracked changes | `pandoc --track-changes=all` |
| Create from scratch (programmatic) | `python-docx` (Python) or `docx` (Node) |
| Edit existing (preserve formatting) | `python-docx` or unpack→XML→repack |
| Convert `.doc` → `.docx` | `soffice --headless --convert-to docx` |
| Convert to PDF/HTML/MD | `pandoc` or `soffice` |
| Accept tracked changes | LibreOffice macro |

## Reading Content

```python
from docx import Document

doc = Document("report.docx")
for para in doc.paragraphs:
    print(para.text)
for table in doc.tables:
    for row in table.rows:
        print([cell.text for cell in row.cells])
```

For full fidelity including tracked changes, footnotes, comments:

```bash
pandoc --track-changes=all document.docx -o output.md
```

## Creating New Documents

```python
from docx import Document
from docx.shared import Pt, RGBColor, Cm, Inches
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT

doc = Document()

# Page setup
section = doc.sections[0]
section.top_margin = Cm(2.54)
section.left_margin = Cm(2.54)

# Heading with style
heading = doc.add_heading("Quarterly Report", level=1)
heading.alignment = WD_ALIGN_PARAGRAPH.CENTER

# Styled paragraph
p = doc.add_paragraph()
run = p.add_run("Executive Summary")
run.bold = True
run.font.size = Pt(14)
run.font.color.rgb = RGBColor(0x1E, 0x27, 0x61)

# Table
table = doc.add_table(rows=1, cols=3)
table.style = "Light Grid Accent 1"
hdr = table.rows[0].cells
hdr[0].text = "Metric"; hdr[1].text = "Q3"; hdr[2].text = "Q4"

# Image
doc.add_picture("chart.png", width=Inches(5))

# Page break + footer
doc.add_page_break()
doc.sections[0].footer.paragraphs[0].text = "Confidential"

doc.save("out.docx")
```

## Editing Existing Documents

Preserve formatting; only touch what you need:

```python
from docx import Document
doc = Document("template.docx")

# Find-and-replace while preserving runs
for para in doc.paragraphs:
    if "{{name}}" in para.text:
        for run in para.runs:
            run.text = run.text.replace("{{name}}", "Alex")

# Insert paragraph before existing one
from docx.oxml.ns import qn
from copy import deepcopy
target = doc.paragraphs[3]
new = deepcopy(target._p)
target._p.addprevious(new)

doc.save("filled.docx")
```

## Style / Theme Application

- Always use **styles** not direct formatting for maintainability: `para.style = doc.styles["Heading 2"]`
- Create custom styles once, reuse everywhere
- Match existing template conventions — never impose new formatting on established files

## Conversion Matrix

```bash
# .doc → .docx (legacy)
soffice --headless --convert-to docx legacy.doc

# .docx → .pdf
soffice --headless --convert-to pdf report.docx

# .docx → Markdown (preserves tables, lists)
pandoc report.docx -o report.md

# .docx → HTML with embedded images
pandoc report.docx --extract-media=./media -o report.html

# Markdown → .docx with reference styles
pandoc draft.md --reference-doc=template.docx -o final.docx
```

## Tracked Changes Workflow

```bash
# Extract WITH tracked changes visible
pandoc --track-changes=all doc.docx -o marked.md

# Accept all tracked changes programmatically (LibreOffice macro)
soffice --headless --norestore --nofirststartwizard \
  --accept="socket,host=localhost,port=2002;urp;" &
# Then use python-uno or the provided accept_changes.py helper
```

## Validation Checklist

Before declaring done:
- [ ] Document opens in Word / LibreOffice without errors
- [ ] All placeholders (`{{...}}`, `XXX`, `Lorem ipsum`) removed — grep the extracted text
- [ ] Table of contents regenerated (Ctrl+A → F9 equivalent)
- [ ] No orphaned styles / broken cross-references
- [ ] Images embedded (not linked) if shared externally
- [ ] File size reasonable (< 20 MB for typical reports)

```bash
# Placeholder hunt
pandoc out.docx -t plain | grep -iE "xxx|lorem|ipsum|todo|fixme|placeholder"
```

## Common Pitfalls

| Pitfall | Fix |
|--------|-----|
| Font not rendering on another machine | Embed fonts: File → Options → Save → Embed fonts |
| Page numbers reset mid-document | Use section breaks, not page breaks |
| Table cells merged incorrectly | Use `cell.merge(other_cell)` in python-docx |
| Emoji / CJK characters show as boxes | Use system fonts that support the script |
| Image resolution too low when printed | Use 300 DPI originals; don't rescale up |

## Dependencies

```bash
pip install python-docx pandocfilters
# For advanced features:
pip install python-docx-ng docxcompose
# CLI:
apt install pandoc libreoffice
npm install -g docx  # alternative JS library
```
