# `.docsconfig` 与 `docs-init` 整合 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 在目标工程仓库根落盘 `.docsconfig`（`DOC_ROOT` / `REPO_ROOT` / `DOC_DIR`），由 `docs-init` 写入；运行时 `validate-*.sh` 通过新 bootstrap 解析该文件；删除 `sdx-doc-root.sh` 与 `sdx-validate-bootstrap.sh`；实现策略 **D**（缺 `.docsconfig`）与 **§4.2.1**（缺 `DOC_DIR`）的交互/非交互行为。

**Architecture:** 所有「由 `DOC_ROOT` 推算 `REPO_ROOT` + `DOC_DIR`」的纯逻辑集中在 `scripts/docs-config.sh`；`docs-init.sh` 在满足 §2.3 时调用写入；`.agent/scripts/docsconfig-bootstrap.sh` 实现 §4.1.1 解析 + §4.2 / §4.2.1 确认流（不 `export` 关键变量）；各 skill 的 `validate-*.sh` 改为 `source` 新 bootstrap，从 `.docsconfig` 读取并赋值 **`DOC_ROOT`**（及 `REPO_ROOT`、`DOC_DIR`）。

**Tech Stack:** Bash 5+、`git`、`python3`（`validate-agent-md-links.sh` 保持 Python 校验段）。

**权威规格:** `docs/superpowers/specs/2026-04-08-docsconfig-docs-init-design.md`

---

## 文件结构（创建 / 修改一览）

| 路径 | 职责 |
|------|------|
| `scripts/docs-config.sh` | 新增：`.docsconfig` 读写、`DOC_ROOT`→`REPO_ROOT`/`DOC_DIR` 推算、路径工具（不 `export`） |
| `scripts/docs-init.sh` | 新增：`--scope=config`/`c` 分支、在满足 §2.3 时写入 `.docsconfig`、`config` 与 `central` 组合拒绝或文档化 |
| `scripts/README.md` | 更新：`doc_root` / `.docsconfig` / `--scope=c` 说明 |
| `.agent/scripts/docsconfig-bootstrap.sh` | **新建**：§4.1.1 解析、加载 `.docsconfig`、策略 D / §4.2.1 |
| `.agent/scripts/validate-agent-md-links.sh` | 改为走 `.docsconfig` + 前缀传参给 Python（取消 `export` 敏感变量或按 §2.2.2） |
| `.agent/skills/*/scripts/validate-*.sh`（7 个 skill + 根下 `validate-agent-md-links` 已单列） | `source` 新 bootstrap；注释更新 |
| `.agent/scripts/sdx-doc-root.sh` | **已删除** |
| `.agent/scripts/sdx-validate-bootstrap.sh` | **已删除** |
| `.agent/README.md`、`INDEX_GUIDE.md`（若仍引用旧脚本） | 更新指针 |
| `docs/superpowers/specs/2026-04-07-agent-external-refs-path-resolution-design.md` | 按规格 §5 增加「已由 `.docsconfig` 取代」短段 |

**说明:** `docs-indexing/scripts/indexing.sh` 若 `source` 旧 bootstrap，一并改为新文件（grep 全仓库 `sdx-validate-bootstrap` 清零）。

---

### Task 1: `docs-config.sh` — 核心推算与读写

**Files:**
- Modify: `scripts/docs-config.sh`
- Test: `bash -n scripts/docs-config.sh`

- [ ] **Step 1: 在 `docs-config.sh` 末尾添加函数（命名可与下表等价）**

