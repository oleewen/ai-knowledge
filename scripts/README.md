# docs-init：初始化脚本说明

运行要求：`Bash 5+`。

本文档仅说明 `docs-init` 脚本的参数、模式和落地产物。  
Slash 技能命令请查看 [.agent/skills/README.md](../.agent/skills/README.md)，不在此重复。

## 功能概述

1. **文档与知识库**：按 **`--type` × `--mode`** 从中央库多根目录同步到目标文档目录（**工程根**默认可用 `-r` 创建；详见 [知识库 v2 设计](../docs/superpowers/specs/2026-04-07-knowledge-layout-v2-design.md) §6）：

   | 模式 | 未传 `--type` 时默认 | 源目录 | 行为摘要 |
   |------|---------------------|--------|----------|
   | **standalone** | `application` | `application/` | 全量拷贝（排除 `DESIGN.md`、`CONTRIBUTING.md`）；内容替换见 `docs-init` |
   | **central** | **`system`**（例外） | 默认 **`system/`** | 组织级系统知识库模板同步到目标；**不**执行应用登记 |
   | **standalone** | `application`（显式可省略） | `application/` | 同上 |
   | **central** + **`--type=application`**（须显式） | — | `application/` **§2.1 子集** | 仅 `changelogs/`、`knowledge/`、`specs/`、`INDEX_GUIDE.md`、`README.md`、`docs_meta.yaml`、`manifest.yaml` + 本仓库 `application/INDEX_GUIDE.md`「十」登记 + `system/application-<slug>/` 槽位 |
   | 任意 + **`--type=system`** | — | 仓库 `system/` | 组织级模板同步 |
   | 任意 + **`--type=company`** | — | 仓库 `company/` | 公司级模板同步 |

   - **内容替换（application 类型）**：`system` → `application`，`系统` → `应用`；文件名/内容：`system_meta` → `docs_meta`，`SYSTEM_INDEX`/`APPLICATION_INDEX` → `INDEX_GUIDE`（见 `docs-init` `_rewrite_doc_file`）。
   - **system/company 类型**：仅做路径前缀类替换（`_rewrite_doc_file_minimal`），避免把「组织级 system」语义整体替换为「应用」。

2. **Agent 配置**：为多 Agent 安装 skills 和 rules（**安装根为用户主目录 `$HOME`**，不写入目标工程根）
   - 支持 Agent：`cursor`、`trea`、`claude`，可多选（如 `--agents=cursor,trea`）
   - 安装目录映射（相对于 `$HOME`）：
     - `cursor` → `.cursor/`
     - `trea` → `.trea/`
     - `claude` → `.claude/`
   - 安装内容：`.agent/skills/*` → `$HOME/{agent}/skills/`，`.agent/rules/*` → `$HOME/{agent}/rules/`
   - 路径改写：文件中的 `.agent/` 替换为对应 Agent 目录前缀（如 `.cursor/`），`application/` 替换为相对工程根的文档目录（如 `application/`）

3. **冲突处理**：若目标路径已存在，默认会交互式提示；使用 `--force` 强制覆盖，或 `--dry-run` 预览操作。

4. **同步范围控制**：通过 `--scope` 控制执行范围
   - `all`（默认）：同步知识库 + 安装 Agent skills/rules
   - `knowledge`：仅同步知识库（`application/`）
   - `skills`：仅安装 Agent skills/rules（不落地知识库文档）

## doc_root 与 `.docsconfig`（`.agent/scripts/docsconfig-bootstrap.sh`）

目标工程仓库根落盘 **`.docsconfig`**（由 **`docs-init`** 写入 **`DOC_ROOT`** / **`REPO_ROOT`** / **`DOC_DIR`**）。部分 `.agent/skills/*/scripts/validate-*.sh` 与 **`docs-indexing/scripts/indexing.sh`** 经 **`.agent/scripts/docsconfig-bootstrap.sh`**：

- **`validate_bootstrap_docsconfig`**：按规格 §4.1.1 定位仓库根、加载三键（不 `export`）；缺文件或缺 `DOC_DIR` 时走策略 D / §4.2.1。
- **`resolve_repo_doc_root`**：返回 **`validate_bootstrap_docsconfig`** 已加载的 **`DOC_ROOT`**（与 `.docsconfig` 一致），**无参数、不支持 override**。典型写法：**`DOC_ROOT="$(resolve_repo_doc_root)"`**。

规格与迁移说明见 [docs/superpowers/specs/2026-04-08-docsconfig-docs-init-design.md](../docs/superpowers/specs/2026-04-08-docsconfig-docs-init-design.md)。首段目录探测与 validate 引导已由 **`.docsconfig`** + **`docsconfig-bootstrap.sh`** 取代；旧版 **`sdx-doc-root.sh`** / **`sdx-validate-bootstrap.sh`** 已移除。

