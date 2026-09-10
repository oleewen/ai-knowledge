---
type: Documentation
tags: [federation]
title: system-slots（系统联邦槽位根）
---
<!-- markdownlint-disable-next-line MD025 -->
# system-slots

公司层**系统联邦槽位根**。子目录 `system-{NAME}/` 承载各系统库经 `/docs-pull` 同步的镜像；**不是** `knowledge/` SSOT。

| 读什么 | 文件 |
|--------|------|
| 本层索引 | [index.md](index.md) |
| 槽位模板 | [system-NAME/README.md](system-NAME/README.md) |
| 建联清单 | [../knowledge-links.yaml](../knowledge-links.yaml) |
| 布局契约 | [../../agent/references/knowledge-layout.md](../../agent/references/knowledge-layout.md) |

## 约定

- 路径：`company/system-slots/system-{NAME}/`（硬切；根下直挂 `system-*` 无效）
- 建槽：`docs-link`（模板 `system-NAME/` → 实例 `system-<slug>/`）
- 同步：`/docs-pull --sys-name <slug>`；排除槽位 `README.md` / `index.md` / `changelogs/`
- 追溯：各槽 `changelogs/CHANGE-LOG.md`

系统层对称（`application-slots`）见根 [GRILL-LOG](../../changelogs/GRILL-LOG.md)。
