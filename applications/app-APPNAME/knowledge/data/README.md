> **模板示例**：本文件为知识库模板示例，实际项目请按需替换内容与 ID。

# data — 数据视角

本目录描述数据存储结构、数据实体与治理属性（敏感级别、归属等），并通过 ID 与其他视角建立映射。

- **数据架构总览**：[DATA-ARCHITECTURE.md](./DATA-ARCHITECTURE.md)（存储全景、表结构、缓存与分片策略）

---

## 层级结构

```
数据存储 (DS) → 数据实体 (ENT)
```

- **数据存储**：如 MySQL 主库、Redis 集群，目录 `{DS-ID}/`，含 `_meta.yaml`。
- **数据实体**：表或集合，文件 `schema/{ENT-ID}.yaml`。

---

## 关键字段（用于映射）

- **DS（数据存储）**：`app_id`（可选，归属 technical APP/MS）
- **ENT（数据实体）**：`maps_to_aggregate_id`（→ business AGG）

---

## 本视角内示例

- 数据存储：[DS-ORDER-MYSQL-PRIMARY](./DS-ORDER-MYSQL-PRIMARY/)
- 数据实体：[ENT-T_ORDER](./DS-ORDER-MYSQL-PRIMARY/schema/ENT-T_ORDER.yaml)

---

## 与其他视角的映射

- **数据 ← 业务**：聚合的 `persisted_as_entity_ids` 指向本层 ENT；ENT 的 `maps_to_aggregate_id` 指向 business 的 AGG。
- **数据 ← 技术**：数据存储的 `app_id` 或数据权属表指向 technical 的 APP/MS。

更多见仓库根目录 [INDEX.md](../../../INDEX.md) 与系统设计说明 [system/DESIGN.md](../../../system/DESIGN.md)。