**`.agent` 内 Markdown 链接自检**（可选，在仓库根执行）：`bash .agent/scripts/validate-agent-md-links.sh` —— 校验 `.agent/**/*.md` 中链接：`.agent` 内互链须存在；跨出 `.agent` 须落在 `REPO_ROOT`/`DOC_ROOT` 下且存在（Agent 语义可达）。落实 [链接可达性要求](../docs/superpowers/specs/2026-04-07-agent-doc-link-reachability-requirements.md)。

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
| `<目标工程文档目录>` | 目标工程下的文档目录路径，如 `~/project/docs`。`standalone` 且 `--scope` 为 `skills` / `rules` / `rs` 时可省略；`central` 或 `all` / `knowledge` 时必须提供 | - |
| `--mode=MODE` | 模式：`standalone`（独立）\| `central`（中央登记）；缩写：`s` \| `c` | `standalone` |
| `--scope=SCOPE` | 同步范围：`all(a)` \| `knowledge(k)` \| `skills(s)` | `all` |
| `-r` | 允许工程根目录不存在时自动创建（等同 `CREATE_PROJECT_ROOT=1`） | 关闭 |
| `--app-id=APP-ID` | Central 模式下使用的 APP ID（如 `APP-MYSERVICE`），不传则从工程目录名推导 | - |
| `--agents=LIST` | 要安装的 Agent：`cursor` \| `trea` \| `claude` \| `all`；可多选，逗号分隔 | `cursor` |
| `--force` | 强制覆盖已存在内容，不提示 | - |
| `--dry-run` | 预览模式，仅打印将要执行的操作 | - |
| `-h`, `--help` | 显示帮助信息 | - |

注意：`--mode=central` 可与任意 `--scope` 组合。**中央登记仅在目标文档目录下已存在 `knowledge/` 时生效**（通常为此前已用 `--scope=all|knowledge` 落地模板）；若仅安装 skills/rules/rs 且尚无 `knowledge/`，将跳过登记并给出警告。`--dry-run` 且本次 scope 为 `all`/`knowledge` 时，仍可按预览输出 central 步骤。

## 初始化后的目录结构

以 `--mode=standalone --agents=cursor` 为例：文档模板落在**目标工程**，Agent 配置落在**用户主目录**。

**目标工程**（参数 `<目标工程文档目录>` 及其父目录）：

```
your-project/
├── application/                          # 文档目录（application/ 模板拷贝，已替换 system→application）
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

**用户主目录 `$HOME`**（Agent skills/rules；覆盖已有配置时可在 `~/.docs-init/` 下备份）：

```
~/
├── .cursor/                       # Cursor Agent 配置（示例；多 Agent 时另有 .trea/、.claude/）
│   ├── skills/                    # Skills（agent-*、docs-*、knowledge-*、sdx-*）
│   └── rules/                     # Rules（编码、设计、测试规范）
└── .docs-init/                    # 用户主目录侧备份（与工程侧备份共用同一时间戳目录名）
```

**注意**：standalone + `type=application`（默认）下自动排除 `DESIGN.md` 和 `CONTRIBUTING.md`，并替换内容中的 `system` → `application`，`系统` → `应用`。

## Central 模式额外产物（仅 `--type=application`）

使用 `--mode=central --type=application` 时，在本仓库（ai-knowledge）额外写入：

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
| standalone，默认 type=application | `application/` | 目标文档目录 | 全量；`system`→`application`；排除 `DESIGN.md`、`CONTRIBUTING.md` |
| central，默认 type=system | `system/` | 目标文档目录 | 最小替换（`_rewrite_doc_file_minimal`） |
| central，`--type=application` | `application/` §2.1 子集 | 目标文档目录 | 全量替换 + 登记 `application/INDEX_GUIDE.md`「十」+ `system/application-<slug>/` |
| `--type=company` | `company/` | 目标文档目录 | 最小替换 |

### Agent 安装

1. 从 `.agent/skills/` 筛选 `agent-*`、`docs-*`、`knowledge-*`、`sdx-*` 前缀的技能目录
2. 拷贝到 `$HOME/{agent_dir}/skills/`（`{agent_dir}` 为 `.cursor`、`.trea`、`.claude` 之一），同时拷贝 `.agent/skills/README.md`
3. 从 `.agent/rules/` 同步所有规则到 `$HOME/{agent_dir}/rules/`
4. 改写路径引用：`.agent/` → `.cursor/`（或 `.trea/`、`.claude/`）；`application/` → 目标文档相对路径（如 `application/`）

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
