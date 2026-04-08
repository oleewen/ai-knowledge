# `.agent` 文档链接可达性要求

**日期**: 2026-04-07  
**状态**: 已落地（见 `.agent/rules/CONVENTIONS.md` §二-1、`.agent/scripts/validate-agent-md-links.sh`）  
**适用**: `.agent/skills/`、`.agent/rules/` 等会经 `docs-init` 同步到 `~/.{agent}/` 的 Markdown；以及人类/Agent 在 **ai-knowledge** 或 **目标工程仓库** 内阅读时。

---

## 1. 目标（分层：强校验 vs 推荐）

### 1.1 Agent 读可达（**强校验**）

- **含义**：Agent 在上下文中加载 Skill/规则（含同步到 `~/.cursor/skills/` 等副本）时，能通过**路径语义**定位到正确资源：要么在同一技能树内可解析，要么在说明中明确「相对何处的仓库根 / 文档根」。
- **检验**：不出现仅依赖「当前工作目录碰巧是仓库根」才能理解的裸路径；跨树引用须有稳定锚点（相对 skills 的 `../`、或下文规定的仓库根相对写法）。
- **边界（跨出 `.agent`）**：`.agent` 目录下文件可**自由**互链 `.agent` 内资源；指向非 `.agent` 时，解析后的路径须落在 **`REPO_ROOT` 或 `DOC_ROOT` 目录树内**（见 `resolve_repo_doc_root`），且目标文件在**本仓库克隆**中存在。无论 `.agent` 位于 `REPO_ROOT/.agent` 还是同步到用户目录下的副本，均以 **Agent 可读可达**为准。
- **自动化**：仓库根执行 `bash .agent/scripts/validate-agent-md-links.sh` 落实上述存在性与边界（含禁止链接 `.git`）。

### 1.2 仓库内阅读可通过链接打开（**推荐**，非跨边界硬门禁）

- **含义**：在 **ai-knowledge** 或 **目标工程** 克隆中，用编辑器/GitHub 打开 `.agent/...` 下 Markdown 时，`[text](path)` 中 **path** 能解析为仓库内真实文件（或本仓库约定存在的路径），便于人类点链浏览。
- **检验**：在仓库根为工作区根时，链接目标存在；避免在 skills 子目录使用会被解析成「`skills/某技能/application/...`」这类错误基目录的短链（见 §3）。
- **与 §1.1 的关系**：对**跨出 `.agent`** 的引用，**不**将「IDE/GitHub 可点击」作为脚本强门禁；以 §1.1 的存在性与 `REPO_ROOT`/`DOC_ROOT` 边界为准。树内 L1/L2 仍建议兼顾可点击与 Agent 双稳。

---

## 2. 非目标（本规范不承诺）

- **不保证**仅打开 `~/.cursor/` 下副本、**不**打开工程仓库时，所有外链均可单击直达（该场景以 SKILL 步骤与 Agent 检索为主，见 `docs-init` 安装说明）。
- **不替代** `docs-init` 对 `.agent/` → `.cursor/` 等字面替换；二者叠加：字面前缀由脚本替换，**链接结构**由本规范约束。

---

## 3. 链接写法分层

| 层级 | 场景 | 要求 |
|------|------|------|
| **L1 技能树内** | 同技能 `reference/`、`assets/`、`SKILL.md` 互链 | 使用**相对当前文件的**路径（如 `reference/foo.md`、`../assets/bar.md`）。同步到 `~/.cursor/skills/<name>/` 后结构不变，**Agent 与仓库内双击均稳定**。 |
| **L2 跨技能（仍在 `.agent/skills/`）** | 引用其他技能的文档 | 使用**相对当前文件的** `../../<other-skill>/...`（或等价层数）。禁止依赖「从仓库根起算」却写成无 `../` 的 `<other-skill>/...`（在子目录会断）。 |
| **L3 仓库根资源** | `application/`、`docs/`、`scripts/`、`README.md` 等 | 在 **`.agent/` 内部文件**中，若需可点击链接，应使用**以仓库根为锚的显式路径**：从**含 `.agent/` 的文件**出发，使用 `../../application/...`、`../../docs/...` 等（层数按实际深度调整）；或在 **仅位于 `.agent/` 一级** 的文档中使用 `../application/...`。**禁止**在深层 `skills/.../reference/` 中单独写 `application/foo.md` 作为相对链接（会被解析到 `skills/.../reference/application/...`）。 |
| **L4 规则目录** | `.agent/rules/CONVENTIONS.md` 等 | 指向 skills 时用 `../skills/...`；指向仓库其他顶格目录用 `../application/...` 等，与当前文件深度一致。 |

---

## 4. 与 `docs-init` 的关系

- 安装时会对正文做 **`.agent/` → `.cursor/`**（等）替换；**L1/L2** 纯相对路径**不参与**该替换亦可保持树内可达。
- 文中若出现字面量 **`.agent/skills/...`**，安装后变为 **`.cursor/skills/...`**，表示「用户 HOME 下 Agent 树」，**不**等同于「当前打开的工程仓库路径」；因此 **L3** 仍以 **仓库内相对路径（`../` 上到根再进 `application/`）** 为主，保证 **§1.1** 的语义可达，并**推荐**满足 **§1.2** 的可点击体验。

---

## 5. 评审清单（PR / 自检）

- [ ] 新增或修改的链接是否满足 **§1.1**（Agent 能说明「链到哪」；跨出 `.agent` 须在 `REPO_ROOT`/`DOC_ROOT` 内）？
- [ ] 在仓库根打开文件时，是否需要人类可点击？若需要，`](...)` 目标是否存在 **§1.2**？
- [ ] 是否避免在 `skills/**/reference/` 等深层目录使用无 `../` 的 `application/`、`docs/` 短链？

---

## 6. 相关文件

- `scripts/docs-init.sh`（`_rewrite_agent_file` / `rewrite_agent_tree`）
- `scripts/README.md`（Agent 安装与路径替换说明）
- `docs/superpowers/specs/2026-04-07-agent-external-refs-path-resolution-design.md`（`DOC_ROOT` 与脚本侧约定）
- `.agent/scripts/validate-agent-md-links.sh`（仓库根执行；相对链接存在性与 L3 裸路径禁令）
- `.agent/rules/CONVENTIONS.md`（§二-1 约定摘要）
