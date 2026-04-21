---
name: pptx-pro
description: Use this skill whenever a .pptx file is involved — as input, output, or both. Trigger for creating slide decks, pitch decks, presentations; reading, parsing, or extracting text from .pptx files; editing, modifying, or updating existing presentations; working with templates, layouts, speaker notes, comments, or master slides; combining or splitting slide files; converting to PDF or images. Trigger on keywords "deck", "slides", "presentation", "pitch", or any .pptx filename. If a .pptx needs to be touched, use this skill.
license: MIT
metadata:
  version: 1.0.0
  category: office-automation
  stack: python-pptx, pptxgenjs, libreoffice, pdftoppm
---

# Presentation Automation

Build decks that look *designed*, not *templated*. Quality bar: if a senior designer saw it, they shouldn't say "AI-generated".

## Quick Reference

| Task | Tool |
|------|------|
| Read / extract text | `python-pptx` or `markitdown` |
| Create from template | `python-pptx` + unpack→XML→repack |
| Create from scratch (JS) | `pptxgenjs` |
| Convert to PDF | `soffice --headless --convert-to pdf` |
| Render slides as images for QA | `pdftoppm -jpeg -r 150` |

## Reading Content

```python
from pptx import Presentation

prs = Presentation("deck.pptx")
for i, slide in enumerate(prs.slides, 1):
    print(f"--- Slide {i} ---")
    for shape in slide.shapes:
        if shape.has_text_frame:
            for para in shape.text_frame.paragraphs:
                print(para.text)
    if slide.notes_slide and slide.notes_slide.notes_text_frame:
        print("NOTES:", slide.notes_slide.notes_text_frame.text)
```

For text-only Markdown export:

```bash
python -m markitdown deck.pptx > deck.md
```

## Design Principles (Before Any Slide)

Anti-template discipline — required for every deck:

1. **Single accent color** — one brand color dominates; no rainbow palettes
2. **60-70% dominance** — pick one color as primary visual weight, 1-2 supporting, 1 sharp accent
3. **Dark/light contrast** — dark for title + conclusion, light for content (sandwich), OR committed dark throughout
4. **One visual motif** — rounded image frames, colored icon circles, single-side borders — pick one, repeat
5. **Every slide has a visual element** — text-only slides are forgettable
6. **No accent lines under titles** — hallmark of AI slop; use whitespace or background color

## Color Palettes (Topic-Matched)

Pick what matches the subject, not default blue:

| Theme | Primary | Secondary | Accent |
|-------|---------|-----------|--------|
| **Midnight Executive** | `1E2761` (navy) | `CADCFC` (ice blue) | `FFFFFF` (white) |
| **Forest & Moss** | `2C5F2D` (forest) | `97BC62` (moss) | `F5F5F5` (cream) |
| **Coral Energy** | `F96167` (coral) | `F9E795` (gold) | `2F3C7E` (navy) |
| **Warm Terracotta** | `B85042` (terracotta) | `E7E8D1` (sand) | `A7BEAE` (sage) |
| **Ocean Gradient** | `065A82` (deep blue) | `1C7293` (teal) | `21295C` (midnight) |
| **Charcoal Minimal** | `36454F` (charcoal) | `F2F2F2` (off-white) | `212121` (black) |
| **Teal Trust** | `028090` (teal) | `00A896` (seafoam) | `02C39A` (mint) |
| **Berry & Cream** | `6D2E46` (berry) | `A26769` (dusty rose) | `ECE2D0` (cream) |
| **Sage Calm** | `84B59F` (sage) | `69A297` (eucalyptus) | `50808E` (slate) |
| **Cherry Bold** | `990011` (cherry) | `FCF6F5` (off-white) | `2F3C7E` (navy) |

## Typography Pairings

Avoid Arial default. Pick a header with personality, clean body:

| Header | Body |
|--------|------|
| Georgia | Calibri |
| Arial Black | Arial |
| Cambria | Calibri |
| Trebuchet MS | Calibri |
| Impact | Arial |
| Palatino | Garamond |

| Element | Size |
|---------|------|
| Slide title | 36-44pt bold |
| Section header | 20-24pt bold |
| Body | 14-16pt |
| Captions | 10-12pt muted |

