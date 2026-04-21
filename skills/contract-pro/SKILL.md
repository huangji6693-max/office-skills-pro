---
name: contract-pro
description: Generate professional, jurisdiction-aware business documents — freelance contracts, project proposals, Statements of Work, NDAs (mutual + one-way), Master Service Agreements, SaaS agreements, Data Processing Addenda. Covers US-Delaware, EU/GDPR, UK, DACH (German/Austrian/Swiss) law. Outputs structured Markdown with optional .docx conversion. Trigger on "contract", "proposal", "SOW", "NDA", "MSA", "DPA", "terms of service", "service agreement", "freelance agreement". NOT a substitute for legal counsel.
license: MIT
metadata:
  version: 1.0.0
  category: office-automation
  disclaimer: Templates only — review with an attorney for high-value or complex engagements
---

# Contract & Proposal Writer

Generate jurisdiction-aware business documents. Templates, not legal advice.

## Safety Notice (Always Show)

> These are templates for starting points only. **Not legal advice.** Review with qualified counsel before signing, especially for: contracts > $50k, multi-jurisdiction deals, IP-heavy work, regulated industries (health, finance, government), or anything where breach would materially harm the business.

## Before Drafting — Gather

Ask (one batch):

1. **Document type?** Contract / Proposal / SOW / NDA / MSA / DPA / Terms of Service
2. **Jurisdiction?** US-Delaware / US-California / EU / UK / DACH (DE/AT/CH) / Other
3. **Engagement type?** Fixed-price / Hourly / Monthly retainer / Milestone-based
4. **Parties?** Names, roles, registered addresses (legal entity not trade name)
5. **Scope summary?** 1-3 sentences describing the work
6. **Total value** or hourly rate + estimated hours
7. **Start date / end date or duration**
8. **Special requirements?** IP assignment, white-label, subcontractors allowed, exclusivity, GDPR data handling, right-to-audit, SLAs

## Document Types

### Freelance / Contractor Agreement (Fixed-Price)

Standard clauses:
- Scope of Work (exhibit A)
- Payment terms (deposit + milestones, Net-14/30)
- Change order process (written, signed, re-priced)
- IP assignment (on full payment) or license-back
- Confidentiality (2-5 years, perpetual for trade secrets)
- Limitation of liability (1× contract value typical)
- Warranty period (30-90 days)
- Termination (for cause 14-day cure; for convenience 30-day notice)
- Governing law + dispute resolution

### Statement of Work (SOW)

