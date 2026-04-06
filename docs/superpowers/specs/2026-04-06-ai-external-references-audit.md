# `.ai` 目录对外部路径引用审计

**日期**: 2026-04-06  
**类型**: 静态审计（非改造任务）  
**结论摘要**: **有**对「非 `.ai/` 下文件」的引用；分为 **仓库内显式链接**、**脚本 source**、**约定式路径字面量** 三类。

---

## 1. 显式指向 `.ai` 之外的仓库相对路径（Markdown 链接）

**已处理（2026-04-06）**：`.ai/README.md` 中上述关系改为 **纯文本路径**（`` `AGENTS.md` `` 等），**不再**使用 `](../…)` 形式的仓库根外链。

其余 `.ai/skills/**`、`rules/CONVENTIONS.md` 中的 `../` 链接多在 **`.ai` 内部**（如 `../skills/...`、`../assets/...`），**不**算出 `.ai` 树。

---

## 2. Shell 脚本对仓库根 `scripts/` 的依赖（运行时 source）

以下脚本通过相对路径 **source 仓库根** `scripts/sdx-validate-bootstrap.sh`（再加载 `scripts/sdx-doc-root.sh`），路径在 **`.ai` 之外**：

- `.ai/skills/sdx-solution/scripts/validate-solution.sh`
- `.ai/skills/sdx-analysis/scripts/validate-analysis.sh`
- `.ai/skills/sdx-prd/scripts/validate-prd.sh`
- `.ai/skills/sdx-design/scripts/validate-design.sh`
- `.ai/skills/sdx-test/scripts/validate-test.sh`
- `.ai/skills/docs-build/scripts/validate-extraction.sh`

若目标工程 **仅** 同步了 `~/.cursor/skills` 而无 `scripts/`，需单独提供或复制上述脚本，否则走 **stub** 逻辑。

---

## 3. 约定式引用（非必须存在的链接，文本/指令中的工程布局）

大量 SKILL、reference、模板中出现 **`system/`**、**`knowledge/`**、**`AGENTS.md`**、**`INDEX_GUIDE.md`** 等，含义是 **目标工程文档树** 或 **协作契约**，不是 `.ai` 内可点击的相对文件路径；`docs-init` 会将部分字面量改写为 `docs/` 等。

**联邦**：`docs-fetch` 等提及 `applications/app-{APPNAME}/`、manifest——指向中央库目录结构。

---

## 4. 跨技能但仍在 `.ai` 内

例如 `sdx-analysis/reference/workflow-spec.md` 中 `../../sdx-solution/reference/...` — 仍位于 `.ai/skills/` 下。

---

## 5. 自检

- 与「仅统计磁盘上 `.ai` 外显式路径」一致；**不**将「`system/` 字面量」全部计为外链文件依赖。