## Creating from Scratch (python-pptx)

```python
from pptx import Presentation
from pptx.util import Inches, Pt, Emu
from pptx.dgm.color import RGBColor
from pptx.enum.shapes import MSO_SHAPE
from pptx.enum.text import PP_ALIGN

prs = Presentation()
prs.slide_width = Inches(13.333)
prs.slide_height = Inches(7.5)

# Title slide with dark background
slide = prs.slides.add_slide(prs.slide_layouts[6])  # blank
bg = slide.shapes.add_shape(MSO_SHAPE.RECTANGLE, 0, 0, prs.slide_width, prs.slide_height)
bg.fill.solid(); bg.fill.fore_color.rgb = RGBColor(0x1E, 0x27, 0x61)
bg.line.fill.background()

title = slide.shapes.add_textbox(Inches(0.8), Inches(3.0), Inches(11), Inches(1.5))
tf = title.text_frame
p = tf.paragraphs[0]
p.alignment = PP_ALIGN.LEFT
run = p.add_run(); run.text = "Q4 Strategy"
run.font.name = "Georgia"; run.font.size = Pt(54); run.font.bold = True
run.font.color.rgb = RGBColor(0xFF, 0xFF, 0xFF)

prs.save("deck.pptx")
```

## Editing from Template (Preferred)

1. Open template in PowerPoint/Keynote, note slide layouts
2. `python-pptx` load → iterate slides → replace text runs while keeping formatting
3. Unpack XML only when python-pptx can't express the change (complex SmartArt, animation)

```python
prs = Presentation("template.pptx")
for slide in prs.slides:
    for shape in slide.shapes:
        if not shape.has_text_frame: continue
        for para in shape.text_frame.paragraphs:
            for run in para.runs:
                if "{{company}}" in run.text:
                    run.text = run.text.replace("{{company}}", "Acme Inc.")
prs.save("filled.pptx")
```

## Slide Layout Patterns

**Two-column** (text left, visual right) · **Icon-row** (colored icon circles + bold header + description) · **2x2 / 2x3 grid** (image on one side, content blocks the other) · **Half-bleed image** (full left or right with overlay content) · **Big stat** (60-72pt number + small label)

## Visual QA Loop (MANDATORY)

Your first render is almost never correct. Approach QA as a bug hunt.

```bash
# Render each slide as an image
soffice --headless --convert-to pdf deck.pptx
pdftoppm -jpeg -r 150 deck.pdf slide
```

Inspect with a fresh pair of eyes (subagent or dispatcher) using this prompt:

> Visually inspect these slides. Assume there are issues — find them.
> Look for: overlapping elements, text overflow / cutoff, decorative lines misaligned when title wraps, source citations colliding with content above, elements < 0.3" apart, uneven gaps, insufficient margins (< 0.5"), inconsistent column alignment, low-contrast text/icons, leftover placeholder content.
> Report ALL issues including minor.

Loop: generate → render → inspect → fix → re-render → repeat until clean.

## Placeholder Hunt

```bash
python -m markitdown deck.pptx | grep -iE "xxx|lorem|ipsum|click to add|this.*(page|slide).*layout|TBD|FIXME"
```

Any match = not done.

## Export Matrix

```bash
# .pptx → PDF
soffice --headless --convert-to pdf deck.pptx

# Individual slides as PNG / JPG
pdftoppm -png -r 200 deck.pdf slide      # high-res PNG
pdftoppm -jpeg -r 150 deck.pdf slide     # lighter JPG

# Specific slide range
pdftoppm -jpeg -f 3 -l 5 -r 150 deck.pdf slide

# .pptx → MP4 video (LibreOffice + ffmpeg)
soffice --headless --convert-to pdf deck.pptx
# then stitch slides with ffmpeg at desired duration
```

## Speaker Notes

```python
notes_slide = slide.notes_slide
notes_slide.notes_text_frame.text = "Key point: emphasize growth trajectory."
```

## Dependencies

```bash
pip install python-pptx Pillow "markitdown[pptx]"
apt install libreoffice poppler-utils
npm install -g pptxgenjs  # JavaScript alternative
```
