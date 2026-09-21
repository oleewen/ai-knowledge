---
type: Perspective Meta
title: 业务视角元数据（system/knowledge/business）
---
# 业务视角元数据（system/knowledge/business）

系统级业务版图（一级 BSD→二级 BSD→BC→AGG→AB）视角元数据 SSOT。实例索引：[index.md](../index.md)。

---

## 1. 概览

| 字段 | 值 |
| --- | --- |
| meta_id | `DIR-SYSTEM-KNOWLEDGE-BUSINESS` |
| 视角 | business |
| 层级范围 | system |
| 说明 | 系统级 DDD 业务版图；BD / 一级 BSD 为 company reference；自二级 BSD 起为本层 SSOT。 |

---

## 2. 层级链

| 链序 | 层级代码 | 说明 |
| --- | --- | --- |
| 1 | BD | 业务域（公司层 SSOT；系统层可为视角根 reference） |
| 2 | 一级 BSD | 业务子域（公司层 SSOT；系统层可为 reference；`level: 1`） |
| 3 | 二级 BSD | 业务子域（系统层 SSOT；`level: 2`；父级为一级 BSD） |
| 4 | BC | 限界上下文（系统层首次定义） |
| 5 | AGG | 聚合根（系统层首次定义） |
| 6 | AB | 领域能力（系统层首次定义） |

---

## 3. 层定义

| order | key | code | id_pattern | parent |
| --- | --- | --- | --- | --- |
| 1 | bd | BD | `BD-{NAME}` | —（reference → company） |
| 2 | bsd1 | BSD | `BSD-{NAME}` | BD（`level: 1`） |
| 3 | bsd2 | BSD | `BSD-{NAME}` | 一级 BSD（`level: 2`） |
| 4 | bc | BC | `BC-{NAME}` | 二级 BSD |
| 5 | agg | AGG | `AGG-{NAME}` | BC |
| 6 | ab | AB | `AB-{NAME}` | AGG |

---

## 4. BD 落盘例外

| 层级 | 路径 | 说明 |
| --- | --- | --- |
| company | `BD-{NAME}.md` | 公司 SSOT |
| system | `knowledge/business/BD-{NAME}.md` | 视角根 reference（非域文件夹） |
| system | `knowledge/business/一级BSD-{NAME}/二级BSD-{NAME}/` | 一级 BSD→二级 BSD→BC→AGG→AB 域扁平树 |
| application | `BD-*.md` | 应用 reference |

---

## 5. 字段（OKF）

Frontmatter 10 必填 + 正文四段（`## 关系` · `## 跨视角` · `## 详细说明` · `## 依据与证据`）见 okf-spec §2；本层 `layer_scope` 固定 `system`。

### 各层专属（正文 / 扩展）

| 层级 | 字段 | 建议段落 |
| --- | --- | --- |
| 一级 BSD | `definition_scope: reference`、`level: 1` | FM 扩展 / 详细说明 |
| 二级 BSD | `level: 2`、`parent`、`maps_to_pd` | FM / 关系 |
| BC | `aggregates`、`implemented_by_app_id` | 关系 / 跨视角 |
| AGG | `abilities`、`root_entity`、`persisted_as_entity_ids`、`implemented_by_service_ids` | 关系 / 跨视角 / 详细说明 |
| AB | `capability`（`apis` 多在应用层补全） | 详细说明 / 跨视角 |

---

## 6. 跨视角引用

| 源字段 | 目标 | 说明 |
| --- | --- | --- |
| BD / 一级 BSD（reference） | company 同名 id | 上游公司 SSOT |
| 二级 BSD.maps_to_pd | 本库 PD.id | 二级 BSD 对标产品服务 |
| BC.implemented_by_app_id | APP.id | 上下文实现应用 |
| AGG.persisted_as_entity_ids | ENT.id | 聚合持久化实体 |
| AGG.implemented_by_service_ids | MS.id | 聚合实现入口簇 |
| 应用层 AB.apis | API.id | 能力 API（下游引用） |

---

## 7. 关联文档

| 路径 | 说明 |
| --- | --- |
| [README.md](README.md) | 叙事文档索引 |
| [index.md](../index.md) | BD/BSD/BC/AGG/AB 实例 SSOT |
| knowledge-governance（agent/knowledge） | 系统库设计契约 |
| BD-*, CAP-* | 公司层业务 SSOT（reference） |
| naming-conventions（Agent 元知识） | ID 命名 SSOT |

**索引**：`readme_index_table: false`；变更 ID 时同步 index.md 与 narrative 章节（按需）。
