# 📘 AI文档库精要索引指南

> 生成时间：2026-03-20 10:36:29.251  |  执行模式：Mode 3（精读模式，全量更新）  |  索引覆盖率：全量（与 `system/README.md`「快速导航」及 §3.2 对齐；运行记录见 `./system/changelogs/indexing-log.jsonl`）

## 1. 全局元信息

- **项目名称**：`ai-knowledge`
- **核心定位**：企业级软件系统全局知识底座（SSOT + 联邦治理）
- **项目形态**：纯文档库 + Bash 初始化脚本（用于向任意项目“注入”SDD 文档与 Agent 配置）
- **技术栈**：
  - **主要格式**：Markdown、YAML（知识实体与各视角元数据 YAML，如 `business_meta.yaml`、`*_meta.yaml` 等）
  - **脚本**：Bash 5+（`sdx-init`、`sdx-init-bootstrap`）
  - **协作**：Git（Conventional Commits，见 `AGENTS.md` 与 `./.ai/rules/CONVENTIONS.md`）
- **关键外部依赖（3–8）**：
  - `git`（bootstrap 克隆仓库）
  - `curl`（通过网络拉取 bootstrap 脚本）
  - `bash`（Bash 5+ 必需）
  - `rsync`（可选：用于更安全/高效同步；脚本自动 fallback 到 `cp`）
- **入口**：
  - 总入口：`./README.md`
  - 根索引（本文件）：`./INDEX_GUIDE.md`
  - 系统知识库入口：`./system/README.md`、`./system/SYSTEM_INDEX.md`
  - 应用知识库入口：`./applications/APPLICATIONS_INDEX.md`
  - 初始化入口：`./scripts/knowledge-init.sh`、`./scripts/README.md`
  - 规范入口：`./.ai/rules/CONVENTIONS.md`、`./.ai/rules/`
  - Slash 命令一览：`./.ai/skills/README.md`
- **构建/启动命令**（本仓库自身不包含服务端/应用启动）：
  - 在任意项目目录初始化（bootstrap）：
    - `curl -sL "https://raw.githubusercontent.com/oleewen/ai-knowledge/main/scripts/knowledge-init-bootstrap.sh" | bash -s -- [选项]`
  - 已克隆本仓库时对目标目录初始化：
    - `REPO_ROOT=/path/to/ai-knowledge /path/to/ai-knowledge/scripts/knowledge-init.sh [选项]`

## 2. 架构拓扑

### 2.1 目录树（带语义注释）

```text
./
├── README.md                     # 仓库总入口：定位、初始化、关键路径导航
├── INDEX_GUIDE.md                # AI 文档库精要索引指南（Index Guide，权威）
├── AGENTS.md                     # AI Agents 开发指南（角色、约束、提交规范等）
├── system/                       # 系统级知识库（宪法层 + 四视角 + 交付阶段文档）
│   ├── README.md                 # 查阅顺序、SDD 主线、快速导航（与 AGENTS 对齐）
│   ├── SYSTEM_INDEX.md           # system 树索引、SDD 文档流、映射速查、接入登记、AI 工作流
│   ├── DESIGN.md                 # 原则、元模型、system/ 内目录、映射、演进
│   ├── CONTRIBUTING.md           # 六步工作流、各阶段规则与模板指针
│   ├── knowledge/                # 宪法层 + 业务/产品/技术/数据视角
│   ├── solutions/                # 解决方案（README + SOLUTION-{ID}.md）
│   ├── analysis/                 # 需求分析（README + ANALYSIS-{ID}.md）
│   ├── requirements/             # 需求交付（README + REQUIREMENT-{ID}/…；规约可在各需求包内 specs/）
│   └── changelogs/               # README、CHANGELOG、可选 changes-index / indexing-log
├── applications/                 # 应用级知识库模板与治理入口
│   ├── README.md                 # 应用侧联邦单元说明与初始化示例
│   └── APPLICATIONS_INDEX.md     # 应用知识结构/方案/需求/治理信息导航（权威）
├── scripts/                      # sdx-init 初始化工具链（Bash 5+）
│   ├── README.md                 # 初始化使用说明与选项
│   ├── knowledge-init.sh         # 核心初始化：将中央库 `system/` 模板拷至目标文档根（默认 `docs/`）、安装 .ai/ 与 Agent skills
│   ├── knowledge-init-bootstrap.sh # bootstrap：临时 clone 并执行 knowledge-init
│   ├── knowledge-init.sh         # 将应用知识库根目录模板（applications/app-APPNAME）初始化到目标工程
│   └── knowledge-config.sh       # 默认值、校验函数、支持的 Agents/skills
├── .ai/                          # AI 规范与技能（README、rules、skills）
│   ├── README.md                 # .ai 目录说明与上游文档指针
│   ├── rules/                    # 规范与模板（CONVENTIONS、各子域 rules）
│   └── skills/                   # Slash 技能（SKILL.md）
│       └── README.md             # Slash 命令一览
└── .trea/                        # Trea Agent 配置（若存在）
```

