# 知识库初始化脚本说明（knowledge-init / agent-init）

运行要求：`Bash 5+`。

本文档说明知识库与 Agent 初始化脚本的参数、模式和落地产物。  
Slash 技能以仓库 `agent/skills/` 下各 `SKILL.md` 为准（若存在总览 `README.md` 可一并查阅）；不在此重复。

**维护策略（已选 A）**：`agent-init.sh` 与 `knowledge-init.sh` 均为**自包含**；`docs-config.sh` 与 `lib/docs-init-core.sh` 为**对照 SSOT**。改初始化行为时须同步 SSOT、`knowledge-init.sh` 内联段，并对 Agent 侧执行 `bash scripts/maintain-agent-init.sh`。不采用公共 `source` 库（B）或单一生成管线（C），以避免当前「零 source」约束下的架构切换。

## 推荐入口（一分为三）

| 脚本 | 用途 |
|------|------|
| `agent-init.sh` | 仅安装 Agent（`scripts` / `rules` / `skills`），`--scope=agent`。 |
| `knowledge-init.sh` | 知识库同步与 `.docsconfig`（含 **`KNOWLEDGE_TYPE`**），默认 `--scope=knowledge`；允许 `--scope=config`；禁止 `agent`（请用上一行）。 |
| `knowledge-link.sh` | 在**当前 Git 仓库（源知识库）**内维护 `company/knowledge-links.yaml` 或 `system/knowledge-links.yaml`，登记/注销**本地 path** 目标库（`link` / `unlink`）；**自包含**，不 `source` 其它脚本（内联 `.docsconfig` 读入子集）。 |

**`knowledge-init.sh`** 为**自包含单文件**（内联 **`docs-config.sh`** 语义与 **`lib/docs-init-core.sh`** 主体，不 `source` 其它脚本），**不安装** Agent 文件。**Agent 安装**（scripts/rules/skills）仅在 **`agent-init.sh`**（**自包含**，不 `source` `lib/*.sh`）。**`lib/docs-init-core.sh`** 仍供 **`maintain-agent-init.sh`** 生成 `agent-init` 时引用，并与 `knowledge-init` 并行维护时需对齐。

**`docs-bootstrap.sh`**：远程 `curl` 下载后执行；临时 **clone** 本仓库，再调用 **`knowledge-init.sh`** 透传参数（**仅**知识库初始化；**仅装 Agent** 请本地 clone 后使用 **`agent-init.sh`**）。

## 功能概述

1. **文档与知识库**：按 **`--type` × `--mode`** 从中央库多根目录同步到目标文档目录（**工程根**默认可用 `-r` 创建；

| `mode` | `type` | 源目录 | 行为摘要 |
|------|---------------------|--------|----------|
| **standalone** | `application`（默认） | `application/` | 全量拷贝（排除 `DESIGN.md`、`CONTRIBUTING.md`）；内容替换见 `knowledge-init` |
| **standalone** | `system` / `company` | `system/` / `company/` | 组织级 / 公司级模板同步 |
| **central**  | `application`（默认） | `application/` **子集** | 仅 `changelogs/`、`knowledge/`、`specs/`、`INDEX_GUIDE.md`、`README.md`、`docs_meta.yaml`、`manifest.yaml` + 登记 `application/INDEX_GUIDE.md`「十」+ 联邦槽位 `system/application-<slug>/`（**slug 由目标工程 git remote / 目录名自动推导**） |
| **central**  | **`system`** | **`system/`** | 同步 `system/`；登记 `system/INDEX_GUIDE.md`「十」+ 联邦槽位 `company/system-<slug>/` |

