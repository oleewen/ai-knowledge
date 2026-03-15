# data — 数据视角

本目录描述**数据存储结构、数据实体与治理属性**（敏感级别、归属等）。与业务、技术视角通过 ID 显式关联。

- **数据架构总览**：[DATA-ARCHITECTURE.md](./DATA-ARCHITECTURE.md)（存储全景、表结构、缓存与分片策略）

---

## 层级结构

```
数据存储 (DS) → 数据实体 (ENT)
```

- **数据存储**：如 MySQL 主库、Redis 集群，目录 `{DS-ID}/`，含 `_meta.yaml`。
- **数据实体**：表或集合，文件 `schema/{ENT-ID}.yaml`。

---

## 元数据约定

### 数据存储 _meta.yaml

| 字段 | 说明 |
|------|------|
| id, name, description | 存储标识与描述 |
| type | 如 MySQL / Redis / Kafka |
| app_id | 归属的 technical 应用 ID（可选，表示该存储由哪一应用主要使用/拥有） |

### 数据实体 YAML

| 字段 | 说明 |
|------|------|
| id, name, description | 实体标识与描述（name 可含物理表名） |
| fields | 字段列表，可含 name, type, is_primary, sensitivity 等 |
| maps_to_aggregate_id | 对应的 business 聚合根 ID（核心映射） |

敏感级别建议：L1–L4 或 公开/内部/机密/绝密，由治理规范统一。

---

## 本视角内示例

- 数据存储：[DS-ORDER-MYSQL-PRIMARY](./DS-ORDER-MYSQL-PRIMARY/)
- 数据实体：[ENT-T_ORDER](./DS-ORDER-MYSQL-PRIMARY/schema/ENT-T_ORDER.yaml)

---

## 与其他视角的映射

- **数据 ← 业务**：聚合的 `persisted_as_entity_ids` 指向本层 ENT；ENT 的 `maps_to_aggregate_id` 指向 business 的 AGG。
- **数据 ← 技术**：数据存储的 `app_id` 或数据权属表指向 technical 的 APP/MS。

更多见仓库根目录 [INDEX.md](../../INDEX.md) 与 [DESIGN.md](../../DESIGN.md)。
