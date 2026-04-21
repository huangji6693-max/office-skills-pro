---
name: form-automator
description: Automate filling, generating, and submitting forms — PDF forms (AcroForm + XFA), Word form fields, Excel templates, HTML forms, Google Forms, and survey outputs. Trigger when the user wants to bulk-fill a template, merge a data file into a form, generate personalized documents from a list (mail merge), or extract data from completed forms. Covers: mail merge, CSV-to-filled-PDF batch, template-driven document generation, form data extraction, submission automation.
license: MIT
metadata:
  version: 1.0.0
  category: office-automation
  stack: pypdf, python-docx, openpyxl, Jinja2
---

# Form & Template Automator

Turn one template + one data file into N personalized documents. Or the reverse: pull structured data out of completed forms.

## Use Cases

- **Mail merge** — letter / contract template × customer list → N docs
- **Bulk PDF forms** — application form template × applicant data → N filled PDFs
- **Certificate generation** — 200 event attendees → 200 PDF certificates
- **Invoice generation** — line-items table → branded invoice PDFs
- **Form scraping** — 500 completed PDFs → one consolidated spreadsheet

## Pattern 1: Word Mail Merge (python-docx)

```python
from docx import Document
from copy import deepcopy
import pandas as pd

template = Document("letter_template.docx")   # contains {{name}}, {{date}}, etc.
data = pd.read_csv("recipients.csv")

for _, row in data.iterrows():
    doc = Document("letter_template.docx")   # fresh copy
    for p in doc.paragraphs:
        for run in p.runs:
            for col in data.columns:
                placeholder = "{{" + col + "}}"
                if placeholder in run.text:
                    run.text = run.text.replace(placeholder, str(row[col]))
    # Also handle tables
    for tbl in doc.tables:
        for r in tbl.rows:
            for cell in r.cells:
                for p in cell.paragraphs:
                    for run in p.runs:
                        for col in data.columns:
                            ph = "{{" + col + "}}"
                            if ph in run.text:
                                run.text = run.text.replace(ph, str(row[col]))
    doc.save(f"out/{row['id']}.docx")
```

**Caveat:** `{{placeholder}}` must live inside a single `run`. If Word split it across runs (due to formatting change mid-placeholder), the replace silently fails. Fix by cleaning the template: select the placeholder text in Word and apply Clear Formatting.

## Pattern 2: PDF Form (AcroForm) Batch Fill

```python
from pypdf import PdfReader, PdfWriter
import pandas as pd

template = "application_form.pdf"
data = pd.read_csv("applicants.csv")

for _, row in data.iterrows():
    r = PdfReader(template)
    w = PdfWriter(clone_from=r)
    for page in w.pages:
        w.update_page_form_field_values(page, {
            "full_name": row["name"],
            "dob":       row["dob"],
            "email":     row["email"],
            "agreed":    "/Yes",           # checkbox: /Yes or /Off
        })
    with open(f"out/{row['id']}.pdf", "wb") as f:
        w.write(f)
```

Inspect available field names:
```python
print(PdfReader("form.pdf").get_fields())
```

To flatten so output is non-editable:
```python
# Using pymupdf
import fitz
doc = fitz.open("filled.pdf")
doc.bake()            # flattens all form fields into static content
doc.save("locked.pdf")
```

## Pattern 3: Jinja2 + docx → Maximum Flexibility

`docxtpl` combines Jinja2 templating with python-docx — handles loops, conditionals, tables.

```bash
pip install docxtpl
```

Template `invoice.docx` uses Jinja syntax:
```
Invoice #{{ invoice_no }}
Bill to: {{ customer.name }}

{% for item in items %}
  {{ item.description }}  {{ item.qty }} × {{ item.price | currency }}
{% endfor %}

Total: {{ total | currency }}
```

Python:
```python
from docxtpl import DocxTemplate

tpl = DocxTemplate("invoice.docx")
ctx = {
    "invoice_no": "INV-2026-042",
    "customer": {"name": "Acme Inc.", "address": "..."},
    "items": [
        {"description": "Consulting", "qty": 10, "price": 150},
        {"description": "Support",    "qty": 1,  "price": 500},
    ],
    "total": 2000,
}
tpl.render(ctx)
tpl.save("out/INV-2026-042.docx")
```

Custom filters (currency, dates):
```python
from jinja2 import Environment
jenv = Environment()
jenv.filters["currency"] = lambda v: f"${v:,.2f}"
tpl.render(ctx, jinja_env=jenv)
```

