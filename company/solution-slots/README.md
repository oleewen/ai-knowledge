---
type: Documentation
tags: [federation]
title: solution-slots（解决方案联邦槽位根）
---
# solution-slots

公司层**解决方案联邦槽位根**。`solution-{NAME}` 为指向下级解决方案库 `文档目录` 的**软链**；**不是** `knowledge/` SSOT。

| 读什么 | 文件 |
|--------|------|
| 本层索引 | [index.md](index.md) |
| 建联清单 | [../knowledge-links.yaml](../knowledge-links.yaml) |
| 布局契约 | [../../agent/references/knowledge-layout.md](../../agent/references/knowledge-layout.md) |

## 约定

- 路径：`company/solution-slots/solution-{NAME}` → 软链至解决方案仓 `文档目录`
- 建槽：`docs-link`（company→solution）
- 维护：`docs-link --check` 全量检查；`--repair --target <已登记路径或URL>` 单槽位修复，可先 `--dry-run`。
- 内容更新：遵循解决方案仓普通 Git 工作流；缺仓先按已登记 `path` 准备本地仓。检查/修复不访问远端。
- 公司不挂 `system-slots`。系统槽位在解决方案层 `system-slots`
