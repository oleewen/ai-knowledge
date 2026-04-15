# Cursor Skills 指南

## Slash 命令（Skills）

本目录下的命令均为 **Skill**（`SKILL.md` 工作流，由 Agent 执行），不是仓库 `scripts/` 下的 Bash 脚本。

- Skill 路径：`agent/skills/<skill-name>/SKILL.md`
- 命令名约定：目录名即 Slash 命令（如 `docs-indexing` -> `/docs-indexing`）
- 调用方式：在 Chat 输入 `/` 选择命令，或使用 `@<skill-name>` 作为上下文附加

## 当前可用技能

| 命令 | 说明 |
|------|------|
| `/docs-indexing` | 生成结构化 `INDEX_GUIDE.md`（九章文档地图），作为 Agent 导航与 RAG 权威来源；索引运行日志写入 `changelogs/INDEXING-LOG.md`；支持全量/增量扫描与深度 1/2/3。 |
| `/docs-change` | 从 git commit、CHANGELOG/CHANGE-LOG、本地文件 mtime 采集变更，落盘 `CHANGE-LOG.md`（文末 HTML 注释承载增量基线）；供下游增量索引等使用。 |
| `/docs-upgrade` | 定向增改 Markdown、源代码注释与配置文本；落盘后链式同步引用链，并辅以关键词检索（同义/近义/中英文）对齐同类表述；支持替换简写 `a - b` / `a > b` / `a 2 b`。 |
| `/agent-guide` | 生成或更新根目录 `README.md`（人类）与 `AGENTS.md`（Agent）；以落盘 `INDEX_GUIDE.md` 为唯一地图，与 Index 职责不重叠。 |
| `/docs-archive` | 将 `system/application-{name}/` 已核实内容归档到系统知识库 `system/architecture/`；支持 `--app` `--since` `--full` `--dry-run`，默认按增量锚点归档。 |
| `/docs-fetch` | 从已通过中央知识库挂载建联注册的目标工程拉取最新文档，覆盖更新本仓库联邦镜像 `applications/app-{APPNAME}/`，并追加同步 changelog。 |
| `/docs-build` | 从工程代码与文档按四视角（技术→数据→业务→产品）提取链上实体 ID，生成 `*_knowledge.json`（schema 2.1），刷新各视角 README 与 `{DOC_DIR}/knowledge/KNOWLEDGE_INDEX.md`。 |
| `/sdx-solution` | 产出解决方案阶段文档（Solution 阶段）。 |
| `/sdx-analysis` | 产出需求分析阶段文档（Analysis 阶段）。 |
| `/sdx-prd` | 产出 PRD 阶段文档（Requirements 阶段）；总确认前默认禁止写入 `{DOC_DIR}/requirements/**/PRD-*.md`（见技能 HARD-GATE）。 |
| `/sdx-design` | 产出架构/设计阶段文档（Architecture Design 阶段）。 |
| `/sdx-test` | 产出测试设计与验证阶段文档（Test 阶段）；总确认前默认禁止写入 `{DOC_DIR}/requirements/**/TDD-*.md`（见技能 HARD-GATE）。 |
| `/skill-creator` | 创建、评测与迭代技能的官方工作流（含 `scripts/`、`eval-viewer/`）。来源：Anthropic 仓库 [anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official) 中 `plugins/skill-creator/skills/skill-creator`；本仓库副本在 `agent/skills/skill-creator/`。 |

## 使用说明

- 这些命令由 Agent 依据对应 `SKILL.md` 执行并落盘产物。
- **`git commit` / `git push`**：须遵守仓库 **[git-guidelines.md](../rules/coding/git-guidelines.md)**「提交前用户确认」— **禁止**在未经用户明确同意时提交；步骤中若写「Commit」，意为**经用户确认后再提交**。
- `scripts/` 目录负责项目初始化（如 `docs-*.sh`），不等同于 Skill 命令。
- 若命令输出涉及索引或变更记录，请以仓库约定路径为准（如 `INDEX_GUIDE.md`、`{DOC_DIR}/changelogs/`）。
