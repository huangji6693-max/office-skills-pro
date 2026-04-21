#!/usr/bin/env bash
set -euo pipefail

# Office Skills Pro 安装器
# 把 12 个办公自动化 skill 拷到 ~/.claude/skills/
# 并校验系统依赖

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"

echo "==> 安装 Office Skills Pro 到 $TARGET"
mkdir -p "$TARGET"

SKILLS=(docx-pro xlsx-pro pptx-pro pdf-pro doc-coauthor email-pro meeting-analyzer contract-pro data-cleaner report-builder form-automator office-orchestrator)

installed=0
for skill in "${SKILLS[@]}"; do
    src="$SCRIPT_DIR/skills/$skill"
    dst="$TARGET/$skill"
    if [[ ! -d "$src" ]]; then
        echo "   跳过  $skill（源文件缺失）"
        continue
    fi
    if [[ -e "$dst" ]]; then
        echo "   替换  $skill"
        rm -rf "$dst"
    else
        echo "   新增  $skill"
    fi
    cp -r "$src" "$dst"
    installed=$((installed + 1))
done
echo "==> 装了 $installed 个 skill"

echo ""
echo "==> 检查 Python 依赖"
missing_py=()
for pkg in docx openpyxl pandas pptx pypdf pdfplumber fitz reportlab PIL docxtpl jinja2; do
    python3 -c "import $pkg" 2>/dev/null || missing_py+=("$pkg")
done
if (( ${#missing_py[@]} > 0 )); then
    echo "   缺失的 Python 包：${missing_py[*]}"
    echo "   用这条命令装："
    echo "     pip install python-docx docxtpl openpyxl xlsxwriter pandas \\"
    echo "       python-pptx 'markitdown[pptx,docx,xlsx]' \\"
    echo "       pypdf pdfplumber pymupdf reportlab pdfminer.six ocrmypdf img2pdf \\"
    echo "       python-dateutil chardet rapidfuzz jinja2 regex webvtt-py srt Pillow"
else
    echo "   Python 包全在"
fi

echo ""
echo "==> 检查系统工具"
for bin in soffice pandoc pdftoppm pdftotext tesseract; do
    if command -v "$bin" >/dev/null 2>&1; then
        echo "   有     $bin"
    else
        echo "   缺     $bin"
    fi
done

cat <<'EOF'

==> 搞定。

快速上手 —— 这些话随便说一句都会自动触发对应的 skill：
  • "给我做一份 Q4 财务模型 Excel"              → xlsx-pro
  • "把这份会议转录做成辅导反馈"                 → meeting-analyzer
  • "给一位德国的自由职业者起草 NDA"             → contract-pro
  • "清洗这份 CSV · 然后给每个客户发对应的发票" → office-orchestrator
                                                       （data-cleaner → form-automator → email-pro）

完整文档：https://github.com/huangji6693-max/office-skills-pro
EOF
