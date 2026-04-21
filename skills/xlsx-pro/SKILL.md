---
name: xlsx-pro
description: Use this skill whenever a spreadsheet file (.xlsx, .xlsm, .xls, .csv, .tsv, .ods) is the primary input or output. Trigger for: opening, reading, editing, or fixing spreadsheets; creating from scratch or from other data sources; adding columns, formulas, charts, pivot tables; formatting, conditional formatting, data validation; cleaning messy tabular data; building financial models; converting between tabular formats. Especially trigger when the user references a spreadsheet by name or path. Do NOT trigger when the primary deliverable is a Word doc, HTML report, standalone Python script, or database integration — even if tabular data is involved.
license: MIT
metadata:
  version: 1.0.0
  category: office-automation
  stack: openpyxl, pandas, xlsxwriter, libreoffice
---

# Spreadsheet Automation

Complete toolkit for Excel / LibreOffice Calc automation with financial-modeling-grade quality standards.

## Golden Rules (Never Violate)

### 1. Use formulas, NOT hardcoded values

The spreadsheet must be **dynamic** — recalculate when source data changes.

```python
# ❌ WRONG — Python calculates, Excel just shows the result
sheet["B10"] = df["Sales"].sum()          # Hardcodes 5000

# ✅ CORRECT — Excel calculates
sheet["B10"] = "=SUM(B2:B9)"
sheet["C5"] = "=(C4-C2)/C2"               # Growth rate
sheet["D20"] = "=AVERAGE(D2:D19)"
```

Applies to every calculation: totals, percentages, ratios, differences, lookups.

### 2. Zero formula errors on delivery

Never ship a spreadsheet with `#REF!`, `#DIV/0!`, `#VALUE!`, `#N/A`, `#NAME?` unless the user explicitly asked for them (e.g. `=IFERROR(...)` demos).

Run the recalc + error scan script:

```bash
python scripts/recalc.py output.xlsx
```

### 3. Respect existing templates

When editing a file with established formatting, **match its conventions exactly**. Don't impose "best-practice" formatting on a file that already has its own style.

---

## Quick Reference

| Task | Library |
|------|---------|
| Data manipulation | **pandas** |
| Formulas + formatting + preservation | **openpyxl** |
| Writing very large files fast | **xlsxwriter** |
| Reading only, low memory | `openpyxl(read_only=True)` |
| Formula evaluation | **LibreOffice** (`soffice --calc`) |

## Reading & Analysis

```python
import pandas as pd

# Straight to DataFrame
df = pd.read_excel("book.xlsx", sheet_name="Data", dtype={"id": str})
df.info()
df.describe()

# Read only specific columns for large files
df = pd.read_excel("big.xlsx", usecols=["A", "C", "E"])

# Handle dates
df = pd.read_excel("dates.xlsx", parse_dates=["created_at"])
```

Preserve formulas (not values) with openpyxl:

```python
from openpyxl import load_workbook
wb = load_workbook("model.xlsx")   # default: formulas preserved
wb_vals = load_workbook("model.xlsx", data_only=True)   # calculated values
# WARNING: saving a `data_only=True` workbook DESTROYS formulas
```

## Creating & Editing

