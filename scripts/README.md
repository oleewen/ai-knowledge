# knowledge-init：知识库初始化脚本

运行要求：`Bash 5+`。

将本仓库**系统知识库模板**（`system/` 目录）初始化到目标工程的文档目录下，同时安装 Agent skills 和 rules。

## 功能概述

1. **文档与知识库**：使用 `system/` 目录作为模板，支持两种模式（**工程根默认要求已存在**：可用 `-r` 或 `CREATE_PROJECT_ROOT=1` 允许父目录不存在时自动创建；`docs` 等子目录可在拷贝时自动创建）：
   - **standalone（默认）**：将 `system/` 内容拷贝到目标工程的 `docs/` 目录
     - 排除治理文档：`DESIGN.md` 和 `CONTRIBUTING.md`（应用侧无需）
     - 内容替换：`system` → `application`，`系统` → `应用`
     - 文件名替换：`system_meta.yaml` → `application_meta.yaml`，`SYSTEM_INDEX.md` → `APPLICATION_INDEX.md`（`SYSTEM_INDEX` 先整体替换；其余路径段中 `system` 不区分大小写 → `application`）
   - **central**：在 standalone 基础上，额外在本仓库登记目标工程信息
     - 在 `system/SYSTEM_INDEX.md` 中记录应用接入信息
     - 在 `applications/app-<后缀>/` 下生成联邦镜像（后缀为 APP ID 去掉 `APP-` 后的部分）与 `APPNAME_manifest.yaml`

2. **Agent 配置**：为多 Agent 安装 skills 和 rules
   - 支持 Agent：`cursor`、`trea`、`claude`，可多选（如 `--agents=cursor,trea`）
   - 安装目录映射：
     - `cursor` → `.cursor/`
     - `trea` → `.trea/`
     - `claude` → `.claude/`
   - 安装内容：`.ai/skills/*` → `{agent}/skills/`，`.ai/rules/*` → `{agent}/rules/`
   - 路径改写：文件中的 `.ai/` 替换为对应 Agent 目录（如 `.cursor/`），`system/` 替换为相对工程根的文档目录（如 `system/`）

3. **冲突处理**：若目标路径已存在，默认会交互式提示；使用 `--force` 强制覆盖，或 `--dry-run` 预览操作。

4. **同步范围控制**：通过 `--scope` 控制执行范围
   - `all`（默认）：同步知识库 + 安装 Agent skills/rules
   - `knowledge`：仅同步知识库（`system/`）
   - `skills`：仅安装 Agent skills/rules（不落地知识库文档）

## 使用方式

### 方式一：远程执行（无需克隆仓库）

```bash
# 进入目标项目目录
cd /path/to/your-project

# 基础用法（standalone 模式 + cursor Agent）
curl -sL "https://raw.githubusercontent.com/oleewen/ai-sdd-knowledge/main/scripts/knowledge-init-bootstrap.sh" | bash -s -- ./docs

# Central 模式（同时登记到中央知识库）
curl -sL "https://raw.githubusercontent.com/oleewen/ai-sdd-knowledge/main/scripts/knowledge-init-bootstrap.sh" | bash -s -- --mode=central ./docs

# 多 Agent 支持
curl -sL "https://raw.githubusercontent.com/oleewen/ai-sdd-knowledge/main/scripts/knowledge-init-bootstrap.sh" | bash -s -- --agents=cursor,trea ./docs

# 仅同步知识库
curl -sL "https://raw.githubusercontent.com/oleewen/ai-sdd-knowledge/main/scripts/knowledge-init-bootstrap.sh" | bash -s -- --scope=knowledge ./docs

# 仅同步 Agent skills/rules
curl -sL "https://raw.githubusercontent.com/oleewen/ai-sdd-knowledge/main/scripts/knowledge-init-bootstrap.sh" | bash -s -- --scope=skills ./docs

# 指定 APP ID（central 模式）
curl -sL "https://raw.githubusercontent.com/oleewen/ai-sdd-knowledge/main/scripts/knowledge-init-bootstrap.sh" | bash -s -- --mode=central --app-id=APP-MYSERVICE ./docs

# 强制覆盖 + 预览
curl -sL "https://raw.githubusercontent.com/oleewen/ai-sdd-knowledge/main/scripts/knowledge-init-bootstrap.sh" | bash -s -- --dry-run ./docs
curl -sL "https://raw.githubusercontent.com/oleewen/ai-sdd-knowledge/main/scripts/knowledge-init-bootstrap.sh" | bash -s -- --force ./docs
```

环境变量（可选）：
```bash
export GIT_REPO_URL=https://github.com/oleewen/ai-sdd-knowledge.git  # 仓库地址
export GIT_REF=main                                                  # 分支或标签
```

### 方式二：本地执行（已克隆仓库）

```bash
# 进入本仓库
cd ai-sdd-knowledge

# 基础用法
./scripts/knowledge-init.sh /path/to/your-project/docs

# Central 模式
./scripts/knowledge-init.sh --mode=central /path/to/your-project/docs

# 多 Agent
./scripts/knowledge-init.sh --agents=cursor,trea,claude /path/to/your-project/docs

# 仅同步知识库
./scripts/knowledge-init.sh --scope=knowledge /path/to/your-project/docs

# 仅同步 Agent skills/rules
./scripts/knowledge-init.sh --scope=skills /path/to/your-project/docs

# 指定环境变量
REPO_ROOT=/path/to/ai-sdd-knowledge ./scripts/knowledge-init.sh /path/to/your-project/docs
```

