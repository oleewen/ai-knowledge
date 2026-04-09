# docsconfig：`~` 根路径与 `AGENT_*` 键 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 实现 `.docsconfig` 对 `DOC_ROOT`/`REPO_ROOT`/`AGENT_ROOT` 的 C 策略（位于 `$HOME` 下时写 `~/...`）、在 `--scope=config` 落盘 `AGENT_ROOT`/`AGENT_DIRS`，读入侧对 `*_ROOT` 做 `~` 展开，并更新 `docsconfig-bootstrap.sh` 与 `scripts/README.md`；术语替换按 [docs/superpowers/specs/2026-04-09-docsconfig-agent-keys-tilde-design.md](../specs/2026-04-09-docsconfig-agent-keys-tilde-design.md) §4.4 增量处理。

**Architecture:** 路径「绝对 → 写入用 `~/` 或保留绝对」与「读入值 → 绝对路径」集中在 `scripts/docs-config.sh`（复用已有 `abs_path`/`expand_tilde`）；`docsconfig_write` 唯一写出口；`docs-init.sh` 仅在 `scope=config` 时于 `write_target_docsconfig` 之前调用 `apply_agents` 并传入 Agent 元数据；`install_central` 继续使用**内存中**未改写的绝对路径变量（§6），不读 `.docsconfig` 展示串。

**Tech Stack:** Bash 5+；无新增语言依赖。

**Spec:** [2026-04-09-docsconfig-agent-keys-tilde-design.md](../specs/2026-04-09-docsconfig-agent-keys-tilde-design.md)

---

## 文件结构（变更映射）

| 文件 | 职责 |
|------|------|
| `scripts/docs-config.sh` | `docsconfig_format_root_for_write`、`docsconfig_expand_value_for_read`（或内联 `expand_tilde`）；扩展 `docsconfig_write`、`docsconfig_read_into`、`docsconfig_grep_keys` |
| `scripts/docs-init.sh` | `scope=config`：`apply_agents` → `write_target_docsconfig`；`write_target_docsconfig` 内组装 Agent 元数据并调用新 `docsconfig_write`；非 config 末段写 `.docsconfig` 仍走同一 `write_target_docsconfig`（不写 `AGENT_*`） |
| `.agent/scripts/docsconfig-bootstrap.sh` | `docsconfig_parse_into_globals`：识别 `AGENT_ROOT`/`AGENT_DIRS`；`*_ROOT` 赋值后展开 `~`；文件头注释补充变量说明 |
| `scripts/README.md` | `.docsconfig` 键列表、`~` 与 `AGENT_*` 一句说明 |
| （可选后续）`.agent/`、`application/` 等 | §4.4 术语替换，独立提交 |

---

### Task 1：`docs-config.sh` — 写入格式化与 `docsconfig_write`

**Files:**
- Modify: `scripts/docs-config.sh`（`.docsconfig` 区块，约 370–482 行）

- [ ] **Step 1：实现 `docsconfig_format_root_for_write`**

在 `# .docsconfig` 一节**之前**（或紧接 `abs_path` 之后）新增：

```bash
# 将绝对路径格式化为写入 .docsconfig 的 *_ROOT 值（C 策略）
# Usage: docsconfig_format_root_for_write <abs_path>
# stdout: ~/... 或不在 $HOME 下时为绝对路径
docsconfig_format_root_for_write() {
    local p home
    p="$(strip_trailing_slash "$(abs_path "${1:?}")")"
    [[ -n "${HOME:-}" ]] || { printf '%s\n' "$p"; return 0; }
    home="$(strip_trailing_slash "$(abs_path "$HOME")")"
    [[ -n "$home" ]] || { printf '%s\n' "$p"; return 0; }
    if [[ "$p" == "$home" ]]; then
        printf '~\n'
    elif [[ "$p" == "$home"/* ]]; then
        printf '~/%s\n' "${p#"$home"/}"
    else
        printf '%s\n' "$p"
    fi
}
```

- [ ] **Step 2：重写 `docsconfig_write` 签名与实现**

