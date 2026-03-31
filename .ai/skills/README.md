# Cursor Skills 指南

## Slash 命令（Skills）

本目录下的命令均为 **Skill**（`SKILL.md` 工作流，由 Agent 执行），不是仓库 `scripts/` 下的 Bash 脚本。

- Skill 路径：`.ai/skills/<skill-name>/SKILL.md`
- 命令名约定：目录名即 Slash 命令（如 `docs-indexing` -> `/docs-indexing`）
- 调用方式：在 Chat 输入 `/` 选择命令，或使用 `@<skill-name>` 作为上下文附加

## 当前可用技能

| 命令 | 说明 |
|------|------|
| `/docs-indexing` | 生成面向 AI 的仓库索引（`INDEX_GUIDE.md`），支持分层检索与路径精确引用。 |
| `/docs-change` | 聚合 git/CHANGELOG/文件 mtime 生成变更索引（如 `changes-index.*`）。 |
| `/agent-guide` | 生成/更新根目录 `AGENTS.md` 与 `README.md`，对齐仓库导航与约束。 |
| `/knowledge-archive` | 将应用侧有效知识回收至系统知识库，保持联邦治理与 SSOT。 |
| `/knowledge-build` | 按知识工程流程构建/补全知识资产与关联结构。 |
| `/sdx-solution` | 产出解决方案阶段文档（Solution 阶段）。 |
| `/sdx-analysis` | 产出需求分析阶段文档（Analysis 阶段）。 |
| `/sdx-prd` | 产出 PRD 阶段文档（Requirements 阶段）。 |
| `/sdx-design` | 产出架构/设计阶段文档（Architecture Design 阶段）。 |
| `/sdx-test` | 产出测试设计与验证阶段文档（Test 阶段）。 |

## 使用说明

- 这些命令由 Agent 依据对应 `SKILL.md` 执行并落盘产物。
- `scripts/` 目录负责项目初始化（如 `knowledge-init*.sh`），不等同于 Skill 命令。
- 若命令输出涉及索引或变更记录，请以仓库约定路径为准（如 `INDEX_GUIDE.md`、`system/changelogs/`）。
