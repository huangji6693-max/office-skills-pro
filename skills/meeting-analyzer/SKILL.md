---
name: meeting-analyzer
description: Analyze meeting transcripts and recordings to surface communication patterns, speaking dynamics, hedging, conflict avoidance, filler words, and actionable coaching feedback. Trigger whenever the user uploads or points to meeting transcripts (.txt, .md, .vtt, .srt, .docx, .json), asks about their communication habits, wants feedback on how they run meetings, wants speaking-ratio analysis, mentions filler words or conflict avoidance, or wants cross-time comparisons. Also trigger for Granola, Otter, Fireflies, Zoom, Teams, Meet transcripts.
license: MIT
metadata:
  version: 1.0.0
  category: office-automation
  inspiration: maximcoding via claude-skills team
---

# Meeting Insights Analyzer

Turn meeting transcripts into evidence-backed feedback on communication patterns, leadership behaviors, and interpersonal dynamics.

## Core Workflow

### 1. Ingest & Inventory

Scan the target directory for transcript files (`.txt`, `.md`, `.vtt`, `.srt`, `.docx`, `.json`).

For each file extract:
- Meeting date (from filename `YYYY-MM-DD` prefix or embedded timestamps)
- Speaker labels — patterns: `Speaker 1:`, `[Name]:`, `Name  00:14:32`, VTT/SRT cues
- Duration (from timestamps), participant count, word count

Print an inventory table. User confirms scope before heavy analysis starts.

### 2. Normalize Transcripts

Everything into one internal structure:

```python
{"speaker": str, "timestamp_sec": float | None, "text": str}
```

Per format:
- **VTT/SRT** — cue timestamps + text; inline `<v Name>` or prefixed labels
- **Plain text** — `Name:` or `[Name]` prefixes; warn if none
- **Markdown** — strip formatting, treat as text
- **DOCX** — `python-docx` → text
- **JSON** — common Otter/Fireflies shape: array of `{speaker, text}`

If no timestamps: degrade gracefully, skip timing metrics.

### 3. Analysis Modules

Run each independently; skip what doesn't apply.

---

#### Module A: Speaking Dynamics

Per speaker:
- Word count + percentage
- Turn count (times they spoke)
- Average turn length (words per uninterrupted turn)
- Longest monologue (flag > 60 sec or > 200 words)
- Interruption count (turn starts < 2 sec after previous speaker, or mid-sentence)

**Red flags to surface:**
- User speaks > 60% in a 1:many → dominating
- User speaks < 15% in a meeting they facilitate → disengaged
- One participant never speaks → excluded voice
- Interruption ratio > 2:1 (user interrupts others 2× more than interrupted)

---

#### Module B: Conflict & Directness

Scan user's speech for hedging and avoidance:

**Hedging markers:**
- Qualifiers: "maybe", "kind of", "sort of", "I guess", "potentially", "arguably"
- Permission-seeking: "if that's okay", "would it be alright if", "I don't know if this is right but"
- Deflection: "whatever you think", "up to you", "I'm flexible"
- Softeners: "I don't want to push back but", "this might be a dumb question"

**Conflict avoidance (needs context):**
- Topic changes after tension (A raises problem → user pivots to logistics)
- Agreement-without-commitment ("yeah totally" + no action follow-up)
- Reframing others' concerns smaller ("it's probably not that big a deal")
- Missing feedback in 1:1s where performance would be expected

For each flagged instance output:
- Full quote + 2 turns of surrounding context
- Severity: `low` (single hedge) / `medium` (pattern in one exchange) / `high` (clearly avoided a needed conversation)
- Rewrite suggestion — what a more direct version would sound like

---

#### Module C: Filler Words & Verbal Habits

Count: "um", "uh", "like" (non-comparative), "you know", "actually", "basically", "literally", "right?" (tag), "so yeah", "I mean"

Report:
- Total count per meeting
- Rate per 100 words (normalizes across lengths)
- Breakdown by filler type
- Contextual spikes (do fillers increase when responding to seniors, giving negative feedback, answering cold?)

---

#### Module D: Listening & Questions

- Open questions asked (start with "what", "how", "why", "tell me")
- Closed questions (yes/no)
- Did they paraphrase / summarize others?
- Response latency — did they answer immediately or pause to think?

Good listeners: > 1 open question per 10 minutes, paraphrase key points, pause before answering hard questions.

---

#### Module E: Facilitation (if user runs the meeting)

- Did they state agenda at start?
- Did they time-box agenda items?
- Did they invite silent participants?
- Did they summarize decisions + action items at end?
- Did they close on time?

---

#### Module F: Decision & Action Extraction

Scan for:
- Explicit decisions: "we'll go with X", "decided to Y", "agreed we'll"
- Action items: "[Name] will [do X] by [date]", "I'll own", "let's have [name] handle"
- Unresolved threads: questions raised without answers, topics tabled

Output as a clean table: decision / owner / deadline / source quote.

---

### 4. Output Format

Deliver three tiers:

**Tier 1 — Executive summary (3 bullets)**
Top patterns, top strengths, top growth areas.

**Tier 2 — Metrics dashboard (table)**
Meeting date / speaking % / fillers per 100w / hedges / interruptions / open questions.

**Tier 3 — Coaching deep-dive**
Per module: findings + quote evidence + specific rewrites. Cite timestamps.

### 5. Cross-Meeting Trends

If multiple transcripts across time:
- Chart metrics over time (improving, degrading, stable)
- Context-specific patterns (hedging spikes when X type of person in room)
- Leading vs. lagging behaviors

## Tone of Feedback

- **Evidence-based** — every claim has a quote
- **Specific** — "you hedged 11 times in 30 minutes" beats "you hedge a lot"
- **Actionable** — every finding has a rewrite suggestion
- **Non-judgmental** — describe behavior, let the user decide what to change
- **No sycophancy** — don't soften real problems with "but overall you did great"

## Privacy Guardrails

- If transcripts contain names of non-consenting participants, anonymize unless user confirms
- Never save transcripts to memory — process and discard
- Flag if transcript appears to be from a different organization than the user

## Dependencies

```bash
pip install python-docx webvtt-py srt
# Optional for large-scale:
pip install spacy nltk
python -m spacy download en_core_web_sm
```

## Integration

- `doc-coauthor` — if the user wants to turn findings into a development plan doc
- `email-pro` — to send a summary to the user's manager/coach
- `xlsx-pro` — export metrics dashboard to spreadsheet for tracking