```bash
# 由 DOC_ROOT 得 REPO_ROOT（§3.3 推荐 (a)：失败则返回空）
docsconfig_repo_root_from_doc_root() {
  local doc_root="${1:?doc_root}"
  git -C "$doc_root" rev-parse --show-toplevel 2>/dev/null || true
}

# 由 REPO_ROOT + DOC_ROOT 得 DOC_DIR（相对段，仓库根与文档根重合时为 "."）
docsconfig_doc_dir_from_roots() {
  local repo_root="${1:?repo_root}"
  local doc_root="${2:?doc_root}"
  local rr dr
  rr="$(cd -P "$repo_root" 2>/dev/null && pwd)" || { printf '%s\n' "无法解析 REPO_ROOT: $repo_root" >&2; return 1; }
  dr="$(cd -P "$doc_root" 2>/dev/null && pwd)" || { printf '%s\n' "无法解析 DOC_ROOT: $doc_root" >&2; return 1; }
  case "$dr" in
    "$rr") printf '%s\n' '.' ;;
    "$rr"/*) printf '%s\n' "${dr#"$rr"/}" ;;
    *) printf '%s\n' "DOC_ROOT 不在 REPO_ROOT 下: $dr vs $rr" >&2; return 1 ;;
  esac
}

# 写入 $REPO_ROOT/.docsconfig（三行 KEY=value，UTF-8）
# 签名: docsconfig_write <repo_root> <doc_root> <doc_dir> [dry_run:0|1]
docsconfig_write() {
  local repo_root="${1:?repo_root}" doc_root="${2:?doc_root}" doc_dir="${3:?doc_dir}"
  local dry="${4:-0}" out="$repo_root/.docsconfig"
  if [[ "$dry" == "1" ]]; then
    printf 'Would write %s:\nDOC_ROOT=%s\nREPO_ROOT=%s\nDOC_DIR=%s\n' "$out" "$doc_root" "$repo_root" "$doc_dir"
    return 0
  fi
  umask 022
  printf 'DOC_ROOT=%s\nREPO_ROOT=%s\nDOC_DIR=%s\n' "$doc_root" "$repo_root" "$doc_dir" >"$out"
}

# 解析已有文件：见 docsconfig_read_into / docsconfig_grep_keys（已实现）
```

- [ ] **Step 2: 实现 `docsconfig_doc_dir_from_roots`**

逻辑：`realpath "$repo_root"` 与 `realpath "$doc_root"`；若 `doc_root` 等于 `repo_root`，输出 `.`；否则输出相对路径（`doc_root` 须在 `repo_root` 下，否则实现应报错退出，与 §3.3 推荐 (a) 一致）。

- [ ] **Step 3: 实现 `docsconfig_write`**

非 dry-run：`mkdir -p` 不必要（文件在已有仓库根）。写入：

```text
DOC_ROOT=/abs/path
REPO_ROOT=/abs/path
DOC_DIR=relative/or/dot
```

- [ ] **Step 4: 语法检查**

Run: `bash -n scripts/docs-config.sh`  
Expected: 无输出，退出码 0

- [ ] **Step 5: Commit**

```bash
git add scripts/docs-config.sh
git commit -m "feat(docs-config): 增加 .docsconfig 读写与 DOC_ROOT 推算函数"
```

---

### Task 2: `docs-init.sh` — `--scope=config` / `c` 与写入钩子

**Files:**
- Modify: `scripts/docs-init.sh`（`parse_args`、`_validate_sync_scope`、`main`）
- Test: `bash -n scripts/docs-init.sh`；手工：`docs-init.sh --dry-run --scope=c <path>`

- [ ] **Step 1: 扩展 `_validate_sync_scope`**

在 `case` 规范化中增加：`c|config) CFG[scope]=config ;;`（或统一为字面 `config`）。**禁止**与现有 `s`→`skills` 冲突：`c` 仅表示 config。

- [ ] **Step 2: `usage` 与 `parse_args`**

在 `--scope` 说明中增加 `config(c)`；确保 `CFG[scope]` 可解析为 `config`。

- [ ] **Step 3: `config` + `central` 组合**

在 `main` 中于早期加入：若 `CFG[scope]==config` 且 `CFG[mode]==central`，`error "无效组合: --scope=config 不与 central 混用"`（与规格 §3.1「推荐拒绝」一致）。

- [ ] **Step 4: `config` 仅写盘分支**

