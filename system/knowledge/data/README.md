# data — 数据视角

本目录描述数据存储结构、数据实体与治理属性，并通过 ID 与其他视角建立映射。

- **统一元数据**：[data_meta.yaml](./data_meta.yaml) — `layers`（ds / ent）。
- **实体清单（唯一事实来源）**：[data_knowledge.json](./data_knowledge.json)

---

## 数据线索引表（示例）

| 链序 | 层级 | 类型 | 名称 | 锚点目录 / 文件 |
|:----:|------|------|------|----------------|
| — | 索引 | 数据视角 | 数据视角 | [data_meta.yaml](./data_meta.yaml) |
| L1 | 数据存储 | DS | 示例数据源 | `data_knowledge.json`（`hierarchy=DS` / `full_id=DS-EXAMPLE`） |
| L2 | 数据实体 | ENT | 示例实体 | `data_knowledge.json`（`hierarchy=ENT` / `full_id=ENT-EXAMPLE`） |

---

## 层级结构

```
数据存储 (DS) → 数据实体 (ENT)   （内容整合于 data_knowledge.json）
```

- **字段模板**：**`data_meta.yaml` → `layers`**
- **层级内容**：**`data_knowledge.json`**（本目录不再物化 `DS-*` 子目录与 `DATA-ARCHITECTURE.md`）。

---

## 关键字段（用于映射）

- **DS**：`owned_by_app_id`（→ APP/MS）
- **ENT**：`maps_to_aggregate_id`（→ AGG）

---

## 本视角导航

- 数据存储与实体清单（唯一事实来源）：[data_knowledge.json](./data_knowledge.json)

---

## 与其他视角的映射

- **数据 ← 业务**：`persisted_as_entity_ids` ↔ ENT。
- **数据 ← 技术**：`owned_by_app_id` → APP/MS。

系统索引：[../../INDEX_GUIDE.md](../../INDEX_GUIDE.md)；全库仓库入口：[../../../@docs/INDEX_GUIDE.md](../../../@docs/INDEX_GUIDE.md)；设计：[../../DESIGN.md](../../DESIGN.md)。
