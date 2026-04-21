---
name: doc-coauthor
description: Guide users through a structured workflow for co-authoring documentation. Use when user wants to write documentation, proposals, technical specs, decision docs, PRDs, RFCs, design docs, ADRs, runbooks, or similar structured content. This workflow transfers context efficiently, refines content iteratively, and reader-tests the doc before others see it. Trigger when the user mentions writing docs, drafting specs, or starting a substantial writing task.
license: MIT
metadata:
  version: 1.0.0
  category: office-automation
  pattern: three-stage-coauthoring
---

# Document Co-Authoring Workflow

Structured three-stage workflow for collaborative document creation. Act as an active guide — not a passive drafter.

## When to Offer This Workflow

**Trigger phrases:**
- "write a doc", "draft a proposal", "create a spec", "write up"
- Doc types: PRD, RFC, design doc, decision doc, ADR, runbook, postmortem
- Substantial writing task the user is starting

**Opening move:**
> I can walk you through a 3-stage workflow that makes docs land better:
> 1. **Context Gathering** — you info-dump, I ask clarifying questions
> 2. **Refinement & Structure** — we build each section iteratively
> 3. **Reader Testing** — a fresh Claude reads it cold and flags blind spots
>
> Want to try this, or freeform?

If user declines → freeform. If accepts → proceed to Stage 1.

---

## Stage 1: Context Gathering

**Goal:** close the gap between what the user knows and what I know, so I can guide smartly later.

### Initial Meta-Questions

Ask in one batch, not drip-feed:

1. What type of doc? (spec / decision / proposal / runbook / PRD / RFC)
2. Who's the primary audience? (role + seniority + their context level)
3. Desired impact when someone reads it? (approval / alignment / handoff / reference)
4. Template or format to follow? (link or paste)
5. Any constraints — length, deadline, sensitive content?

State: "Answer in shorthand or dump however works. I'll ask follow-ups after."

### Info Dump Phase

After meta-questions, ask the user to dump:
- Background on the project/problem
- Related team discussions (Slack threads, meeting notes, past docs)
- Why alternatives aren't being used
- Org context (politics, past incidents, team dynamics)
- Timeline / constraints
- Technical architecture / dependencies
- Stakeholder concerns

Offer multiple ways:
- Stream-of-consciousness dump
- Point me to channels/threads to read
- Paste links to shared docs

### Clarifying Questions Round

Once they've dumped, ask targeted follow-ups. Example types:
- "You mentioned X blocker — what triggered that?"
- "Who are the main stakeholders who'll push back, and on what grounds?"
- "What's the one thing readers must take away?"

### Stage 1 Exit Criteria

Before moving on:
- [ ] I can describe the doc's goal in one sentence without reading the user's answer
- [ ] I know the top 2-3 risks / objections I should address
- [ ] I know who reads it, when, and what they'll do after

If NOT met → ask more. Don't proceed with ambiguity.

---

## Stage 2: Refinement & Structure

**Goal:** build each section iteratively, not dump a full draft.

### Step 2.1 — Propose Structure

Offer 2-3 structural options with tradeoffs. Example for a decision doc:

> Option A (Problem-first): Problem → Options → Recommendation → Risks → FAQ
> Option B (TL;DR-first): Recommendation → Why → Options considered → Risks
> Option C (Narrative): Background → Discovery journey → Decision
>
> For your audience (busy execs skim-reading), **B** usually lands. Want B, or adjust?

Get user buy-in BEFORE writing.

### Step 2.2 — Section-by-Section

For each section:

1. **Brainstorm** — "For this section, I'm thinking we cover X, Y, Z. Missing anything?"
2. **Draft** — write a tight version (not the final polish yet)
3. **User reacts** — wrong framing? Missing evidence? Tone off?
4. **Iterate** — one revision round, then lock
5. **Move on** — resist perfecting section 1 when sections 2-5 are blank

### Step 2.3 — Pass Discipline

Do **breadth before depth**:
- Pass 1: rough structure + one sentence per section
- Pass 2: expand each section to 60% done
- Pass 3: polish language, tighten, add evidence

Don't finish section 1 at 100% before section 3 has an outline. Half-built section 3 shapes section 1's framing.

### Tone Calibration

Ask the user to paste 1-2 examples of previous docs they've written or admired. Match:
- Voice (formal / casual / punchy)
- Density (prose-heavy / bullets / tables)
- Opinion (neutral synthesis vs. strong recommendation)

### Common Doc Patterns

**PRD**: Problem → Goals → Non-goals → Users → Requirements → Open questions → Timeline

**RFC**: Summary → Motivation → Detailed design → Alternatives → Prior art → Unresolved questions

**Decision doc**: TL;DR → Context → Options (table) → Recommendation → Why not X → Risks → Decision owner / date

**Postmortem**: Impact → Timeline (UTC) → Root cause → Contributing factors → What went well → Action items (owner + date)

**Runbook**: Trigger → Symptoms → Diagnosis steps → Mitigation → Escalation → Rollback → Known variants

---

## Stage 3: Reader Testing

**Goal:** catch blind spots before others read it. People won't tell you "I didn't understand section 3" — they just disengage.

### Step 3.1 — Fresh Reader Test

Spawn a subagent / fresh Claude with **no context**:

> You're a [role] reading this doc cold. No prior context. After reading:
> 1. What do you think this doc is asking you to do / know?
> 2. What's unclear or missing?
> 3. What questions would you ask the author?
> 4. Where did you have to re-read?
> 5. What parts felt confusing or redundant?
>
> Be specific. Cite line or section.
> [paste full doc]

### Step 3.2 — Triage Feedback

Map each issue:
- **Fix now** — real confusion / ambiguity / missing info
- **Intentional** — the doc covers this later; maybe add a forward pointer
- **Out of scope** — reader's own context gap; ignore

### Step 3.3 — Second Pass if Needed

If feedback reveals a structural problem (wrong framing, missing section), not just local edits — go back to Stage 2.2 and rebuild that section.

### Step 3.4 — Accessibility Pass

- Every image has alt text (else: Claude can't see it when stakeholders paste into Claude)
- Every acronym defined on first use
- Every link labeled (not "click here")
- Tables have column headers
- Reading level appropriate (use `readability` lib if unsure)

---

## Handoff Artifacts

When done, deliver:
1. **The doc itself** (Markdown, Google Doc link, or .docx — ask user's preference)
2. **A "how to use this doc" preamble** for the author — what to emphasize when presenting, what to expect as pushback
3. **A distribution checklist** — who gets it, in what order, with what framing

## Integration with Other Skills

- `docx-pro` — export final to Word with company styles
- `pdf-pro` — lock for distribution
- `brand-voice` — if company has a voice guide
- `meeting-analyzer` — if the doc came from a meeting and you have transcripts
