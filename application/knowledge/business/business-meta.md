---
type: Perspective Meta
title: 业务视角元数据（application/knowledge/business）
---

应用侧 DDD 业务版图（BD→BSD→BC→AGG→AB）实体登记与实现映射元数据。实例索引 [../index.md](../index.md)（§1，扫描生成；实体 `{ID}.md` = SSOT）。

## 1. 概览

| 字段 | 值 |
| --- | --- |
| meta_id | `DIR-KNOWLEDGE-BUSINESS` |
| 视角 | business |
| 层级范围 | application |
| 说明 | DDD 业务版图；公司级 BD/CAP ∈ `company/knowledge/business/` 首次定义，系统层自 BSD 起首次定义，本层承接实现映射与实例登记。 |
| entities_shape | 实体 `{ID}.md`（OKF）；`BSD` = 目录锚点，`BC/AGG` = 容器目录，`AB` = `AGG` 下叶子；索引见 KNOWLEDGE_INDEX §1 |

## 2. 层级链

| 链序 | 层级代码 | 说明 |
| --- | --- | --- |
| 1 | BD | 业务域（应用层可登记；公司层 = SSOT） |
| 2 | BSD | 业务子域（系统层首次定义，应用层可引用/登记） |
| 3 | BC | 限界上下文（系统层首次定义，应用层承接实现映射） |
| 4 | AGG | 聚合根（系统层首次定义，应用层补充持久化/服务映射） |
| 5 | AB | 领域能力（Ability，系统层首次定义，应用层补充 API 映射） |

## 3. 层定义

| order | key | code | id_pattern | parent |
| --- | --- | --- | --- | --- |
| 1 | bd | BD | `BD-{NAME}` | — |
| 2 | bsd | BSD | `BSD-{NAME}` | BD |
| 3 | bc | BC | `BC-{NAME}` | BSD |
| 4 | agg | AGG | `AGG-{NAME}` | BC |
| 5 | ab | AB | `AB-{NAME}` | AGG |

## 4. 字段（OKF）

**Frontmatter（10 必填）**：`type` · `title` · `description` · `tags` · `timestamp` · `full_id` · `perspective` · `hierarchy` · `parent_id` · `layer_scope`（本层固定 `application`）。详见 [okf-spec](../../../agent/knowledge/okf-spec.md) §2。

**正文四段**：`## 关系` · `## 跨视角` · `## 详细说明` · `## 依据与证据`。业务属性写正文，勿堆 frontmatter。

### 各层专属（正文）

| 层级 | 字段 | 建议段落 |
| --- | --- | --- |
| BD | `strategic_classification`、`children` | 关系 / 详细说明 |
| BSD | `bounded_contexts` | 关系 |
| BC | `aggregates`、`implemented_by_app_id` | 关系 / 跨视角 |
| AGG | `abilities`、`root_entity`、`persisted_as_entity_ids`、`implemented_by_service_ids` | 关系 / 跨视角 / 详细说明 |
| AB | `capability`、`apis`（链 API） | 详细说明 / 跨视角 |

## 5. 跨视角引用

| 源字段 | 目标 | 说明 |
| --- | --- | --- |
| BC.implemented_by_app_id | APP.full_id | 上下文实现应用 |
| AGG.persisted_as_entity_ids | ENT.full_id | 聚合持久化实体 |
| AGG.implemented_by_service_ids | MS.full_id | 聚合实现入口簇 |
| AB.apis[].id | API.id | 能力实现 API |

## 6. 关联文档

| 路径 | 说明 |
| --- | --- |
| [README.md](README.md) | 人类可读说明 |
| [../index.md](../index.md) | §1 业务视角 + 五视角实例索引（扫描生成） |
| [../../index.md](../../index.md) | 联邦索引 |

**索引**：`readme_index_table: true`；变更 ID 时同步 README、index.md（按需）。
