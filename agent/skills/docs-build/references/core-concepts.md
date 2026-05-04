# docs-build 核心概念

[SKILL.md](../SKILL.md) 为主干；提取细则见 [extraction-rules.md](extraction-rules.md)。

---

## 视角与产物

| 视角 | 典型前缀 | 产出 |
|------|-----------|------|
| technical | SYS / APP / MS / API | `technical_knowledge.json`（分类 `entities`） |
| data | DS / ENT | `data_knowledge.json`（扁平） |
| business | BD / BSD / BC / AGG / AB | `business_knowledge.json`（扁平） |
| product | PL / PM / FT / UC | `product_knowledge.json`（扁平） |

主索引：`{DOC_DIR}/knowledge/KNOWLEDGE_INDEX.md`。

---

## 依赖

- **上游**：主 Index Guide（通常由 `/docs-indexing` 生成）。
- **不替代**：`docs-indexing`（根 INDEX）、`docs-archive`（overview 归档）、`docs-distill` / `docs-extract`（系统 overview）。
