# CLAUDE.md · Office Skills Pro

这份文件配置龙虾（Claude Code）怎么用 office-skills-pro 这套库 —— 改之前先看懂 · 它决定 skill 路由的行为。

## Skill 路由

主人的请求匹配到某个 skill 的 description 时 · 龙虾自动调那个 skill。描述匹配由 Claude Code 的 skill runtime 完成 · 这里只是把决策规则写清楚。

### 按格式触发

| 请求里出现 | 触发的 skill |
|-----------|------------|
| `.docx` / "Word 文档" / "公文" / "信函" / "备忘录" | `docx-pro` |
| `.xlsx` / `.csv` / "表格" / "Excel" / "财务模型" | `xlsx-pro` |
| `.pptx` / "PPT" / "幻灯片" / "演示文稿" / "路演" | `pptx-pro` |
| `.pdf` / "PDF" / "OCR" / "填 PDF 表单" | `pdf-pro` |

### 按工作流触发

| 信号 | Skill |
|------|-------|
| "写 PRD / RFC / 决策文档 / 技术规范" | `doc-coauthor` |
| "起草邮件" / "冷启动外联" / "邮件序列" | `email-pro` |
| "分析会议" / "转录" / "我表现怎样" | `meeting-analyzer` |
| "合同" / "NDA" / "SOW" / "提案" / "MSA" | `contract-pro` |
| "清洗这份数据" / "乱 CSV" / "修这张表" | `data-cleaner` |
| "周报" / "月报" / "从数字做董事会汇报" | `report-builder` |
| "邮件合并" / "批量填" / "根据这份列表生成 N 份文档" | `form-automator` |
| 多格式流水线（数据 → PPT → PDF → 邮件）| `office-orchestrator` |

### 消歧规则

1. **单格式请求** → 直接用对应的格式 skill · 别用 `office-orchestrator` 做单步任务
2. **多格式流水线** → 调 `office-orchestrator` · 它再分发
3. **内容创作 + 特定格式** → 先调工作流 skill（比如 `doc-coauthor`）· 最后渲染用格式 skill（`docx-pro`）
4. **数据分析 + 演示** → `report-builder` 拿叙事主导权 · 按需调 `xlsx-pro` / `pptx-pro`

## 所有 Skill 都要守的质量线

这套库产出的每一份交付物都遵守：

1. **验证才说完成** —— 每个 skill 都有明确 checklist · 没过 checklist 不许说 done
2. **不准在表格里写死数字** —— 永远用公式（按 `xlsx-pro` 的标准）
3. **PPT 不要"标题下横线" · 不要超过 5 片的饼图 · 不要 emoji 装饰** —— 所有 PPT 和报告走反 slop 纪律
4. **基于证据** —— 会议分析引用时间戳 · 数据清洗输出 changelog · 报告不仅说数字还说 "what / so what / now what"
5. **邮件合并先 dry run** —— 永远先测 3-5 条给主人看 · 批准后才批量
6. **不准吞错误** —— 输出成功的同时一定带 `errors.csv` / changelog / warnings
7. **匹配既有模板** —— 改一个已经有既定样式的文件时 · 不许强加所谓"最佳实践"覆盖原样式

## 依赖

核心 Python 栈（全开源）：
- `python-docx` / `docxtpl` —— Word
- `openpyxl` / `xlsxwriter` / `pandas` —— Excel
- `python-pptx` —— PowerPoint
- `pypdf` / `pdfplumber` / `pymupdf` / `reportlab` —— PDF
- `jinja2` / `python-dateutil` / `chardet` / `rapidfuzz` —— 工具

系统工具：
- `libreoffice`（soffice）—— 跨格式转换 · Excel 公式重算
- `pandoc` —— docx ↔ md ↔ html
- `poppler-utils`（pdftoppm · pdftotext）—— PDF 内省
- `tesseract-ocr` —— 扫描件 OCR

一条命令装完 · 跑 `install.sh`。

## 文件操作安全

- **破坏性操作**（覆盖、删除、批量发邮件）需要主人明确确认 —— 除非主人开了自动模式
- **输出默认去** `./deliverables/` —— 不原地修改源文件
- **永远不提交密钥** —— SMTP 密码 · API key · 数据库 URL 必须走环境变量
- **PII / 敏感数据** —— 主人给个人数据时 · 本地处理 · 不往记忆系统里存中间副本

## 和龙虾其它功能的整合

- **任务跟踪** —— 多步编排要用 TaskCreate 明确建任务
- **后台 Agent** —— 长跑流水线（批量邮件合并 · 几千份 PDF OCR）用后台 agent
- **记忆** —— 不把转录 / 合同 / PII 存进 auto-memory · 处理完即抛
- **子 Agent** —— PPT / 文档的视觉 QA 按 `pptx-pro` 的流程 · 每次起新子 agent

## 版本管理

每份 SKILL.md 在 frontmatter 声明自己的版本。破坏性变更升 major · 新能力升 minor · 修错别字 / 改文档升 patch。

改 skill 时顺手更新 frontmatter 的 `version` · 让用户能跟上游 diff。

## 求助

- 每个 SKILL.md 都是深度技术文档 · 直接读
- 问题 / 功能建议：https://github.com/huangji6693-max/office-skills-pro/issues
- 缺了某个模式？fork 加 —— 11 个可组合 skill 的架构就是为了扩展设计的
