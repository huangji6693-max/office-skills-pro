---
name: email-pro
description: Use this skill for professional email composition, email sequences, cold outreach, replies, announcements, templates, and mailbox automation. Triggers include "write an email", "reply to this", "cold email", "follow-up sequence", "email template", "newsletter", "internal announcement", "status update email", or any mention of Gmail/Outlook/Mail operations. Covers one-off emails, multi-touch sequences, tone adaptation, attachment handling, and subject-line testing.
license: MIT
metadata:
  version: 1.0.0
  category: office-automation
  pattern: intent-driven-email
---

# Professional Email

Write emails people actually read and respond to. Not wall-of-text, not LinkedIn-speak, not "I hope this email finds you well."

## Before Writing — Clarify Intent

Ask (or infer from context) in one batch:

1. **Who** — name, role, seniority, your relationship history
2. **Why** — one-sentence goal of this email (what happens if they do nothing? if they take action?)
3. **Desired action** — reply, click, approve, schedule, just-FYI
4. **Tone** — formal / peer / warm / direct
5. **Context they already have** — new thread or continuing one?
6. **Constraints** — length, attachment limits, sensitivity

## Structure (Universal)

```
Subject: [specific, skimmable, no "Quick question"]

[Greeting — name, single line]

[Line 1: WHY you're writing — the ask or the news, up front]

[Lines 2-4: minimum context needed to act]

[Closing: specific call-to-action with deadline or "no action needed"]

[Sign-off]
[Name]
```

**Rule of thumb:** if they read only the first line after the greeting, can they act? If no, rewrite.

## Subject Lines

### Good
- "Approval needed by Fri: Q3 budget reallocation"
- "Postmortem attached — 2 decisions needed"
- "Intro: Alice (legal) ↔ Bob (product)"
- "Tue 3pm move to 4pm?"

### Avoid
- "Quick question" — vague, buries the point
- "FYI" — reader can't prioritize
- "Hi" or "Meeting" — near-useless in inbox scan
- Emoji unless intentional to the brand / relationship
- ALL CAPS

## Tone Ladder

| Register | When | Example opening |
|----------|------|-----------------|
| Formal | Unknown exec, legal, procurement | "Dear Ms. Chen," |
| Warm-formal | B2B colleague, cross-team | "Hi Jordan," |
| Peer | Direct peer or known vendor | "Hey Sam," |
| Casual | Close teammate, internal chat-adjacent | "Hey —" |

Match the register the recipient last used with you. Escalating formality feels cold; de-escalating feels presumptuous.

## Templates

### Cold Outreach (B2B)

```
Subject: [Their company] + [specific observation] → quick idea

Hi [First name],

Saw [Company] just [specific event — launched X / hired Y / expanded to Z]. Congrats.

We [one-sentence what you do] for teams like yours — [company 1] cut their [metric] by [X%], [company 2] [similar outcome].

Worth a 15-min call to see if there's a fit? I have openings Wed/Thu this week.

[Name]
[Title / Company / calendar link]
```

**Never** use: "I hope this finds you well", "I wanted to reach out", "circling back", "touching base".

### Follow-up Sequence (3 touches)

**Touch 1 — Day 0 (original)**
See above cold outreach.

**Touch 2 — Day 3**
```
Subject: RE: [Their company] + [original subject stem]

Hi [First name],

Following up in case the first one got buried. Short version: [1-sentence value prop].

Want to grab 15 min next week, or should I close the loop?

[Name]
```

**Touch 3 — Day 8 (break-up)**
```
Subject: Closing the loop

[First name] — haven't heard back, which usually means the timing's not right. I'll stop reaching out.

If [specific trigger event] happens in the next 6 months, I'm around.

[Name]
```

### Meeting Request

