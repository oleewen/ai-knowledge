---
type: Documentation
tags: [federation]
title: application-slots（应用联邦槽位根）
---
# application-slots

系统层**应用联邦槽位根**。`application-{NAME}` → 应用库 `文档目录` 软链；**不是** `knowledge/` SSOT。

| 读什么 | 文件 |
|--------|------|
| 本层索引 | [index.md](index.md) |
| 建联清单 | [../knowledge-links.yaml](../knowledge-links.yaml) |
| 布局契约 | [../../agent/references/knowledge-layout.md](../../agent/references/knowledge-layout.md) |

## 约定

- 路径：`system/application-slots/application-{NAME}` → 应用仓 `文档目录`
- 建槽：`docs-link --link --target <应用仓库根>`（双边清单 + 软链）
- 维护：`docs-link --check` 检查全部 child；单槽位修复用 `--repair --target <已登记路径或URL>`，可先 `--dry-run`。
- 内容更新：遵循应用仓普通 Git 工作流；缺仓先按已登记 `path` 准备本地仓。检查/修复不访问远端。

上游：[solution/system-slots](../../solution/system-slots/README.md) · [company/solution-slots](../../company/solution-slots/README.md)。