## 选项说明

| 选项 | 说明 | 默认 |
|------|------|------|
| `<目标工程文档目录>` | 目标工程下的文档目录路径，如 `~/project/docs` | - |
| `--mode=MODE` | 模式：`standalone`（独立）\| `central`（中央登记）；缩写：`s` \| `c` | `standalone` |
| `--scope=SCOPE` | 同步范围：`all(a)` \| `knowledge(k)` \| `skills(s)` | `all` |
| `-r` | 允许工程根目录不存在时自动创建（等同 `CREATE_PROJECT_ROOT=1`） | 关闭 |
| `--app-id=APP-ID` | Central 模式下使用的 APP ID（如 `APP-MYSERVICE`），不传则从工程目录名推导 | - |
| `--agents=LIST` | 要安装的 Agent：`cursor` \| `trea` \| `claude` \| `all`；可多选，逗号分隔 | `cursor` |
| `--force` | 强制覆盖已存在内容，不提示 | - |
| `--dry-run` | 预览模式，仅打印将要执行的操作 | - |
| `-h`, `--help` | 显示帮助信息 | - |

注意：`--mode=central` 需要同步知识库，因此不支持 `--scope=skills`（或 `--scope=s`）。

## 初始化后的目录结构（目标工程）

以 `--mode=standalone --agents=cursor` 为例：

```
your-project/
├── system/                          # 文档目录（system/ 模板拷贝，已替换 system→application）
│   ├── README.md                  # 应用知识库 README
│   ├── APPLICATION_INDEX.md       # 应用索引（原 SYSTEM_INDEX.md）
│   ├── application_meta.yaml      # 根目录元数据（原 system_meta.yaml）
│   ├── knowledge/                 # 知识库（四视角 + 宪法层）
│   │   ├── README.md
│   │   ├── knowledge_meta.yaml
│   │   ├── constitution/          # 宪法层（原则、标准、ADR）
│   │   ├── business/              # 业务视角
│   │   ├── product/               # 产品视角
│   │   ├── technical/             # 技术视角
│   │   └── data/                  # 数据视角
│   ├── solutions/                 # 解决方案阶段
│   ├── analysis/                  # 需求分析阶段
│   ├── requirements/              # 需求交付阶段
│   └── changelogs/                # 变更日志
├── .cursor/                       # Cursor Agent 配置
│   ├── skills/                    # Skills（agent-*, document-*, knowledge-*, sdx-*）
│   └── rules/                     # Rules（编码、设计、测试规范）
└── .knowledge-init/               # 备份目录（自动创建）
```

**注意**：standalone 模式下自动排除 `DESIGN.md` 和 `CONTRIBUTING.md`（应用侧无需系统治理文档），并自动替换内容中的 `system` → `application`，`系统` → `应用`。

## Central 模式额外产物

使用 `--mode=central` 时，在本仓库（ai-sdd-knowledge）额外生成：

```
ai-sdd-knowledge/
├── system/SYSTEM_INDEX.md         # 更新：追加接入工程登记记录
└── applications/app-<后缀>/       # 中央模式：本仓库内新建联邦镜像目录
    └── {APP-ID}_manifest.yaml     # 应用 manifest 文件
```

## 工作原理

### 模板来源

| 模式 | 模板源 | 目标路径 | 替换规则 |
|------|--------|----------|----------|
| standalone | `system/` | `system/` | 文件名/内容：`system`→`application`，`系统`→`应用`；排除 `DESIGN.md`、`CONTRIBUTING.md` |
| central | `system/` | `system/` | 同上，额外登记到 `system/SYSTEM_INDEX.md`「五、中央知识库接入工程」与 `applications/app-<后缀>/` |

### Agent 安装

1. 从 `.ai/skills/` 筛选 `agent-*`、`document-*`、`knowledge-*`、`sdx-*` 前缀的技能目录
2. 拷贝到 `{agent_dir}/skills/`，同时拷贝 `.ai/skills/README.md`
3. 从 `.ai/rules/` 同步所有规则到 `{agent_dir}/rules/`
4. 改写路径引用：`.ai/` → `.cursor/`（或 `.trea/`、`.claude/`）；`system/` → 目标文档相对路径（如 `system/`）

## 脚本组成

| 脚本 | 说明 |
|------|------|
| `knowledge-init-bootstrap.sh` | 引导脚本，远程执行时自动克隆仓库并调用 `knowledge-init.sh` |
| `knowledge-init.sh` | 主初始化脚本，执行模板拷贝、Agent 安装、Central 模式登记 |
| `knowledge-config.sh` | 配置模块，定义常量、默认值、校验函数 |

## 版本历史

| 版本 | 变更 |
|------|------|
| 2.0.0 | 重构：使用 `system/` 作为模板源；新增文件名/内容替换；支持多 Agent（cursor、trea、claude）；Agent 目录改为 `.cursor/`、`.trea/`、`.claude/`；standalone 模式排除 DESIGN.md 和 CONTRIBUTING.md |
| 1.0.0 | 初始版本：使用 `applications/app-APPNAME/` 作为模板源；支持 standalone 和 central 模式；Agent 配置安装在 `.ai/` 目录 |
