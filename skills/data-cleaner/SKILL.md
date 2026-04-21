---
name: data-cleaner
description: Clean, normalize, and reshape messy tabular data — CSV, TSV, Excel, JSON arrays, raw copy-pasted tables. Trigger when the user has a data file that's malformed, has inconsistent types, duplicate rows, junk headers, encoding issues, mixed date formats, merged cells, or when they want to prepare data for import / analysis / reporting. Handles: type coercion, dedup, fuzzy match/dedup, regex extraction, date normalization, encoding fixes, column splits/merges, pivots, explode/flatten, outlier detection.
license: MIT
metadata:
  version: 1.0.0
  category: office-automation
  stack: pandas, regex, chardet, python-dateutil, rapidfuzz
---

# Data Cleaning Pipeline

Turn messy real-world tabular data into something you can trust.

## Universal Workflow

```
1. INSPECT   — load 100 rows, profile types, spot obvious issues
2. FIX encoding & structure — delimiters, encoding, merged headers
3. COERCE types — numeric, date, boolean
4. DEDUPE — exact + fuzzy
5. VALIDATE — constraints, referential integrity
6. OUTPUT — clean format with changelog
```

## Step 1: Inspect

```python
import pandas as pd
import chardet

# Detect encoding first
with open("messy.csv", "rb") as f:
    enc = chardet.detect(f.read(100_000))["encoding"]
print(f"Encoding: {enc}")

# Load with error tolerance
df = pd.read_csv("messy.csv", encoding=enc, on_bad_lines="skip", nrows=100)

# Profile
print(df.shape)
print(df.dtypes)
print(df.isna().sum())
print(df.head())
print(df.describe(include="all"))

# Spot suspicious columns
for c in df.select_dtypes("object"):
    print(c, df[c].str.len().describe())
```

## Step 2: Fix Encoding & Structure

### Common encoding issues

```python
# BOM on column name ("ï»¿id" instead of "id")
df.columns = df.columns.str.replace("\ufeff", "")

# Double-encoded UTF-8 (mojibake: "Ã©" instead of "é")
df["name"] = df["name"].str.encode("latin-1").str.decode("utf-8", errors="ignore")

# Mixed encodings in same file (rare but happens) — read chunk-by-chunk
```

### Header normalization

```python
df.columns = (df.columns
    .str.strip()
    .str.lower()
    .str.replace(r"[^\w]+", "_", regex=True)
    .str.strip("_"))
```

### Multi-row headers

```python
# Excel files with 2-row headers
df = pd.read_excel("report.xlsx", header=[0, 1])
# Flatten
df.columns = [" ".join(c).strip() for c in df.columns.values]
```

### Detect the real data start row

```python
# File has junk rows before the actual table
raw = pd.read_csv("dirty.csv", header=None)
# Find first row with expected structure
header_row = raw.apply(lambda r: r.notna().sum() >= 5, axis=1).idxmax()
df = pd.read_csv("dirty.csv", skiprows=header_row)
```

## Step 3: Type Coercion

```python
# Numeric — keep bad values as NaN, log them
df["amount_raw"] = df["amount"]
df["amount"] = pd.to_numeric(
    df["amount"].astype(str).str.replace(r"[$,\s]", "", regex=True),
    errors="coerce"
)
bad = df[df["amount"].isna() & df["amount_raw"].notna()]
print(f"{len(bad)} unparseable amounts: sample={bad['amount_raw'].head().tolist()}")

# Dates — try multiple formats
from dateutil import parser as dparser
def smart_parse(x):
    try: return dparser.parse(str(x), fuzzy=True)
    except: return pd.NaT
df["date"] = df["date_raw"].apply(smart_parse)

# Boolean from strings
df["active"] = df["active_raw"].str.lower().map({
    "yes": True, "y": True, "true": True, "1": True,
    "no": False, "n": False, "false": False, "0": False,
})
```

## Step 4: Dedup

```python
# Exact dedup
df = df.drop_duplicates(subset=["id"])

# Near-dedup on normalized string
df["_key"] = (df["email"].str.lower().str.strip()
              if "email" in df.columns
              else df["name"].str.lower().str.replace(r"[^a-z0-9]", "", regex=True))
df = df.drop_duplicates(subset=["_key"]).drop(columns=["_key"])

# Fuzzy dedup
from rapidfuzz import process, fuzz
names = df["company"].dropna().unique().tolist()
clusters = {}
used = set()
for n in names:
    if n in used: continue
    matches = process.extract(n, names, scorer=fuzz.token_set_ratio, score_cutoff=90)
    group = [m[0] for m in matches]
    canonical = min(group, key=len)
    for m in group:
        clusters[m] = canonical
        used.add(m)
df["company_clean"] = df["company"].map(clusters).fillna(df["company"])
```

