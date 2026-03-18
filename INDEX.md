# 📘 AI文档库精要索引指南
> 生成时间：2026-03-18  |  执行模式：Mode 3（精读模式，覆盖关键治理与视角说明）  |  索引覆盖率：已精读 22 个核心文件（其余路径按“未索引区域”声明）

## 1. 全局元信息

- **项目名称**：`ai-sdd-knowledge`
- **核心定位**：企业级软件系统全局知识底座（SSOT + 联邦治理）
- **项目形态**：纯文档库 + Bash 初始化脚本（用于向任意项目“注入”SDD 文档与 Agent 配置）
- **技术栈**：
  - **主要格式**：Markdown、YAML（知识实体与 `_meta.yaml` 等）
  - **脚本**：Bash 5+（`sdx-init`、`sdx-init-bootstrap`）
  - **协作**：Git（Conventional Commits，见 `AGENTS.md` 与 `.ai/CONVENTIONS.md`）
- **关键外部依赖（3–8）**：
  - `git`（bootstrap 克隆仓库）
  - `curl`（通过网络拉取 bootstrap 脚本）
  - `bash`（Bash 5+ 必需）
  - `rsync`（可选：用于更安全/高效同步；脚本自动 fallback 到 `cp`）
- **入口**：
  - 总入口：`./README.md`
  - 根索引（本文件）：`./INDEX.md`
  - 系统知识库入口：`./system/README.md`、`./system/INDEX.md`
  - 应用知识库入口：`./applications/INDEX.md`
  - 初始化入口：`./scripts/sdx-init.sh`、`./scripts/sdx-init-bootstrap.sh`、`./scripts/README.md`
  - 规范入口：`./.ai/CONVENTIONS.md`、`./.ai/rules/`
  - Cursor 命令入口：`./.cursor/README.md`
- **构建/启动命令**（本仓库自身不包含服务端/应用启动）：
  - 在任意项目目录初始化（bootstrap）：
    - `curl -sL "https://raw.githubusercontent.com/oleewen/ai-sdd-knowledge/main/scripts/sdx-init-bootstrap.sh" | bash -s -- [选项]`
  - 已克隆本仓库时对目标目录初始化：
    - `REPO_ROOT=/path/to/ai-sdd-knowledge /path/to/ai-sdd-knowledge/scripts/sdx-init.sh [选项]`

## 2. 架构拓扑

### 2.1 目录树（带语义注释）

```text
./
├── README.md                     # 仓库总入口：定位、初始化、关键路径导航
├── AGENTS.md                     # AI Agents 开发指南（角色、约束、提交规范等）
├── system/                       # 系统级知识库（宪法层 + 四视角 + 交付阶段文档）
│   ├── README.md                 # system 入口与导航
│   ├── INDEX.md                  # system 全局索引：knowledge/solutions/analysis/requirements/specs
│   ├── DESIGN.md                 # 设计哲学、元模型规范、映射机制、演进路线
│   ├── CONTRIBUTING.md           # 新增/修改规则：ID 引用、模板与提交流程
│   ├── knowledge/                # 宪法层 + 业务/产品/技术/数据视角
│   ├── solutions/                # 解决方案（SOLUTION-{ID}.md）
│   ├── analysis/                 # 需求分析（REQUIREMENT-{ID}.md）
│   ├── requirements/             # 需求交付（REQUIREMENT-{ID}/MVP-Phase-*/）
│   ├── specs/                    # 需求规约（接口/服务/实体等）
│   └── changelogs/               # 变更日志（未索引）
├── applications/                 # 应用级知识库模板与治理入口
│   ├── README.md                 # 应用侧联邦单元说明与初始化示例
│   └── INDEX.md                  # 应用知识结构/方案/需求/治理信息导航
├── scripts/                      # sdx-init 初始化工具链（Bash 5+）
│   ├── README.md                 # 初始化使用说明与选项
│   ├── sdx-init.sh               # 核心初始化逻辑：复制 docs/.ai/Agent skills
│   ├── sdx-init-bootstrap.sh     # bootstrap：临时 clone 并执行 sdx-init
│   └── sdx-config.sh             # 默认值、校验函数、支持的 Agents/skills
├── .ai/                          # AI 规范与技能（CONVENTIONS、rules、skills）
│   ├── CONVENTIONS.md            # 规范索引与关键摘要（编码/设计/测试/文档/交付）
│   └── rules/                    # 规范与模板（solution/analysis/requirement 等）
└── .cursor/                      # Cursor 配置与技能入口（Slash 命令表、skills）
    └── README.md                 # Slash 命令与 skills 列表
```

### 2.2 模块依赖方向图（A → B）

