# docs-init：初始化脚本说明

运行要求：`Bash 5+`。

本文档仅说明 `docs-init` 脚本的参数、模式和落地产物。  
Slash 技能命令请查看 [.agent/skills/README.md](../.agent/skills/README.md)，不在此重复。

## 功能概述

1. **文档与知识库**：按 **`--type` × `--mode`** 从中央库多根目录同步到目标文档目录（**工程根**默认可用 `-r` 创建；

| `mode` | `type` | 源目录 | 行为摘要 |
|------|---------------------|--------|----------|
| **standalone** | `application` | `application/` | 全量拷贝（排除 `DESIGN.md`、`CONTRIBUTING.md`）；内容替换见 `docs-init` |
| **central**  | `application` | `application/` **子集** | 仅 `changelogs/`、`knowledge/`、`specs/`、`INDEX_GUIDE.md`、`README.md`、`docs_meta.yaml`、`manifest.yaml` + 执行应用知识库登记 `system/application-<slug>/`  |
| **central**  | **`system`** | **`system/`** | 系统知识库同步到；执行系统知识库登记 `company/system-<slug>/` |
| **central** | **`company`** | **`company/`** | 公司级模板同步；  |

2. **Agent 配置**：为多 Agent 安装 skills 和 rules；**安装根**与是否传入 `<目标工程文档目录>` 一致（与 `docs-init` 内 `agent_install_root` 语义对齐）：
   - `--scope=skills|rules|rs` 时：执行 Agent 安装；若传入 `<目标工程文档目录>`，会同步写入 `.docsconfig`。
   - `--scope=ck|config|knowledge` 且传入文档目录：会推导 `DOC_ROOT/REPO_ROOT/DOC_DIR`。
     - `ck`：若目标 `.docsconfig` 已有 `AGENT_ROOT` 则保留，否则补为 `REPO_ROOT`。
     - `config|knowledge`：若目标 `.docsconfig` 已有 `AGENT_ROOT` 则保留，否则补为 `REPO_ROOT`。
   - 支持 Agent：`cursor`、`trea`、`claude`，可多选（如 `--agents=cursor,trea`）；`AGENT_DIRS` 会按当前 `--agents` 写入。
   - 安装内容：中央库 `.agent/skills/*`、`.agent/rules/*` → 各 **`$AGENT_ROOT/AGENT_DIR/skills|rules/`**。
   - 路径改写：当前仅改写文件中的 `.agent/` → 对应 Agent 目录前缀。

3. **冲突处理**：若目标路径已存在，默认会交互式提示；使用 `--force` 强制覆盖，或 `--dry-run` 预览操作。

4. **同步范围控制**：通过 `--scope` 控制执行范围
   - `ck`（默认）：同步知识库 + 写入 `.docsconfig`
     - 未传 `<目标工程文档目录>` 时，`ck` 仅写入 `~/.docsconfig`（不执行知识库同步）
   - `config`：仅写入 `.docsconfig`（不执行中央登记；`--mode=central` / `--type` 在此 scope 下不驱动登记）
   - `knowledge`：仅同步知识库（`application/`）
   - `skills`：仅安装 Agent skills（不落地知识库文档）
   - `rules`：仅安装 Agent rules（不落地知识库文档）
   - `rs`：同时安装 Agent skills + rules（不落地知识库文档）

## doc_root 与 `.docsconfig`（`.agent/scripts/docsconfig-bootstrap.sh`）

目标工程仓库根落盘 **`.docsconfig`**（由 **`docs-init`** 写入）。**必选键**：**`DOC_ROOT`**、**`REPO_ROOT`**、**`DOC_DIR`**。**可选键**：**`AGENT_ROOT`**、**`AGENT_DIRS`**（引号内空格分隔目录名，如 `.cursor .claude`）。凡 **`DOC_ROOT` / `REPO_ROOT` / `AGENT_ROOT`** 的路径若位于用户主目录下，文件中为 **`~/...`** 形式；运行时应按 shell 规则展开 **`~`**（**`validate_bootstrap_docsconfig`** 会将 **`DOC_ROOT` / `REPO_ROOT` / `AGENT_ROOT`** 解析为绝对路径）。

部分 `.agent/skills/*/scripts/validate-*.sh` 与 **`docs-indexing/scripts/indexing.sh`** 经 **`.agent/scripts/docsconfig-bootstrap.sh`**：

- **`validate_bootstrap_docsconfig`**：按规格 §4.1.1 定位仓库根、加载上述键（不 `export`）；缺文件或缺 `DOC_DIR` 时走策略 D / §4.2.1。
- **`resolve_repo_doc_root`**：返回 **`validate_bootstrap_docsconfig`** 已加载的 **`DOC_ROOT`**（与 `.docsconfig` 一致），**无参数、不支持 override**。典型写法：**`DOC_ROOT="$(resolve_repo_doc_root)"`**。