在 `main` 中，在 `_validate_agents` 之前或之后（保持可读性）：若 `scope=config`：

1. 要求 `CFG[docs_abs]` 非空，否则 `error`。
2. 若 `dry_run`，打印将写入的 `.docsconfig` 内容并 `_print_checklist` 或简化退出。
3. 否则：`REPO_TARGET=$(docsconfig_repo_root_from_doc_root "${CFG[docs_abs]}")`；空则 `error`（§3.3 (a)）。
4. `DOC_DIR=$(docsconfig_doc_dir_from_roots "$REPO_TARGET" "${CFG[docs_abs]}")`。
5. `docsconfig_write "$REPO_TARGET" "${CFG[docs_abs]}" "$DOC_DIR"`。
6. `exit 0`（**不**调用 `install_system_to_docs` / `install_agent_*`）。

- [ ] **Step 5: `all` / `knowledge` 等同场写入**

在现有成功同步路径前或后（建议：`install_system_to_docs` 之前，且 `docs_abs` 已校验）：若 `scope` 为 `all|knowledge|...` 且满足规格 §2.3（非 dry-run、有 `docs_abs`），调用同一套写入函数；若已存在 `.docsconfig` 且缺 `DOC_DIR`，按 §3.2 步骤 1 补算并写回。

- [ ] **Step 6: 语法检查与 dry-run**

Run: `bash -n scripts/docs-init.sh`  
Run: `bash scripts/docs-init.sh --dry-run --scope=c "$(pwd)/application" 2>&1 | head`（路径按本仓库可调）

- [ ] **Step 7: Commit**

```bash
git add scripts/docs-init.sh
git commit -m "feat(docs-init): 支持 --scope=config 并写入 .docsconfig"
```

---

### Task 3: `docsconfig-bootstrap.sh` — 运行时解析与策略 D / §4.2.1（原 `sdx-docsconfig-bootstrap.sh`）

**Files:**
- Create: `.agent/scripts/docsconfig-bootstrap.sh`
- Modify: 各 `validate-*.sh`（下一步）

- [ ] **Step 1: 实现 `resolve_repo_doc_root` 兼容层**

规格要求 validate 仍可能调用 `resolve_repo_doc_root`（旧名 `sdx_resolve_repo_doc_root`）：在新 bootstrap 内 **定义**该函数，语义为返回文档根绝对路径（与 `.docsconfig` 的 **`DOC_ROOT`** 键及旧名 **`REPO_DOC_ROOT`** 对齐）；若尚未加载成功，行为与调用方约定（可先返回空并由调用方 `error`）。

- [ ] **Step 2: 实现 §4.1.1 `REPO_ROOT` 解析**

顺序：`git -C "$PWD"` → `git -C "$script_dir"` → 自 `$PWD` 向上最多 N 层（如 32）找 `/.docsconfig`。找到则 `REPO_ROOT` 为所在目录。

- [ ] **Step 3: 加载 `.docsconfig`**

解析 `DOC_ROOT`、`REPO_ROOT`、`DOC_DIR`（简单 `KEY=value` 行解析即可）。**不** `export DOC_ROOT`/`REPO_ROOT`/`DOC_DIR`（§2.2.2）。

- [ ] **Step 4: 策略 D — 无文件**

若仍无 `REPO_ROOT/.docsconfig`：若 `[[ -t 0 ]]`，打印说明并 `read -r` 确认是否代为执行 `docs-init.sh --scope=c "<DOC_ROOT_HINT>"`（`DOC_ROOT_HINT` 可用 `PWD` 推导的候选路径，规格允许「实现 PR 为准」）；非交互打印命令并 `exit 1`。

- [ ] **Step 5: §4.2.1 — 缺 `DOC_DIR`**

若文件存在但 `DOC_DIR` 为空：交互强制确认 `docs-init.sh --scope=c ...`；拒绝 → `exit 1`；非交互 → 打印命令 `exit 1`。**不**内存补算后继续。

