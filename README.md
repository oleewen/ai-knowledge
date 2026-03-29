# 软件系统知识文档库 (ai-sdd-knowledge)

本仓库是企业级软件系统的**全局知识底座**，采用「单一事实源」与「联邦治理」理念管理架构与知识体系。

**AI / RAG 导航：** 路径级精要与未读声明见根目录 [INDEX_GUIDE.md](INDEX_GUIDE.md)（Index Guide）；本文件面向人类快速上手与可复制命令。

## 快速启动

在任意目录下执行以下命令，可从本仓库初始化 SDD 开发环境（文档模板、知识库结构、`.ai` 配置与 Agent 的 skills/命令）：

方式一：从 Git 拉取并初始化当前目录（可选通过环境变量覆盖仓库地址/分支）

```bash
curl -sL "https://raw.githubusercontent.com/oleewen/ai-sdd-knowledge/main/scripts/knowledge-init-bootstrap.sh" | bash -s -- [选项]
```

方式二：已克隆本仓库时，在目标目录执行

```bash
cd /path/to/your-project
REPO_ROOT=/path/to/ai-sdd-knowledge /path/to/ai-sdd-knowledge/scripts/knowledge-init.sh [选项]
```

## 命令简介

下表为 **Cursor Slash 命令**，对应 **Skill**（`.ai/skills/<name>/SKILL.md`），由 Agent 按文档执行；**不是** `scripts/` 下的 Bash 可执行文件。

| 命令                   | 说明                                                                                                                 |
| -------------------- | ------------------------------------------------------------------------------------------------------------------ |
| `/document-change`   | **Skill**：合并 git / CHANGELOG / 文件 mtime，生成 `system/changelogs/changes-index.*`（供增量索引与审计）。                          |
| `/document-indexing` | **Skill**：为代码库/文档库生成面向下游 AI 的 Index Guide（拓扑/结构/精读三模式，七段标准输出，零幻觉路径精确）。                                                  |
| `/agent-guide`       | 生成/更新根目录 `AGENTS.md` 与 `README.md`；① document-indexing 产出 Index → ② agent-guide 产出 AGENTS/README                   |
| `/knowledge-build`   | 知识库构建：① document-indexing 产出 Index → ② agent-guide 产出 AGENTS/README → ③ 按 Index 选择性阅读并写入 knowledge → ④ 验证。         |
| `/knowledge-upgrade` | 应用级知识库增量升级：① 应用内 document-indexing → ③ 按 applications/APPLICATIONS_INDEX 与应用 knowledge 格式选择性阅读并回写 → ④ 验证（无 AGENTS/README 第二阶段）。 |
| `/knowledge-archive` | 归档 applications/ 知识库变更；将应用侧有效信息按 system/knowledge 与 CONTRIBUTING 规范上行补充系统库（联邦 SSOT、仅 ID 引用）。                       |

## 功能简介

**系统知识库** 已统一放在 **[system/](system)** 目录下（查阅顺序与根目录 `INDEX_GUIDE.md` / `AGENTS.md` 对齐；SDD 主线见 [system/README.md](system/README.md)）：

- [system/README.md](system/README.md) — 查阅顺序、SDD 主线、快速导航  
- [system/SYSTEM_INDEX.md](system/SYSTEM_INDEX.md) — system 树索引、映射速查、应用接入、AI 工作流指针  
- [system/DESIGN.md](system/DESIGN.md) — 原则、元模型、目录与映射、演进  
- [system/CONTRIBUTING.md](system/CONTRIBUTING.md) — 贡献工作流与各阶段模板入口  
- [system/changelogs/README.md](system/changelogs/README.md) — 变更日志入口（规约随各 `requirements/REQUIREMENT-*/…/specs/`）

**应用知识库** 已统一放在 **[applications/](applications)** 目录下，包含：

- [applications/README.md](applications/README.md) — 应用知识库说明与初始化方式  
- [applications/APPLICATIONS_INDEX.md](applications/APPLICATIONS_INDEX.md) — 应用知识结构、方案与需求、治理信息导航（权威入口）

## 目录结构

```text
ai-sdd-knowledge/
├── README.md           # 本文件：总览、快速初始化、功能简介与文档索引
├── INDEX_GUIDE.md      # AI 文档库精要索引指南（Index Guide，与 document-indexing 对齐）
├── AGENTS.md           # AI Agents 开发指南（角色、关键路径、规范、命令）
├── system/             # 系统知识库
│   ├── README.md, SYSTEM_INDEX.md, DESIGN.md, CONTRIBUTING.md
│   ├── knowledge/      # 四视角 + 宪法层（constitution, business, product, technical, data）
│   ├── solutions/      # 解决方案（SOLUTION-{ID}.md）
│   ├── analysis/       # 需求分析（ANALYSIS-{ID}.md）
│   ├── requirements/   # 需求交付（REQUIREMENT-{ID}/MVP-Phase-*；规约可在包内 specs/）
│   └── changelogs/     # 变更日志（README、CHANGELOG、可选索引文件）
├── applications/       # 应用知识库（README、APPLICATIONS_INDEX 及各应用子目录）
├── scripts/            # sdx-init、knowledge-init 等，详见 scripts/README.md
├── .ai/                # AI 规范与技能（README、rules/、skills/README.md Slash 一览）
└── .trea/             # Trea Agent 配置
```

## 文档索引（Documentation）


| 用途         | 文档                                                                            |
| ---------- | ----------------------------------------------------------------------------- |
| 文档索引地图    | [INDEX_GUIDE.md](INDEX_GUIDE.md)                                              |
| 索引运行日志     | [system/changelogs/indexing-log.jsonl](system/changelogs/indexing-log.jsonl)  |
| 系统知识库入口     | [system/README.md](system/README.md)、[system/SYSTEM_INDEX.md](system/SYSTEM_INDEX.md)      |
| 知识库设计与约定    | [system/DESIGN.md](system/DESIGN.md)、[.ai/rules/CONVENTIONS.md](.ai/rules/CONVENTIONS.md) |
| 贡献与新增约定    | [system/CONTRIBUTING.md](system/CONTRIBUTING.md)                              |
| 初始化与选项     | [scripts/README.md](scripts/README.md)                                        |
| Cursor 命令表 | [.ai/skills/README.md](.ai/skills/README.md)                                        |
| AI 开发指南    | [AGENTS.md](AGENTS.md)                                                        |
| 变更索引（滚动基线） | [system/changelogs/changes-index.json](system/changelogs/changes-index.json) |


