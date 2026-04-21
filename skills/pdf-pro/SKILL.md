---
name: pdf-pro
description: Use this skill whenever any PDF file is involved. Trigger for reading or extracting text/tables from PDFs, combining or splitting PDFs, rotating pages, adding watermarks or page numbers, creating new PDFs programmatically, filling PDF forms (AcroForm + XFA), encrypting/decrypting, adding/verifying signatures, extracting images, running OCR on scanned PDFs, redacting sensitive content, and comparing two PDF versions. If the user mentions a .pdf file or asks to produce one, use this skill.
license: MIT
metadata:
  version: 1.0.0
  category: office-automation
  stack: pypdf, pdfplumber, pymupdf, reportlab, ocrmypdf
---

# PDF Processing

End-to-end PDF toolkit using open-source libraries — no proprietary services required.

## Library Matrix

| Library | Best for |
|---------|---------|
| **pypdf** | Merge, split, rotate, metadata, basic encryption |
| **pdfplumber** | Text + table extraction with layout fidelity |
| **pymupdf (fitz)** | Fast rendering, annotations, redaction, images |
| **reportlab** | Generating new PDFs from scratch |
| **ocrmypdf** | OCR scanned PDFs (wraps Tesseract) |
| **pdfminer.six** | Deep text extraction when others fail |

## Reading & Extraction

```python
from pypdf import PdfReader
r = PdfReader("doc.pdf")
print(f"Pages: {len(r.pages)}")
text = "\n".join(p.extract_text() for p in r.pages)
```

Tables with layout awareness:

```python
import pdfplumber
with pdfplumber.open("report.pdf") as pdf:
    for page in pdf.pages:
        for table in page.extract_tables():
            for row in table:
                print(row)
```

Metadata:

```python
m = r.metadata
print(m.title, m.author, m.subject, m.creator)
```

## Merge / Split

```python
from pypdf import PdfWriter, PdfReader

# Merge
w = PdfWriter()
for f in ["a.pdf", "b.pdf", "c.pdf"]:
    for p in PdfReader(f).pages:
        w.add_page(p)
w.write("merged.pdf")

# Split into single pages
for i, page in enumerate(PdfReader("big.pdf").pages):
    w = PdfWriter(); w.add_page(page)
    w.write(f"page_{i+1:03d}.pdf")
```

## Rotate / Reorder

```python
r = PdfReader("src.pdf")
w = PdfWriter()
for page in r.pages:
    page.rotate(90)      # 90 CW
    w.add_page(page)
w.write("rotated.pdf")

# Reorder: pages [3,1,2] → new order
order = [2, 0, 1]  # zero-indexed
w = PdfWriter()
for idx in order:
    w.add_page(r.pages[idx])
w.write("reordered.pdf")
```

## Watermark / Stamp / Page Numbers

```python
from pypdf import PdfReader, PdfWriter
src = PdfReader("report.pdf")
stamp = PdfReader("draft_watermark.pdf").pages[0]

w = PdfWriter()
for page in src.pages:
    page.merge_page(stamp, over=False)   # underlay
    w.add_page(page)
w.write("stamped.pdf")
```

Add page numbers with reportlab overlay:

```python
from reportlab.pdfgen import canvas
from reportlab.lib.pagesizes import letter
from pypdf import PdfReader, PdfWriter
from io import BytesIO

src = PdfReader("src.pdf")
w = PdfWriter()
for i, page in enumerate(src.pages, 1):
    buf = BytesIO()
    c = canvas.Canvas(buf, pagesize=letter)
    c.setFont("Helvetica", 9)
    c.drawRightString(560, 30, f"{i} / {len(src.pages)}")
    c.save()
    buf.seek(0)
    overlay = PdfReader(buf).pages[0]
    page.merge_page(overlay)
    w.add_page(page)
w.write("numbered.pdf")
```

## Creating New PDFs

