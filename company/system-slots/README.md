---
type: Documentation
tags: [federation]
title: system-slots（系统联邦槽位根）
---
<!-- markdownlint-disable-next-line MD025 -->
# system-slots

公司层**系统联邦槽位根**。`system-{NAME}` 为指向下级系统库 `DOC_ROOT` 的**软链**；**不是** `knowledge/` SSOT。

| 读什么 | 文件 |
|--------|------|
| 本层索引 | [index.md](index.md) |
| 蒸馏日志 | [changelogs/ARCHIVE-LOG.md](changelogs/ARCHIVE-LOG.md) |
| 建联清单 | [../knowledge-links.yaml](../knowledge-links.yaml) |
| 布局契约 | [../../agent/references/knowledge-layout.md](../../agent/references/knowledge-layout.md) |

## 约定

- 路径：`company/system-slots/system-{NAME}` → 软链至系统仓 `DOC_ROOT`
- 建槽：`docs-link`（写 yaml + 建/刷新软链；允许悬空，待 `/docs-pull` 补仓）
- 同步：`/docs-pull --sys-name <slug>`（校验软链；失效则按 `repository` clone/pull；脏工作区拒绝 pull）
- 追溯：`SYNC_OK` 含 commit；变更历史 `git log` / `git diff`；蒸馏锚点 [changelogs/ARCHIVE-LOG.md](changelogs/ARCHIVE-LOG.md)

系统层对称见 [system/application-slots](../../system/application-slots/README.md)。
