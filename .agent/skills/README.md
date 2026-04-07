# Cursor Skills 指南

## Slash 命令（Skills）

本目录下的命令均为 **Skill**（`SKILL.md` 工作流，由 Agent 执行），不是仓库 `scripts/` 下的 Bash 脚本。

- Skill 路径：`.agent/skills/<skill-name>/SKILL.md`
- 命令名约定：目录名即 Slash 命令（如 `docs-indexing` -> `/docs-indexing`）
- 调用方式：在 Chat 输入 `/` 选择命令，或使用 `@<skill-name>` 作为上下文附加

## 当前可用技能

| 命令 | 说明 |
|------|------|
| `/docs-indexing` | 生成面向 AI 的仓库索引（`INDEX_GUIDE.md`），支持分层检索与路径精确引用。 |
| `/docs-change` | 聚合 git/CHANGELOG/文件 mtime 生成变更索引（如 `changes-index.*`）。 |
| `/docs-upgrade` | 定向增改文档与代码注释；默认沿引用链并辅以关键词检索（同义/近义/中英文）对齐同类表述；显式路径或引用片段时自动执行；支持 `a - b` / `a > b` / `a 2 b`；不确定项列选项由用户决策。 |
| `/agent-guide` | 生成/更新根目录 `AGENTS.md` 与 `README.md`，对齐仓库导航与约束。 |
| `/docs-archive` | 将应用侧有效知识归档到**系统知识库根目录**（`application/`）全目录（含 knowledge、solutions、analysis、requirements、specs、上行批次 changelogs 及受影响的系统导航/契约文件），支持增量归档（changelog 锚点），可指定应用或处理所有未归档内容。 |
| `/docs-fetch` | 从已注册的应用知识库（central 模式）拉取最新文档内容，更新**应用知识库根目录**下 `applications/app-{APPNAME}/` 联邦镜像，并记录同步 changelog。 |
| `/docs-build` | 按知识工程流程构建/补全知识资产与关联结构。 |
| `/sdx-solution` | 产出解决方案阶段文档（Solution 阶段）。 |
| `/sdx-analysis` | 产出需求分析阶段文档（Analysis 阶段）。 |
| `/sdx-prd` | 产出 PRD 阶段文档（Requirements 阶段）。 |
| `/sdx-design` | 产出架构/设计阶段文档（Architecture Design 阶段）。 |
| `/sdx-test` | 产出测试设计与验证阶段文档（Test 阶段）。 |
| `/skill-creator` | 创建、评测与迭代技能的官方工作流（含 `scripts/`、`eval-viewer/`）。来源：Anthropic 仓库 [anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official) 中 `plugins/skill-creator/skills/skill-creator`；本仓库副本在 `.cursor/skills/skill-creator/`。 |

## 使用说明

- 这些命令由 Agent 依据对应 `SKILL.md` 执行并落盘产物。
- `scripts/` 目录负责项目初始化（如 `docs-*.sh`），不等同于 Skill 命令。
- 若命令输出涉及索引或变更记录，请以仓库约定路径为准（如 `INDEX_GUIDE.md`、系统知识库根目录下 `application/changelogs/`）。