### 2.2 模块依赖方向图（A → B）

- `scripts/` → 目标文档根：初始化时拷贝中央库 `system/` 模板至目标仓库（默认文档根目录名为 `docs/`）
- `scripts/` → `applications/`：初始化时拷贝应用知识库到目标项目（standalone 为 `system/application`；federation 为 `system/applications`）
- `scripts/` → `.ai/`：初始化时拷贝 `.ai` 配置到目标项目 `.ai/`
- `scripts/` → `.ai/`（`--agents=cursor` 时向目标 `.ai/skills`、`rules` 增量安装）/ `.trea/`：按 `--agents` 生成/拷贝 Agent 配置与 skills
- `system/DESIGN.md` → `system/knowledge/*`：定义四视角元模型、目录与元数据 YAML 映射机制
- `system/CONTRIBUTING.md` → `system/knowledge/*`：约束新增/修改的字段、文件命名与引用规则
- `system/SYSTEM_INDEX.md` → `system/knowledge/*`：提供宪法层与四视角入口与示例路径
- `system/SYSTEM_INDEX.md` → `.ai/rules/*`：连接阶段模板（solutions/analysis/requirements）与规范入口
- `system/README.md` → `./INDEX_GUIDE.md`、`./README.md`、`./AGENTS.md`：查阅顺序与 SDD 主线对齐
- `applications/APPLICATIONS_INDEX.md` → `system/SYSTEM_INDEX.md`：应用库结构与主库对齐，并引用系统级设计/规范
- `system/knowledge/*/README.md` → `system/DESIGN.md`、`system/SYSTEM_INDEX.md`：各视角 README 明确映射字段与阅读入口

## 3. 详细索引字典

### 3.0 全局标签词表（受控，≤30）

`入口`、`索引`、`导航`、`初始化`、`bootstrap`、`联邦治理`、`SSOT`、`知识库`、`宪法层`、`术语表`、`ADR`、`命名规范`、`业务视角`、`产品视角`、`技术视角`、`数据视角`、`映射字段`、`元模型`、`解决方案`、`需求分析`、`需求交付`、`需求规约`、`模板`、`规范`、`Cursor`、`Trea`、`Agent技能`、`脚本`、`ConventionalCommits`

### 3.1 根目录与总入口


| 文件路径          | 功能精要               | 检索标签                       | 上游依赖 | 下游被依赖                                      | 重要度 |
| ------------- | ------------------ | -------------------------- | ---- | ------------------------------------------ | --- |
| `./README.md` | 仓库定位与初始化入口总导航      | `入口` `导航` `初始化`            | -    | `system/*` `scripts/*` `.ai/*` | ⭐⭐⭐ |
| `./AGENTS.md` | Agent 角色、关键路径与提交规范 | `规范` `ConventionalCommits` | -    | 人工/Agent 开发流程                              | ⭐⭐  |


### 3.2 系统知识库（system）

与 `[system/README.md](system/README.md)` 中「查阅顺序」「SDD 主线」「快速导航」**一一对应**（下列表格为根目录索引视角的检索字段补充）。

#### 3.2.1 顶层与治理


