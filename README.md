# Office Skills Pro · 龙虾的办公自动化 12 件套

> 12 个实战沉淀出来的 Claude Code skill · 把龙虾变成完整的办公自动化专家 —— 覆盖 Word / Excel / PowerPoint / PDF 四大核心格式，再加上文档协作、会议分析、邮件、合同、数据清洗、报告生成、表单自动化、跨格式编排 8 套工作流。

灵感来源：
- [anthropics/skills](https://github.com/anthropics/skills) —— Anthropic 官方 skill 的办公文档模式、QA 循环、设计原则
- [alirezarezvani/claude-skills](https://github.com/alirezarezvani/claude-skills) —— 商业办公模式（合同、会议分析）
- 中小企业 / SaaS / 自由职业的真实使用场景

所有 skill 都是**原创实现** · 用开源库（python-docx / openpyxl / python-pptx / pypdf / pymupdf / pandas / reportlab）· MIT 协议 —— fork、改、发。

## 12 个 Skill

| Skill | 做什么 |
|-------|--------|
| [**docx-pro**](skills/docx-pro/SKILL.md) | Word 文档创建、编辑、模板、修订追踪、格式转换 |
| [**xlsx-pro**](skills/xlsx-pro/SKILL.md) | Excel 自动化 —— 金融级标准 · 全公式 · 不写死数字 · 零错误 |
| [**pptx-pro**](skills/pptx-pro/SKILL.md) | 让 PPT 看起来像"设计过的"而不是模板套的 —— 10 套配色 · QA 循环 · 反 slop 纪律 |
| [**pdf-pro**](skills/pdf-pro/SKILL.md) | 全套 PDF 工具箱 —— 合并、拆分、OCR、表单、涂黑、加密、对比 |
| [**doc-coauthor**](skills/doc-coauthor/SKILL.md) | 3 阶段结构化协作流 · 写 PRD / RFC / 技术决策文档 |
| [**email-pro**](skills/email-pro/SKILL.md) | 专业邮件写作、邮件序列、模板、要干掉的反模式 |
| [**meeting-analyzer**](skills/meeting-analyzer/SKILL.md) | 会议转录分析 —— 发言权重、对冲词、口头禅、辅导反馈 |
| [**contract-pro**](skills/contract-pro/SKILL.md) | 按司法管辖区起草合同 / NDA / SOW / MSA / DPA（美国 / 欧盟 / 英国 / 德奥瑞）|
| [**data-cleaner**](skills/data-cleaner/SKILL.md) | 清洗凌乱数据 —— 编码、类型、去重、校验、变更日志 |
| [**report-builder**](skills/report-builder/SKILL.md) | 数据 → 叙事 → 打磨过的交付物（周报 / 月报 / 董事会汇报）|
| [**form-automator**](skills/form-automator/SKILL.md) | 邮件合并 —— 模板 × 数据 → N 份个性化文档（docx / pdf / xlsx）|
| [**office-orchestrator**](skills/office-orchestrator/SKILL.md) | 总指挥 —— 把上面所有 skill 串成多步流水线 |

## 安装

### 方式 1：Claude Code 插件市场（以后）

上了市场之后：

```
/plugin marketplace add huangji6693-max/office-skills-pro
/plugin install office-skills-pro
```

### 方式 2：手动装（现在就能用）

```bash
# 克隆仓库
git clone https://github.com/huangji6693-max/office-skills-pro ~/office-skills-pro

# 跑安装脚本（复制 skill 到 ~/.claude/skills/）
cd ~/office-skills-pro && bash install.sh
```

### 方式 3：只装某一个 skill

```bash
cp -r skills/xlsx-pro ~/.claude/skills/
```

### 装系统依赖

```bash
# Python 包（一条命令搞定）
pip install python-docx docxtpl openpyxl xlsxwriter pandas \
    python-pptx "markitdown[pptx,docx,xlsx]" \
    pypdf pdfplumber pymupdf reportlab pdfminer.six ocrmypdf img2pdf \
    python-dateutil chardet rapidfuzz jinja2 regex webvtt-py srt

# 系统工具
# Ubuntu / Debian：
apt install -y libreoffice poppler-utils tesseract-ocr \
    tesseract-ocr-chi-sim tesseract-ocr-chi-tra \
    ghostscript pdftk-java exiftool

# macOS：
brew install libreoffice poppler tesseract tesseract-lang ghostscript exiftool pdftk-java

# 可选：Node 版替代方案
npm install -g docx pptxgenjs
```

## Skill 之间怎么配合

```
                         ┌─── office-orchestrator ───┐
                         │        总指挥               │
                         └──┬────┬────┬────┬────┬────┘
                            │    │    │    │    │
         ┌──────┬───────┬───┘    │    │    │    └────┬─────────┐
         ▼      ▼       ▼        ▼    ▼    ▼         ▼         ▼
    docx-pro xlsx-pro pptx-pro pdf-pro email-pro data-cleaner report-builder
       │         │       │        │                    │            │
       └─────────┴───────┴────────┼────────────────────┘            │
                                  │                                 │
                     ┌────────────┼──────────────┐                  │
                     ▼            ▼              ▼                  │
              doc-coauthor meeting-analyzer contract-pro            │
                                                                    │
              form-automator ─── 用 docx-pro + pdf-pro + xlsx-pro ──┘
```

每个 skill 都自成一体 · 可以单独用。`office-orchestrator` 负责把它们串起来跑跨格式流水线。

## 设计原则

所有 skill 共用同一套质量标准 —— 源自 Anthropic 内部 skill + 实战验证：

1. **纯开源栈** —— 不依赖任何付费服务
2. **验证才说完成** —— 明确的 checklist、校验脚本、可视化 QA 循环
3. **行业标准输出** —— 财务模型用蓝 / 黑 / 绿 / 红四色约定 · PPT 遵守单主色 / 60-70% 主导色规则 · 文档匹配既有模板
4. **叙事 > 数字** —— 报告永远要讲 "what / so what / now what"
5. **反 slop 纪律** —— 不用 emoji 装饰 · 不做标题下横线 · 不玩渐变噪声填充
6. **证据导向反馈** —— 会议分析引用时间戳 · 数据清洗输出 changelog
7. **邮件合并安全** —— 批处理前先 dry run · 错误暴露不吞没
8. **司法管辖区意识** —— 合同自适应美 / 欧 / 英 / 德奥瑞
9. **可组合** —— 每个 skill 独立 · 编排器串联

## 在 Claude Code 里怎么用

装完之后 · 龙虾会在识别到匹配任务时自动调 skill：

```
主人："把这份客户名单清洗一下 · 然后给每位客户发对应的发票邮件"

龙虾自动编排：
  1. data-cleaner → 输出 clean.csv
  2. form-automator → 生成 N 份发票 PDF
  3. pdf-pro → 平整化 + 加密
  4. email-pro → 先出 dry-run 草稿 → （批准后）批量发送
```

也可以显式指定：

```
主人："用 xlsx-pro 做一份 Q4 财务模型 · 按标准配色"
```

## 为什么是 12 个 · 不是更多？

写 50 个 skill 很容易 · 但我们只给 12 个 · 理由：
- **每个 SKILL.md 被触发时都会进上下文** —— 少而深 > 多而浅
- **12 个能覆盖真实办公工作的 95%** —— 长尾需求不值得维护成本
- **组合比专精更强大** —— `office-orchestrator` 把 12 个串成成千上万种工作流

如果你需要很专的东西（比如 `sales-deck-builder`）· fork 加一个就行 · 骨架已经在这里了。

## 贡献

欢迎 PR · 重点方向：
- `docx-pro` 增加更多语言支持（RTL · 中日韩字体排版）
- `pdf-pro` 更好的 XFA 处理
- `pptx-pro` 更多行业配色变体
- `contract-pro` 增加更多司法管辖区（亚太 · 拉美）

## 协议

MIT · 详见 [LICENSE](LICENSE)。

## 致谢

- Anthropic 的 [skills](https://github.com/anthropics/skills) 团队 —— PPTX 设计纪律 + XLSX 金融标准的设计模式来自他们 · 这里是用开源库做的原创重写
- [Alireza Rezvani](https://github.com/alirezarezvani) —— 合同和会议分析模式参考了 MIT 协议的 `claude-skills` 仓库
- [Simon Willison](https://github.com/simonw) —— 最早记录 skill 生态的人

---

为 [Claude Code](https://claude.com/claude-code) 打造 · 零魔法 · 零密钥 · 零厂商锁定。
