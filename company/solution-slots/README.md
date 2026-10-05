---
type: Documentation
tags: [federation]
title: solution-slots（解决方案联邦槽位根）
---
# solution-slots

公司层**解决方案联邦槽位根**。`solution-{NAME}` 为指向下级解决方案库 `DOC_ROOT` 的**软链**；**不是** `knowledge/` SSOT。

| 读什么 | 文件 |
|--------|------|
| 本层索引 | [index.md](index.md) |
| 蒸馏日志 | [changelogs/ARCHIVE-LOG.md](changelogs/ARCHIVE-LOG.md) |
| 建联清单 | [../knowledge-links.yaml](../knowledge-links.yaml) |
| 布局契约 | [../../agent/references/knowledge-layout.md](../../agent/references/knowledge-layout.md) |

## 约定

- 路径：`company/solution-slots/solution-{NAME}` → 软链至解决方案仓 `DOC_ROOT`
- 建槽：`docs-link`（company→solution）
- 同步：`/docs-pull --sln-name <slug>`
- 公司不挂 `system-slots`。系统槽位在解决方案层

下游：[solution/system-slots](../../solution/system-slots/README.md)。
