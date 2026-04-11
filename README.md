# 软件系统知识文档库（ai-knowledge）

企业级**全局知识底座**：以 SSOT（单一事实源）与联邦治理组织架构与交付文档；本仓库为 **Markdown/YAML 知识库 + Bash 初始化脚本**，用于向任意工程注入 SDD 文档与 Agent 配置。

## 简介

`ai-knowledge` 是**纯文档型**中央库：提供 `**application/`** 应用知识库 SSOT、`**system/**` / `**company/**` 组织与公司级槽位骨架、`**applications/**` 联邦迁移说明入口、`**.agent/**` 规范与 Slash 技能，以及 `**scripts/**` 下的 `docs-init` / `docs-bootstrap` 初始化链。业务细节、路径级精要与检索字段以 **[INDEX_GUIDE.md](INDEX_GUIDE.md)** 为权威地图（与 [application/INDEX_GUIDE.md](application/INDEX_GUIDE.md) 互为补充说明时以前者落地路径为准）。**破坏性变更**：**v2.2** 起原顶层 `system/` 知识树已迁至 `**application/`**；**v2.3** 起 `docs-init` 支持 `--type=application|system|company`，且 **`--mode=central` 且未传 `--type` 时默认同步仓库 `system/`（组织级）**，若需旧式「central 全量 application + 登记」请使用 **`--mode=central --type=application`**。详见 [scripts/README.md](scripts/README.md) 与 [docs/superpowers/specs/2026-04-07-knowledge-layout-v2-design.md](docs/superpowers/specs/2026-04-07-knowledge-layout-v2-design.md)。

人类上手、可复制命令与协作入口以本文件为准；Agent 行为约束见 **[AGENTS.md](AGENTS.md)**。

## 快速开始

### 环境要求

- **Bash** 5+
- **Git**；**curl**（远程 bootstrap）
- **rsync**（可选；脚本可回退为 `cp`）

### 安装与启动

**方式一：Agent 初始化（推荐）**

将下列意图交给 Agent，按其中「方法二或三」把知识库初始化到目标目录（例如 `./docs`）：

```text
按 https://github.com/oleewen/ai-knowledge README.md 的快速启动中方法二或三，初始化知识库到 ./docs
```

**方式二：远程初始化**

```bash
curl -sL "https://raw.githubusercontent.com/oleewen/ai-knowledge/main/scripts/docs-bootstrap.sh" | bash -s -- [选项]
```

**方式三：本地初始化（已克隆本仓库）**

```bash
cd /path/to/your-workspaces
git clone https://github.com/oleewen/ai-knowledge
./ai-knowledge/scripts/docs-init.sh [--选项] ./your-project/docs
```

初始化参数、模式与落地产物说明见 **[scripts/README.md](scripts/README.md)**。在**目标工程**侧，`docs-init` 会在该工程 Git 仓库根写入 **`.docsconfig`**（必选 **`DOC_ROOT`/`REPO_ROOT`/`DOC_DIR`**；相关 scope 下可含 **`AGENT_ROOT`/`AGENT_DIRS`**；路径在 `$HOME` 下时常为 **`~/...`**）。**`--scope=config` 或 `knowledge`（`k`）时必须提供 `<目标工程文档目录>`**（此三 scope 下：`.docsconfig` 已有 **`AGENT_ROOT`** 则保留，否则默认为 **`~`**）；**`--scope=agent`（`a`）** 可省略文档目录（仅装 Agent 时配置写在 `$HOME` 侧）。供 Skill 与脚本通过 **`docsconfig-bootstrap`** 解析。

## 常见 Skill 与推荐流程

Skill 由 Agent 执行的流程化指令承载，用于文档治理、索引维护与阶段交付；完整清单以 **[.agent/skills/README.md](.agent/skills/README.md)** 为准。`skills/` 与 `scripts/` 互补，不互相替代。

**从初始化到交付的推荐顺序：**

1. 按上文完成环境初始化（`docs-bootstrap.sh` 或 `docs-init.sh`）。
2. 需要可检索入口时执行 `/docs-indexing`，生成或更新根目录 **[INDEX_GUIDE.md](INDEX_GUIDE.md)**。
3. 协作入口或约束变化时执行 `/agent-guide`，更新本文件与 **[AGENTS.md](AGENTS.md)**。
4. 按知识工程需要执行 `/docs-build`，维护 **[application/knowledge/](application/knowledge/)** 与相关索引。
5. 阶段交付可按需使用 `/sdx-solution` → `/sdx-analysis` → `/sdx-prd` → `/sdx-design` → `/sdx-test`。
6. 同步变更可执行 `/docs-change`，将信息沉淀到 **[application/changelogs/](application/changelogs/)**，供后续索引增量更新。


