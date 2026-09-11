# Cursor Skills 指南

## Slash 命令（Skills）

本目录下的命令均为 **Skill**（`SKILL.md` 工作流，由 Agent 执行），不是仓库 `scripts/` 下的 Bash 脚本。

- Skill 路径：`agent/skills/<skill-name>/SKILL.md`
- 命令名约定：目录名即 Slash 命令（如 `docs-indexing` → `/docs-indexing`）
- 调用方式：Chat 输入 `/` 选择，或 `@<skill-name>` 附加上下文
- **共通协议**（重闸门族）：参数向导 → **澄清 → 生成 → 烤干** → `C/M/G/F`（docs 另有 `S`）；语义性变更先确认。契约：[intent-clarify.md](../references/intent-clarify.md)、[unit-cycle-protocol.md](../references/unit-cycle-protocol.md)、[grilling-skill.md](../references/grilling-skill.md)、[CONVENTIONS.md §3](../rules/CONVENTIONS.md#artifact-gates)
- **轻流程**（不绑意图澄清）：`docs-okf` / `docs-change` / `docs-tag` / `docs-link` / `docs-pull` / `docs-push` / `docs-install` / `agent-install` / `docs-upgrade` / `skill-upgrade`；动作 `C/M/S/F` 见 [light-flow-actions.md](../references/light-flow-actions.md)（无 `G`）
- **知识库布局**：[knowledge-layout.md](../references/knowledge-layout.md)

下表**只写差异**（产物、关键参数、特殊产物）；协议不逐行复述。

## 当前可用技能

| 命令 | 差异要点 |
| ---- | ---- |
| `/docs-indexing` | 参数 `mode/depth/output/since`；产出九章 `INDEX-GUIDE.md` + `changelogs/INDEXING-LOG.md`（须列完整仓库根相对路径） |
| `/docs-change` | 三源采集变更 → `{output_dir}/CHANGE-LOG.md`（文末增量基线注释）；轻流程 |
| `/docs-tag` | overview 关键词：候选附录、表行 ✅、架构摘录（phase 3）；轻流程 + phase 轻量校核（非语义族 grilling）。见 [workflow.md](docs-tag/references/workflow.md) |
| `/docs-revise` | 术语/路径链式同步 + 定向纠错；烤干修订后走协议 simplify 遍；整篇结构交 `/docs-simplify` |
| `/docs-simplify` | 金字塔结构 + 激进精简 + SSOT 去重引用；原则见 [docs-simplify.md](../references/docs-simplify.md) |
| `/docs-agent` | 根 `README.md` + `AGENTS.md`；九章地图以已落盘 `INDEX-GUIDE.md` 为准，与 `index.md` 职责不重叠 |
| `/docs-distill` | `--app / --since / --full / --dry-run` → 系统 `overview` 第三列 + `DISTILL-LOG` |
| `/docs-extract` | `--sources / --overview / --dry-run` → 系统或公司 overview 第三列；不写 `DISTILL-LOG` |
| `/docs-merge` | `<source> <target>`〔`--dry-run`〕→ 按目标 H2/H3 章节合入；新增确认、类似合并、冲突 grilling；源只读 |
| `/docs-install` | 知识库同步 + `.docsconfig`；`--target`/`--scope`/`--type`/`--mode`；默认 dry-run；轻流程 |
| `/agent-install` | 整棵 Agent 树；`--agents`/`--target`/`--scope`；默认 dry-run；轻流程 |
| `/skill-upgrade` | 生态 skills 追新（`npx skills update`）；无源经确认走 find-skills 补源；本仓 Agent 树 → `/agent-install`；轻流程 |
| `/docs-upgrade` | 读 `.docsconfig` + `type: meta` 对齐元库最新结构；正文保本库；H2/H3 重填；未落位清单确认；可选 `@` 指定文件/目录强制对齐（与整树互斥）；禁清空式 install |
| `/docs-link` | `--link`/`--unlink` + `--target`〔`--app-name`〕〔`--rewrite-http`〕→ 双边 `knowledge-links.yaml` + 槽位软链；脚本 `agent/skills/docs-link/scripts/`；默认 dry-run；轻流程 |
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
- 装机脚本在 `agent/skills/docs-install/scripts/`、`agent/skills/agent-install/scripts/`；仓根 `bootstrap.sh` 编排双轨；`agent/scripts/` = 共享 Bash 库。
- 索引/变更类产物路径以约定为准（`INDEX-GUIDE.md`、`index.md`、`{DOC_DIR}/changelogs/`）。