将原三键写入改为：对 `repo_root`、`doc_root` 先传入 `docsconfig_format_root_for_write`；`DOC_DIR` **不**做 tilde（相对段）。  
增加可选参数：第 5、6 个参数为 **`agent_root_abs`**（绝对路径，可为空）、**`agent_dirs_quoted`**（空格分隔的目录名，如 `.cursor .claude`，可为空）。

行为：

- 总是写出：`DOC_ROOT=`、`REPO_ROOT=`、`DOC_DIR=`（前两键为格式化后的 `~/` 或绝对路径）。
- 当且仅当 **`agent_root_abs` 非空** 时写出 `AGENT_ROOT=`（格式化后）与 `AGENT_DIRS="..."`（值用双引号包裹，内部空格分隔）。

`dry_run=1` 时 `printf` 预览与实写相同行结构。

```bash
# Usage: docsconfig_write <repo_root_abs> <doc_root_abs> <doc_dir> <dry:0|1> [agent_root_abs] [agent_dirs_space_separated]
docsconfig_write() {
    local repo_root="${1:?repo_root}" doc_root="${2:?doc_root}" doc_dir="${3:?doc_dir}" dry="${4:-0}"
    local agent_root_in="${5:-}" agent_dirs_in="${6:-}"
    local out rr dr ar line
    out="$(strip_trailing_slash "$(abs_path "$repo_root")")/.docsconfig"
    rr="$(docsconfig_format_root_for_write "$repo_root")"
    dr="$(docsconfig_format_root_for_write "$doc_root")"
    if [[ "$dry" == "1" ]]; then
        printf 'Would write %s:\nDOC_ROOT=%s\nREPO_ROOT=%s\nDOC_DIR=%s\n' \
            "$out" "$dr" "$rr" "$doc_dir"
        if [[ -n "$agent_root_in" ]]; then
            ar="$(docsconfig_format_root_for_write "$agent_root_in")"
            printf 'AGENT_ROOT=%s\nAGENT_DIRS="%s"\n' "$ar" "$agent_dirs_in"
        fi
        return 0
    fi
    umask 022
    {
        printf 'DOC_ROOT=%s\nREPO_ROOT=%s\nDOC_DIR=%s\n' "$dr" "$rr" "$doc_dir"
        if [[ -n "$agent_root_in" ]]; then
            ar="$(docsconfig_format_root_for_write "$agent_root_in")"
            printf 'AGENT_ROOT=%s\nAGENT_DIRS="%s"\n' "$ar" "$agent_dirs_in"
        fi
    } >"$out"
}
```

（若与仓库现有 `docsconfig_write` 行号合并，保留 `umask`/`printf` 风格一致即可。）

- [ ] **Step 3：提交**

```bash
git add scripts/docs-config.sh
git commit -m "feat(docsconfig): *_ROOT 写入 ~/ 形式并支持 AGENT_* 可选键"
```

---

### Task 2：`docs-config.sh` — `docsconfig_read_into` 与 `docsconfig_grep_keys`

**Files:**
- Modify: `scripts/docs-config.sh`

- [ ] **Step 1：实现读入后展开（复用 `expand_tilde`）**

在解析每行 `KEY=value` 后：

- 对 `DOC_ROOT`、`REPO_ROOT`、`AGENT_ROOT`（若存在）的值调用 `expand_tilde` 再 `abs_path`（或与现有 bootstrap 一致：仅 `expand_tilde` 若已绝对）。

建议统一辅助函数：

```bash
# Usage: docsconfig_normalize_root_value <raw_value>
# stdout: 绝对路径，供脚本使用
docsconfig_normalize_root_value() {
    local v="${1:-}"
    v="${v%$'\r'}"
    printf '%s' "$(abs_path "$(expand_tilde "$v")")"
}
```

- [ ] **Step 2：扩展 `docsconfig_read_into`**

增加可选 nameref 参数 5、6：`AGENT_ROOT`、`AGENT_DIRS`（字符串，展开后 `AGENT_ROOT` 为绝对路径；`AGENT_DIRS` 保留为去引号后的 `"a b c"` 字符串，供 `for d in $AGENT_DIRS` 使用）。  
`case "$line" in` 增加 `AGENT_ROOT=* | AGENT_DIRS=*)`。  
解析 `AGENT_DIRS` 时去掉首尾空白；若值以 `"` 包裹则去掉引号。