| 文件路径                       | 功能精要                                          | 检索标签             | 上游依赖                                     | 下游被依赖                          | 重要度 |
| -------------------------- | --------------------------------------------- | ---------------- | ---------------------------------------- | ------------------------------ | --- |
| `./system/README.md`       | 查阅顺序（与 AGENTS 对齐）、SDD 主线、快速导航表              | `入口` `导航` `SSOT` | `./INDEX_GUIDE.md`、`./README.md`、`./AGENTS.md` | `system/SYSTEM_INDEX.md` 及各子目录 README | ⭐⭐⭐ |
| `./system/SYSTEM_INDEX.md`        | SDD 文档流、knowledge～requirements 索引、映射速查、应用接入、AI 工作流指针 | `索引` `映射字段`      | `./INDEX_GUIDE.md`、`system/README.md`          | solutions～changelogs           | ⭐⭐⭐ |
| `./system/DESIGN.md`       | 原则、元模型、`system/` 内目录、映射字段、演进                  | `元模型` `映射字段`     | `system/README.md`                       | knowledge 与各阶段                 | ⭐⭐⭐ |
| `./system/CONTRIBUTING.md` | 六步工作流、各阶段新增规则与模板指针                            | `规范` `模板`        | `system/DESIGN.md`、`AGENTS.md`           | 贡献与评审                          | ⭐⭐⭐ |


#### 3.2.2 阶段与子目录入口（与 system/README「快速导航」一致）


| 文件路径                               | 功能精要                                                              | 检索标签       | 上游依赖                                             | 下游被依赖                    | 重要度 |
| ---------------------------------- | ----------------------------------------------------------------- | ---------- | ------------------------------------------------ | ------------------------ | --- |
| `./system/knowledge/README.md`     | knowledge 主体、三步维护、system/SYSTEM_INDEX 与根 INDEX_GUIDE 指针                        | `知识库` `入口` | `system/DESIGN.md`、`system/SYSTEM_INDEX.md`             | constitution 与四视角 README | ⭐⭐⭐ |
| `./system/solutions/README.md`     | 解决方案阶段三步流程与方案索引登记                                                 | `解决方案`     | `system/DESIGN.md`、`.ai/skills/sdx-solution`     | `analysis/`              | ⭐⭐⭐ |
| `./system/analysis/README.md`      | 需求分析阶段三步流程与分析索引登记                                                 | `需求分析`     | `solutions/`、`knowledge/`                          | `requirements/`          | ⭐⭐⭐ |
| `./system/requirements/README.md`  | 需求交付四步主线与目录结构（含各需求包内规约 specs/）                                       | `需求交付`     | `analysis/`、`solutions/`、`.ai/skills/sdx-prd` / `sdx-design` / `sdx-test` | 阶段交付物                    | ⭐⭐⭐ |
| `./system/changelogs/README.md`    | changelogs 说明；docs-change / docs-indexing **Skill** 产出物说明 | `变更` `运维`  | `README.md`、`AGENTS.md`                          | 索引链路                     | ⭐⭐  |
| `./system/changelogs/CHANGELOG.md` | system 文档体系维护性变更记录                                                | `变更`       | -                                                | 审计与追溯                    | ⭐⭐  |


### 3.3 应用知识库（applications）


| 文件路径                                               | 功能精要                                            | 检索标签         | 上游依赖                  | 下游被依赖                         | 重要度 |
| -------------------------------------------------- | ----------------------------------------------- | ------------ | --------------------- | ----------------------------- | --- |
| `./applications/APPLICATIONS_INDEX.md`             | 应用侧知识结构与治理信息入口                                  | `索引` `联邦治理`  | `system/SYSTEM_INDEX.md`     | 应用目录下 knowledge/solutions/... | ⭐⭐⭐ |
| `./applications/README.md`                         | 应用侧联邦单元说明与初始化示例                                 | `联邦治理` `初始化` | `scripts/knowledge-init.sh` | 应用库落地参考                       | ⭐⭐  |
| `./applications/app-APPNAME/application_meta.yaml` | 应用知识库根目录模板级机器可读索引（对照 `system/system_meta.yaml`） | `联邦治理` `元数据` | `system/DESIGN.md`    | `knowledge-init` 落地副本         | ⭐⭐  |


### 3.4 初始化脚本（scripts）


