---
name: office-orchestrator
description: Orchestrate multi-step, multi-format office workflows. Use when a task spans multiple document types (e.g., pull data from Excel → build deck from the numbers → email PDF to stakeholders), when a deliverable has multiple formats (docx + pdf + pptx), or when a pipeline needs to run on a schedule with data handoffs between steps. The conductor skill — delegates to docx-pro / xlsx-pro / pptx-pro / pdf-pro / email-pro / data-cleaner / report-builder / form-automator / doc-coauthor / meeting-analyzer / contract-pro.
license: MIT
metadata:
  version: 1.0.0
  category: office-automation
  role: orchestrator
---

# Office Suite Orchestrator

The conductor. Pick the right individual skills, sequence them, pass data between them, verify at each stage.

## When to Use This Skill

Trigger on tasks like:
- "Take this spreadsheet and build a deck out of it, then email as PDF"
- "Every Monday: pull metrics from DB → weekly report → Slack + email"
- "Process all contracts in inbox, extract terms, put in spreadsheet"
- "From this meeting transcript, draft a decision doc, get approval, distribute"

If the task uses only ONE format (just a PDF, just a spreadsheet) — skip this skill, use the format-specific one directly.

## Workflow Pattern

```
INTAKE → PLAN → EXECUTE (sequence of skill calls) → VERIFY → DELIVER
```

### 1. Intake

Ask in one batch:
- What's the **input** (file(s), data source, free-text request)?
- What's the **deliverable** (single file, package, email, ticket)?
- Who's the **audience**?
- Any **constraints** — deadline, tools available, confidentiality, templates to match?
- Is this **one-off** or **recurring**?

### 2. Plan

Output an explicit plan BEFORE executing. Example:

> **Plan for "Spreadsheet → exec deck → PDF email":**
> 1. `data-cleaner` — validate the spreadsheet, fix any encoding / dedup
> 2. `xlsx-pro` — compute derived metrics (MoM delta, YoY, vs. plan)
> 3. Build chart images from the clean data (matplotlib)
> 4. `pptx-pro` — create 8-slide deck using "Midnight Executive" palette
> 5. `pdf-pro` — convert deck → PDF, add page numbers
> 6. `email-pro` — draft distribution email with the PDF attached
> 7. Output to `./deliverables/`
>
> Proceed?

Get user buy-in (unless Auto Mode + low risk).

### 3. Execute

Call each skill with scoped input. Pass structured outputs between stages:

```
stage_1 → stage_2: {data_file: "clean.xlsx", changelog: "..."}
stage_2 → stage_3: {metrics: {...}, charts: ["rev.png", "cust.png"]}
stage_3 → stage_4: {deck_file: "deck.pptx", slide_count: 8}
stage_4 → stage_5: {pdf_file: "deck.pdf"}
stage_5 → stage_6: {attachments: ["deck.pdf"], subject: "...", body: "..."}
```

### 4. Verify Between Stages

Each stage has its own verification — don't proceed if the prior stage failed:

| Stage | Verify |
|-------|--------|
| After `data-cleaner` | No unparseable rows beyond threshold; changelog emitted |
| After `xlsx-pro` | `scripts/recalc.py` returns zero errors |
| After chart gen | Images exist, dimensions sane, no matplotlib warnings |
| After `pptx-pro` | Visual QA loop; no placeholders via `markitdown \| grep` |
| After `pdf-pro` | PDF opens; text is extractable; page count matches |
| After `email-pro` | Subject + body + attachments all set; dry-run draft |

Between-stage gates prevent cascading errors.

### 5. Deliver

- Output directory: `./deliverables/YYYY-MM-DD_task-name/`
- Contains: final deliverable(s), intermediate files (for debugging), run log
- Summary back to user: what was produced, verification status, any manual follow-ups

## Canonical Orchestrations

### A. Weekly Metrics Report (recurring)