## Step 5: Validate

```python
# Required columns non-null
assert df[["id", "email", "amount"]].notna().all().all(), "Required cols have nulls"

# Range checks
assert (df["amount"] >= 0).all(), "Negative amounts present"
assert (df["date"] >= "2020-01-01").all(), "Dates before 2020"

# Regex
import re
bad_emails = ~df["email"].str.match(r"^[^@]+@[^@]+\.[^@]+$")
print(f"Invalid emails: {bad_emails.sum()}")

# Unique
assert df["id"].is_unique, "Duplicate IDs"

# Referential (if you have a lookup table)
missing = set(df["country_code"]) - set(countries["code"])
assert not missing, f"Unknown country codes: {missing}"
```

## Step 6: Output

```python
# Save cleaned + separate log of rejected rows
df.to_csv("clean.csv", index=False)
bad.to_csv("rejected.csv", index=False)

# Excel with summary sheet
with pd.ExcelWriter("clean.xlsx", engine="openpyxl") as w:
    df.to_excel(w, sheet_name="Data", index=False)
    summary = pd.DataFrame({
        "metric": ["rows_in", "rows_out", "duplicates_removed", "invalid_rows"],
        "value": [len(raw), len(df), len(raw) - len(df) - len(bad), len(bad)],
    })
    summary.to_excel(w, sheet_name="Summary", index=False)
```

## Common Patterns

### Split a column (e.g., "First Last" → two cols)

```python
df[["first", "last"]] = df["name"].str.split(" ", n=1, expand=True)
```

### Merge cols

```python
df["full_name"] = df["first"].fillna("") + " " + df["last"].fillna("")
df["full_name"] = df["full_name"].str.strip()
```

### Explode a list column

```python
df = df.assign(tag=df["tags"].str.split(",")).explode("tag")
df["tag"] = df["tag"].str.strip()
```

### Pivot long → wide

```python
wide = df.pivot_table(index="user_id", columns="metric", values="value", aggfunc="sum")
```

### Outlier detection

```python
# IQR method
q1, q3 = df["amount"].quantile([0.25, 0.75])
iqr = q3 - q1
lo, hi = q1 - 1.5*iqr, q3 + 1.5*iqr
outliers = df[(df["amount"] < lo) | (df["amount"] > hi)]
print(f"{len(outliers)} outliers, range [{lo:.2f}, {hi:.2f}]")
```

### Regex extraction

```python
# Extract phone, email, URL from a free-text column
df["phone"] = df["notes"].str.extract(r"(\+?\d[\d\s().-]{7,}\d)")
df["email"] = df["notes"].str.extract(r"([\w._%+-]+@[\w.-]+\.[a-zA-Z]{2,})")
```

## Changelog Discipline

Always emit a human-readable changelog alongside cleaned data:

```
CLEANUP REPORT — messy.csv → clean.csv
========================================
Input:  12,345 rows × 14 cols
Output:  9,872 rows × 12 cols

- Encoding fixed: cp1252 → utf-8 (14 cells with mojibake)
- Header normalized: stripped whitespace, lowercased, snake_case
- Dedup: 1,847 exact duplicates removed on id
- Dedup: 389 fuzzy duplicates merged on company (≥90% token_set_ratio)
- Type coercion:
  - amount: 127 unparseable → NaN (saved to rejected.csv)
  - date: 4 formats found, all normalized to ISO 8601
- Validation:
  - 34 rows with invalid emails → dropped
  - 3 rows with negative amounts → flagged, manual review needed

Dropped columns: notes_old, legacy_id (100% null)
```

## Anti-Patterns

- Dropping rows silently without logging → always emit a rejected.csv
- Converting `"N/A"` / `"unknown"` / `""` all to NaN without checking meaning — "unknown" might be a real category
- Using `float` for IDs (loses precision, adds `.0`)
- Ignoring encoding issues with `errors="ignore"` → silently loses data
- Cleaning date strings with regex instead of `dateutil` → brittle
- Normalizing company names too aggressively → "Apple" vs "Apple Inc." might matter

## Dependencies

```bash
pip install pandas openpyxl python-dateutil chardet rapidfuzz regex
```