| 文件路径                              | 功能精要                                       | 检索标签                         | 上游依赖            | 下游被依赖                           | 重要度 |
| --------------------------------- | ------------------------------------------ | ---------------------------- | --------------- | ------------------------------- | --- |
| `./scripts/README.md`             | knowledge-init 用法、模式与选项清单                 | `初始化` `脚本`                   | -               | `knowledge-init.sh`            | ⭐⭐⭐ |
| `./scripts/knowledge-init.sh`     | 将中央库 `system/`、`.ai/`、Agent skills 安装至目标工程 | `初始化` `联邦治理` `Cursor` `Trea` | `knowledge-config.sh` | 目标项目的文档根（默认 `docs/`）、`.ai/` | ⭐⭐⭐ |
| `./scripts/knowledge-config.sh`   | 默认值、校验函数、支持的 Agents/skills                 | `脚本` `初始化`                   | -               | `knowledge-init.sh`            | ⭐⭐  |
| `./scripts/knowledge-init.sh`     | 初始化应用知识库根目录（applications/app-APPNAME）到目标工程 | `初始化` `联邦治理` `Agent技能`       | `knowledge-config.sh` | 目标工程的应用知识库模板                    | ⭐⭐  |


### 3.5 规范与模板（.ai）


| 文件路径                         | 功能精要                                           | 检索标签               | 上游依赖                                      | 下游被依赖             | 重要度 |
| ---------------------------- | ---------------------------------------------- | ------------------ | ----------------------------------------- | ----------------- | --- |
| `./.ai/rules/CONVENTIONS.md` | 规范索引与关键摘要（编码/设计/测试/交付）                         | `规范` `模板`          | `.ai/rules/*`                             | 人工/Agent 编写文档与交付物 | ⭐⭐⭐ |
| `./.ai/skills/README.md`     | Slash 命令与 `skills/` 入口；Skill 非 scripts 脚本 | `Cursor` `Agent技能` | `.ai/skills/*` | 用户交互入口            | ⭐⭐  |


### 3.6 knowledge 宪法层（system/knowledge；总入口见 §3.2.2）


| 文件路径                                                              | 功能精要                 | 检索标签         | 上游依赖               | 下游被依赖                | 重要度 |
| ----------------------------------------------------------------- | -------------------- | ------------ | ------------------ | -------------------- | --- |
| `./system/knowledge/constitution/README.md`                       | 宪法层组件入口：术语/原则/标准/ADR | `宪法层` `入口`   | -                  | standards/adr 相关     | ⭐⭐⭐ |
| `./system/knowledge/constitution/GLOSSARY.md`                     | 术语表：术语ID、映射字段速查      | `术语表` `映射字段` | -                  | 全库统一语言               | ⭐⭐⭐ |
| `./system/knowledge/constitution/standards/NAMING-CONVENTIONS.md` | ID 命名规范：TYPE 前缀与引用规则 | `命名规范`       | `system/DESIGN.md` | 全库实体命名               | ⭐⭐⭐ |
| `./system/knowledge/constitution/adr/adr-template.md`             | ADR 模板：状态/上下文/决策/后果  | `ADR` `模板`   | -                  | `constitution/adr/*` | ⭐⭐  |


### 3.7 四视角 README（system/knowledge/*）


| 文件路径                                     | 功能精要                  | 检索标签          | 上游依赖               | 下游被依赖  | 重要度 |
| ---------------------------------------- | --------------------- | ------------- | ------------------ | ------ | --- |
| `./system/knowledge/business/README.md`  | BD→BSD→BC→AGG 分层与映射字段 | `业务视角` `映射字段` | `system/DESIGN.md` | 业务实体目录 | ⭐⭐⭐ |
| `./system/knowledge/product/README.md`   | PL→PM→FT→UC 分层与映射字段   | `产品视角` `映射字段` | `system/DESIGN.md` | 产品实体目录 | ⭐⭐⭐ |
| `./system/knowledge/technical/README.md` | SYS→APP→MS 分层与应用注册约定  | `技术视角` `映射字段` | `system/DESIGN.md` | 技术实体目录 | ⭐⭐⭐ |
| `./system/knowledge/data/README.md`      | DS→ENT 分层与敏感级别/映射字段   | `数据视角` `映射字段` | `system/DESIGN.md` | 数据实体目录 | ⭐⭐⭐ |


