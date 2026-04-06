# `.ai` 对外引用复评与「脚本推断路径」可行性

**日期**: 2026-04-06  
**类型**: 静态审计 + 方案评估（非实现承诺）

---

## 1. 结论摘要

**仍有**对「`.ai/` 树外」的引用，分为四类：

| 类别 | 说明 | 是否适合用「脚本在运行时推断」替代文档中的字面路径 |
|------|------|----------------------------------|
| A. Shell 运行时 | ~~`.ai/skills/sdx-validate-bootstrap.sh` → 仓库根 `scripts/sdx-doc-root.sh`~~ **已改为**同目录 `.ai/skills/sdx-doc-root.sh`（方案丙）；仓库根 `scripts/sdx-doc-root.sh` 仅转发 | **已落地**：校验链以 `.ai/skills` 内两文件为自足；`git` 根后备仍保留 |
| B. 约定式路径字面量 | 全文 `` `system/...` ``、`applications/...`、`knowledge/`、仓库根 `AGENTS.md` / `INDEX_GUIDE.md` 等 | **不适合**用脚本在 Skill 执行时「推断成唯一磁盘路径」——目标工程 doc_root 可能是 `docs/` / `system/` / 其他；应保留**语义路径 + doc_root 解析**（与现有 `sdx-doc-root` 一致），而非在 `.ai` 内写死绝对树 |
| C. 指向仓库根 `scripts/` 的文档与示例 | 如 `docs-fetch` 中 `scripts/fetch-docs.sh`、`docs-indexing` 中 `scripts/indexing.sh`、`agent-guide` 中 `scripts/validate-guide.sh` 等 | **可**在「安装/bootstrap」或「校验脚本」中解析：以含 `.git` 或 `scripts/` 的仓库根为锚点；**不建议**在 Markdown 中改为动态生成，以免人类无法静态阅读 |
| D. Markdown 站内链接 | `rules/CONVENTIONS.md` → `../skills/...`（仍在 `.ai` 内）；跨技能 `../../sdx-solution/...`（仍在 `.ai/skills` 内） | **无**对外部仓库的链接；与上次审计一致 |
| E. 外部 URL | 如 `skills/README` 中 Anthropic 插件链接、`manifest-spec` 中示例 `repo_url` | **故意**外链；非本仓库路径推断问题 |

---

## 2. 引用清单（按类）

### 2.1 运行时依赖（Bash）

- **`.ai/skills/sdx-validate-bootstrap.sh`**：优先 `"$boot_dir/sdx-doc-root.sh"`，失败则 `script_dir/../../../../.ai/skills/sdx-doc-root.sh`、`git` 根下 `.ai/skills/sdx-doc-root.sh` 或 `scripts/sdx-doc-root.sh`（转发）。
- **`.ai/skills/sdx-doc-root.sh`**：doc_root 解析实现（方案丙）；仓库根 **`scripts/sdx-doc-root.sh`** 转发至此文件。
- **各 `validate-*.sh`**：`source "$SCRIPT_DIR/../../sdx-validate-bootstrap.sh"`（`.ai` 内）。

### 2.2 文档中显式写出「仓库根 `scripts/`」

- **`.ai/README.md`**：职责表说明仓库根 `scripts/`。
- **多个 `SKILL.md`**：示例命令 `scripts/fetch-docs.sh`、`scripts/change-indexing.sh`、`scripts/validate-*.sh`、`scripts/indexing.sh` 等（相对**目标工作目录 = 克隆后的 ai-knowledge 仓库根**）。
- **`CONVENTIONS.md`**：`scripts/docs-*.sh` 边界说明。

### 2.3 目标工程布局（非 `.ai` 内文件，而是契约）

- 大量 `` `system/...` ``、`` `applications/...` ``、`AGENTS.md`、`INDEX_GUIDE.md`：**语义约定**，依赖 `docs-init` / doc_root 与联邦规则，**不是**要求磁盘上存在「相对 `.ai` 的某一固定相对路径」的可点击链接。

### 2.4 与上次审计的差异

- **`sdx-validate-bootstrap` 已迁入** `.ai/skills/`，校验脚本不再 `source` 仓库根同名文件（仓库根脚本可为薄转发）。
- **`sdx-doc-root` 已迁入** `.ai/skills/sdx-doc-root.sh`，与 bootstrap 组成自足校验链；仓库根 `scripts/sdx-doc-root.sh` 为薄转发。
- **`.ai/README.md`** 已去除指向仓库根的 Markdown 超链接，改为纯文本路径说明。

---

## 3. 「脚本推断目录/文件」的可选方案

### 方案甲：保持现状 + 文档声明锚点（推荐）

- **做法**：约定「凡写 `scripts/foo.sh` 均相对**克隆后的仓库根**」；运行时脚本已用 `git rev-parse` / 相对 bootstrap 定位 `scripts/sdx-doc-root.sh`。
- **优点**：简单、与开源仓库惯例一致；人类与 CI 可读。
- **缺点**：仅克隆 `.ai` 到 Agent 目录时，需单独携带 `scripts/` 或接受 stub。

### 方案乙：仓库内静态审计脚本（辅助）

- **做法**：增加 `scripts/audit-ai-refs.sh`（或 make 目标）：扫描 `.ai` 下 `*.md` / `*.sh`，报告（1）指向 `](..` 跳出 `.ai` 的链接；（2）字面量 `scripts/`（非 `.ai/skills/.../scripts/`）；（3）可选：禁止列表。
- **优点**：可进 CI，防止回归；**不**改变 Skill 语义。
- **缺点**：需维护允许清单（如 `scripts/sdx-doc-root.sh` 在注释中的引用）。

### 方案丙：把 `sdx-doc-root.sh` 再迁入 `.ai` 并单一 source 链（**已落地**）

- **做法**：与 bootstrap 类似，将 `sdx-doc-root.sh` 副本置于 `.ai/skills/`，仓库根 `scripts/sdx-doc-root.sh` 仅转发；`sdx_find_repo_root_from_path` 同时识别 `.ai/skills/sdx-doc-root.sh` 与 `scripts/sdx-doc-root.sh`。
- **优点**：**仅同步 `.ai/skills`**（含 `sdx-doc-root.sh`）时校验链可自足。
- **缺点**：仓库根转发与 `.ai` 副本须同提交维护（与 `sdx-validate-bootstrap` 策略一致）。

### 方案丁：用环境变量统一「仓库根」

- **做法**：定义 `SDX_REPO_ROOT` / `AI_KNOWLEDGE_ROOT`，脚本优先读环境再回退 `git`。
- **优点**：容器与 monorepo 子目录友好。
- **缺点**：文档仍需说明变量；Agent 易漏设。

---

## 4. 推荐组合

1. **语义路径**（`system/`、`applications/`）继续作为 **doc_root 相对** 叙述，**不**改为脚本生成 Markdown。
2. **运行时**以 **`.ai/skills/sdx-doc-root.sh`** 为主，**git 根**下 `scripts/sdx-doc-root.sh` 为兼容入口；方案丙已满足「仅带 `.ai/skills` 可跑校验链」。
3. 若团队希望 **零回归**，落地 **方案乙** 作为轻量门禁。

---

## 5. 自检

- 与当前仓库文件一致；未承诺具体实现排期。
- 术语与同目录 [2026-04-06-ai-external-references-audit.md](./2026-04-06-ai-external-references-audit.md) 中「系统知识库根目录 / 应用知识库根目录」表述兼容。