- `scripts/` → `system/`：初始化时拷贝 `system/` 到目标项目文档根（默认 `docs/system`）
- `scripts/` → `applications/`：初始化时拷贝应用知识库到目标项目（standalone 为 `docs/application`；federation 为 `docs/applications`）
- `scripts/` → `.ai/`：初始化时拷贝 `.ai` 配置到目标项目 `.ai/`
- `scripts/` → `.cursor/` / `.trea/`：按 `--agents` 生成/拷贝 Agent 配置与 skills
- `system/DESIGN.md` → `system/knowledge/*`：定义四视角元模型、目录与 `_meta.yaml` 映射机制
- `system/CONTRIBUTING.md` → `system/knowledge/*`：约束新增/修改的字段、文件命名与引用规则
- `system/INDEX.md` → `system/knowledge/*`：提供宪法层与四视角入口与示例路径
- `system/INDEX.md` → `.ai/rules/*`：连接阶段模板（solutions/analysis/requirements）与规范入口
- `applications/INDEX.md` → `system/INDEX.md`：应用库结构与主库对齐，并引用系统级设计/规范
- `system/knowledge/*/README.md` → `system/DESIGN.md` / `./INDEX.md`：各视角 README 明确映射字段与阅读入口

## 3. 详细索引字典

### 3.0 全局标签词表（受控，≤30）

`入口`、`索引`、`导航`、`初始化`、`bootstrap`、`联邦治理`、`SSOT`、`知识库`、`宪法层`、`术语表`、`ADR`、`命名规范`、`业务视角`、`产品视角`、`技术视角`、`数据视角`、`映射字段`、`元模型`、`解决方案`、`需求分析`、`需求交付`、`需求规约`、`模板`、`规范`、`Cursor`、`Trea`、`Agent技能`、`脚本`、`ConventionalCommits`

### 3.1 根目录与总入口

| 文件路径 | 功能精要 | 检索标签 | 上游依赖 | 下游被依赖 | 重要度 |
|---|---|---|---|---|---|
| `./README.md` | 仓库定位与初始化入口总导航 | `入口` `导航` `初始化` | - | `system/*` `scripts/*` `.ai/*` `.cursor/*` | ⭐⭐⭐ |
| `./AGENTS.md` | Agent 角色、关键路径与提交规范 | `规范` `ConventionalCommits` | - | 人工/Agent 开发流程 | ⭐⭐ |

### 3.2 系统知识库（system）

| 文件路径 | 功能精要 | 检索标签 | 上游依赖 | 下游被依赖 | 重要度 |
|---|---|---|---|---|---|
| `./system/README.md` | system 入口：结构说明与设计原则 | `入口` `知识库` `SSOT` | - | `system/INDEX.md` | ⭐⭐⭐ |
| `./system/INDEX.md` | knowledge/solutions/analysis/requirements/specs 总索引 | `索引` `映射字段` | `system/README.md` | 各阶段/视角文档导航 | ⭐⭐⭐ |
| `./system/DESIGN.md` | 设计哲学、元模型规范、映射机制、演进路线 | `元模型` `映射字段` | `system/README.md` | 全库目录与治理依据 | ⭐⭐⭐ |
| `./system/CONTRIBUTING.md` | 新增/修改规则：字段、引用与模板入口 | `规范` `映射字段` | `system/DESIGN.md` | 知识条目新增/评审流程 | ⭐⭐⭐ |

### 3.3 应用知识库（applications）

| 文件路径 | 功能精要 | 检索标签 | 上游依赖 | 下游被依赖 | 重要度 |
|---|---|---|---|---|---|
| `./applications/INDEX.md` | 应用侧知识结构与治理信息入口 | `索引` `联邦治理` | `system/INDEX.md` | 应用目录下 knowledge/solutions/... | ⭐⭐⭐ |
| `./applications/README.md` | 应用侧联邦单元说明与初始化示例 | `联邦治理` `初始化` | `scripts/sdx-init.sh` | 应用库落地参考 | ⭐⭐ |

### 3.4 初始化脚本（scripts）

| 文件路径 | 功能精要 | 检索标签 | 上游依赖 | 下游被依赖 | 重要度 |
|---|---|---|---|---|---|
| `./scripts/README.md` | sdx-init 用法、模式与选项清单 | `初始化` `脚本` | - | `sdx-init.sh` | ⭐⭐⭐ |
| `./scripts/sdx-init.sh` | 拷贝 docs/.ai/Agent 技能的核心逻辑 | `初始化` `联邦治理` `Cursor` `Trea` | `sdx-config.sh` | 目标项目的 `docs/`、`.ai/`、`.cursor/` | ⭐⭐⭐ |
| `./scripts/sdx-init-bootstrap.sh` | 临时 clone 仓库并执行初始化 | `bootstrap` `初始化` | `git` `bash` | `sdx-init.sh` | ⭐⭐ |
| `./scripts/sdx-config.sh` | 默认值、校验函数、支持的 Agents/skills | `脚本` `初始化` | - | `sdx-init.sh` | ⭐⭐ |