**`.agent` 内 Markdown 链接自检**（可选，在仓库根执行）：`bash .agent/scripts/validate-agent-md-links.sh` —— 校验 `.agent/**/*.md` 中链接：`.agent` 内互链须存在；跨出 `.agent` 须落在 `REPO_ROOT`/`DOC_ROOT` 下且存在（Agent 语义可达）。

## 使用方式

### 方式一：远程执行（无需克隆仓库）

```bash
# 进入目标项目目录
cd /path/to/your-project

# 基础用法（standalone 模式 + cursor Agent）
curl -sL "https://raw.githubusercontent.com/oleewen/ai-knowledge/main/scripts/docs-bootstrap.sh" | bash -s -- ./docs

# Central 模式（同时登记到中央知识库）
curl -sL "https://raw.githubusercontent.com/oleewen/ai-knowledge/main/scripts/docs-bootstrap.sh" | bash -s -- --mode=central ./docs

# 多 Agent 支持
curl -sL "https://raw.githubusercontent.com/oleewen/ai-knowledge/main/scripts/docs-bootstrap.sh" | bash -s -- --agents=cursor,trea ./docs

# 仅同步知识库
curl -sL "https://raw.githubusercontent.com/oleewen/ai-knowledge/main/scripts/docs-bootstrap.sh" | bash -s -- --scope=knowledge ./docs

# 仅同步 Agent skills/rules
curl -sL "https://raw.githubusercontent.com/oleewen/ai-knowledge/main/scripts/docs-bootstrap.sh" | bash -s -- --scope=skills ./docs

# 指定 APP ID（central 模式）
curl -sL "https://raw.githubusercontent.com/oleewen/ai-knowledge/main/scripts/docs-bootstrap.sh" | bash -s -- --mode=central --app-id=APP-MYSERVICE ./docs

# 强制覆盖 + 预览
curl -sL "https://raw.githubusercontent.com/oleewen/ai-knowledge/main/scripts/docs-bootstrap.sh" | bash -s -- --dry-run ./docs
curl -sL "https://raw.githubusercontent.com/oleewen/ai-knowledge/main/scripts/docs-bootstrap.sh" | bash -s -- --force ./docs
```

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

### 方式二：本地执行（已克隆仓库）

```bash
# 进入本仓库
cd ai-knowledge

# 基础用法
./scripts/docs-init.sh /path/to/your-project/docs

# Central 模式
./scripts/docs-init.sh --mode=central /path/to/your-project/docs

# 多 Agent
./scripts/docs-init.sh --agents=cursor,trea,claude /path/to/your-project/docs

# 仅同步知识库
./scripts/docs-init.sh --scope=knowledge /path/to/your-project/docs

# 仅同步 Agent skills/rules
./scripts/docs-init.sh --scope=skills /path/to/your-project/docs

# 指定环境变量
REPO_ROOT=/path/to/ai-knowledge ./scripts/docs-init.sh /path/to/your-project/docs
```

## 选项说明

| 选项 | 说明 | 默认 |
|------|------|------|
| `<目标工程文档目录>` | 目标工程下的文档目录路径，如 `~/project/docs`。`standalone` 且 `--scope` 为 `skills` / `rules` / `rs` / `config` / `ck` 时可省略；`central` 或 `knowledge` 时必须提供 | - |
| `--mode=MODE` | 模式：`standalone`（独立）\| `central`（中央登记，**仅** `scope=ck` / `knowledge` 时生效）；缩写：`s` \| `c` | `standalone` |
| `--scope=SCOPE` | 同步范围：`ck` \| `config(c)` \| `knowledge(k)` \| `skills(s)` \| `rules(r)` \| `rs`；传 docs 时会写 `.docsconfig`（含 `skills/rules/rs`）；`ck/config/knowledge`（传 docs）已有 `AGENT_ROOT` 保留，否则补 REPO_ROOT | `ck` |
| `-r` | 允许工程根目录不存在时自动创建（等同 `CREATE_PROJECT_ROOT=1`） | 关闭 |
| `--app-id=APP-ID` | Central 模式下使用的 APP ID（如 `APP-MYSERVICE`），不传则从工程目录名推导 | - |
| `--agents=LIST` | 要安装的 Agent：`cursor` \| `trea` \| `claude` \| `all`；可多选，逗号分隔 | `cursor` |
| `--force` | 强制覆盖已存在内容，不提示 | - |
| `--dry-run` | 预览模式，仅打印将要执行的操作 | - |
| `-h`, `--help` | 显示帮助信息 | - |

注意：`--mode=central` 与 `--type` **仅在** `scope=ck` 或 `knowledge` 时参与中央登记与知识库模板选型；其它 `scope` 传入时会忽略并提示。`scope=config` 仅写入 `.docsconfig`（`install_docsconfig`），**不**执行中央登记。应用知识库中央登记依赖 `mode=central`、`type=application` 与目标文档目录（见上表）。

