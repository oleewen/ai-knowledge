# docs-build 核心概念

[SKILL.md](../SKILL.md)；细则 [extraction-rules.md](extraction-rules.md)。

## 视角与产物

| 视角 | 前缀 | 产出 |
|------|------|------|
| application | SYS/APP/MS/API | `application_knowledge.json`（`entities` 分类） |
| data | DS、ENT | `data_knowledge.json`（扁平） |
| business | BD→AB | `business_knowledge.json`（扁平） |
| product | PL→UC | `product_knowledge.json`（扁平） |

主索引：`{DOC_DIR}/knowledge/KNOWLEDGE_INDEX.md`。

## 依赖

- 上游：主 Index Guide（多由 `/docs-indexing`）
- 不替代：docs-indexing、docs-archive、docs-distill、docs-extract