2. **Agent 配置**：为多 Agent 安装 skills、rules、scripts 等；**安装根**与是否传入 `<目标工程文档目录>` 一致（与 `agent-init` / core 内 `agent_install_root` 语义对齐）：
   - `--scope=agent`（缩写 `a`）时：执行 Agent 安装（agent/*）；若传入 `<目标工程文档目录>`，会同步推导 `.docsconfig` 的 `AGENT_ROOT`、`AGENT_DIRS`。
   - `--scope=k|knowledge|config`：**必须**传入 `<目标工程文档目录>`（`k` 与 `knowledge` 等价）；会推导 `DOC_ROOT/REPO_ROOT/DOC_DIR`。
     - 若目标 `.docsconfig` 已有 `AGENT_ROOT` 则保留，否则默认为 `$HOME`（文件中常写 `~`）。
   - 支持 Agent：`cursor`、`trea`、`claude`，可多选（如 `--agents=cursor,trea`）；`AGENT_DIRS` 会按当前 `--agents` 写入。
    - 安装内容：中央库 `agent/*`  → 各 **`$AGENT_ROOT/AGENT_DIR/skills|rules|scripts/`**。
    - 路径改写：当前仅改写文件中的 `agent/` → 对应 Agent 目录前缀。

3. **冲突处理**：若目标路径已存在，默认会交互式提示；使用 `--force` 强制覆盖，或 `--dry-run` 预览操作。

4. **同步范围控制**：通过 `--scope` 控制执行范围
   - `knowledge`（`k`，**默认**）：同步知识库 + 写入 `.docsconfig`（须传 `<目标工程文档目录>`）
   - `config`：仅写入 `.docsconfig`（须传 `<目标工程文档目录>`；不执行中央登记；`--mode=central` / `--type` 在此 scope 下不驱动登记）
   - `agent`（`a`）：安装 Agent scripts、rules、skills（不落地知识库文档）

## doc_root 与 `.docsconfig`（`agent/scripts/docsconfig-bootstrap.sh`）

目标工程仓库根落盘 **`.docsconfig`**（由 **`knowledge-init`** / **`agent-init`** 写入）。**必选键**：**`DOC_ROOT`**、**`REPO_ROOT`**、**`DOC_DIR`**。**可选键**：**`KNOWLEDGE_TYPE`**（`application` \| `system` \| `company`，与知识库模板 `--type` 一致）、**`AGENT_ROOT`**、**`AGENT_DIRS`**（引号内空格分隔目录名，如 `.cursor .claude`）。凡 **`DOC_ROOT` / `REPO_ROOT` / `AGENT_ROOT`** 的路径若位于用户主目录下，文件中为 **`~/...`** 形式；运行时应按 shell 规则展开 **`~`**（**`validate_bootstrap_docsconfig`** 会将 **`DOC_ROOT` / `REPO_ROOT` / `AGENT_ROOT`** 解析为绝对路径）。

部分 `agent/skills/*/scripts/validate-*.sh` 与 **`docs-indexing/scripts/indexing.sh`** 经 **`agent/scripts/docsconfig-bootstrap.sh`**：

- **`validate_bootstrap_docsconfig`**：按规格 §4.1.1 定位仓库根、加载上述键（不 `export`）；缺文件或缺 `DOC_DIR` 时走策略 D / §4.2.1。
- **`resolve_repo_doc_root`**：返回 **`validate_bootstrap_docsconfig`** 已加载的 **`DOC_ROOT`**（与 `.docsconfig` 一致），**无参数、不支持 override**。典型写法：**`DOC_ROOT="$(resolve_repo_doc_root)"`**。

**`agent` 内 Markdown 链接自检**（可选，在仓库根执行）：`bash agent/scripts/validate-agent-md-links.sh` —— 校验 `agent/**/*.md` 中链接：`agent` 内互链须存在；跨出 `agent` 须落在 `REPO_ROOT`/`DOC_ROOT` 下且存在（Agent 语义可达）。

## 使用方式

### 方式一：克隆后执行（推荐）

```bash
git clone https://github.com/oleewen/ai-knowledge.git
cd ai-knowledge

# 知识库 + .docsconfig（默认 standalone；central 加 --mode=central）
./scripts/knowledge-init.sh /path/to/your-project/docs
./scripts/knowledge-init.sh --mode=central /path/to/your-project/docs

# 仅安装 Agent
./scripts/agent-init.sh /path/to/your-project/docs
./scripts/agent-init.sh   # 未传文档目录时安装到 $HOME 侧