```
Trigger: cron / Monday 9am
  ↓
data-cleaner: pull from DB / CSV, validate
  ↓
report-builder: compute metrics, narrate
  ↓
xlsx-pro: build the data appendix
  ↓
pptx-pro: build 5-slide deck (title, TL;DR, metrics, deep dive, asks)
  ↓
pdf-pro: deck → PDF with page numbers
  ↓
email-pro: send to distribution list
  ↓
Archive: ./reports/2026-W17/
```

### B. Meeting → Decision Doc → Distribution

```
meeting-analyzer: ingest transcript, extract decisions + actions
  ↓
doc-coauthor: guide user through 3-stage doc creation using the extracted decisions
  ↓
docx-pro: export final to company template
  ↓
pdf-pro: lock as PDF
  ↓
email-pro: distribute
```

### C. Contract Workflow

```
contract-pro: generate Markdown draft from questionnaire
  ↓
docx-pro: apply company template (fonts, letterhead, signature block)
  ↓
(user review + counsel review — manual step)
  ↓
pdf-pro: lock final with encryption; flatten form fields if any
  ↓
email-pro: send to counterparty with signing instructions
  ↓
(counterparty signs via DocuSign / HelloSign — external)
  ↓
pdf-pro: final archival with metadata stamp
```

### D. Bulk Personalization

```
data-cleaner: validate recipient list
  ↓
form-automator: template × list → N docs
  ↓
pdf-pro: batch convert + flatten
  ↓
email-pro: dry run to 3 test recipients
  ↓ (user approves)
email-pro: full distribution
  ↓
Log: who received what, when, delivery status
```

### E. Inbox → Structured Data

```
Intake: PDF forms in ./inbox/
  ↓
form-automator: extract form fields to DataFrame
  ↓
data-cleaner: dedup, validate, type-coerce
  ↓
xlsx-pro: consolidated master spreadsheet with pivot
  ↓
report-builder: summary stats + charts
  ↓
email-pro: daily digest to ops team
```

## Data Passing Contracts

When one skill hands off to another, the interface should be explicit:

```python
# Generic contract
@dataclass
class StageOutput:
    files: list[Path]          # artifacts produced
    data: dict                 # structured data for next stage
    changelog: str             # what happened
    warnings: list[str]        # non-fatal issues
    next_stage_hint: str       # suggested next skill

# Each stage validates its input against expected shape before starting
```

## Parallel vs. Sequential

| Can parallelize | Must sequence |
|-----------------|---------------|
| Generating charts from independent data slices | Data clean → data analysis |
| Multiple format exports from same source (docx + pdf + pptx) | Analysis → visualization |
| Sending N emails from N generated files | Generation → distribution |

Use parallel when:
- Steps have no shared state
- Steps are CPU-bound and you have cores
- Failure of one doesn't block others

## Failure Handling

Each stage must fail loudly, not silently:

```python
if verification_failed:
    log_error(stage, details)
    emit_partial_outputs()
    raise OrchestrationError(
        stage=stage,
        failed_check=details,
        artifacts_so_far=artifacts,
        recovery_hint="Fix X then resume from stage Y",
    )
```

For recurring pipelines: alert on failure (email, Slack), keep prior successful output as the "last good" fallback.

## Observability

For recurring pipelines, log per run:
- Start / end timestamp
- Input hash (so you know if source data changed)
- Rows processed
- Warnings
- Artifact paths + sizes
- Downstream delivery status (email sent? SMTP response?)

Store in `./runs/YYYY-MM-DD_HH-MM/` with a JSON log.

## Checklist Before Running Recurring Pipelines

- [ ] Sample run on real data manually reviewed
- [ ] Failure mode tested (what happens if DB is down? template missing?)
- [ ] Idempotent (running twice doesn't send the email twice)
- [ ] Output cleaned up (don't fill disk with old runs)
- [ ] Alerts wired (email / Slack on failure)
- [ ] Secrets via env vars, not hardcoded
- [ ] Credentials rotatable without code change

## Integration Map

This skill USES:
- `docx-pro` · `xlsx-pro` · `pptx-pro` · `pdf-pro`
- `email-pro` · `data-cleaner` · `report-builder` · `form-automator`
- `doc-coauthor` · `meeting-analyzer` · `contract-pro`

This skill DOESN'T replace any of them — it sequences them.