## 4. 核心数据流（Mode 3）

> 说明：本仓库主要“数据流”是初始化与知识引用流，而非运行时请求流。

- **数据流 1：向目标项目注入 SDD 文档体系**
  - `./scripts/knowledge-init.sh` → 将中央库 `system/` 模板、`applications/`、`.ai/`、Agent 配置复制到目标目录（默认为 `docs/`；standalone 另含 `system/application/`，federation 为 `system/applications/` 等；并安装 `.ai`、`.trea`）。
- **数据流 2：系统知识库的跨视角引用（SSOT）**
  - `./system/DESIGN.md` 定义四视角元模型与映射机制 → 具体实体在各视角元数据 YAML 与实体定义 `*.yaml` 中写目标实体 ID。
  - 常用映射字段（见 `system/DESIGN.md` 与 `system/knowledge/constitution/GLOSSARY.md`）：
    - `implemented_by_app_id`（BC → APP）
    - `relies_on_context_ids`（PM → BC）
    - `invokes_api_ids`（FT → API）
    - `persisted_as_entity_ids`（AGG → ENT）
    - `maps_to_aggregate_id`（ENT → AGG）
    - `owned_by_service_id` / `app_id`（数据归属 → MS/APP）

## 5. 配置与环境变量索引（Mode 3）


| 配置项/环境变量                  | 所在文件                              | 语义                              | 默认值                                               | 敏感性       |
| ------------------------- | --------------------------------- | ------------------------------- | ------------------------------------------------- | --------- |
| `GIT_REPO_URL`            | `./scripts/knowledge-init-bootstrap.sh` | bootstrap 拉取仓库地址                | `https://github.com/oleewen/ai-knowledge.git` | 低         |
| `GIT_REF`                 | `./scripts/knowledge-init-bootstrap.sh` | 指定克隆分支/标签                       | `HEAD`                                            | 低         |
| `REPO_ROOT`               | `./scripts/knowledge-init.sh`     | 指定本仓库根目录                        | 自动推导 `SCRIPT_DIR/..`                              | 低         |
| `TARGET_DIR`              | `./scripts/knowledge-init.sh`     | 初始化目标目录                         | 当前目录 `pwd`                                        | 低         |
| `DOCS_DIR` / `--dd`       | `./scripts/knowledge-config.sh`   | 目标文档根目录                         | `docs`                                          | 低         |
| `SDX_MODE` / `--mode`     | `./scripts/knowledge-init.sh`     | 初始化模式：`standalone`/`federation` | `standalone`                                      | 低         |
| `DOCS_SCOPE` / `--ds`     | `./scripts/knowledge-init.sh`     | 模板拷贝范围：`knowledge`/`full`      | `knowledge`                                       | 低         |
| `AI_RULES_SCOPE` / `--as` | `./scripts/knowledge-init.sh`     | `.ai/rules` 范围控制                | `no-solution-analysis`                            | 低         |
| `AGENTS_OPT` / `--agents` | `./scripts/knowledge-config.sh`   | 要初始化的 Agent 列表                  | `cursor`                                          | 低         |
| `SKILLS_OPT` / `--skills` | `./scripts/knowledge-init.sh`     | 要安装的 skills 列表                  | 默认仅 agent/knowledge 相关                            | 低         |
| `--force`                 | `./scripts/knowledge-init.sh`     | 覆盖已存在目录                         | 关闭                                                | 中（可能覆盖文件） |
| `--dry-run`               | `./scripts/knowledge-init.sh`     | 仅打印不执行                          | 关闭                                                | 低         |
| `--mode`                  | `./scripts/knowledge-init.sh`     | 应用知识库初始化模式：仅拷贝/中央登记             | `standalone`                                      | 低         |
| `--app-id`                | `./scripts/knowledge-init.sh`     | 中央模式写入技术视角 APP ID               | 自动推导                                              | 低         |
| `--agents`                | `./scripts/knowledge-init.sh`     | 安装 Agent（cursor/trea/all）       | `cursor`                                          | 低         |
| `--dry-run`               | `./scripts/knowledge-init.sh`     | 仅预览，不落盘                         | 关闭                                                | 低         |


