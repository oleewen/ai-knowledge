# 知识库初始化脚本说明（knowledge-init / agent-init）

运行要求：`Bash 5+`。

本文档说明知识库与 Agent 初始化脚本的参数、模式和落地产物。  
Slash 技能以仓库 `agent/skills/` 下各 `SKILL.md` 为准（若存在总览 `README.md` 可一并查阅）；不在此重复。

**维护策略（当前）**：`knowledge-init.sh` / `knowledge-link.sh` / `agent-init.sh` 分别 `source` 对应 `*-config.sh`；三者中路径与 `.docsconfig` 相关能力统一复用 `agent/scripts/docs-config.sh`。改对应脚本行为时需同步其 config 脚本与本文档。

## 推荐入口（一分为三）

| 脚本 | 用途 |
|------|------|
| `agent-init.sh` | 仅安装 Agent（`hooks` / `scripts` / `rules` / `skills`）；`--scope`=`a`/`r`/`s`/`h`/`sh`，`--target`（默认 `$HOME`），`--agents`（默认 `cursor`，可 `all` 或多选），`--dry-run`。 |
| `knowledge-init.sh` | 知识库同步与配置分流；默认 `--scope=config`。仅 `--scope=config` 处理 `.docsconfig`（含 **`KNOWLEDGE_TYPE`**）；`--scope=knowledge` 只安装知识库。 |
| `knowledge-link.sh` | 在**当前 Git 仓库（源知识库）**内维护 `company/knowledge-links.yaml` 或 `system/knowledge-links.yaml`，登记/注销目标库（`link` / `unlink`，`--target`）；`link` 校验目标 `.docsconfig`，`unlink` 支持目标失联按路径注销。 |

`knowledge-init.sh` 仅负责 knowledge 与 `.docsconfig`（不安装 Agent 文件）；Agent 安装仅由 `agent-init.sh` 负责。

**`docs-bootstrap.sh`**：远程 `curl` 下载后执行；临时 **clone** 本仓库，再调用 **`knowledge-init.sh`** 透传参数（**仅**知识库初始化；**仅装 Agent** 请本地 clone 后使用 **`agent-init.sh`**）。

## 功能概述

1. **文档与知识库**：按 **`--type` × `--mode`** 从中央库多根目录同步到目标文档目录（**工程根**默认可用 `-r` 创建；

| `mode` | `type` | 源目录 | 行为摘要 |
|------|---------------------|--------|----------|
| **standalone** | `application`（默认） | `application/` | 全量拷贝（排除 `DESIGN.md`、`CONTRIBUTING.md`）；内容替换见 `knowledge-init` |
| **standalone** | `system` / `company` | `system/` / `company/` | 组织级 / 公司级模板同步 |
| **central**  | `application`（默认） | `application/` **子集** | 仅 `changelogs/`、`knowledge/`、`specs/`、`INDEX_GUIDE.md`、`README.md`、`docs_meta.yaml`、`manifest.yaml`；**不执行 central 登记/联邦槽位写入** |
| **central**  | `system` / `company` | - | **不支持**（报错） |

2. **Agent 配置**（**`agent-init.sh`**）：在 **`--target`**（默认 **`$HOME`**）下按 **`--agents`**（默认 **`cursor`**，可 **`all`** 或多选）安装到 **`${TARGET}/.{.cursor|.trea|.claude}/`** 中对应目录；按 **`--scope`** 选择同步 **`hooks`**、**`scripts`**、**`rules`**、**`skills`**。当 **`--target` 不是 `$HOME`** 且 **`${TARGET}/.docsconfig`** 已存在时，可更新 **`AGENT_ROOT`** 与 **`AGENT_DIRS`**。`knowledge-init` 不处理 `AGENT_*`。

3. **冲突处理**：**`knowledge-init`** 若目标路径已存在，默认会交互式提示；使用 `--force` 强制覆盖，或 `--dry-run` 预览。**`agent-init`** 对安装树采用同步覆盖（可用 `--dry-run` 预览）。