```
Subject: 30 min re: [specific topic] — [proposed days]

Hi [Name],

Can we grab 30 minutes to align on [topic]? Agenda:
1. [Item 1]
2. [Item 2]
3. Decisions: [X] and [Y]

I have openings:
- Tue 2-4pm
- Wed 10am-12pm
- Thu after 3pm

Or use [calendar link]. Happy to adjust if none work.

[Name]
```

### Status Update (Weekly)

```
Subject: [Project] status — week of [date]

TL;DR: [On track / At risk / Blocked] — [one-line why]

This week:
- Shipped: [X]
- In progress: [Y]
- Blocked: [Z] — need [specific ask]

Next week:
- [3 items max]

Metrics: [1-2 numbers that matter]

[Name]
```

### Rejection / Declining

```
Subject: RE: [their request]

Hi [Name],

Thanks for [what they did / sent / asked]. Unfortunately [specific no — don't pad].

[One line: why, if appropriate]

[One line: alternative, if you can offer one]

Best,
[Name]
```

### Difficult News (Bad update to stakeholders)

```
Subject: [Project] — [specific issue] + plan

[Name],

[One sentence: what happened. No hedging.]

Impact: [concrete — users affected, $ at risk, timeline slip]

Cause: [one sentence, investigate later if unknown]

What we're doing:
1. [Action, owner, by when]
2. [Action, owner, by when]

What we need from you: [specific ask, or "no action needed"]

Next update: [when]

[Name]
```

### Introduction (Double Opt-in)

**Step 1 — ask permission:**
```
Subject: Intro idea — [person A] ↔ you

Hi [Person B], would a 5-min intro to [Person A] be useful?
[Person A] is [role]. They're exploring [topic]. They've built [credibility]. You might hit it off because [specific reason].
Just need a yes/no.
```

**Step 2 — after both opt in:**
```
Subject: Intro: [Person A] ↔ [Person B]

[Both names] —

[Person A]: [Person B] is [1 sentence who they are + why they might help].
[Person B]: [Person A] is [1 sentence who they are + what they're looking for].

I'll drop off. Over to you.

[Your name]
```

## Anti-Patterns (Kill on Sight)

- "Hope this finds you well" → delete, start with the ask
- "I wanted to reach out / touch base / circle back" → just reach out
- "Just following up" (3rd time) → change the ask or stop
- "As per my last email" → passive-aggressive; rewrite
- Four paragraphs before the ask → lead with it
- "Thoughts?" as the entire CTA → specific: "Approve? Or propose a change?"
- Attaching a 50-page doc with no TL;DR → add one
- "Sorry to bother you" → don't apologize before asking
- Replying "Thanks!" as a new thread end → leave it or wait to batch

## Reply-All Discipline

Before hitting Reply All ask: "Does EVERY person on this thread need to see my reply?" Usually no.

## Attachment Etiquette

- Mention every attachment in the body
- PDF for anything final / external
- Don't ZIP single files
- If > 10 MB → link (Drive / Dropbox / company store), don't attach

## Gmail / Outlook Automation

```python
# Gmail via API
from googleapiclient.discovery import build
from google.oauth2.credentials import Credentials

creds = Credentials.from_authorized_user_file("token.json")
service = build("gmail", "v1", credentials=creds)

from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
import base64

msg = MIMEMultipart()
msg["to"] = "alice@example.com"
msg["subject"] = "Approval needed by Fri"
msg.attach(MIMEText("Body text here", "plain"))

raw = base64.urlsafe_b64encode(msg.as_bytes()).decode()
service.users().messages().send(userId="me", body={"raw": raw}).execute()
```

For Outlook: `pywin32` (Windows COM) or Microsoft Graph API.

## Final Check

- [ ] Subject line is skimmable and specific
- [ ] First line states the ask
- [ ] CTA is explicit with a deadline or "no action"
- [ ] No filler ("hope this finds you well", "circling back")
- [ ] Tone matches the relationship
- [ ] Attachments mentioned + under 10 MB
- [ ] Reply-all is actually needed
