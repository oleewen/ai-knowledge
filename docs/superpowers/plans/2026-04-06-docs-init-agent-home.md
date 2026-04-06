# docs-init Agent 安装至用户主目录 — Implementation Plan

> **For agentic workers:** 可按 checkbox 分步执行；本仓库以 Bash 脚本为主，验收以 `bash -n` 与 `--dry-run` 为主。

**Goal:** 将 `.ai/skills`、`.ai/rules` 的安装目标从「工程根下 Agent 目录」改为 **`$HOME` 下对应目录**，并修正覆盖备份路径为 `$HOME/.docs-init/<与工程侧同一时间戳>/`。

**Architecture:** 在 `main` 中生成单次运行的 `DOC_INIT_STAMP`，` _get_backup_root` 与新建的 `_get_backup_root_agent` 共用该时间戳；`backup_path` 根据目标是否位于 `$HOME/.cursor|.trea|.claude` 下选择备份根；`install_agent_*` 使用 `CFG[home_abs]` 拼接 `agent_dir`。

**Tech Stack:** Bash 5+、`docs-config.sh` 中的 `sdx_abs_path` 等工具函数。

---

### Task 1: `scripts/docs-init.sh` — 运行戳、HOME、`backup_path`、Agent 安装路径

**Files:**
- Modify: `scripts/docs-init.sh`

- [x] 在 `CFG` 中增加运行时键 `[home_abs]`（可为空）。
- [x] 增加 `_needs_agent_install`、`_path_is_under_agent_home`、`_BACKUP_ROOT_AGENT`、`_get_backup_root_agent`；`_get_backup_root` 使用 `DOC_INIT_STAMP`。
- [x] `backup_path`：对路径规范化后，若落在 `home_abs` 下 Agent 目录则使用 `_get_backup_root_agent` 与 `rel=${existing#${home_abs}/}`。
- [x] `main`：在写操作前设置 `DOC_INIT_STAMP`；若 scope 需要 Agent 则校验 `HOME` 并设置 `CFG[home_abs]`。
- [x] `install_agent_skills` / `install_agent_rules`：`agent_dir="${CFG[home_abs]}/$(sdx_get_agent_dir …)"`。
- [x] 更新文件头注释与 `usage()`。

---

### Task 2: `scripts/docs-config.sh` — 完成提示清单

**Files:**
- Modify: `scripts/docs-config.sh`（`sdx_post_init_checklist`）

- [x] 将 Agent 配置核对改为用户主目录（如 `~/.cursor`）。

---

### Task 3: `scripts/README.md` — 与行为一致

**Files:**
- Modify: `scripts/README.md`

- [x] Agent 安装目录说明改为相对于 `$HOME`。

---

### Task 4: 规范状态与自检

**Files:**
- Modify: `docs/superpowers/specs/2026-04-06-docs-init-agent-home-design.md`

- [x] 状态改为已实现（若适用）。

---

### 验收命令

```bash
bash -n scripts/docs-init.sh
./scripts/docs-init.sh --dry-run /path/to/existing/docs-dir
```

预期：`信息:` 中 Agent 目录为 `$HOME/.cursor/...` 的绝对路径形式。