若调用方只传 4 个 nameref，后两者可省略（Bash 可用 `$#` 判断或固定传占位）。

- [ ] **Step 3：更新 `docsconfig_grep_keys`**

```bash
grep -E '^(DOC_ROOT|REPO_ROOT|DOC_DIR|AGENT_ROOT|AGENT_DIRS)=' "$path"
```

- [ ] **Step 4：提交**

```bash
git add scripts/docs-config.sh
git commit -m "feat(docsconfig): 读入 *_ROOT 时展开 ~ 并解析 AGENT_*"
```

---

### Task 3：`docs-init.sh` — `scope=config` 顺序与 `write_target_docsconfig`

**Files:**
- Modify: `scripts/docs-init.sh`（`write_target_docsconfig`、`main` 中 `scope=config` 分支）

- [ ] **Step 1：在 `scope=config` 分支中，`validate_docs_and_target` 之后、`write_target_docsconfig` 之前调用 `apply_agents`**

确保 `CFG[home_abs]` 在需要时可用：若 `apply_agents` 不依赖 `HOME`，可仅在计算 Agent 根时用 `abs_path "${CFG[target_dir]}"`（有 `docs_abs` 时与 `agent_install_root` 的父目录一致）。

- [ ] **Step 2：扩展 `write_target_docsconfig`**

在已有 `repo_target`、`doc_root`、`dd` 计算完成后：

- 若 **`${CFG[scope]}" == "config"`**：  
  - `agent_root_abs="$(abs_path "${CFG[target_dir]}")"`  
  - 构建 `agent_dirs_in`：对 `"${ENABLED_AGENTS[@]}"` 逐个 `get_agent_dir "$a"`，空格连接（顺序与 `ENABLED_AGENTS` 一致）。  
  - 调用 `docsconfig_write "$repo_target" "$doc_root" "$dd" "${CFG[dry_run]}" "$agent_root_abs" "$agent_dirs_in"`
- **否则**（`ck`/`all`/`knowledge` 末次写）：  
  - `docsconfig_write "$repo_target" "$doc_root" "$dd" "${CFG[dry_run]}"`（不传第 5、6 参数，不写 `AGENT_*`）。

- [ ] **Step 3：手动快速校验（非自动化）**

在临时目录创建最小 git 仓库与 `docs` 子目录，`HOME` 下路径时：

```bash
bash /path/to/ai-knowledge/scripts/docs-init.sh --scope=config --agents=cursor,claude /path/to/proj/docs
grep -E '^(DOC_ROOT|REPO_ROOT|AGENT_)' /path/to/proj/.docsconfig
```

**期望：** `DOC_ROOT`/`REPO_ROOT`/`AGENT_ROOT` 以 `~/` 开头（当工程在用户主目录下）；`AGENT_DIRS=".cursor .claude"`。

- [ ] **Step 4：提交**

```bash
git add scripts/docs-init.sh
git commit -m "feat(docs-init): config 作用域写入 AGENT_ROOT/AGENT_DIRS 并先 apply_agents"
```

---

### Task 4：`.agent/scripts/docsconfig-bootstrap.sh`

**Files:**
- Modify: `.agent/scripts/docsconfig-bootstrap.sh`

- [ ] **Step 1：文件头注释**

在「Source 成功后」列表中增加：`AGENT_ROOT`、`AGENT_DIRS`（说明：`AGENT_ROOT` 展开后为绝对路径；`AGENT_DIRS` 为去引号后的空格分隔目录名）。

- [ ] **Step 2：扩展 `docsconfig_parse_into_globals`**

- 初始化：`AGENT_ROOT=""`、`AGENT_DIRS=""`。
- `case "$line" in` 增加 `AGENT_ROOT=* | AGENT_DIRS=*)`。
- 赋值后：`AGENT_ROOT="$(docsconfig_normalize_root_value "$AGENT_ROOT")"` — **注意**：`docsconfig_normalize_root_value` 若定义在 `docs-config.sh`，bootstrap **不能**直接调用，除非 `source`。当前 bootstrap **独立**解析，应在 bootstrap 内**内联**与 `docs-init` 相同的 `expand_tilde` + `abs_path` 逻辑（复制 `expand_tilde` 片段或最小重复），避免对 `docs-config.sh` 的依赖链。