# 建联（在「源」公司库或系统库仓库根执行）
./scripts/knowledge-link.sh link --path=/abs/path/to/target-repo
./scripts/knowledge-link.sh unlink --path=/abs/path/to/target-repo
```

### 方式一（续）：远程 curl（无克隆，仅 knowledge 流程）

在**目标工程**目录执行（参数透传给 **`knowledge-init.sh`**；`GIT_REPO_URL` / `GIT_REF` 可选）：

```bash
cd /path/to/your-project
curl -sL "https://raw.githubusercontent.com/oleewen/ai-knowledge/main/scripts/docs-bootstrap.sh" | bash -s -- ./docs
curl -sL "https://raw.githubusercontent.com/oleewen/ai-knowledge/main/scripts/docs-bootstrap.sh" | bash -s -- --mode=central ./docs
```

**说明**：bootstrap **不**调用 `agent-init`；若需仅安装 Agent，须 **git clone** 后使用 **`./scripts/agent-init.sh`**。

## 测试（docs-init）

集成测试设计见 [docs/superpowers/specs/2026-04-10-docs-init-testing-design.md](../../docs/superpowers/specs/2026-04-10-docs-init-testing-design.md)。

在仓库根执行（默认 CI 子集，不修改当前克隆的登记文件）：

```bash
bash scripts/tests/docs-init/run.sh
```

含整库副本与 Central 登记类用例（Spec §6.5 / §6.8；耗时与磁盘占用更高）：

```bash
DOCS_INIT_TEST_FULL=1 bash scripts/tests/docs-init/run.sh
```

环境变量（可选）：
```bash
export GIT_REPO_URL=https://github.com/oleewen/ai-knowledge.git  # 仓库地址
export GIT_REF=main                                                  # 分支或标签
```

## 选项说明

| 选项 | 说明 | 默认 |
|------|------|------|
| `<目标工程文档目录>` | 目标工程下的文档目录路径，如 `~/project/docs`。`standalone` 且 `--scope` 为 `agent` 时可省略；**`config` / `knowledge`（`k`）时必须提供**；`central` 时必须提供 | - |
| `--mode=MODE` | 模式：`standalone`（独立）\| `central`（中央登记，**仅** `scope=knowledge` 时生效）；缩写：`s` \| `c` | `standalone` |
| `--type=TYPE` | `application` \| `system` \| `company`；**`central` 仅允许 `application` \| `system`**；未指定时默认 `application` | `application` |
| `--scope=SCOPE` | 同步范围：`knowledge(k)` \| `config(c)` \| `agent(a)`；**`config`/`knowledge` 须传 `<目标工程文档目录>`**；传 docs 时会写 `.docsconfig`；**`config`/`knowledge` 下** 已有 `AGENT_ROOT` 则保留，否则默认为 `~`（**`agent` 且传入 docs** 时 `AGENT_ROOT` 与 `REPO_ROOT` 一致） | `knowledge` |
| `-r` | 允许工程根目录不存在时自动创建（等同 `CREATE_PROJECT_ROOT=1`）；若文档目录不存在会一并创建 | 关闭 |
| `--agents=LIST` | 要安装的 Agent：`cursor` \| `trea` \| `claude` \| `all`；可多选，逗号分隔 | `cursor` |
| `--force` | 强制覆盖已存在内容，不提示 | - |
| `--dry-run` | 预览模式，仅打印将要执行的操作 | - |
| `-h`, `--help` | 显示帮助信息 | - |

注意：`--mode=central` 与 `--type` **仅在** `scope=knowledge` 时参与中央登记与知识库模板选型；其它 `scope` 传入时会忽略并提示。`scope=config` 仅写入 `.docsconfig`（`install_docsconfig`），**不**执行中央登记。中央登记依赖 `mode=central`、目标文档目录，以及 `type=application`（默认）或 `type=system`（见上表）。旧参数 `--app-id` 已移除，传入将报错并提示迁移。

## 初始化后的目录结构

以 `--mode=standalone --agents=cursor` 为例：文档模板落在**目标工程**。**`--scope=agent` 且传入 `<目标工程文档目录>`** 时，写入的 **`AGENT_ROOT`** 与工程根一致（与 **`REPO_ROOT`** 同目录）。**`--scope=config|knowledge`** 时：若 `.docsconfig` 已有 **`AGENT_ROOT`** 则保留；否则 **`AGENT_ROOT`=`$HOME`**（与仅装 Agent 未传文档目录时一致）。若**未传入**文档目录（仅 **`agent`** 允许），则 **`AGENT_ROOT`=`$HOME`**。

**目标工程**（参数 `<目标工程文档目录>` 及其父目录；含 `.docsconfig` 五键中的 **`DOC_ROOT`/`REPO_ROOT`/`DOC_DIR`**，以及在相关 scope 下写入的 **`AGENT_ROOT`/`AGENT_DIRS`**）：

```
your-project/
├── .docsconfig                    # 可选：由 knowledge-init / agent-init 写入（必选三键；相关 scope 下可含 AGENT_*）
├── application/                          # 文档目录（application/ 模板拷贝）
│   ├── README.md                  # 应用知识库 README
│   ├── INDEX_GUIDE.md             # 九章索引（docs-indexing）；central 登记见「十」
│   ├── docs_meta.yaml             # 根目录元数据
│   ├── constitution/            # 宪法层（原则、标准、ADR；与 knowledge/ 平级）
│   ├── knowledge/                 # 知识库（四视角）
│   │   ├── README.md
│   │   ├── knowledge_meta.yaml
│   │   ├── business/              # 业务视角
│   │   ├── product/               # 产品视角
│   │   ├── technical/             # 技术视角
│   │   └── data/                  # 数据视角
│   ├── solutions/                 # 解决方案阶段
│   ├── analysis/                  # 需求分析阶段
│   ├── requirements/              # 需求交付阶段
│   └── changelogs/                # 变更日志
└── .docs-init/                    # 工程侧备份（覆盖已有文档模板时自动创建）
```

**用户主目录 `$HOME`**（**仅当未指定** `<目标工程文档目录>` 而安装 Agent 时；此时 **`AGENT_ROOT`=`$HOME`**；覆盖已有配置时可在 `~/.docs-init/` 下备份）：

```
~/
├── .cursor/                       # Cursor Agent 配置（示例；多 Agent 时另有 .trea/、.claude/）
│   ├── skills/                    # Skills（agent-*、docs-*、knowledge-*、sdx-*）
│   └── rules/                     # Rules（编码、设计、测试规范）
└── .docs-init/                    # 用户主目录侧备份（与工程侧备份共用同一时间戳目录名）
```

**注意**：standalone + `type=application`（默认）下自动排除 `DESIGN.md` 和 `CONTRIBUTING.md`；内容改写仅处理 `agent/` 前缀映射到目标 Agent 目录。

## Central 模式额外产物

在 **`scope=knowledge`** 的前提下，使用 **`--mode=central`** 时，在本仓库（`REPO_ROOT`，即 ai-knowledge 克隆根）额外写入：

**`--type=application`（默认）**

```
ai-knowledge/
├── application/INDEX_GUIDE.md          # 「十、中央知识库接入工程」登记行
└── system/application-<slug>/          # 联邦槽位（v2.3 起；旧 `applications/app-*` 已废弃）
    └── README.md                       # 首次登记时生成占位说明
