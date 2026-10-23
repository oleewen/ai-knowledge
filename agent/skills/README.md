# Cursor Skills 指南

## Slash 命令（Skills）

本目录下的命令均为 **Skill**（`SKILL.md` 工作流，由 Agent 执行），不是仓库 `scripts/` 下的 Bash 脚本。

- Skill 路径：`agent/skills/<skill-name>/SKILL.md`
- 命令名约定：目录名即 Slash 命令（如 `docs-indexing` → `/docs-indexing`）
- 调用方式：Chat 输入 `/` 选择，或 `@<skill-name>` 附加上下文
- **共通协议**（重闸门族）：参数向导 → **澄清 → 生成 → 烤干** → `C/M/G/F`（docs 另有 `S`）；语义性变更先确认。契约：[intent-clarify.md](../references/intent-clarify.md)、[unit-cycle-protocol.md](../references/unit-cycle-protocol.md)、[grilling-skill.md](../references/grilling-skill.md)、[CONVENTIONS.md §3](../rules/CONVENTIONS.md#artifact-gates)
- **轻流程**（不绑意图澄清）：`docs-okf` / `docs-link` / `docs-pull` / `docs-tag` / `docs-install` / `agent-install` / `docs-upgrade` / `skill-upgrade`；动作 `C/M/S/F` 见 [light-flow-actions.md](../references/light-flow-actions.md)（无 `G`）
- **知识库布局**：[knowledge-layout.md](../references/knowledge-layout.md)

下表**只写差异**（产物、关键参数、特殊产物）；协议不逐行复述。

## 当前可用技能

| 分类 | 命令 | 差异要点 |
| ---- | ---- | ---- |
| 安装与升级 | `/agent-install` | 整棵 Agent 树；`--agents`/`--target`/`--scope`；默认 dry-run；轻流程 |
| 安装与升级 | `/docs-install` | 知识库同步 + `.docsconfig`；`--target`/`--scope`/`--type`/`--mode`；默认 dry-run；轻流程 |
| 安装与升级 | `/docs-upgrade` | 读 `.docsconfig` + `type: meta` 对齐最新元库结构；正文保本库；H2至H6 元库结构重填；未落位 C 后三档（批量文件/单文件批量/逐项并入）；指定路径强制对齐（与整树互斥）；禁清空式 install |
| 安装与升级 | `/docs-publish` | 按四层 DESIGN 版本规则生成 `YYYY.MMdd.patch`；记录 `docs-publish` Git 提交；rebase、推送、快进合并 main，并创建下一 feature 分支 |
| 安装与升级 | `/skill-upgrade` | 生态 skills 追新（`npx skills update`）；无源经确认走 find-skills 补源；本仓 Agent 树 → `/agent-install`；轻流程 |
| 知识生成与构建 | `/docs-indexing` | 参数 `mode/depth/output/since`；产出九章 `INDEX-GUIDE.md` + `INDEX-GUIDE` 增量锚点注释（须列完整仓库根相对路径） |
| 知识生成与构建 | `/docs-agent` | 根 `README.md` + `AGENTS.md`；九章地图以已落盘 `INDEX-GUIDE.md` 为准，与 `index.md` 职责不重叠 |
| 知识生成与构建 | `/docs-build` | 五视角实体 ID → per-entity `{ID}.md`、视角 README、`INDEX-GUIDE.md` 第四章视角导航块 |
| 知识生成与构建 | `/docs-tag` | 四层 `{NAME}-overview.md` 关键词：候选附录、表行 ✅、架构摘录；`--scan-dir` 默认同层 `knowledge/`。轻流程。见 [workflow.md](docs-tag/references/workflow.md) |
| 知识生成与构建 | `/docs-extract` | `--sources / --overview / --dry-run` → 非槽位源写四层 overview 第三列 |
| 知识生成与构建 | `/docs-distill` | `--doc-dir system\|solution\|company` + `--name` + 可选 `--dry-run` → 槽位上行全量写目标层 `overview` 第三列（不写 DISTILL-LOG） |
| 知识生成与构建 | `/docs-archive` | overview 表行 → 四层视角章节；冲突策略；方案确认书=意图澄清 |
| 知识库维护 | `/docs-revise` | 术语/路径链式同步 + 定向纠错；烤干修订后走协议 simplify 遍；整篇结构交 `/docs-simplify` |
| 知识库维护 | `/docs-merge` | `<source> <target>`〔`--dry-run`〕→ 按目标 H2/H3 章节合入；新增确认、类似合并、冲突 grilling；源只读 |
| 知识库维护 | `/docs-simplify` | 金字塔结构 + 激进精简 + SSOT 去重引用；原则见 [simplify-principles.md](../references/simplify-principles.md) |
| 知识库维护 | `/docs-okf` | OKF refresh / validate / viz；须 `.docsconfig` 的 `DOC_DIR`+`AGENT_DIR`+`KNOWLEDGE_TYPE`；脚本走 `{DOC_DIR}/{AGENT_DIR}/`；轻流程 |
| 需求交付 | `/sdx-domains` | → `company/domains/DOMAIN-MAP.md`、`DOMAIN-{BD-ID}.md` |
| 需求交付 | `/sdx-solution` | 解决方案库 `solutions/SOLUTION-*.md`（交付包切分叙事） |
| 需求交付 | `/sdx-analysis` | 系统/应用 `{DOC_DIR}/analysis/ANALYSIS-*.md`（七章需求分析） |
| 需求交付 | `/sdx-feature` | 系统/应用 `{DOC_DIR}/features/FEATURE-*.md`（六章功能特性） |
| 需求交付 | `/sdx-prd` | 基于已共识 FEATURE 当前 MVP → `PRD-*.md` |
| 需求交付 | `/sdx-architect` | 基于 PRD → `ASD-*.md`（§1–§3）；可选 `spec-asd-*.md` |
| 需求交付 | `/sdx-design` | 基于 PRD + ASD/spec-asd → `DSD-*.md`（实现在 §2）；上游可含 `{DOC_DIR}/specs/spec-asd-*.md` |
| 需求交付 | `/sdx-test` | 基于 PRD + DSD/ASD → `TDD-*.md`（策略/用例/数据/环境；不产出自动化代码） |
| 联邦协作 | `/docs-link` | `--link`/`--unlink` + `--target`〔`--app-name`〕〔`--rewrite-http`〕→ 双边 `knowledge-links.yaml` + 槽位软链；脚本 `agent/skills/docs-link/scripts/`；默认 dry-run；轻流程 |
| 联邦协作 | `/docs-pull` | 按 `knowledge-links.yaml` 的 child repository/path 校验联邦槽位并 clone/pull；`SYNC_OK` 含 commit；轻流程 |

## 使用说明

- 由 Agent 按对应 `SKILL.md` 执行并落盘。
- **`git commit` / `git push`**：须 [git-guidelines.md](../rules/coding/git-guidelines.md)「提交前用户确认」；步骤中「Commit」= 确认后再提交。
- 装机脚本在 `agent/skills/docs-install/scripts/`、`agent/skills/agent-install/scripts/`；仓根 `bootstrap.sh` 编排双轨；`agent/scripts/` = 共享 Bash 库。
- 索引类产物路径以约定为准（`INDEX-GUIDE.md`、`index.md`、`{DOC_DIR}/`INDEX-GUIDE` 增量锚点注释）；变更溯源用 `git log` / `git diff`。
