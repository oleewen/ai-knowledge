# Cursor Skills 指南

## Slash 命令（Skills）

本目录下的命令均为 **Skill**（`SKILL.md` 工作流，由 Agent 执行），不是仓库 `scripts/` 下的 Bash 脚本。

- Skill 路径：`agent/skills/<skill-name>/SKILL.md`
- 命令名约定：目录名即 Slash 命令（如 `docs-indexing` → `/docs-indexing`）
- 调用方式：Chat 输入 `/` 选择，或 `@<skill-name>` 附加上下文
- **共通协议**（重闸门族）：参数向导 → **澄清 → 生成 → 烤干** → `C/M/G/F`（docs 另有 `S`）；语义性变更先确认。契约：[intent-clarify.md](../references/intent-clarify.md)、[unit-cycle-protocol.md](../references/unit-cycle-protocol.md)、[grilling-skill.md](../references/grilling-skill.md)、[CONVENTIONS.md §3](../rules/CONVENTIONS.md#artifact-gates)
- **轻流程**（不绑意图澄清）：`docs-okf` / `docs-change` / `docs-tag` / `docs-pull` / `docs-push`；动作 `C/M/S/F` 见 [light-flow-actions.md](../references/light-flow-actions.md)（无 `G`）
- **知识库布局**：[knowledge-layout.md](../references/knowledge-layout.md)

下表**只写差异**（产物、关键参数、特殊产物）；协议不逐行复述。

## 当前可用技能

| 命令 | 差异要点 |
| ---- | ---- |
| `/docs-indexing` | 参数 `mode/depth/output/since`；产出九章 `INDEX-GUIDE.md` + `changelogs/INDEXING-LOG.md`（须列完整仓库根相对路径） |
| `/docs-change` | 三源采集变更 → `{output_dir}/CHANGE-LOG.md`（文末增量基线注释）；轻流程 |
| `/docs-tag` | overview 关键词：候选附录、表行 ✅、架构摘录（phase 3）；轻流程 + phase 轻量校核（非语义族 grilling）。见 [workflow.md](docs-tag/references/workflow.md) |
| `/docs-upgrade` | 范围/替换策略/链式同步；改 Markdown、注释、配置文本 |
| `/docs-simplify` | 金字塔结构 + 激进精简 + SSOT 去重引用；原则见 [docs-simplify.md](../references/docs-simplify.md) |
| `/docs-agent` | 根 `README.md` + `AGENTS.md`；九章地图以已落盘 `INDEX-GUIDE.md` 为准，与 `index.md` 职责不重叠 |
| `/docs-distill` | `--app / --since / --full / --dry-run` → 系统 `overview` 第三列 + `DISTILL-LOG` |
| `/docs-extract` | `--sources / --overview / --dry-run` → 系统或公司 overview 第三列；不写 `DISTILL-LOG` |
| `/docs-pull` | 按 `knowledge-links.yaml` 本地 path → 联邦槽位 + 槽位 `CHANGE-LOG`；无远端 clone；轻流程 |
| `/docs-push` | 中央规约 → 各应用 `path×doc_dir`（legacy / spec-asd）；轻流程 |
| `/docs-build` | 五视角实体 ID → per-entity `{ID}.md`、视角 README、`KNOWLEDGE_INDEX.md` |
| `/docs-archive` | overview 表行 → 目标视角章节；冲突策略；方案确认书=意图澄清 |
| `/docs-okf` | OKF refresh / validate / viz；须 `.docsconfig` 的 `DOC_DIR`+`KNOWLEDGE_TYPE`；轻流程 |
| `/sdx-solution` | → `{DOC_DIR}/solutions/SOLUTION-*.md` |
| `/sdx-analysis` | → `{DOC_DIR}/analysis/ANALYSIS-*.md` |
| `/sdx-prd` | 基于 ANALYSIS 当前 MVP → `PRD-*.md` |
| `/sdx-architect` | 基于 PRD → `ASD-*.md`（§1–§3）；可选 `spec-asd-*.md` |
| `/sdx-design` | 基于 PRD + ASD/spec-asd → `DSD-*.md`（实现在 §2）；上游可含 `{DOC_DIR}/specs/spec-asd-*.md` |
| `/sdx-test` | 基于 PRD + DSD/ASD → `TDD-*.md`（策略/用例/数据/环境；不产出自动化代码） |

## 使用说明

- 由 Agent 按对应 `SKILL.md` 执行并落盘。
- **`git commit` / `git push`**：须 [git-guidelines.md](../rules/coding/git-guidelines.md)「提交前用户确认」；步骤中「Commit」= 确认后再提交。
- 仓库根 `scripts/` = 初始化分发；`agent/scripts/` = Skill 共享 Bash 库——二者不同。
- 索引/变更类产物路径以约定为准（`INDEX-GUIDE.md`、`index.md`、`{DOC_DIR}/changelogs/`）。