4. **同步范围控制（knowledge-init）**：通过 **`--scope`** 控制执行范围
   - `knowledge`（`k`）：仅同步知识库（须传 `--target=<目标工程文档目录>`），不处理 `.docsconfig`
   - `config`（`c`，**默认**）：仅写入 `.docsconfig`（须传 `--target=<目标工程文档目录>`）

   **Agent 安装**请使用 **`agent-init.sh`**（见上表与「agent-init.sh」选项节）。

## doc_root 与 `.docsconfig`（`agent/scripts/config-bootstrap.sh`）

目标工程仓库根落盘 **`.docsconfig`**：`knowledge-init --scope=config` 写入 **`DOC_ROOT`**、**`REPO_ROOT`**、**`DOC_DIR`** 与 **`KNOWLEDGE_TYPE`**；`knowledge-init --scope=knowledge` 不处理 `.docsconfig`。`agent-init` 在其约束下可更新 **`AGENT_ROOT`**、**`AGENT_DIRS`**。凡 **`DOC_ROOT` / `REPO_ROOT` / `AGENT_ROOT`** 位于用户主目录下时，文件中可能使用 **`~/...`**。

部分 `agent/skills/*/scripts/validate-*.sh` 与 **`docs-indexing/scripts/indexing.sh`** 经 **`agent/scripts/config-bootstrap.sh`**：

- **`validate_bootstrap_docsconfig`**：定位含 `.docsconfig` 的仓库根并读入 **`DOC_ROOT`** / **`REPO_ROOT`** / **`DOC_DIR`**（及可选 **`AGENT_*`**），不 `export`；缺少文件或缺少上述必填键时，stderr 提示使用 **`knowledge-init.sh`** 初始化。
- **`resolve_repo_doc_root`**：返回 **`validate_bootstrap_docsconfig`** 已加载的 **`DOC_ROOT`**（与 `.docsconfig` 一致），**无参数、不支持 override**。典型写法：**`DOC_ROOT="$(resolve_repo_doc_root)"`**。

**`agent` 内 Markdown 链接自检**（可选，在仓库根执行）：`bash agent/scripts/validate-agent-md-links.sh` —— 校验 `agent/**/*.md` 中链接：`agent` 内互链须存在；跨出 `agent` 须落在 `REPO_ROOT`/`DOC_ROOT` 下且存在（Agent 语义可达）。

## 使用方式

### 方式一：克隆后执行（推荐）

```bash
git clone https://github.com/oleewen/ai-knowledge.git
cd ai-knowledge

# 知识库 + .docsconfig（默认 standalone；central 加 --mode=central）
./scripts/knowledge-init.sh --target=/path/to/your-project/docs
./scripts/knowledge-init.sh --mode=central --type=application --target=/path/to/your-project/docs

# 仅安装 Agent（默认安装到 $HOME/.cursor 等；--target 为工程根时可更新该根下 .docsconfig 的 AGENT_*）
./scripts/agent-init.sh
./scripts/agent-init.sh --target /path/to/your-project
./scripts/agent-init.sh --scope=sh --dry-run

# 建联（在「源」公司库或系统库仓库根执行）
./scripts/knowledge-link.sh link --target=/abs/path/to/target-repo
./scripts/knowledge-link.sh unlink --target=/abs/path/to/target-repo
```

### 方式一（续）：远程 curl（无克隆，仅 knowledge 流程）

在**目标工程**目录执行（参数透传给 **`knowledge-init.sh`**；`GIT_REPO_URL` / `GIT_REF` 可选）：