### 3.5 规范与模板（.ai / .cursor）

| 文件路径 | 功能精要 | 检索标签 | 上游依赖 | 下游被依赖 | 重要度 |
|---|---|---|---|---|---|
| `./.ai/CONVENTIONS.md` | 规范索引与关键摘要（编码/设计/测试/交付） | `规范` `模板` | `.ai/rules/*` | 人工/Agent 编写文档与交付物 | ⭐⭐⭐ |
| `./.cursor/README.md` | Cursor Slash 命令表与 skills 入口 | `Cursor` `Agent技能` | `.cursor/skills/*` | 用户交互入口 | ⭐⭐ |

### 3.6 knowledge 总入口与宪法层（system/knowledge）

| 文件路径 | 功能精要 | 检索标签 | 上游依赖 | 下游被依赖 | 重要度 |
|---|---|---|---|---|---|
| `./system/knowledge/README.md` | knowledge 定位、入口与索引维护规则 | `知识库` `入口` | `./INDEX.md` | 各视角 README | ⭐⭐⭐ |
| `./system/knowledge/constitution/README.md` | 宪法层组件入口：术语/原则/标准/ADR | `宪法层` `入口` | - | standards/adr 相关 | ⭐⭐⭐ |
| `./system/knowledge/constitution/GLOSSARY.md` | 术语表：术语ID、映射字段速查 | `术语表` `映射字段` | - | 全库统一语言 | ⭐⭐⭐ |
| `./system/knowledge/constitution/standards/naming-conventions.md` | ID 命名规范：TYPE 前缀与引用规则 | `命名规范` | `system/DESIGN.md` | 全库实体命名 | ⭐⭐⭐ |
| `./system/knowledge/constitution/standards/adr-template.md` | ADR 模板：状态/上下文/决策/后果 | `ADR` `模板` | - | `constitution/adr/*` | ⭐⭐ |

### 3.7 四视角 README（system/knowledge/*）

| 文件路径 | 功能精要 | 检索标签 | 上游依赖 | 下游被依赖 | 重要度 |
|---|---|---|---|---|---|
| `./system/knowledge/business/README.md` | BD→BSD→BC→AGG 分层与映射字段 | `业务视角` `映射字段` | `system/DESIGN.md` | 业务实体目录 | ⭐⭐⭐ |
| `./system/knowledge/product/README.md` | PL→PM→FT→UC 分层与映射字段 | `产品视角` `映射字段` | `system/DESIGN.md` | 产品实体目录 | ⭐⭐⭐ |
| `./system/knowledge/technical/README.md` | SYS→APP→MS 分层与应用注册约定 | `技术视角` `映射字段` | `system/DESIGN.md` | 技术实体目录 | ⭐⭐⭐ |
| `./system/knowledge/data/README.md` | DS→ENT 分层与敏感级别/映射字段 | `数据视角` `映射字段` | `system/DESIGN.md` | 数据实体目录 | ⭐⭐⭐ |

## 4. 核心数据流（Mode 3）

> 说明：本仓库主要“数据流”是初始化与知识引用流，而非运行时请求流。

- **数据流 1：向目标项目注入 SDD 文档体系**
  - `./scripts/sdx-init-bootstrap.sh` → 临时 clone 仓库 → 执行 `./scripts/sdx-init.sh` → 将 `system/`、`applications/`、`.ai/`、Agent 配置复制到目标目录（默认 `docs/system`、`docs/application(s)`、`.ai`、`.cursor`/`.trea`）。
- **数据流 2：系统知识库的跨视角引用（SSOT）**
  - `./system/DESIGN.md` 定义四视角元模型与映射机制 → 具体实体在 `system/knowledge/**` 的 `_meta.yaml` / `*.yaml` 中写目标实体 ID。
  - 常用映射字段（见 `system/DESIGN.md` 与 `system/knowledge/constitution/GLOSSARY.md`）：
    - `implemented_by_app_id`（BC → APP）
    - `relies_on_context_ids`（PM → BC）
    - `invokes_api_ids`（FT → API）
    - `persisted_as_entity_ids`（AGG → ENT）
    - `maps_to_aggregate_id`（ENT → AGG）
    - `owned_by_service_id` / `app_id`（数据归属 → MS/APP）

## 5. 配置与环境变量索引（Mode 3）