**推荐：** 在 `docsconfig-bootstrap.sh` 顶部增加与 `docs-config.sh` 一致的 **`expand_tilde` + `abs_path` 最小实现**，或 `source` 目标工程**不**适用——bootstrap 运行在**目标工程**侧，可能无 `scripts/docs-config.sh`。因此 **必须在 bootstrap 内实现 `~` 展开**（复制自模板库 `docs-config.sh` 中 `expand_tilde` 与单行 `abs_path` 逻辑，或嵌入 `docsconfig_normalize_root_value` 的 10 行版本）。

- [ ] **Step 3：提交**

```bash
git add .agent/scripts/docsconfig-bootstrap.sh
git commit -m "feat(docsconfig): bootstrap 解析 AGENT_* 并展开 *_ROOT"
```

---

### Task 5：`scripts/README.md`

**Files:**
- Modify: `scripts/README.md`（`.docsconfig` 小节）

- [ ] **Step 1：增加一段话**

说明：`.docsconfig` 含 `DOC_ROOT`、`REPO_ROOT`、`DOC_DIR`；可选 `AGENT_ROOT`、`AGENT_DIRS`（由 `docs-init --scope=config` 写入）；`*_ROOT` 在位于用户主目录下时为 `~/...`；消费方应对值展开 `~`。

- [ ] **Step 2：提交**

```bash
git add scripts/README.md
git commit -m "docs(scripts): 说明 .docsconfig 五键与 ~ 约定"
```

---

### Task 6：术语与文档（§4.4，可独立 PR）

**Files:**
- 可能涉及：根目录 `README.md`、`AGENTS.md`、`INDEX_GUIDE.md`，`.agent/`、`application/`、`system/`、`company/`、`scripts/` 下符合 spec **边界**的段落

- [ ] **Step 1：检索**

```bash
rg -n "工程根|文档根|\\.cursor|\\.claude|REPO_ROOT|DOC_ROOT" --glob '*.md' .agent application system company scripts README.md AGENTS.md INDEX_GUIDE.md 2>/dev/null | head -80
```

- [ ] **Step 2：按 spec §4.4「边界」逐条判断是否替换**，避免把「本仓库 `application/` 模板」改成 `DOC_ROOT`。

- [ ] **Step 3：提交**（可多条 commit）

```bash
git add -p
git commit -m "docs: 对齐 .docsconfig 术语（DOC_* / AGENT_*）"
```

---

## Self-review（对照 spec）

| Spec 章节 | 对应 Task |
|-----------|-----------|
| §3 C 策略写入 | Task 1 |
| §4 `AGENT_*` + `scope=config` 顺序 | Task 3 |
| §5 读入展开 | Task 2、4 |
| §6 central 绝对路径 | 显式不改为读文件；`install_central` 仍用 `CFG[docs_abs]` |
| §7 dry-run | Task 1 `dry` 分支 |
| §8 检查清单 | Task 1–5 + Task 6 |
| §4.4 术语 | Task 6 |

**占位符扫描：** 本计划无 TBD/TODO 实现步骤。

**一致性：** `docsconfig_write` 第 5、6 参数仅在 Task 1/3 与调用处一致；`AGENT_DIRS` 始终带引号写出。

---

## Execution handoff

**计划已保存至：** `docs/superpowers/plans/2026-04-09-docsconfig-tilde-agent-keys.md`（若目录被 gitignore，使用 `git add -f`）。

**两种执行方式：**

1. **Subagent-Driven（推荐）** — 每任务派生子代理，任务间人工复核，迭代快  
2. **Inline Execution** — 本会话内按任务执行，批量推进并设检查点  

**请选择：** 回复 `1` 或 `2`。若选 1，请配合使用 **subagent-driven-development** 技能逐任务实现。