```bash
cd /path/to/your-project
curl -sL "https://raw.githubusercontent.com/oleewen/ai-knowledge/main/scripts/docs-bootstrap.sh" | bash -s -- --target ./docs
curl -sL "https://raw.githubusercontent.com/oleewen/ai-knowledge/main/scripts/docs-bootstrap.sh" | bash -s -- --mode=central --type=application --target ./docs
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

### agent-init.sh

| 选项 | 说明 | 默认 |
|------|------|------|
| `--scope=SCOPE` | `a`：全部；`r`：rules；`s`：skills；`h`：hooks；`sh`：scripts（含复制 `agent/scripts/docs-config.sh`） | `a` |
| `--target=PATH` | 安装父目录，其下仅为**已选 agent** 创建 **`${TARGET}/.cursor`** 等；**非 `$HOME`** 时若存在 `PATH/.docsconfig` 则更新 `AGENT_ROOT`/`AGENT_DIRS` | `$HOME` |
| `--agents=LIST` | `cursor` \| `trea` \| `claude` \| `all`；逗号或空格分隔多选 | `cursor` |
| `--dry-run` | 预览，不写入 | - |
| `-h`, `--help` | 显示帮助 | - |

### knowledge-init.sh（及与 knowledge 共用的历史选项表）

| 选项 | 说明 | 默认 |
|------|------|------|
| `--target=PATH` | 目标工程文档目录路径（如 `~/project/docs`）；`config` / `knowledge` 均必填 | - |
| `--mode=MODE` | 模式：`standalone`（独立）\| `central`（仅应用子集分发）；缩写：`s` \| `c` | `standalone` |
| `--type=TYPE` | `application` \| `system` \| `company`；**`central` 仅允许 `application`**；未指定时默认 `application` | `application` |
| `--scope=SCOPE` | 同步范围：`knowledge(k)` \| `config(c)`；**须传 `--target`**；仅 `config` 写 `.docsconfig`，`knowledge` 不写 | `config` |
| `-r` | 允许工程根目录不存在时自动创建（等同 `CREATE_PROJECT_ROOT=1`）；若文档目录不存在会一并创建 | 关闭 |
| `--force` | 强制覆盖已存在内容，不提示（knowledge-init） | - |
| `--dry-run` | 预览模式，仅打印将要执行的操作 | - |
| `-h`, `--help` | 显示帮助信息 | - |

注意：`scope=config` 仅写入 `.docsconfig`；`scope=knowledge` 仅安装知识库，不处理 `.docsconfig`。**Agent 安装与 `--scope=a|r|s|h|sh` 仅适用于 `agent-init.sh`。**

## 初始化后的目录结构

以 `--mode=standalone` 为例：文档模板落在**目标工程**。仅 **`--scope=config`** 会写入/更新 `.docsconfig`；`--scope=knowledge` 不处理 `.docsconfig`。`agent-init` 是否更新 `AGENT_*` 取决于其自身参数与目标路径状态。

**目标工程**（参数 `--target=<目标工程文档目录>` 及其父目录；`.docsconfig` 至少包含 **`DOC_ROOT`/`REPO_ROOT`/`DOC_DIR`**，`scope=config` 时含 **`KNOWLEDGE_TYPE`**）：

```
your-project/
├── .docsconfig                    # 可选：由 knowledge-init/agent-init 写入（至少 DOC_*；scope=config 含 KNOWLEDGE_TYPE）
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

**用户主目录 `$HOME`**（**`agent-init`** 默认 **`--target=$HOME`** 时；安装结果示例）：

```
~/
├── .cursor/                       # Cursor（另有 .trea/、.claude/ 下同构）
│   ├── hooks.json                 # 自仓库 agent/hooks.json
│   ├── hooks/                     # 自仓库 agent/hooks/
│   ├── scripts/                   # 含 docs-config.sh（自仓库 agent/scripts/ 复制）与 config-bootstrap 等
│   ├── skills/                    # Skills（不含各层 README）
│   └── rules/                     # Rules
├── .trea/
└── .claude/
```

**注意**：standalone + `type=application`（默认）下自动排除 `DESIGN.md` 和 `CONTRIBUTING.md`。

## Central 模式说明

在 **`scope=knowledge`** + **`type=application`** 下，`--mode=central` 仅切换为 application 子集分发。
不会更新本仓库 `application/INDEX_GUIDE.md` / `system/INDEX_GUIDE.md`，也不会创建联邦槽位目录。

## 工作原理

### 模板来源