- [ ] **Step 6: 提供入口函数供 validate 调用**

例如：`validate_bootstrap_docsconfig "$SCRIPT_DIR"`，内部完成解析/确认，并设置 shell 变量（非 export）`DOC_ROOT`、`REPO_ROOT`、`DOC_DIR`（不再单独设置 `REPO_DOC_ROOT`）。

- [ ] **Step 7: 语法检查**

Run: `bash -n .agent/scripts/docsconfig-bootstrap.sh`

- [ ] **Step 8: Commit**

```bash
git add .agent/scripts/docsconfig-bootstrap.sh
git commit -m "feat(agent): 新增 docsconfig-bootstrap 与 .docsconfig 运行时加载"
```

---

### Task 4: 替换所有 `validate-*.sh` 与 `indexing.sh` 的 bootstrap

**Files:**
- Modify:  
  `.agent/skills/sdx-test/scripts/validate-test.sh`  
  `.agent/skills/agent-guide/scripts/validate-guide.sh`  
  `.agent/skills/docs-build/scripts/validate-extraction.sh`  
  `.agent/skills/sdx-analysis/scripts/validate-analysis.sh`  
  `.agent/skills/sdx-design/scripts/validate-design.sh`  
  `.agent/skills/sdx-prd/scripts/validate-prd.sh`  
  `.agent/skills/sdx-solution/scripts/validate-solution.sh`  
  `.agent/skills/docs-indexing/scripts/indexing.sh`（若 source 旧文件）

- [ ] **Step 1: 全局替换 source 路径**

```bash
# 自各 validate 脚本目录计算 _AI_HOME 后：
source "$_AI_HOME/scripts/docsconfig-bootstrap.sh"
validate_bootstrap_docsconfig "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
```

（保持与现有 `_AI_HOME` 解析方式一致。）

- [ ] **Step 2: 更新文件头注释**

删除指向 `sdx-doc-root.sh` 的旧说明，改为「见 `.docsconfig` 与 `docsconfig-bootstrap.sh`」。

- [ ] **Step 3: 单脚本试跑**

Run: `bash .agent/skills/sdx-solution/scripts/validate-solution.sh`  
Expected: 在本仓库根且已有 `.docsconfig` 时通过；无文件时进入 D 流程或按实现退出（与规格一致）。

- [ ] **Step 4: Commit**

```bash
git add .agent/skills/*/scripts/*.sh
git commit -m "refactor(validate): 改用 docsconfig-bootstrap"
```

---

### Task 5: `validate-agent-md-links.sh` — Python 段与 `.docsconfig`

**Files:**
- Modify: `.agent/scripts/validate-agent-md-links.sh`

- [ ] **Step 1: 移除对 `sdx-doc-root.sh` 的 source**

改为 source `docsconfig-bootstrap.sh` 并设置 `DOC_ROOT`（或仅前缀传参）。

- [ ] **Step 2: Python 入参**

按 §2.2.2，使用：

```bash
DOC_ROOT="$DOC_ROOT" REPO_ROOT="$REPO_ROOT" DOC_DIR="$DOC_DIR" python3 -c '...'
```

或在 `python3` 前内联 `env` 单行；**删除** `export REPO_DOC_ROOT` 若规格禁止；Python 内以 `DOC_ROOT` 为文档根键名更新 `os.environ` 与 `is_under` 逻辑（`doc_root` 语义不变）。

- [ ] **Step 3: 运行校验**

Run: `bash .agent/scripts/validate-agent-md-links.sh`  
Expected: 退出码 0（无 broken link 时）。

- [ ] **Step 4: Commit**

```bash
git add .agent/scripts/validate-agent-md-links.sh
git commit -m "fix(validate): agent-md-links 使用 .docsconfig 变量"
```

---

### Task 6: 删除旧脚本并全局扫残留

**Files:**
- Delete: `.agent/scripts/sdx-doc-root.sh`, `.agent/scripts/sdx-validate-bootstrap.sh`