## 初始化后的目录结构

以 `--mode=standalone --agents=cursor` 为例：文档模板落在**目标工程**。Agent 配置落在 **`AGENT_ROOT`**：若本次命令**传入了** `<目标工程文档目录>`，则 **`AGENT_ROOT`** 与工程根一致（与 `.docsconfig` 之 **`REPO_ROOT`** 同目录）；若**未传入**（仅装 skills/rules），则 **`AGENT_ROOT`=`$HOME`**。

**目标工程**（参数 `<目标工程文档目录>` 及其父目录；含 `.docsconfig` 五键中的 **`DOC_ROOT`/`REPO_ROOT`/`DOC_DIR`**，以及在相关 scope 下写入的 **`AGENT_ROOT`/`AGENT_DIRS`**）：

```
your-project/
├── .docsconfig                    # 可选：由 docs-init 写入（必选三键；相关 scope 下可含 AGENT_*）
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

**注意**：standalone + `type=application`（默认）下自动排除 `DESIGN.md` 和 `CONTRIBUTING.md`；内容改写仅处理 `.agent/` 前缀映射到目标 Agent 目录。

## Central 模式额外产物（仅 `--type=application`）

在 **`scope=ck` 或 `knowledge`** 的前提下，使用 `--mode=central --type=application` 时，在本仓库（ai-knowledge）额外写入：

```
ai-knowledge/
├── application/INDEX_GUIDE.md          # 「十、中央知识库接入工程」登记行
└── system/application-<后缀>/         # 联邦槽位（v2.3 起；旧 `applications/app-*` 已废弃）
    └── README.md                      # 首次登记时生成占位说明
```

## 工作原理

### 模板来源

| 模式 × type | 模板源 | 目标路径 | 替换规则 / 附加步骤 |
|-------------|--------|----------|---------------------|
| standalone，默认 type=application | `application/` | 目标文档目录 | 全量；排除 `DESIGN.md`、`CONTRIBUTING.md` |
| central，默认 type=system | `system/` | 目标文档目录 | 最小替换（`rewrite_agent_file`） |
| central，`--type=application` | `application/` §2.1 子集 | 目标文档目录 | 全量替换 + 登记 `application/INDEX_GUIDE.md`「十」+ `system/application-<slug>/` |
| `--type=company` | `company/` | 目标文档目录 | 最小替换 |

### Agent 安装

1. 从中央库 `.agent/skills/` 筛选 `agent-*`、`docs-*`、`knowledge-*`、`sdx-*` 前缀的技能目录
2. 拷贝到 **`$AGENT_ROOT`/`AGENT_DIR`/skills/**（**`AGENT_DIR`** 为 `.cursor`、`.trea`、`.claude` 之一；**`AGENT_ROOT`** 见上文「功能概述」节），同时拷贝 `.agent/skills/README.md`
3. 从 `.agent/rules/` 同步所有规则到 **`$AGENT_ROOT`/`AGENT_DIR`/rules/**
4. 改写路径引用：当前仅改写 `.agent/` → **`AGENT_DIR/`**（如 `.cursor/`）

## 脚本组成

| 脚本 | 说明 |
|------|------|
| `docs-bootstrap.sh` | 引导脚本，远程执行时自动克隆仓库并调用 `docs-init.sh` |
| `docs-init.sh` | 主初始化脚本，执行模板拷贝、Agent 安装、Central 模式登记 |
| `docs-config.sh` | 配置模块，定义常量、默认值、校验函数 |

## 版本历史

| 版本 | 变更 |
|------|------|
| 2.1.3 | `sdx-doc-root` 默认首段改为 `docs`；目录探测优先 `docs/` 下标记 |
| 2.1.2 | 落地方案 A：`SDX_DOC_ROOT`、`.sdx-doc-root` 与目录探测统一由 `.agent/scripts/sdx-doc-root.sh` 提供；各 `validate-*.sh` 接入 |
| 2.1.1 | `standalone` 下 `--scope` 为 skills/rules/rs 时，`<目标工程文档目录>` 可省略；未指定时 Agent 内 `application/` → 文档前缀替换默认为 `docs/` |
| 2.1.0 | Agent skills/rules 安装目录由「目标工程根下」改为「用户主目录 `$HOME` 下」；备份对应使用 `~/.docs-init/` |
| 2.0.0 | 重构：使用 `application/` 作为模板源；新增文件名/内容替换；支持多 Agent（cursor、trea、claude）；Agent 目录改为 `.cursor/`、`.trea/`、`.claude/`；standalone 模式排除 DESIGN.md 和 CONTRIBUTING.md |
| 1.0.0 | 初始版本：使用 `applications/app-APPNAME/` 作为模板源；支持 standalone 和 central 模式；Agent 配置安装在 `.agent/` 目录 |