```python
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import getSampleStyleSheet
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, Image
from reportlab.lib import colors
from reportlab.lib.units import cm

doc = SimpleDocTemplate("out.pdf", pagesize=A4,
                        leftMargin=2*cm, rightMargin=2*cm,
                        topMargin=2*cm, bottomMargin=2*cm)
styles = getSampleStyleSheet()
story = []
story.append(Paragraph("Annual Report 2025", styles["Title"]))
story.append(Spacer(1, 12))
story.append(Paragraph("This year we ...", styles["BodyText"]))

data = [["Metric", "Q3", "Q4"], ["Revenue", "$1.2M", "$1.8M"]]
t = Table(data)
t.setStyle(TableStyle([
    ("BACKGROUND", (0,0), (-1,0), colors.HexColor("#1E2761")),
    ("TEXTCOLOR", (0,0), (-1,0), colors.white),
    ("GRID", (0,0), (-1,-1), 0.5, colors.grey),
]))
story.append(t)
doc.build(story)
```

## Form Filling (AcroForm)

```python
from pypdf import PdfReader, PdfWriter
r = PdfReader("form.pdf")
w = PdfWriter(clone_from=r)

for page in w.pages:
    w.update_page_form_field_values(page, {
        "name": "Alex Chen",
        "date": "2026-04-21",
        "consent": "/Yes",   # checkbox: /Yes or /Off
    })

# Flatten so fields become static (uneditable)
w.add_metadata({"/Producer": "office-skills-pro"})
with open("filled.pdf", "wb") as f:
    w.write(f)
```

For **XFA** forms (older Adobe LiveCycle): fall back to `pdftk` or convert to AcroForm first.

## OCR for Scanned PDFs

```bash
# Install once
apt install ocrmypdf tesseract-ocr tesseract-ocr-chi-sim tesseract-ocr-chi-tra

# OCR with language detection
ocrmypdf --language eng+chi_sim --deskew --clean scanned.pdf searchable.pdf

# Force re-OCR even if PDF already has a text layer
ocrmypdf --force-ocr --language eng scanned.pdf out.pdf
```

## Redaction (True Removal, Not Black Box)

```python
import fitz   # pymupdf
doc = fitz.open("sensitive.pdf")
for page in doc:
    for inst in page.search_for("SSN: 123-45-6789"):
        page.add_redact_annot(inst, fill=(0, 0, 0))
    page.apply_redactions()
doc.save("redacted.pdf", garbage=4, deflate=True)
```

⚠️ A black rectangle overlay is NOT redaction — the underlying text remains and can be extracted. Always use `apply_redactions()`.

## Encryption

```python
from pypdf import PdfWriter
w = PdfWriter(clone_from=PdfReader("doc.pdf"))
w.encrypt(user_password="view", owner_password="edit", use_128bit=True)
w.write("locked.pdf")
```

## Image Extraction

```python
import fitz
doc = fitz.open("with_images.pdf")
for page_idx, page in enumerate(doc):
    for img_idx, img in enumerate(page.get_images(full=True), 1):
        xref = img[0]
        pix = fitz.Pixmap(doc, xref)
        pix.save(f"img_p{page_idx+1}_{img_idx}.png")
```

## Compare Two PDFs

```bash
# Visual diff with diff-pdf
diff-pdf --output-diff=diff.pdf v1.pdf v2.pdf

# Text diff
pdftotext v1.pdf - | > v1.txt
pdftotext v2.pdf - | > v2.txt
diff v1.txt v2.txt
```

## Convert To/From Images

```bash
# PDF → images
pdftoppm -jpeg -r 150 doc.pdf page       # one JPG per page
pdftoppm -png -r 300 doc.pdf page

# Images → PDF
img2pdf *.jpg -o scanned.pdf
```

## Validation Checklist

- [ ] Opens in Acrobat / Preview / Chrome without warnings
- [ ] Extractable text matches expected content (`pdftotext`)
- [ ] File size reasonable (compress images if > 20 MB)
- [ ] No sensitive data leaks in metadata (`exiftool -all= file.pdf` to strip)
- [ ] For forms: flattened if end-user shouldn't edit
- [ ] For shared documents: encrypted or properly permissioned

## Dependencies

```bash
pip install pypdf pdfplumber pymupdf reportlab pdfminer.six ocrmypdf img2pdf
apt install poppler-utils tesseract-ocr ghostscript pdftk-java diff-pdf exiftool
```
