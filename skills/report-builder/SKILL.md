---
name: report-builder
description: Generate polished business reports from data sources — weekly metrics, monthly business reviews, quarterly board decks, financial summaries, status reports. Combines data pulling (CSV/Excel/DB), analysis, and formatted output (.docx / .pdf / .pptx / HTML email). Trigger when user says "create a report", "monthly report", "weekly metrics", "board deck", "KPI dashboard", "executive summary", or similar recurring deliverables.
license: MIT
metadata:
  version: 1.0.0
  category: office-automation
  pattern: data-to-narrative
---

# Report Builder

Data → analysis → narrative → formatted deliverable. Repeatable, scheduled-friendly.

## Output Format Decision Tree

| Audience | Format | Why |
|----------|--------|-----|
| Executives, board | **.pptx** | Skim-friendly, projectable |
| Finance, ops | **.xlsx** | They want the numbers live |
| Distribution across org | **.pdf** | Locked, consistent rendering |
| Email body | **HTML email** | No "open the attachment" friction |
| Archival, legal | **.docx + .pdf** | Editable source + locked copy |
| Dashboards | **HTML dashboard or BI tool link** | Live, interactive |

## Report Anatomy (Universal)

```
1. Title + date range + author
2. TL;DR (3-5 bullets max)
3. Key metrics (this period vs. prior + target)
4. Highlights (wins, 2-4 items)
5. Lowlights / risks (2-4 items, with mitigation or ask)
6. Deep dives (2-4 sections, one topic each)
7. Asks / decisions needed
8. Appendix (raw data, methodology, definitions)
```

**Rule:** every reader should be able to stop after any section and still understand the state. Inverted pyramid.

## Workflow

### 1. Gather

```
- Data sources (files, DB, API)?
- Time period (this week / this month / Q4)?
- Comparison period (prior period / YoY / vs. plan)?
- Audience + format?
- Existing template or style guide?
- Cadence — one-off or recurring?
```

### 2. Pull data

```python
import pandas as pd

# CSV / Excel
df = pd.read_csv("events.csv", parse_dates=["ts"])

# SQL
import sqlalchemy as sa
engine = sa.create_engine(os.environ["DATABASE_URL"])
df = pd.read_sql("SELECT ... FROM metrics WHERE ts >= :start",
                 engine, params={"start": "2026-04-01"})

# API
import requests
r = requests.get("https://api.example.com/metrics", headers={...})
df = pd.DataFrame(r.json()["data"])
```

### 3. Analyze

Standard metrics to compute for most business reports:

```python
current = df[df["period"] == "2026-04"]
prior   = df[df["period"] == "2026-03"]

def metric_block(name, current_val, prior_val, target=None):
    delta = current_val - prior_val
    pct = (delta / prior_val) * 100 if prior_val else float("inf")
    to_target = (current_val / target - 1) * 100 if target else None
    return {
        "name": name,
        "current": current_val,
        "prior": prior_val,
        "delta": delta,
        "pct_change": pct,
        "vs_target_pct": to_target,
    }
```

