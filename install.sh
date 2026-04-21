#!/usr/bin/env bash
set -euo pipefail

# Office Skills Pro installer
# Copies the 11 office-automation skills into ~/.claude/skills/
# and verifies required system dependencies.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"

echo "==> Installing Office Skills Pro to $TARGET"
mkdir -p "$TARGET"

SKILLS=(docx-pro xlsx-pro pptx-pro pdf-pro doc-coauthor email-pro meeting-analyzer contract-pro data-cleaner report-builder form-automator office-orchestrator)

installed=0
for skill in "${SKILLS[@]}"; do
    src="$SCRIPT_DIR/skills/$skill"
    dst="$TARGET/$skill"
    if [[ ! -d "$src" ]]; then
        echo "   SKIP  $skill (source missing)"
        continue
    fi
    if [[ -e "$dst" ]]; then
        echo "   REPLACE  $skill"
        rm -rf "$dst"
    else
        echo "   ADD      $skill"
    fi
    cp -r "$src" "$dst"
    installed=$((installed + 1))
done
echo "==> Installed $installed skills"

echo ""
echo "==> Checking Python dependencies"
missing_py=()
for pkg in docx openpyxl pandas pptx pypdf pdfplumber fitz reportlab PIL docxtpl jinja2; do
    python3 -c "import $pkg" 2>/dev/null || missing_py+=("$pkg")
done
if (( ${#missing_py[@]} > 0 )); then
    echo "   Missing Python packages: ${missing_py[*]}"
    echo "   Install with:"
    echo "     pip install python-docx docxtpl openpyxl xlsxwriter pandas \\"
    echo "       python-pptx 'markitdown[pptx,docx,xlsx]' \\"
    echo "       pypdf pdfplumber pymupdf reportlab pdfminer.six ocrmypdf img2pdf \\"
    echo "       python-dateutil chardet rapidfuzz jinja2 regex webvtt-py srt Pillow"
else
    echo "   All Python packages present"
fi

echo ""
echo "==> Checking system tools"
for bin in soffice pandoc pdftoppm pdftotext tesseract; do
    if command -v "$bin" >/dev/null 2>&1; then
        echo "   FOUND   $bin"
    else
        echo "   MISSING $bin"
    fi
done

cat <<'EOF'

==> Done.

Quick start — any of these will invoke a skill automatically:
  • "Build me a Q4 financial model in Excel"              → xlsx-pro
  • "Turn this transcript into coaching feedback"          → meeting-analyzer
  • "Draft an NDA for a freelancer in Germany"             → contract-pro
  • "Clean this CSV and email each customer their invoice" → office-orchestrator
                                                              (data-cleaner → form-automator → email-pro)

Full docs: https://github.com/huangji6693-max/office-skills-pro
EOF
