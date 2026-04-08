# `.agent` 对外引用与路径推算结论

**日期**: 2026-04-07  
**状态**: 已落地（脚本统一 + `DOC_ROOT`）  
**范围**: 审计 `.agent` 是否引用非 `.agent` 路径；评估运行时如何推算 `doc-root`、`project-root`（以 **`.docsconfig`** 与 **`docsconfig-bootstrap.sh`** 为 SSOT）。

---

## 1. 审计结论：存在对非 `.agent` 的引用

### 1.1 语义/约定层面的路径（多为正文中的仓库根相对表述）

- **根入口**：`README.md`、`AGENTS.md`、`INDEX_GUIDE.md`（例：`.agent/README.md`、`rules/CONVENTIONS.md`、agent-guide 资产）。
- **系统知识库**：`application/` 下 `DESIGN.md`、`CONTRIBUTING.md`、`INDEX_GUIDE.md`、`knowledge/`、`changelogs/` 等（联邦、archive、docs-build 等技能规范中大量出现）。
- **联邦与初始化**：`applications/`、`scripts/docs-init.sh`、`docs-init`。
- **说明性路径**：`.agent/skills/README.md` 中 skill-creator 副本位置指向 `.agent/skills/skill-creator/`。

### 1.2 Shell 运行时访问的「仓内、但不在 `.agent`」路径

- **`validate-guide.sh`**：解析 `REPO_ROOT`、`DOC_ROOT`；默认 `--root` 为 git 顶层；校验 `README.md` / `AGENTS.md` / `INDEX`（含 `$(basename "$DOC_ROOT")/INDEX_GUIDE.md` 等候选）。
- **`docs-indexing/scripts/indexing.sh`**：`cd "$REPO_ROOT"`；默认输出与 changelog 路径基于 **`DOC_ROOT`**（`${DOC_ROOT}/INDEX_GUIDE.md`、`${DOC_ROOT}/changelogs/...`）。
- **各 `sdx-*/scripts/validate-*.sh`**：`source` **`.agent/scripts/docsconfig-bootstrap.sh`**，**`validate_bootstrap_docsconfig`** 后 **`DOC_ROOT="$(resolve_repo_doc_root …)"`**（与 `.docsconfig` 一致；绝对路径）。

**说明**：`_AI_HOME` 解析为 **`.agent` 目录**（自 `skills/.../scripts` 向上三级），加载 **`.agent/scripts/docsconfig-bootstrap.sh`** 等。

---

## 2. 路径推算结论

### 2.1 已有机制（单一事实来源）

- **目标工程仓库根 `.docsconfig`**（由 **`docs-init`** 写入 **`DOC_ROOT`** / **`REPO_ROOT`** / **`DOC_DIR`**）。
- **`.agent/scripts/docsconfig-bootstrap.sh`**：**`validate_bootstrap_docsconfig`** 加载三键；**`resolve_repo_doc_root`** 供 CLI `--doc-root` 覆盖或与文件内 **`DOC_ROOT`** 对齐。
- **历史**：旧首段探测链 **`sdx-doc-root.sh`** / **`sdx-validate-bootstrap.sh`** 已由 **`.docsconfig`** + **`docsconfig-bootstrap.sh`** 取代；上述脚本已移除。

### 2.2 `project-root`（仓库根）

- **推荐**：以 `git -C <dir> rev-parse --show-toplevel` 为主（与各 `validate-*.sh` 一致）。
- **兜底**（若实现提供）：自路径向上查找 **`.docsconfig`** 或 **`.git`** 以定仓库根，与 `docsconfig-bootstrap.sh` 行为一致；**不再**以「存在 `sdx-doc-root.sh`」为锚。
- **注意**：子模块、特殊 worktree 下两者可能不一致，需在规范中约定**以何种为准**（通常以 git 顶层为准）。

### 2.3 `doc-root` 与 `DOC_ROOT`