Under an existing MSA. Must include:
- Deliverables matrix (item / description / acceptance criteria / due date)
- Timeline with milestones
- Acceptance criteria — objective + testable
- Assumptions (what's NOT included)
- Dependencies from client
- Fees + invoice schedule
- Change management process reference (link to MSA)

### NDA — Mutual vs One-Way

| Feature | Mutual | One-Way |
|---------|--------|---------|
| Who discloses | Both parties | Only one |
| Typical use | Partnership exploration | Employee/contractor receiving confidential info |
| Return of materials | Both | Receiver only |
| Term | 2-5 years | 2-5 years + perpetual for trade secrets |

Standard NDA elements:
- Definition of Confidential Information (include + exclude — public domain, independently developed, lawfully obtained)
- Permitted use (evaluation only — no development, no reverse engineering)
- Permitted disclosures (employees on need-to-know, under their own NDAs; legal compulsion with notice)
- Term
- Return / destruction of materials on request
- Injunctive relief clause (irreparable harm language)
- Governing law

### Master Service Agreement (MSA)

Umbrella terms for ongoing relationship. Individual engagements go in SOWs.

Key sections:
- Services framework (SOWs govern specific work)
- Payment + invoicing
- Change control
- IP ownership + pre-existing IP carve-out
- Representations & warranties
- Indemnification (mutual, with carve-outs for IP infringement, data breach)
- Limitation of liability (cap on cumulative damages, exclusions for gross negligence/willful misconduct/IP indemnification)
- Insurance requirements (GL, E&O, cyber)
- Term + renewal + termination
- Non-solicitation (staff, for term + 12 months)
- Governing law + venue + dispute resolution

### Data Processing Addendum (GDPR)

Required when processing EU personal data. Standard sections:
- Roles (Controller / Processor / Sub-processor)
- Subject matter + duration + nature + purpose of processing
- Categories of data subjects + data
- Controller's documented instructions
- Confidentiality of personnel
- Security measures (Art. 32 — encryption, resilience, testing)
- Sub-processors (list, notification of changes, flow-down obligations)
- Data subject rights (assist controller in responding)
- Data breach notification (within 72 hours to controller)
- DPIA + prior consultation assistance
- Data return / deletion on termination
- Audit rights
- International transfers (SCCs or adequacy decision)

### SaaS Agreement / Order Form

- Service description + SLA (uptime %, support tiers, response/resolution times)
- Credits for SLA breach
- Subscription term + auto-renewal terms
- Fees + price increase caps
- Usage limits + overage pricing
- Data ownership (customer owns their data)
- Export format on termination
- Security certifications (SOC 2, ISO 27001, etc.)

## Jurisdiction-Specific Clauses

### US (Delaware)
- Governing law + venue: Delaware
- Work-for-hire language for IP
- Employee vs. contractor classification (IRS 20-factor)
- Non-compete enforceability varies by state (CA / NY restrict)

### EU (GDPR + local law)
- IP: explicit assignment required (no work-for-hire concept in most EU countries)
- GDPR DPA required for personal-data processing
- Statutory warranty periods (e.g., 2 years in Germany — cannot be waived for consumers)
- Consumer protection overrides contract terms

### UK (post-Brexit)
- Law of England & Wales (unless Scotland/NI specifically)
- UK-GDPR mirrors EU-GDPR; ICO is supervisory authority
- IP: assignment-based (similar to EU)
- Unfair Contract Terms Act 1977

### DACH (Germany / Austria / Switzerland)
- Strict consumer protection (BGB §§ 305-310 in Germany — AGB control)
- IP: statutory author's rights (moral rights inalienable in DE/AT)
- Must translate for consumer contracts (German for Germany)
- Data protection on top of GDPR: BDSG (DE), DSG (AT, CH)

## Standard Clause Options

| Clause | Options |
|--------|---------|
| Payment terms | Net-14 / Net-30 / Milestones / Retainer |
| Late fees | 1-1.5% per month OR prime + 2% |
| IP ownership | Work-for-hire (US) / Assignment (EU/UK) / License-back |
| Liability cap | 1× contract value (standard) / 3× (high-risk) / Uncapped for IP indemnity + willful misconduct |
| Termination | For cause (14-day cure) / Convenience (30/60/90-day notice) |
| Confidentiality term | 2-5 years / Perpetual for trade secrets |
| Warranty | "As-is" disclaimer / Limited 30-90 day fix / Service-level guarantee |
| Dispute resolution | Negotiation → Mediation → Arbitration (AAA/ICC/JAMS) → Courts |
| Force majeure | Standard + pandemic-inclusive language post-2020 |
| Assignment | No assignment without consent / Free to affiliates / Notice-only |

## Workflow

1. **Gather requirements** (questionnaire above)
2. **Select template** (type + jurisdiction)
3. **Customize** — fill in party details, scope, value, dates
4. **Flag unusual asks** — if the user requests non-standard terms, note business implications
5. **Generate Markdown draft** — clean structure, numbered sections, defined terms capitalized
6. **Convert to .docx** (via `docx-pro`) — apply company template if available
7. **Output review checklist** — things the user should verify with counsel

## Output Formats

- **Markdown** (primary) — easy to review and diff
- **.docx** — use `docx-pro` for conversion with company template
- **.pdf** — use `pdf-pro` for locked distribution (after signature)

## Common Mistakes to Avoid

- Mixing trade names and legal entity names → always use the **registered legal entity**
- Defined terms inconsistent capitalization → capitalize ONLY when the Term is defined
- "Reasonable best efforts" vs "best efforts" → legal difference exists in some jurisdictions; be deliberate
- Silent on IP ownership → ownership defaults vary by jurisdiction; always address
- Missing GDPR DPA when EU data flows → huge regulatory exposure
- No termination-for-convenience → lock-in when the relationship should be flexible
- Indemnification not capped → unbounded liability exposure
- No survival clause → confidentiality / IP / payment obligations should survive termination

## Integration

- `docx-pro` — final output to company-styled Word
- `pdf-pro` — lock for signature with encryption
- `email-pro` — cover email with the contract attachment
- `doc-coauthor` — for complex deals where multiple stakeholders need to shape terms
