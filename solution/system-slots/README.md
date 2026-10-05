---
type: Documentation
tags: [federation]
title: system-slots（系统联邦槽位根）
---
# system-slots

解决方案层**系统联邦槽位根**。`system-{NAME}` → 系统库 `DOC_ROOT` 软链；**不是** `knowledge/` SSOT。

| 读什么 | 文件 |
|--------|------|
| 本层索引 | [index.md](index.md) |
| 蒸馏日志 | [changelogs/ARCHIVE-LOG.md](changelogs/ARCHIVE-LOG.md) |
| 建联清单 | [../knowledge-links.yaml](../knowledge-links.yaml) |
| 布局契约 | [../../agent/references/knowledge-layout.md](../../agent/references/knowledge-layout.md) |

## 约定

- 路径：`solution/system-slots/system-{NAME}` → 系统仓 `DOC_ROOT`
- 建槽：`docs-link`（yaml + 软链；company→solution、solution→system、system→application）
- 同步：`/docs-pull`（脏工作区拒绝 pull）

下游对称：[system/application-slots](../../system/application-slots/README.md)。上游：[company/solution-slots](../../company/solution-slots/README.md)。