| 模式 × type | 模板源 | 目标路径 | 替换规则 / 附加步骤 |
|-------------|--------|----------|---------------------|
| standalone，默认 type=application | `application/` | 目标文档目录 | 全量；排除 `DESIGN.md`、`CONTRIBUTING.md` |
| central，`--type=application` | `application/` §2.1 子集 | 目标文档目录 | 子集分发（无中央登记、无联邦槽位写入） |
| standalone，`--type=system` / `company` | `system/` / `company/` | 目标文档目录 | 全量同步 |
| `--type=company` | `company/` | 目标文档目录 | 最小替换 |

### Agent 安装（agent-init.sh）

1. **`--scope` 含 `sh` 时**：将 **`agent/scripts/`** 下条目（**不含** `docs-config.sh`）与 **`agent/scripts/docs-config.sh`（共享实现）** 安装到 **`${TARGET}/.cursor| .trea| .claude/scripts/`**；并对 `scripts/` 下树执行 `agent/` → **`AGENT_DIR/`** 的路径改写。
2. **`--scope` 含 `s` 时**：将 **`agent/skills/`** 下各技能子目录同步到三处 **`skills/`**（排除各层 **README**；不再依赖前缀筛选）。
3. **`--scope` 含 `r` 时**：同步 **`agent/rules/`** 到三处 **`rules/`**。
4. **`--scope` 含 `h` 时**：同步 **`agent/hooks/`** 与 **`agent/hooks.json`**。
5. 改写路径引用：`agent/` → **`.cursor/`** 等对应前缀。

## 脚本组成

| 脚本 | 说明 |
|------|------|
| `agent-init.sh` | **`source` `agent-config.sh`** + Agent 安装；不 `source` `lib/*.sh` |
| `agent-config.sh` | Agent CLI 默认值与校验；`source agent/scripts/docs-config.sh` 复用路径/`.docsconfig` 工具；仅供 **`agent-init.sh`** `source` |
| `knowledge-config.sh` | knowledge-init 配置层；`source agent/scripts/docs-config.sh` 复用路径/`.docsconfig` 工具 |
| `knowledge-init.sh` | knowledge 安装编排入口；默认 `--scope=config`，并 `source` `knowledge-config.sh` |
| `link-config.sh` | knowledge-link 配置层；`source agent/scripts/docs-config.sh` 复用路径/`.docsconfig` 工具 |
| `knowledge-link.sh` | 登记/注销目标知识库；`source link-config.sh`；`link` 校验源/目标 `.docsconfig` 与边关系，`unlink` 支持失联目标注销 |
| `docs-bootstrap.sh` | 临时 clone 后直接执行 **`knowledge-init.sh`**（纯链路：clone → knowledge-init，参数透传） |

## 版本历史

| 版本 | 变更 |
|------|------|
| 3.0.0 | **`agent-init`** / **`agent-config`** 重构：仅 **`--scope`/`--target`/`--dry-run`**；多分根 **`${TARGET}/.cursor|.trea|.claude`**；含 **hooks**；排除 **README**；**`agent/scripts/docs-config.sh`** 复制至各 Agent **`scripts/docs-config.sh`**；**`--target`≠`$HOME`** 时更新 **`.docsconfig`** 之 **`AGENT_*`**（无文件则提示先 **knowledge-init**） |
| 2.9.4 | **移除** **`maintain-agent-init.sh`**；**`agent-init.sh`** 与 core 重叠段改由**人工**与 **`lib/docs-init-core.sh`** / **`knowledge-init`** 对齐 |
| 2.9.3 | 新增 **`agent-config.sh`**（初版自 **`docs-config.sh`** 复制，独立维护）；**`agent-init.sh`** 改为 **`source` `agent-config.sh`**；**`maintain-agent-init.sh`** 不再内联整段 docs-config，并修正对 core 的切片行号 |
| 2.9.2 | **`knowledge-init.sh`** 改为**自包含**（内联 **`docs-config.sh`** 与 **`lib/docs-init-core.sh`** 主体，不 `source` 其它脚本）；**`lib/docs-init-core.sh`** 作对照 SSOT（彼时 **`agent-init`** 由 **`maintain-agent-init.sh`** 生成） |
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
