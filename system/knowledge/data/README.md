# data — 数据视角

本目录描述数据存储结构、数据实体与治理属性（敏感级别、归属等），并通过 ID 与其他视角建立映射。

- **数据视角索引**：[data_meta.yaml](./data_meta.yaml)（本目录说明与索引约定）。
- **数据架构总览**：[DATA-ARCHITECTURE.md](./DATA-ARCHITECTURE.md)（存储全景、表结构、缓存与分片策略）

---

## 数据线索引表（示例）

| 链序 | 层级 | 类型 | 名称（示例） | ID（示例） | 元数据（YAML） | 说明 |
|:----:|------|------|--------------|------------|----------------|------|
| — | 索引 | 数据视角 | 数据视角（knowledge/data） | `DIR-KNOWLEDGE-DATA` | [data_meta.yaml](./data_meta.yaml) | 本视角目录说明、输入输出与索引约定 |
| L1 | 数据存储 | DS | 订单主库 | `DS-ORDER-MYSQL-PRIMARY` | [DS_meta.yaml](./DS_meta.yaml) | 锚点目录 `{DS-ID}/`；`owned_by_app_id` 见 YAML |
| L2 | 数据实体 | ENT | 订单表 | `ENT-T_ORDER` | [ENT-T_ORDER_ENT_meta.yaml](./ENT-T_ORDER_ENT_meta.yaml) | `maps_to_aggregate_id` 映射 business AGG |
| L2 | 数据实体 | ENT | 订单项表 | `ENT-T_ORDER_ITEMS` | [ENT-T_ORDER_ITEMS_ENT_meta.yaml](./ENT-T_ORDER_ITEMS_ENT_meta.yaml) | 从属订单聚合 |

---

## 层级结构

```
数据存储 (DS) → 数据实体 (ENT)
```

- **数据存储 / 数据实体**：元数据分别为 **`DS_meta.yaml`** 与 **`{ENT-ID}_ENT_meta.yaml`**（位于本目录根）。
- **子目录** `{DS-ID}/`：作存储层级锚点（可含 [README](./DS-ORDER-MYSQL-PRIMARY/README.md)）；**不**再放置与根目录重复的目录索引 `*_meta.yaml`。

---

## 关键字段（用于映射）

- **DS（数据存储）**：`owned_by_app_id`（归属 technical APP/MS）
- **ENT（数据实体）**：`maps_to_aggregate_id`（→ business AGG）

---

## 本视角内示例

- 数据存储导航：[DS-ORDER-MYSQL-PRIMARY](./DS-ORDER-MYSQL-PRIMARY/)
- 数据实体：[ENT-T_ORDER_ENT_meta.yaml](./ENT-T_ORDER_ENT_meta.yaml)

---

## 与其他视角的映射

- **数据 ← 业务**：聚合的 `persisted_as_entity_ids` 指向本层 ENT；ENT 的 `maps_to_aggregate_id` 指向 business 的 AGG。
- **数据 ← 技术**：数据存储的 `owned_by_app_id` 指向 technical 的 APP/MS。

系统索引：[../../INDEX.md](../../INDEX.md)；全库 Index Guide：[../../../INDEX.md](../../../INDEX.md)；设计：[../../DESIGN.md](../../DESIGN.md)。
