# docs-init：Agent（.ai/skills、.ai/rules）仅安装至用户主目录

**日期**: 2026-04-06  
**状态**: 已实现  
**范围**: `scripts/docs-init.sh`，必要时同步 `scripts/docs-config.sh`、 `scripts/README.md` 中与安装路径相关的说明。

---

## 1. 背景与目标

当前 `docs-init` 将 `.ai/skills`、`.ai/rules` 安装到 **目标工程根** 下的 Agent 目录：

- `agent_dir = ${target_dir}/$(sdx_get_agent_dir <agent>)`
- `target_dir` = 用户传入的「目标工程文档目录」的父目录

**目标**：上述内容 **仅** 安装到 **`$HOME/$(sdx_get_agent_dir <agent>)`**（例如 `~/.cursor`、`~/.trea`、`~/.claude`），**不再** 写入目标工程目录下的 `.cursor` / `.trea` / `.claude`。

**非目标（保持不变）**：

- `system/` → 目标工程文档目录（`docs_abs`）的同步逻辑、路径映射、排除 `DESIGN.md` / `CONTRIBUTING.md` 等规则不变。
- `central` 模式：仍基于 `CFG[target_dir]`、`CFG[docs_abs]` 登记与建镜像；不因 Agent 安装位置改变。
- 内容替换规则：`.ai/` → `agent_slash`（如 `.cursor/`）、`system/` → `docs_slash` 不变；**物理安装位置**与 **文中路径前缀** 分离——文中仍使用 `.cursor/` 等形式，与 Cursor 等工具约定一致。

---

## 2. 方案对比

| 方案 | 做法 | 优点 | 缺点 |
|------|------|------|------|
| **A. 固定 `$HOME`** | `agent_dir="$HOME/$(sdx_get_agent_dir …)"` | 实现简单、与用户表述一致 | 无法在无 `$HOME` 的极端环境自定义（极少见） |
| **B. 环境变量覆盖** | 如 `AGENT_INSTALL_ROOT` 默认 `$HOME` | 便于 CI/测试指向临时目录 | 多一个概念与文档成本 |
| **C. CLI 参数** | 如 `--agent-root=` | 显式、可脚本化 | 选项膨胀，与现有「仅文档路径为位置参数」风格不一致 |

**推荐**：**方案 A** 作为默认行为；若后续有强需求再增加 **B**（本 spec 不实现 B，避免 YAGNI）。

---

## 3. 设计要点

### 3.1 安装路径

- 对每个 `ENABLED_AGENTS` 中的 agent：`agent_dir="$(sdx_abs_path "${HOME:-}")/$(sdx_get_agent_dir "$agent")"`，或等价地使用经 `sdx_strip_trailing_slash` 规范化的 `$HOME`。
- `install_agent_skills` / `install_agent_rules` 中所有原 `CFG[target_dir]/...` 改为上述 `agent_dir`。
- 日志与 `--dry-run` 输出应显示 **绝对路径**，避免误解为工程内路径。

### 3.2 备份与冲突（关键）

现状：`backup_path` 与 `_get_backup_root` 默认将备份放在 **`${CFG[target_dir]}/.docs-init/<时间戳>/`**；若被覆盖路径在 **`$HOME/.cursor/...`**，则 `rel` 会退化为「去首 `/` 的绝对路径残余」，目录结构不合理。

**规定**：

- 为 **Agent 树**（安装到 `$HOME` 下各 `agent` 目录）单独维护备份根：例如 **`$HOME/.docs-init/<同一时间戳>/`**，与工程侧备份 **共用同一时间戳**（在 `main` 入口生成一次 `RUN_STAMP` 或等价变量），便于一次运行对应一份备份集。
- 当 `existing` 位于 `$HOME/$(sdx_get_agent_dir …)/` 下时：`rel` 取 **`${existing#$HOME/}`**（`$HOME` 需与计算 `agent_dir` 时一致、已规范化）。
- `system/` → `docs_abs` 的拷贝若触发备份，仍使用 **工程侧** `${target_dir}/.docs-init/<同一时间戳>/`（与现行为一致，仅统一时间戳来源）。

实现层面可选两种等价策略：

1. 扩展 `backup_path`：根据目标路径前缀选择 `_BACKUP_ROOT`（工程 vs `$HOME`），并相应计算 `rel`；或  
2. 增加 `backup_path_agent` / `_get_backup_root_agent`，仅供 `copy_file`/`copy_dir` 在 Agent 安装阶段调用。

任选其一，以 **行为清晰、无重复备份根逻辑** 为准。

### 3.3 帮助信息与运维文档

- `usage()` 中说明：`.ai/skills`、`.ai/rules` 安装至 **用户主目录** 下对应 Agent 目录，**不**再写入目标工程根。
- `scripts/README.md` 中与「`{agent}/skills` 相对工程根」相关的句子需改为「相对 `$HOME`」或「用户主目录下」。
- `sdx_post_init_checklist` 中「检查 `.cursor/` 或 `.trea/`」一条，改为明确 **在用户主目录**（例如 `~/.cursor`）核对。

### 3.4 测试与验收

- `docs-init --dry-run <某有效 docs 路径>`：输出中 Agent 目标为 `$HOME/.cursor/...`（默认 cursor）。
- 若已存在同名 skill 目录：触发覆盖时，备份出现在 `$HOME/.docs-init/<stamp>/...`，且原 `$HOME/.cursor/...` 被移走而非破坏性地无备份删除（与现 `backup_path` 语义一致）。

---

## 4. 影响面摘要

| 区域 | 影响 |
|------|------|
| 目标工程目录 | 不再出现 `.cursor` / `.trea` / `.claude`（由本脚本写入） |
| 用户主目录 | 新增/更新 `~/.cursor/skills`、`~/.cursor/rules` 等；冲突时 `~/.docs-init/` |
| Central / `SYSTEM_INDEX` | 无变化 |

---

## 5. 自检（Spec review）

- 无 TBD：备份规则与时间戳已写明。
- 与「仅改 Agent 安装根、不改 system 同步」一致。
- 范围：单实现批次可完成；若需 `AGENT_INSTALL_ROOT` 属后续变更。

---

## 6. 实现后下一步

用户审阅本 spec 通过后，使用 **writing-plans** 技能生成实现任务清单，再改 `docs-init.sh` / `docs-config.sh` / `scripts/README.md`。