```python
from openpyxl import Workbook
from openpyxl.styles import Font, PatternFill, Alignment, Border, Side
from openpyxl.utils import get_column_letter
from openpyxl.formatting.rule import ColorScaleRule
from openpyxl.chart import BarChart, Reference

wb = Workbook()
ws = wb.active
ws.title = "Revenue"

# Headers
headers = ["Month", "Revenue", "COGS", "Gross Margin"]
for c, h in enumerate(headers, 1):
    cell = ws.cell(row=1, column=c, value=h)
    cell.font = Font(bold=True, color="FFFFFF")
    cell.fill = PatternFill("solid", fgColor="1E2761")
    cell.alignment = Alignment(horizontal="center")

# Data + formulas
months = ["Jan", "Feb", "Mar"]
for r, m in enumerate(months, 2):
    ws.cell(row=r, column=1, value=m)
    ws.cell(row=r, column=2, value=10000)
    ws.cell(row=r, column=3, value=4000)
    ws.cell(row=r, column=4, value=f"=B{r}-C{r}")

# Column widths
for c, w in enumerate([12, 14, 14, 16], 1):
    ws.column_dimensions[get_column_letter(c)].width = w

# Conditional formatting
ws.conditional_formatting.add(
    "D2:D4",
    ColorScaleRule(start_type="min", start_color="F8696B",
                   mid_type="percentile", mid_value=50, mid_color="FFEB84",
                   end_type="max", end_color="63BE7B"),
)

# Chart
chart = BarChart()
chart.add_data(Reference(ws, min_col=2, min_row=1, max_col=4, max_row=4), titles_from_data=True)
chart.set_categories(Reference(ws, min_col=1, min_row=2, max_row=4))
chart.title = "Monthly P&L"
ws.add_chart(chart, "F2")

wb.save("model.xlsx")
```

## Financial Model Color Coding (Industry Standard)

| Color | RGB | Use for |
|-------|-----|---------|
| Blue text | `0,0,255` | Hardcoded inputs, scenario inputs |
| Black text | `0,0,0` | Formulas and calculations |
| Green text | `0,128,0` | Links to other sheets (same workbook) |
| Red text | `255,0,0` | External file links |
| Yellow fill | `255,255,0` | Key assumptions, cells needing attention |

## Formula Construction Rules

1. **Assumptions in dedicated cells** — never hardcode inside formulas
   - ❌ `=B5*1.05`
   - ✅ `=B5*(1+$B$6)` where `B6` is the growth-rate cell
2. **Absolute references for assumption cells** — `$B$6`, not `B6`
3. **Named ranges** for anything referenced 3+ times
4. **IFERROR wrapping** for division / lookups with legitimate edge cases
5. **Avoid volatile functions** (NOW, TODAY, RAND, OFFSET, INDIRECT) in large models

## Number Formatting

| Data type | Format | Example |
|-----------|--------|---------|
| Years | Text | `"2024"` not `2,024` |
| Currency | `$#,##0` | `$1,234` |
| Currency with zero dash | `$#,##0;($#,##0);-` | negatives in parens, zeros as `-` |
| Percentage | `0.0%` | `12.3%` |
| Multiples | `0.0"x"` | `3.5x` |
| Negatives | Parentheses | `(123)` not `-123` |

## Data Cleaning Workflow

```python
import pandas as pd

df = pd.read_csv("messy.csv", on_bad_lines="skip")

# 1. Drop completely empty rows/cols
df = df.dropna(how="all").dropna(axis=1, how="all")

# 2. Strip whitespace, normalize case
df.columns = df.columns.str.strip().str.lower().str.replace(" ", "_")
for col in df.select_dtypes("object"):
    df[col] = df[col].str.strip()

# 3. Coerce types with error tolerance
df["amount"] = pd.to_numeric(df["amount"], errors="coerce")
df["date"] = pd.to_datetime(df["date"], errors="coerce")

# 4. Dedup
df = df.drop_duplicates(subset=["id"])

# 5. Save cleaned
df.to_excel("cleaned.xlsx", index=False, engine="openpyxl")
```

## Recalculation Script

Included: `scripts/recalc.py` — triggers LibreOffice headless recalc then scans all cells for error values.

```bash
python scripts/recalc.py file.xlsx   # exits 1 if errors found, prints locations
```

## Pre-Flight Checklist

- [ ] Every formula verified on 2-3 sample inputs
- [ ] `scripts/recalc.py` returns zero errors
- [ ] Column widths auto-fit OR explicitly sized
- [ ] Frozen panes on header row for long sheets (`ws.freeze_panes = "A2"`)
- [ ] All sheets named meaningfully — no `Sheet1`
- [ ] No hidden rows/columns unless intentional
- [ ] Totals row / sum row checks tie to source data
- [ ] File passes `openpyxl` + Excel round-trip

## Dependencies

```bash
pip install openpyxl pandas xlsxwriter pyxlsb odfpy
apt install libreoffice
```