| 配置项/环境变量 | 所在文件 | 语义 | 默认值 | 敏感性 |
|---|---|---|---|---|
| `GIT_REPO_URL` | `./scripts/sdx-init-bootstrap.sh` | bootstrap 拉取仓库地址 | `https://github.com/oleewen/ai-sdd-knowledge.git` | 低 |
| `GIT_REF` | `./scripts/sdx-init-bootstrap.sh` | 指定克隆分支/标签 | `HEAD` | 低 |
| `REPO_ROOT` | `./scripts/sdx-init.sh` | 指定本仓库根目录 | 自动推导 `SCRIPT_DIR/..` | 低 |
| `TARGET_DIR` | `./scripts/sdx-init.sh` | 初始化目标目录 | 当前目录 `pwd` | 低 |
| `DOCS_DIR` / `--dd` | `./scripts/sdx-config.sh` | 目标文档根目录 | `docs` | 低 |
| `SDX_MODE` / `--mode` | `./scripts/sdx-init.sh` | 初始化模式：`standalone`/`federation` | `standalone` | 低 |
| `DOCS_SCOPE` / `--ds` | `./scripts/sdx-init.sh` | docs 范围：`knowledge`/`full` | `knowledge` | 低 |
| `AI_RULES_SCOPE` / `--as` | `./scripts/sdx-init.sh` | `.ai/rules` 范围控制 | `no-solution-analysis` | 低 |
| `AGENTS_OPT` / `--agents` | `./scripts/sdx-config.sh` | 要初始化的 Agent 列表 | `cursor` | 低 |
| `SKILLS_OPT` / `--skills` | `./scripts/sdx-init.sh` | 要安装的 skills 列表 | 默认仅 agent/knowledge 相关 | 低 |
| `--force` | `./scripts/sdx-init.sh` | 覆盖已存在目录 | 关闭 | 中（可能覆盖文件） |
| `--dry-run` | `./scripts/sdx-init.sh` | 仅打印不执行 | 关闭 | 低 |

> 说明：默认值集中在 `./scripts/sdx-config.sh` 的 `SDX_DEFAULTS`；`sdx-init.sh` 允许用环境变量/参数覆盖。

## 6. 未索引区域声明

> 零幻觉原则：以下路径仅“发现存在”，但未精读其内容；因此不对其内部结构/语义做断言。

- **系统级未精读**
  - `./system/solutions/**`、`./system/analysis/**`、`./system/requirements/**`、`./system/specs/**`、`./system/changelogs/**`
- **knowledge 未精读**
  - `./system/knowledge/constitution/adr/**`、`./system/knowledge/constitution/principles/**`（仅精读了宪法层 README、术语表、标准与 ADR 模板）
  - `./system/knowledge/**/_meta.yaml`、`./system/knowledge/**/*.yaml`（仅精读了四视角 README 与 DESIGN/CONTRIBUTING 约定；实体样例未逐一通读）
- **应用级未精读**
  - `./applications/**` 的应用子目录（若存在）
- **AI 规则与技能未精读**
  - `./.ai/rules/**`（仅基于 `./.ai/CONVENTIONS.md` 的索引信息确认其存在）
  - `./.ai/skills/**`、`./.cursor/skills/**`（仅确认 `./.cursor/README.md` 的命令索引）

## 7. AI 查阅指北（检索表 + Prompt 模板）

| 要了解什么 | 优先标签 | 优先路径 |
|---|---|---|
| 仓库能解决什么问题/如何开始 | `入口` `导航` | `./README.md` |
| system 知识库目录与四视角如何组织 | `知识库` `宪法层` | `./system/README.md` |
| 全局索引与跨视角映射字段 | `索引` `映射字段` | `./system/INDEX.md` |
| 应用侧知识库应如何对齐主库 | `联邦治理` `索引` | `./applications/INDEX.md` |
| 如何在新项目中初始化 SDD 环境 | `初始化` `bootstrap` | `./scripts/README.md`、`./scripts/sdx-init*.sh` |
| 规范/模板入口在哪里 | `规范` `模板` | `./.ai/CONVENTIONS.md`、`./.ai/rules/` |
| Cursor 可用 Slash 命令有哪些 | `Cursor` `Agent技能` | `./.cursor/README.md` |

### 快速检索 Prompt 模板（面向仓库内搜索/阅读）

- **模板 1：定位“初始化输出目录与模式差异”**
  - “在 `./scripts/sdx-init.sh` 中，`standalone` 与 `federation` 模式分别会创建哪些目标目录？涉及哪些参数（`--dd`、`--ds`、`--as`）？”
- **模板 2：定位“system 知识映射字段与关系”**
  - “在 `./system/INDEX.md` 中，列出所有关键映射字段及其关系方向，并指出对应的视角层级（BC/AGG/PM/FT/ENT 等）。”
- **模板 3：扩展索引覆盖率（进入 Mode 3）**
  - “精读 `./system/knowledge/constitution/principles/` 与 `./system/knowledge/constitution/adr/`，补充原则与 ADR 决策，并将新增信息回填到 `./INDEX.md` 的 §3/§6/§7。”