> 说明：默认值集中在 `./scripts/knowledge-config.sh` 的 `SDX_DEFAULTS`；`knowledge-init.sh` 允许用环境变量/参数覆盖。

## 6. 未索引区域声明

> 零幻觉原则：以下路径仅“发现存在”，但未精读其内容；因此不对其内部结构/语义做断言。

- **根目录其它文档约定**
  - `./doc/**`（少数项目用作文档根；本仓库未使用）
- **系统级阶段目录（除各目录 README 入口外）**
  - `./system/solutions/`**、`./system/analysis/**`、`./system/requirements/**` 内具体方案 / 分析 / 交付正文未逐一精读
  - `./system/changelogs/changes-index.*`、`./system/changelogs/indexing-log.jsonl` 等工具产出未精读（`README.md`、`CHANGELOG.md` 为入口说明，见 §3.2.2）
- **knowledge 未精读**
  - `./system/knowledge/constitution/adr/`**、`./system/knowledge/constitution/principles/**`（仅精读了宪法层 README、术语表、标准与 ADR 模板）
  - `./system/knowledge/**/*_meta.yaml`、各阶段 `./system/{solutions,analysis,requirements,changelogs}/*_meta.yaml`、`./system/knowledge/**/*.yaml`（仅精读了四视角 README 与 DESIGN/CONTRIBUTING 约定；实体样例未逐一通读）
- **应用级未精读**
  - `./applications/`** 的应用子目录（若存在）
- **AI 规则与技能未精读**
  - `./.ai/rules/`**（仅精读了 `./.ai/rules/CONVENTIONS.md`；其余规则模板未逐一精读）
  - `./.ai/skills/**`（已精读 `docs-indexing`/`docs-change`；并抽读 `agent-guide`、`knowledge-upgrade` 的入口与阶段划分；其余技能未逐一精读）

## 7. AI 查阅指北（检索表 + Prompt 模板）

| 要了解什么                       | 优先标签               | 优先路径                                           |
| --------------------------- | ------------------ | ---------------------------------------------- |
| 仓库能解决什么问题/如何开始              | `入口` `导航`          | `./README.md`                                  |
| system 知识库目录、SDD 主线与四视角如何组织 | `知识库` `宪法层`        | `./system/README.md`                           |
| system 树内索引、映射字段与阶段入口       | `索引` `映射字段`        | `./system/SYSTEM_INDEX.md`                            |
| system 变更日志与索引运维入口          | `变更` `运维`          | `./system/changelogs/README.md`                |
| 应用侧知识库应如何对齐主库               | `联邦治理` `索引`        | `./applications/APPLICATIONS_INDEX.md`         |
| 如何在新项目中初始化 SDD 环境           | `初始化` `bootstrap`  | `./scripts/README.md`、`./scripts/sdx-init*.sh` |
| 规范/模板入口在哪里                  | `规范` `模板`          | `./.ai/rules/CONVENTIONS.md`、`./.ai/rules/`    |
| 可用 Slash 命令有哪些       | `Agent技能` | `./.ai/skills/README.md`                          |


### 快速检索 Prompt 模板（面向仓库内搜索/阅读）

- **模板 1：定位“初始化输出目录与模式差异”**
  - “在 `./scripts/knowledge-init.sh` 中，`standalone` 与 `federation` 模式分别会创建哪些目标目录？涉及哪些参数（`--dd`、`--ds`、`--as`）？”
- **模板 2：定位“system 知识映射字段与关系”**
  - “在 `./system/SYSTEM_INDEX.md` 中，列出所有关键映射字段及其关系方向，并指出对应的视角层级（BC/AGG/PM/FT/ENT 等）。”
- **模板 3：扩展索引覆盖率（进入 Mode 3）**
  - “精读 `./system/knowledge/constitution/principles/` 与 `./system/knowledge/constitution/adr/`，补充原则与 ADR 决策，并将新增信息回填到 `./INDEX_GUIDE.md` 的 §3/§6/§7。”

## 索引日志索引

- **索引日志目录**：`./system/changelogs/`
- **索引日志文件**：`./system/changelogs/indexing-log.jsonl`