## Pattern 4: Excel Template Fill

```python
from openpyxl import load_workbook
import pandas as pd

template = "timesheet_template.xlsx"
data = pd.read_csv("employees.csv")

for _, row in data.iterrows():
    wb = load_workbook(template)
    ws = wb.active
    ws["B2"] = row["name"]
    ws["B3"] = row["employee_id"]
    ws["B4"] = row["period"]
    # ... etc
    wb.save(f"out/timesheet_{row['employee_id']}.xlsx")
```

## Pattern 5: Bulk Convert DOCX → PDF After Merge

```bash
# Converts every docx in out/ to pdf
for f in out/*.docx; do
  soffice --headless --convert-to pdf "$f" --outdir out/
done

# Remove the docx if only pdf needed
rm out/*.docx
```

Or in Python:
```python
import subprocess, glob
for f in glob.glob("out/*.docx"):
    subprocess.run(["soffice", "--headless", "--convert-to", "pdf",
                    "--outdir", "out/", f], check=True)
```

## Pattern 6: Extract Data FROM Completed Forms

### From PDF forms
```python
from pypdf import PdfReader
import pandas as pd, glob

rows = []
for f in glob.glob("received/*.pdf"):
    r = PdfReader(f)
    fields = r.get_form_text_fields() or {}
    fields["source_file"] = f
    rows.append(fields)

pd.DataFrame(rows).to_csv("consolidated.csv", index=False)
```

### From Word forms
```python
from docx import Document
import glob, pandas as pd

rows = []
for f in glob.glob("received/*.docx"):
    doc = Document(f)
    # Read content controls (structured doc tags)
    ns = {"w": "http://schemas.openxmlformats.org/wordprocessingml/2006/main"}
    sdts = doc.element.findall(".//w:sdt", ns)
    record = {}
    for sdt in sdts:
        alias = sdt.find(".//w:alias", ns)
        text  = sdt.find(".//w:t", ns)
        if alias is not None and text is not None:
            record[alias.get(f"{{{ns['w']}}}val")] = text.text
    record["source_file"] = f
    rows.append(record)

pd.DataFrame(rows).to_csv("consolidated.csv", index=False)
```

## Email Distribution After Merge

```python
# After generating N PDFs, send each to the right person
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.application import MIMEApplication
import smtplib

for _, row in data.iterrows():
    msg = MIMEMultipart()
    msg["From"] = "you@example.com"
    msg["To"] = row["email"]
    msg["Subject"] = f"Your Invoice #{row['invoice_no']}"
    msg.attach(MIMEText(f"Hi {row['name']}, please find attached.", "plain"))
    with open(f"out/{row['id']}.pdf", "rb") as f:
        part = MIMEApplication(f.read(), Name=f"{row['id']}.pdf")
        part["Content-Disposition"] = f'attachment; filename="{row["id"]}.pdf"'
        msg.attach(part)
    with smtplib.SMTP_SSL("smtp.example.com", 465) as s:
        s.login("you", "password")
        s.send_message(msg)
```

**Safer pattern:** generate + review a sample first (5 recipients), then batch-send to the full list. Use a dry-run flag.

## Error Handling / Safety

```python
errors = []
for _, row in data.iterrows():
    try:
        generate_document(row)
    except Exception as e:
        errors.append({"id": row["id"], "error": str(e)})

if errors:
    pd.DataFrame(errors).to_csv("errors.csv", index=False)
    print(f"⚠ {len(errors)} failures, see errors.csv")
```

Never silently skip failures — log them and surface to the user.

## Checklist

- [ ] Template placeholder syntax consistent throughout (no mixed `{{x}}` / `{x}` / `<<x>>`)
- [ ] Sample run on 3-5 rows verified manually before batching
- [ ] Output directory clean before re-running (or timestamped subfolder)
- [ ] Data file validated (no nulls in required columns, no encoding issues)
- [ ] Output files named with stable unique key (row ID) not index
- [ ] Errors captured and reported, not swallowed
- [ ] For email distribution — dry run with manual inspection before live send

## Dependencies

```bash
pip install python-docx docxtpl pypdf pymupdf openpyxl pandas jinja2
apt install libreoffice
```

## Integration

- `docx-pro` — template preparation
- `xlsx-pro` — data source preparation
- `pdf-pro` — post-merge flattening / locking
- `email-pro` — distribution
- `data-cleaner` — preprocess the data file