- [x] **Step 1: 全仓库 grep**

Run: `rg 'sdx-doc-root|sdx-validate-bootstrap' --glob '*.sh' --glob '*.md'`  
Expected: `*.sh` 无匹配；`*.md` 仅保留历史/迁移叙述或本计划中的自检说明。

- [x] **Step 2: 删除文件并提交**

```bash
git rm .agent/scripts/sdx-doc-root.sh .agent/scripts/sdx-validate-bootstrap.sh
git commit -m "chore(agent): 移除 sdx-doc-root 与 sdx-validate-bootstrap"
```

---

### Task 7: 文档与索引

**Files:**
- Modify: `scripts/README.md`, `.agent/README.md`, `INDEX_GUIDE.md`（仅当仍列旧脚本）
- Modify: `docs/superpowers/specs/2026-04-07-agent-external-refs-path-resolution-design.md`

- [ ] **Step 1: `scripts/README.md`**

说明 `.docsconfig` 位置、`--scope=c`、与 `DOC_ROOT`/`REPO_ROOT`/`DOC_DIR` 语义；删除「sdx-doc-root 为单一事实来源」类表述。

- [ ] **Step 2: `.agent/README.md`**

列出 `docsconfig-bootstrap.sh`，删除对已删脚本的依赖说明。

- [ ] **Step 3: 外部引用规格短段**

在 `2026-04-07-agent-external-refs-path-resolution-design.md` 增加指向 `2026-04-08-docsconfig-docs-init-design.md` 的 supersede 说明（§5）。

- [ ] **Step 4: Commit**

```bash
git add scripts/README.md .agent/README.md docs/superpowers/specs/2026-04-07-agent-external-refs-path-resolution-design.md INDEX_GUIDE.md
git commit -m "docs: 同步 .docsconfig 与 validate 引导说明"
```

---

### Task 8: 实施自检（§6）与回归

- [ ] **Step 1: 在本仓库根生成 `.docsconfig`**

Run: `bash scripts/docs-init.sh --scope=c "$(pwd)/application"`（路径按实际文档根调整）

- [ ] **Step 2: 校验内容**

`cat .docsconfig`：`DOC_ROOT`/`REPO_ROOT`/`DOC_DIR` 与 §2.2.1 一致。

- [ ] **Step 3: 跑全部 validate 脚本**

逐个执行 Task 4 列表中的脚本，确认退出码 0。

- [ ] **Step 4: 最终 commit（若仅有小修正）**

---

## Self-Review（计划作者自检）

| 规格章节 | 对应 Task |
|----------|-----------|
| §2 格式、禁止 export | Task 1、5 |
| §2.3 写入条件 | Task 2 |
| §3.2 / §3.3 写入顺序与 git 失败 | Task 1–2 |
| §4.1.1 解析顺序 | Task 3 |
| §4.2 / §4.2.1 | Task 3 |
| §4.4 validate-agent-md-links | Task 5 |
| §5 文档 | Task 7 |
| 删除旧脚本 | Task 6 |

**占位符扫描:** Task 3 交互流程需按规格写满 `read`/提示文案；不得留 `TBD`。

**类型/命名:** `REPO_ROOT`（目标工程）与 `CFG[repo_root]`（模板仓库）在 `docs-init.sh` 中不得混用变量名——Task 2 应用 `local` 或 `TARGET_REPO` 等区分。

---

## Execution Handoff

**计划已保存至:** `docs/superpowers/plans/2026-04-08-docsconfig-docs-init-implementation.md`

**两种执行方式：**

1. **Subagent-Driven（推荐）** — 每个 Task 派生子代理，Task 间人工复核，迭代快  
2. **Inline Execution** — 本会话用 executing-plans 批量执行并设检查点  

**请选择其一。**

若选 Subagent-Driven：**必须**配合使用 **subagent-driven-development** 技能；若选 Inline：**必须**配合 **executing-plans** 技能。
