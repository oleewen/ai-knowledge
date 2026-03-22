# data — 数据视角

本目录描述数据存储结构、数据实体与治理属性（敏感级别、归属等），并通过 ID 与其他视角建立映射。

- **统一元数据**：[data_meta.yaml](./data_meta.yaml) — 单文件 SSOT：`identity`、`repository`、`pipeline`、`integration`、`layers`（ds / ent）。
- **数据架构总览**：[DATA-ARCHITECTURE.md](./DATA-ARCHITECTURE.md)（存储全景、表结构、缓存与分片策略）

---

## 数据线索引表（示例）

| 链序 | 层级 | 类型 | 名称（示例） | ID（示例） | 元数据（YAML） | 说明 |
|:----:|------|------|--------------|------------|----------------|------|
| — | 索引 | 数据视角 | 数据视角（knowledge/data） | `DIR-KNOWLEDGE-DATA` | [data_meta.yaml](./data_meta.yaml) | `identity` + `layers` + `integration` |
| L1 | 数据存储 | DS | 订单主库 | `DS-ORDER-MYSQL-PRIMARY` | 同上 · `key: ds` | 锚点 `{DS-ID}/`；`fields.owned_by_app_id` |
| L2 | 数据实体 | ENT | 订单表 | `ENT-T_ORDER` | 同上 · `key: ent` | `maps_to_aggregate_id` → AGG |
| L2 | 数据实体 | ENT | 订单项表 | `ENT-T_ORDER_ITEMS` | 同上 · `key: ent` | 从属订单聚合 |

---

## 层级结构

```
数据存储 (DS) → 数据实体 (ENT)
```

- **数据存储 / 数据实体**：字段模板见 **`data_meta.yaml` → `layers`**。
- **子目录** `{DS-ID}/`：作存储层级锚点（可含 [README](./DS-ORDER-MYSQL-PRIMARY/README.md)）；**不**再放置与根索引冲突的重复 meta。

---

## 关键字段（用于映射）

- **DS（数据存储）**：`owned_by_app_id`（归属 technical APP/MS）
- **ENT（数据实体）**：`maps_to_aggregate_id`（→ business AGG）

---

## 本视角内示例

- 数据存储导航：[DS-ORDER-MYSQL-PRIMARY](./DS-ORDER-MYSQL-PRIMARY/)
---

## 与其他视角的映射

- **数据 ← 业务**：聚合的 `persisted_as_entity_ids` 指向本层 ENT；ENT 的 `maps_to_aggregate_id` 指向 business 的 AGG。
- **数据 ← 技术**：数据存储的 `owned_by_app_id` 指向 technical 的 APP/MS。

系统索引：[../../SYSTEM_INDEX.md](../../SYSTEM_INDEX.md)；全库 Index Guide：[../../../INDEX_GUIDE.md](../../../INDEX_GUIDE.md)；设计：[../../DESIGN.md](../../DESIGN.md)。