```

**`--type=system`**

```
ai-knowledge/
├── system/INDEX_GUIDE.md               # 「十、中央系统知识库接入工程」登记行
└── company/system-<slug>/
    └── README.md
```

## 工作原理

### 模板来源

| 模式 × type | 模板源 | 目标路径 | 替换规则 / 附加步骤 |
|-------------|--------|----------|---------------------|
| standalone，默认 type=application | `application/` | 目标文档目录 | 全量；排除 `DESIGN.md`、`CONTRIBUTING.md` |
| central，默认 type=application | `application/` §2.1 子集 | 目标文档目录 | 全量替换 + 登记 `application/INDEX_GUIDE.md`「十」+ `system/application-<slug>/` |
| central，`--type=system` | `system/` | 目标文档目录 | 最小替换 + 登记 `system/INDEX_GUIDE.md`「十」+ `company/system-<slug>/` |
| standalone，`--type=system` / `company` | `system/` / `company/` | 目标文档目录 | 最小替换（`rewrite_agent_file`） |
| `--type=company` | `company/` | 目标文档目录 | 最小替换 |

### Agent 安装

1. **`--scope=agent` 时**：将 **`agent/scripts/`** 下条目（**不含** 与 SSOT 同名的 `docs-config.sh`，避免重复拷贝）与 **`scripts/docs-config.sh`（SSOT）** 安装到 **`$AGENT_ROOT`/`AGENT_DIR`/scripts/**；并对 `scripts/` 下树执行 `agent/` → **`AGENT_DIR/`** 的路径改写。供 `docsconfig-bootstrap.sh` 运行时 `source` 与共享脚本使用。
2. 从中央库 `agent/skills/` 筛选 `agent-*`、`docs-*`、`knowledge-*`、`sdx-*` 前缀的技能目录
3. 拷贝到 **`$AGENT_ROOT`/`AGENT_DIR`/skills/**（**`AGENT_DIR`** 为 `.cursor`、`.trea`、`.claude` 之一；**`AGENT_ROOT`** 见上文「功能概述」节），同时拷贝 `agent/skills/README.md`
4. 从 `agent/rules/` 同步所有规则到 **`$AGENT_ROOT`/`AGENT_DIR`/rules/**
5. 改写路径引用：当前仅改写 `agent/` → **`AGENT_DIR/`**（如 `.cursor/`）

## 脚本组成

| 脚本 | 说明 |
|------|------|
| `agent-init.sh` | **自包含**（内联 docs-config / core 子集 / Agent 安装逻辑），不 `source` 其它脚本；等价原 **`--scope=agent`** 流程；与 SSOT 同步请运行 **`maintain-agent-init.sh`** |
| `maintain-agent-init.sh` | 从 **`docs-config.sh`**、**`lib/docs-init-core.sh`** 及内嵌 Agent 安装段**重新生成** **`agent-init.sh`** |
| `knowledge-init.sh` | **自包含**（内联 docs-config + core 语义），默认 `--scope=knowledge`；禁止 `source` 其它脚本 |
| `knowledge-link.sh` | **自包含**，不 `source` 其它脚本；源库内维护 `knowledge-links.yaml`（仅本地 `path`）；内联 `.docsconfig` 读入（与 `docs-config.sh` 语义对齐、需并行维护） |
| `docs-bootstrap.sh` | 临时 clone 后执行 **`knowledge-init.sh`**；`SDX_BS_FALLBACK_REPO` 须与 `docs-config.sh` 中 `SDX_GIT_REPO_URL` 一致（集成测试校验） |
| `lib/docs-init-core.sh` | 与 **`knowledge-init`** 重叠的逻辑片段（供 **`maintain-agent-init`** 生成）；**勿**被 **`knowledge-init`** `source`（已内联） |
| `docs-config.sh` | 配置模块，定义常量、默认值、校验函数、`.docsconfig` 读写（含 **`KNOWLEDGE_TYPE`**）；**`agent-init.sh`** / **`knowledge-link.sh`** 内联同语义子集处，与此文件并行维护 |

## 版本历史

| 版本 | 变更 |
|------|------|
| 2.9.2 | **`knowledge-init.sh`** 改为**自包含**（内联 **`docs-config.sh`** 与 **`lib/docs-init-core.sh`** 主体，不 `source` 其它脚本）；**`lib/docs-init-core.sh`** 仍供 **`maintain-agent-init.sh`** 与对照 |
| 2.9.1 | **`knowledge-link.sh`** 不再 `source` **`docs-config.sh`**，内联 `.docsconfig` 读入最小子集（与 **`docs-config.sh`** 并行维护） |
| 2.9.0 | **`agent-init.sh`** 改为**自包含单文件**（内联 docs-config / core 子集 / 原 Agent 安装逻辑），**不** `source` 其它脚本；删除 **`lib/agent-init-install.sh`** |
| 2.8.0 | 移除 **`docs-init.sh`** 兼容入口；统一使用 **`knowledge-init.sh`** / **`agent-init.sh`** |
| 2.7.0 | 拆分 **`agent-init.sh`** / **`knowledge-init.sh`** / **`knowledge-link.sh`**；核心逻辑迁至 **`lib/docs-init-core.sh`**；`.docsconfig` 增加 **`KNOWLEDGE_TYPE`**；**`docs-bootstrap.sh`** 改为调用 **`knowledge-init.sh`** |
| 2.6.0 | **`--scope`**：**移除 `ck`**；**`k`/`knowledge`** 表示原 `ck` 行为（同步知识库 + `.docsconfig`）；默认 **`SCOPE`** 改为 **`knowledge`** |
| 2.5.0 | **`--scope`**：新增 **`agent`/`a`**，一次安装 scripts + rules + skills；**移除** scope **`skills`/`s`、`rules`/`r`、`rs`**（请改用 **`--scope=agent`**） |
| 2.4.0 | `central`：`--type` 仅 `application`\|`system`，默认 `application`；移除 `--app-id`；`system` 中央登记写入 `system/INDEX_GUIDE.md` 与 `company/system-<slug>/`；`-r` 时自动创建文档目录 |
| 2.1.3 | `sdx-doc-root` 默认首段改为 `docs`；目录探测优先 `docs/` 下标记 |
| 2.1.2 | 落地方案 A：`SDX_DOC_ROOT`、`.sdx-doc-root` 与目录探测统一由 `agent/scripts/sdx-doc-root.sh` 提供；各 `validate-*.sh` 接入 |
| 2.1.1 | `standalone` 下 `--scope` 为 `agent` 时，`<目标工程文档目录>` 可省略；未指定时 Agent 内 `application/` → 文档前缀替换默认为 `docs/` |
| 2.1.0 | Agent skills/rules 安装目录由「目标工程根下」改为「用户主目录 `$HOME` 下」；备份对应使用 `~/.docs-init/` |
| 2.0.0 | 重构：使用 `application/` 作为模板源；新增文件名/内容替换；支持多 Agent（cursor、trea、claude）；Agent 目录改为 `.cursor/`、`.trea/`、`.claude/`；standalone 模式排除 DESIGN.md 和 CONTRIBUTING.md |
| 1.0.0 | 初始版本：使用 `applications/app-APPNAME/` 作为模板源；支持 standalone 和 central 模式；Agent 配置安装在 `agent/` 目录 |
