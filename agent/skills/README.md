# Cursor Skills 指南

## Slash 命令（Skills）

本目录下的命令均为 **Skill**（`SKILL.md` 工作流，由 Agent 执行），不是仓库 `scripts/` 下的 Bash 脚本。

- Skill 路径：`agent/skills/<skill-name>/SKILL.md`
- 命令名约定：目录名即 Slash 命令（如 `docs-indexing` -> `/docs-indexing`）
- 调用方式：在 Chat 输入 `/` 选择命令，或使用 `@<skill-name>` 作为上下文附加
- `sdx-*` 与 `docs-distill / docs-extract / docs-archive / docs-build / docs-indexing / docs-upgrade` 默认走参数向导 + 当前段/当前单元推进；语义性变更先确认
- **知识库布局**（双库路径、overview、流水线）：[knowledge-layout.md](../references/knowledge-layout.md)
- **grilling 能力契约**（Skill 优先、fallback 提问协议、统一输出）：[grilling-skill.md](../references/grilling-skill.md)

## 当前可用技能

| 命令 | 说明 |
| ---- | ---- |
| `/docs-indexing` | 通过参数向导确认 `mode/depth/output/since`，按当前输出路径组生成九章 `INDEX-GUIDE.md` 与 `INDEXING-LOG.md`；当前单元自动 grilling 收敛后由用户用 `C/M/G/F` 推进。 |
| `/docs-change` | 从 git commit、CHANGELOG/CHANGE-LOG、本地文件 mtime 采集变更，落盘 `CHANGE-LOG.md`（文末 HTML 注释承载增量基线）；供下游增量索引等使用。 |
| `/docs-tag` | 为 Markdown 概览做关键词驱动标记：候选词附录、表格行 ✅、架构摘录（phase 3）；流程见 [docs-tag/references/workflow.md](docs-tag/references/workflow.md)。 |
| `/docs-upgrade` | 通过参数向导确认范围、替换策略与链式同步范围；按当前范围块/同步块推进 Markdown、注释与配置文本升级，当前单元自动 grilling 收敛后由用户用 `C/M/G/F` 推进。 |
| `/docs-agent` | 生成或更新根目录 `README.md`（人类）与 `AGENTS.md`（Agent）；以落盘 `INDEX-GUIDE.md` 为唯一九章地图，与 `index.md` 的目录索引职责不重叠。 |
| `/docs-distill` | 通过参数向导确认 `--app / --since / --full / --dry-run`，按当前目标块蒸馏 `overview` 第三列与 `DISTILL-LOG`；当前单元自动 grilling 收敛后由用户用 `C/M/G/F` 推进。 |
| `/docs-extract` | 通过参数向导确认 `--sources / --overview / --dry-run`，按当前来源批次与目标块提炼业务知识写入 `system/knowledge/overview/` 或 `company/knowledge/overview/` 第三列。 |
| `/docs-pull` | 按 `knowledge-links.yaml` 从本地 `path` 同步到联邦槽位（`system/application-{APPNAME}/` 或 `company/system-{SYSNAME}/`），并追加槽位 `changelogs/CHANGE-LOG.md`；不做远端 clone。 |
| `/docs-push` | 将 `spec-{yyMMdd}-{n}-{app_name}.md` 推送到 `knowledge-links.yaml` 登记的本机 `path` 下 `{doc_dir}/specs/`；支持 `path` / `repo+feature` 与 Git 四档（`push-specs.sh`）。 |
| `/docs-build` | 通过参数向导确认视角、阈值与输出策略，按当前实体批次/视角批次提取链上实体 ID，刷新各视角 README 与 `{DOC_DIR}/knowledge/KNOWLEDGE_INDEX.md`。 |
| `/docs-archive` | 通过参数向导确认归档范围、目标章节与冲突策略；按当前归档块把 `overview` 知识归档到目标章节，当前单元自动 grilling 收敛后由用户用 `C/M/G/F` 推进。 |
| `/sdx-solution` | 产出解决方案阶段文档（Solution 阶段）。 |
| `/sdx-analysis` | 产出需求分析阶段文档（Analysis 阶段）。 |
| `/sdx-prd` | 基于 ANALYSIS 当前 MVP 通过参数向导与分段直写产出 PRD 阶段文档（Requirements 阶段）；每段自动 grilling 收敛后由用户用 `C/M/G/F` 推进。 |
| `/sdx-architect` | 基于 PRD 通过参数向导与分段直写产出架构设计说明书 **ASD**（§1–§3，System/Company 联邦概要主场）；每段自动 grilling 收敛后由用户用 `C/M/G/F` 推进，可选 **`spec-asd-*.md`**。 |
| `/sdx-design` | 基于 PRD 与 ASD/spec-asd 通过参数向导与分段直写产出详细设计说明书 **DSD**（§1–§3，实现在 §2）；每段自动 grilling 收敛后由用户用 `C/M/G/F` 推进，上游可含 **`{DOC_DIR}/specs/spec-asd-*.md`**（[asd-spec-template](sdx-architect/assets/asd-spec-template.md)）。 |
| `/sdx-test` | 基于 PRD 与 DSD/ASD 通过参数向导与分段直写产出测试设计文档 **TDD**；每段自动 grilling 收敛后由用户用 `C/M/G/F` 推进，聚焦用例、回归、进出标准、数据与环境。 |
| `/skill-creator` | 创建、评测与迭代技能的官方工作流（含 `scripts/`、`eval-viewer/`）。来源：Anthropic 仓库 [anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official) 中 `plugins/skill-creator/skills/skill-creator`；本仓库副本在 `agent/skills/skill-creator/`。 |

## 使用说明

- 这些命令由 Agent 依据对应 `SKILL.md` 执行并落盘产物。
- **`git commit` / `git push`**：须遵守仓库 **[git-guidelines.md](../rules/coding/git-guidelines.md)**「提交前用户确认」— **禁止**在未经用户明确同意时提交；步骤中若写「Commit」，意为**经用户确认后再提交**。
- `scripts/` 目录负责项目初始化（如 `docs-*.sh`），不等同于 Skill 命令。
- 若命令输出涉及索引或变更记录，请以仓库约定路径为准（如 `INDEX-GUIDE.md`、`index.md`、`{DOC_DIR}/changelogs/`）。