- **脚本变量 `DOC_ROOT`**：与 `.docsconfig` 中 **`DOC_ROOT`** 键一致；可选经 **`resolve_repo_doc_root`** 与 `--doc-root` 合成。各 `validate-*.sh` 在 **`validate_bootstrap_docsconfig`** 之后使用上述变量。

### 2.4 Markdown 链接（落地说明）

- **仓库根入口文档**（如根目录 `README.md`、`AGENTS.md`）：链接目标可使用 **`.agent/...`**（相对仓库根）。
- **`.agent/` 内部文件**：链接目标宜为**相对当前文件**的路径（如 `reference/foo.md`、`../../sdx-solution/...`），以便 GitHub 正确解析；规则入口 **`.agent/README.md`**、**`.agent/rules/CONVENTIONS.md`** 使用相对 `.agent/` 子目录的短路径（`rules/`、`../skills/`）。
- 正文中的 `application/...` 等仍可为**仓库根相对表述**（文字），与 shell 变量分工不变。

### 2.5 强校验（`.agent` 内 Markdown 链接边界）

- **`.agent` 内**：可自由引用 `.agent` 目录下文件（目标路径解析后须存在）。
- **跨出 `.agent`**：仅可指向 **`REPO_ROOT` 或 `DOC_ROOT` 目录树内**路径（二者在通常布局下为包含关系：`DOC_ROOT` 多为 `REPO_ROOT` 子树；可执行判定为「落在并集目录树内且文件存在」）。禁止指向 `.git` 等元数据路径。
- **同步场景**：无论 `.agent` 同步到 `REPO_ROOT/.agent` 还是用户目录下的 `~/.cursor/` 等副本，以 **Agent 读可达**（路径语义 + 仓库内实文件）为准；**不要求**在副本或 IDE 中链接可点击打开（与 [链接可达性要求](./2026-04-07-agent-doc-link-reachability-requirements.md) 中「可点击」条款分工）。

---

## 3. 已选策略（已实施）

| 策略 | 内容 |
|------|------|
| **脚本统一** | **`docsconfig-bootstrap.sh`**：`REPO_ROOT` / **`DOC_ROOT`** / **`DOC_DIR`** 来自 `.docsconfig`；`indexing.sh`、`validate-guide.sh` 对齐。 |
| **文档链接** | 根目录文档可用 `.agent/...`；`.agent` 内部以**相对路径**为主，避免在子目录使用 `](.agent/...)` 导致解析为 `.agent/.agent/...`。 |
| **链接校验** | `validate-agent-md-links.sh`：`.agent` 内互链 + 跨边界须 `REPO_ROOT`/`DOC_ROOT`；见 §2.5。 |

---

## 4. 结论摘要

1. **引用存在**：大量指向 `application/`、根 `INDEX_GUIDE` / `AGENTS` 的**文字约定**；若干脚本读写**仓库根**或 **`DOC_ROOT`** 下文件。
2. **推算可行**：**`DOC_ROOT`** 以 `.docsconfig` 为 SSOT，与 `validate-*.sh`、`docs-indexing/scripts/indexing.sh` 行为对齐。
3. **Markdown**：根目录与 `.agent` 内链接按 §2.4 分工，兼顾「根相对」表述与 GitHub 相对解析；强边界见 §2.5。

---

## 5. 参考文件

- `.agent/scripts/docsconfig-bootstrap.sh`（`validate_bootstrap_docsconfig`、`resolve_repo_doc_root`）
- `docs/superpowers/specs/2026-04-08-docsconfig-docs-init-design.md`（`.docsconfig` 权威规格）
- `.agent/skills/sdx-design/scripts/validate-design.sh`（`REPO_ROOT` / `DOC_ROOT`）
- `scripts/README.md`（doc_root 与 `DOC_ROOT` 说明）
- [`.agent` 文档链接可达性要求](./2026-04-07-agent-doc-link-reachability-requirements.md)（Agent 读可达强校验 + 可点击推荐）
