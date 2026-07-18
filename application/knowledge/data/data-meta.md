---
type: Perspective Meta
title: 数据视角元数据（application/knowledge/data）
---

应用侧数据版图（MDG→DS→ENT→TBL）实体登记与物理落地元数据。实例索引见 [../index.md](../index.md)（§4，扫描生成；实体文件 `{ID}.md` 为 SSOT）。

---

## 1. 概览

| 字段 | 值 |
| --- | --- |
| meta_id | `DIR-KNOWLEDGE-DATA` |
| 视角 | data |
| 层级范围 | application |
| 说明 | 数据存储与实体；公司级 MDG 在 `company/knowledge/data/` 首次定义，系统层自 DS/ENT 起首次定义，本层补齐 MDG reference 并承接物理表锚点与应用归属信息。 |
| entities_shape | 实体文件 `{ID}.md`（OKF 概念实体）；索引见 KNOWLEDGE_INDEX §4 |

---

## 2. 层级链

| 链序 | 层级代码 | 说明 |
| --- | --- | --- |
| 1 | MDG | 主数据域（公司层 SSOT；本层为视角根 reference） |
| 2 | DS | 数据存储（系统层首次定义） |
| 3 | ENT | 数据实体（表/集合，系统层首次定义） |
| 4 | TBL | 物理表锚点（应用层首次定义；挂 DS） |

---

## 3. 层定义

| order | key | code | id_pattern | parent |
| --- | --- | --- | --- | --- |
| 1 | mdg | MDG | `MDG-{NAME}` | —（reference → company） |
| 2 | ds | DS | `DS-{NAME}` | MDG（逻辑归属，`authoritative_mdg_id` 推荐） |
| 3 | ent | ENT | `ENT-{NNN}` 或 `ENT-{NAME}` | DS |
| 4 | tbl | TBL | `TBL-{NAME}` | DS |

---

## 4. 必填字段

### 通用字段

| 字段 | 说明 |
| --- | --- |
| hierarchy | `MDG` / `DS` / `ENT` / `TBL` |
| full_id | 规范 ID |
| name | 中文名称 |
| description | 实体描述 |
| evidence_source | 证据来源 |
| layer_scope | 固定为 `application` |

### 各层专属

| 层级 | 必填字段 |
| --- | --- |
| MDG | `definition_scope: reference`、`governance_owner` |
| DS | `type`、`config_key`、`owned_by_app_id` |
| ENT | `parent_id`、`logical_name`、`physical_table` |
| TBL | `parent_id`、`physical_name` |

### 推荐字段

| 层级 | 字段 | 说明 |
| --- | --- | --- |
| ENT | `maps_to_aggregate_id` | 映射业务聚合 AGG |

---

## 5. 跨视角引用

| 源字段 | 目标 | 说明 |
| --- | --- | --- |
| MDG（reference） | company MDG.full_id | 上游公司 SSOT |
| DS.authoritative_mdg_id | MDG.full_id | 数据源归属主数据域（推荐） |
| AGG.persisted_as_entity_ids | ENT.full_id | 聚合持久化 |
| ENT.maps_to_aggregate_id | AGG.full_id | 实体归属聚合 |
| DS.owned_by_app_id | APP.full_id | 数据源归属应用 |

---

## 6. 关联文档

| 路径 | 说明 |
| --- | --- |
| [README.md](README.md) | 人类可读说明 |
| [../index.md](../index.md) | §4 数据视角实例索引（扫描生成） |
| [../index.md](../index.md) | 五视角索引 |

**索引**：`readme_index_table: true`；变更 ID 时同步 README、index.md（按需）。
