---
name: docs-pull
type: Skill
status: draft
---

# docs-pull

本技能用于联邦同步：

- application → system：将应用仓库本地 `path` 的 `{DOC_ROOT}/{DOC_DIR}/` 同步到 system 槽位 `application-{app_name}/`
- system → company：将系统仓库本地 `path` 的 `{DOC_ROOT}/{DOC_DIR}/` 同步到 company 槽位 `system-{sys_name}/`

约束：

- 仅使用本地 `path`（必须存在且为 Git 工作区），不 clone，不提供分支参数
- 输入 SSOT 为当前知识库的 `knowledge-links.yaml`
- 同步写槽位根目录时排除覆盖：`README.md`、`index.md`、`changelogs/`
- 每次同步后必须写槽位 `changelogs/CHANGE-LOG.md` 追溯记录（`source` 固定为 `repository`）

