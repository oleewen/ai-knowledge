# 核心概念

| 视角 | 层级 | SSOT 载体 |
| --- | --- | --- |
| application | SYS/APP/MS/API | 各实体 per-entity `{ID}.md`（OKF concept + frontmatter；schema 2.1 字段语义） |
| data | DS、ENT | 锚点目录 + 叶子 `{ID}.md` |
| business | BD→AB | 锚点目录 + 叶子 `{ID}.md` |
| product | PL→UC | 锚点目录 + 叶子 `{ID}.md` |
| technical | MW/CMP | 扁平 `technical/{ID}.md` |

层级与必填字段见各视角 `{perspective}-meta.md`；聚合索引由扫描生成 `KNOWLEDGE_INDEX.md`（非 SSOT）。
