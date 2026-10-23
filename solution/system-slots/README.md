---
type: Documentation
tags: [federation]
title: system-slots（系统联邦槽位根）
---
# system-slots

解决方案层**系统联邦槽位根**。`system-{NAME}` → 系统库 `文档目录` 软链；**不是** `knowledge/` SSOT。

| 读什么 | 文件 |
|--------|------|
| 本层索引 | [index.md](index.md) |
| 建联清单 | [../knowledge-links.yaml](../knowledge-links.yaml) |
| 布局契约 | [../../agent/references/knowledge-layout.md](../../agent/references/knowledge-layout.md) |

## 约定

- 路径：`solution/system-slots/system-{NAME}` → 系统仓 `文档目录`
- 建槽：`docs-link`（yaml + 软链；company→solution、solution→system、system→application）
- 维护：`docs-link --check` 全量检查；`--repair --target <已登记路径或URL>` 单槽位修复，可先 `--dry-run`。
- 内容更新：遵循系统仓普通 Git 工作流；缺仓先按已登记 `path` 准备本地仓。检查/修复不访问远端。

解决方案不挂 `application-slots`。应用槽位在系统层 `application-slots`。上游：[company/solution-slots](../../company/solution-slots/README.md)。
