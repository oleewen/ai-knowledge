# 数据视角元数据（application/knowledge/data）

应用层数据版图（DS→ENT）视角元数据 SSOT。实例索引见 [data-entities.md](data-entities.md)。

---

## 1. 概览

| 字段 | 值 |
| --- | --- |
| meta_id | `DIR-KNOWLEDGE-DATA` |
| 视角 | data |
| 层级范围 | application |
| 说明 | 数据存储与实体；公司级 MDG 在 `company/ea/data/` 首次定义，系统层 DS，本层登记 ENT。 |

---

## 2. 层级链

| 链序 | 层级代码 | 说明 |
| --- | --- | --- |
| 1 | DS | 数据存储 |
| 2 | ENT | 数据实体（表/集合） |

---

## 3. 层定义

| order | key | code | id_pattern | parent |
| --- | --- | --- | --- | --- |
| 1 | ds | DS | `DS-{NAME}` | — |
| 2 | ent | ENT | `ENT-{NNN}` 或 `ENT-{NAME}` | DS |

---

## 4. 必填字段

### 通用字段

| 字段 | 说明 |
| --- | --- |
| hierarchy | `DS` / `ENT` |
| full_id | 规范 ID |
| name | 中文名称 |
| description | 实体描述 |
| evidence_source | 证据来源 |

### 各层专属

| 层级 | 必填字段 |
| --- | --- |
| DS | `type`、`config_key`、`owned_by_app_id` |
| ENT | `parent_id`、`logical_name`、`physical_table` |

### 推荐字段

| 层级 | 字段 | 说明 |
| --- | --- | --- |
| ENT | `maps_to_aggregate_id` | 映射业务聚合 AGG |

---

## 5. 跨视角引用

| 源字段 | 目标 | 说明 |
| --- | --- | --- |
| AGG.persisted_as_entity_ids | ENT.full_id | 聚合持久化 |
| ENT.maps_to_aggregate_id | AGG.full_id | 实体归属聚合 |
| DS.owned_by_app_id | APP.full_id | 数据源归属应用 |

---

## 6. 关联文档

| 路径 | 说明 |
| --- | --- |
| [README.md](README.md) | 人类可读说明 |
| [data-entities.md](data-entities.md) | 扁平实体 SSOT |
| [../KNOWLEDGE_INDEX.md](../KNOWLEDGE_INDEX.md) | 五视角索引 |

**索引**：`readme_index_table: true`；变更 ID 时同步 README、KNOWLEDGE_INDEX.md（按需）。