| 场景          | 推荐 Skill                                                             | 说明                                      |
| ----------- | -------------------------------------------------------------------- | --------------------------------------- |
| 生成全库索引与检索入口 | `/docs-indexing`                                                     | 产出或更新 `INDEX_GUIDE.md`，用于路径检索与知识定位      |
| 构建或补全文档资产   | `/docs-build`                                                        | 按知识工程流程补全结构、关系与资产                       |
| 同步仓库协作入口    | `/agent-guide`                                                       | 更新 `AGENTS.md` 与本 `README.md` 的导航与约束说明  |
| 阶段化交付（SDD）  | `/sdx-solution` `/sdx-analysis` `/sdx-prd` `/sdx-design` `/sdx-test` | 方案、分析、需求、设计、测试阶段产物                      |
| 维护文档变更追踪    | `/docs-change`                                                       | 聚合变更到 `application/changelogs/`，便于审计与回溯 |


## 技术架构

- **主要格式**：Markdown、YAML（知识实体与各视角元数据）
- **脚本**：Bash 5+（`sdx-init`、`sdx-init-bootstrap` 等初始化链）
- **协作**：Git（Conventional Commits，见 [AGENTS.md](AGENTS.md) 与 [.agent/rules/CONVENTIONS.md](.agent/rules/CONVENTIONS.md)）
- **本仓库自身**：不包含服务端或业务应用运行时；构建/启动命令以向**目标工程**注入文档为准，见 [INDEX_GUIDE.md](INDEX_GUIDE.md) 第 1 节与 [scripts/README.md](scripts/README.md)。

## 项目结构

与 **[INDEX_GUIDE.md](INDEX_GUIDE.md)** 第 2 节目录树一致，以下为精简视图：

```text
ai-knowledge/
├── README.md
├── INDEX_GUIDE.md
├── AGENTS.md
├── application/                 # 应用知识库 SSOT（宪法层、四视角、阶段文档、changelogs）
├── system/                      # 组织级系统知识库壳（architecture、application-{name}/）
├── company/                     # 公司知识库壳（architecture、system-{name}/）
├── applications/                # 联邦模板已迁出；仅存迁移说明与索引入口
├── scripts/                     # docs-init / docs-bootstrap 初始化工具链（Bash 5+）
└── .agent/                      # 规范（rules）与 Slash 技能（skills）
```

## 文档导航


| 文档                                                                       | 用途                  |
| ------------------------------------------------------------------------ | ------------------- |
| [INDEX_GUIDE.md](INDEX_GUIDE.md)                                         | 全库路径地图与检索精要（权威索引）   |
| [AGENTS.md](AGENTS.md)                                                   | AI Agent 契约、约束与关键路径 |
| [application/README.md](application/README.md)                           | 应用知识库主线与查阅顺序        |
| [application/INDEX_GUIDE.md](application/INDEX_GUIDE.md)                   | 九章索引（docs-indexing）、central 登记见「十」 |
| [system/README.md](system/README.md)                                     | 组织级系统知识库与联邦槽位说明     |
| [company/README.md](company/README.md)                                   | 公司知识库与槽位说明          |
| [applications/README.md](applications/README.md)                         | 联邦路径迁移说明            |
| [applications/APPLICATIONS_INDEX.md](applications/APPLICATIONS_INDEX.md) | 应用联邦入口（迁移后）         |
| [.agent/README.md](.agent/README.md)                                     | AI 协作规则与目录说明        |
| [.agent/skills/README.md](.agent/skills/README.md)                       | Slash 技能命令一览        |
| [scripts/README.md](scripts/README.md)                                   | 初始化脚本参数、模式与落地产物；目标工程 **`.docsconfig`** 键（`DOC_*` / `AGENT_*`）与 `~` 约定     |
| [application/changelogs/README.md](application/changelogs/README.md)     | 变更记录与索引运维说明         |


## 开发指南

- **规范索引**：[.agent/rules/CONVENTIONS.md](.agent/rules/CONVENTIONS.md)
- **系统设计、元模型与贡献流程**：[application/DESIGN.md](application/DESIGN.md)、[application/CONTRIBUTING.md](application/CONTRIBUTING.md)
- **提交信息**：Conventional Commits，`<类型>: <描述>`（示例：`docs: 更新 application/INDEX_GUIDE 登记`）

## 贡献指南

新增或修改知识实体、阶段文档与索引前，请先阅读 [application/CONTRIBUTING.md](application/CONTRIBUTING.md) 与相关子目录 README；避免破坏跨文档 ID 引用与导航表一致性。