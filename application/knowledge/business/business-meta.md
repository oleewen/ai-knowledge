---
type: Perspective Meta
title: 业务视角元数据（application/knowledge/business）
---
# 业务视角元数据（application/knowledge/business）

应用侧 DDD 业务版图（BD→BSD→BC→AGG→AB）实体登记与实现映射元数据。实例索引见 [../KNOWLEDGE_INDEX.md](../KNOWLEDGE_INDEX.md)（§1，扫描生成；实体文件 `{ID}.md` 为 SSOT）。

---

## 1. 概览

| 字段 | 值 |
| --- | --- |
| meta_id | `DIR-KNOWLEDGE-BUSINESS` |
| 视角 | business |
| 层级范围 | application |
| 说明 | DDD 业务版图；公司级 BD/CAP 在 `company/knowledge/business/` 首次定义，系统层自 BSD 起首次定义，本层承接实现映射与实例登记。 |
| entities_shape | 实体文件 `{ID}.md`（OKF 概念实体）；索引见 KNOWLEDGE_INDEX §1 |

---

## 2. 层级链

| 链序 | 层级代码 | 说明 |
| --- | --- | --- |
| 1 | BD | 业务域（应用层可登记实例；公司层为 SSOT） |
| 2 | BSD | 业务子域（系统层首次定义，应用层可引用/登记） |
| 3 | BC | 限界上下文（系统层首次定义，应用层承接实现映射） |
| 4 | AGG | 聚合根（系统层首次定义，应用层补充持久化/服务映射） |
| 5 | AB | 领域能力（Ability，系统层首次定义，应用层补充 API 映射） |

---

## 3. 层定义

| order | key | code | id_pattern | parent |
| --- | --- | --- | --- | --- |
| 1 | bd | BD | `BD-{NAME}` | — |
| 2 | bsd | BSD | `BSD-{NAME}` | BD |
| 3 | bc | BC | `BC-{NAME}` | BSD |
| 4 | agg | AGG | `AGG-{NAME}` | BC |
| 5 | ab | AB | `AB-{NAME}` | AGG |

---

## 4. 必填字段

### 通用字段

| 字段 | 说明 |
| --- | --- |
| hierarchy | `BD` / `BSD` / `BC` / `AGG` / `AB` |
| full_id | 规范 ID |
| name | 中文名称 |
| description | 实体描述 |
| evidence_source | 证据来源 |
| layer_scope | 固定为 `application` |

### 各层专属

| 层级 | 必填字段 |
| --- | --- |
| BD | `strategic_classification`、`children`（子 BSD full_id 列表） |
| BSD | `parent_id`、`bounded_contexts` |
| BC | `parent_id`、`implemented_by_app_id`、`aggregates` |
| AGG | `parent_id`、`root_entity`、`persisted_as_entity_ids`、`implemented_by_service_ids`、`abilities` |
| AB | `parent_id`、`capability`、`apis`（含 `id`、`method`、`description`） |

---

## 5. 跨视角引用

| 源字段 | 目标 | 说明 |
| --- | --- | --- |
| BC.implemented_by_app_id | APP.full_id | 上下文实现应用 |
| AGG.persisted_as_entity_ids | ENT.full_id | 聚合持久化实体 |
| AGG.implemented_by_service_ids | MS.full_id | 聚合实现入口簇 |
| AB.apis[].id | API.id | 能力实现 API |

---

## 6. 关联文档

| 路径 | 说明 |
| --- | --- |
| [README.md](README.md) | 人类可读说明 |
| [../KNOWLEDGE_INDEX.md](../KNOWLEDGE_INDEX.md) | §1 业务视角实例索引（扫描生成） |
| [../KNOWLEDGE_INDEX.md](../KNOWLEDGE_INDEX.md) | 五视角索引 |
| [../../INDEX_GUIDE.md](../../INDEX_GUIDE.md) | 联邦索引 |

**索引**：`readme_index_table: true`；变更 ID 时同步 README、KNOWLEDGE_INDEX.md、INDEX_GUIDE.md（按需）。
