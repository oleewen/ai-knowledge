---
type: Documentation
tags: [federation]
title: application-slots（应用联邦槽位根）
---
<!-- markdownlint-disable-next-line MD025 -->
# application-slots

系统层**应用联邦槽位根**。子目录 `application-{NAME}/` 承载各应用库经 `/docs-pull` 同步的镜像；**不是** `knowledge/` SSOT。

| 读什么 | 文件 |
|--------|------|
| 本层索引 | [index.md](index.md) |
| 槽位模板 | [application-NAME/README.md](application-NAME/README.md) |
| 建联清单 | [../knowledge-links.yaml](../knowledge-links.yaml) |
| 布局契约 | [../../agent/references/knowledge-layout.md](../../agent/references/knowledge-layout.md) |

## 约定

- 路径：`system/application-slots/application-{NAME}/`（硬切；根下直挂 `application-*` 无效）
- 建槽：`docs-link`（模板 `application-NAME/` → 实例 `application-<slug>/`）
- 同步：`/docs-pull --app <slug>`；排除槽位 `README.md` / `index.md` / `changelogs/`
- 追溯：各槽 `changelogs/CHANGE-LOG.md`

公司层对称见 [company/system-slots](../../company/system-slots/README.md)。