Red / yellow / green based on thresholds (define in the report, don't assume):

```python
def rag(pct, green_floor=0, yellow_floor=-5):
    if pct >= green_floor: return "GREEN"
    if pct >= yellow_floor: return "YELLOW"
    return "RED"
```

### 4. Narrate (not just numbers)

Each metric gets:
- **What** — the number
- **So what** — interpretation (is this good / bad / expected?)
- **Now what** — what's changing because of it / what's the ask

Example:
> Revenue: $1.82M (+12% MoM, +3% vs plan)
> **Drivers:** Enterprise deal close in Q4 (40% of delta); SMB new logos +8 (15%).
> **Risk:** One customer (23% of revenue); diversification push in Q2 plan.
> **Ask:** Approval for 2 new SMB AE hires to de-risk concentration.

### 5. Render

For each format, use the matching skill:

- `.docx` → `docx-pro`
- `.xlsx` → `xlsx-pro`
- `.pptx` → `pptx-pro`
- `.pdf` → `pdf-pro`
- HTML email → template below

## Charts (Design Rules)

- **One chart = one point** — if your chart has 3 takeaways, make 3 charts
- **Label directly** instead of using a legend (where possible)
- **Sort bars by value** unless category order is meaningful (time, size, etc.)
- **Truncate Y-axis only if you explicitly annotate it** — never silently
- **Color = meaning** — red = bad, green = good, grey = baseline; don't decorate
- **No 3D charts, ever.** No pie charts with > 5 slices. No gradient fills.

```python
import matplotlib.pyplot as plt

fig, ax = plt.subplots(figsize=(8, 4.5), dpi=150)
ax.bar(df["month"], df["revenue"], color="#1E2761")
ax.set_title("Monthly Revenue ($k)", loc="left", fontweight="bold")
ax.spines["top"].set_visible(False)
ax.spines["right"].set_visible(False)
ax.grid(axis="y", linestyle="--", alpha=0.3)
for x, y in zip(df["month"], df["revenue"]):
    ax.text(x, y, f"${y:,.0f}k", ha="center", va="bottom")
fig.tight_layout()
fig.savefig("revenue.png")
```

## HTML Email Template

```html
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Weekly Update — {{week}}</title>
</head>
<body style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; max-width: 640px; margin: 0 auto; color: #222; line-height: 1.5;">

  <h1 style="font-size: 22px; border-bottom: 2px solid #1E2761; padding-bottom: 8px;">
    Weekly Update — {{week}}
  </h1>

  <p><strong>TL;DR:</strong></p>
  <ul>
    <li>{{bullet_1}}</li>
    <li>{{bullet_2}}</li>
    <li>{{bullet_3}}</li>
  </ul>

  <h2 style="font-size: 18px; margin-top: 32px;">Key Metrics</h2>
  <table style="border-collapse: collapse; width: 100%;">
    <thead>
      <tr style="background: #F5F5F5;">
        <th style="text-align: left; padding: 8px; border-bottom: 1px solid #DDD;">Metric</th>
        <th style="text-align: right; padding: 8px; border-bottom: 1px solid #DDD;">This Week</th>
        <th style="text-align: right; padding: 8px; border-bottom: 1px solid #DDD;">Δ vs Last</th>
      </tr>
    </thead>
    <tbody>
      {{rows}}
    </tbody>
  </table>

  <h2 style="font-size: 18px; margin-top: 32px;">Highlights</h2>
  <ul>{{highlights}}</ul>

  <h2 style="font-size: 18px; margin-top: 32px;">Risks & Asks</h2>
  <ul>{{risks}}</ul>

  <p style="margin-top: 48px; color: #888; font-size: 12px;">
    Archive: <a href="{{archive_url}}">{{archive_url}}</a>
  </p>
</body>
</html>
```

## Recurring / Scheduled Reports

For weekly / monthly cadence, turn the pipeline into a single script:

```python
# report.py
import argparse, datetime as dt
from report_lib import fetch_data, analyze, render

if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--period", default=dt.date.today().isoformat())
    ap.add_argument("--format", choices=["pdf", "pptx", "email"], default="pdf")
    args = ap.parse_args()

    data = fetch_data(args.period)
    analysis = analyze(data)
    output = render(analysis, fmt=args.format)
    print(f"Rendered: {output}")
```

Run via cron / GitHub Actions / Airflow on schedule.

## Validation Before Sending

- [ ] Every number traces back to a query / source — no hallucinated stats
- [ ] Time period labeled unambiguously (W15 2026, not "this week")
- [ ] Units on every metric ($, %, count, hours)
- [ ] Comparison baseline stated (vs. last week / vs. plan / YoY)
- [ ] No RAG without thresholds defined
- [ ] Charts pass the 5-second test (get the point without reading the text)
- [ ] TL;DR was written LAST (so it reflects reality, not plan)
- [ ] Asks have owners + deadlines

## Integration

- `xlsx-pro` — data model + appendix
- `pptx-pro` — executive version
- `pdf-pro` — locked archival
- `docx-pro` — long-form version with full narrative
- `email-pro` — distribution email
- `data-cleaner` — upstream pipeline
