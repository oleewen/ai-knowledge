---
type: Perspective Meta
title: 数据视角元数据（system/knowledge/data）
---
# 数据视角元数据（system/knowledge/data）

系统级数据版图（MDG→DS→ENT）视角元数据 SSOT。实例索引见 [../index.md](../index.md)。

---

## 1. 概览

| 字段 | 值 |
| --- | --- |
| meta_id | `DIR-SYSTEM-KNOWLEDGE-DATA` |
| 层级范围 | system |
| 视角 | data |
| 说明 | 系统级数据存储与实体建模；公司级 MDG 在 `company/knowledge/data/` 首次定义，本层 MDG 为视角根 reference，自 DS/ENT 起为系统 SSOT；应用层补充物理表锚点。 |

---

## 2. 层级链

| 链序 | 层级代码 | 说明 |
| --- | --- | --- |
| 1 | MDG | 主数据域（公司层 SSOT；系统层为视角根 reference） |
| 2 | DS | 数据存储（系统层首次定义） |
| 3 | ENT | 数据实体（表/集合，系统层首次定义） |

---

## 3. 层定义

| order | key | code | id_pattern | parent |
| --- | --- | --- | --- | --- |
| 1 | mdg | MDG | `MDG-{NAME}` | —（reference → company） |
| 2 | ds | DS | `DS-{NAME}` | MDG（逻辑归属，`authoritative_mdg_id`） |
| 3 | ent | ENT | `ENT-{NNN}` 或 `ENT-{NAME}` | DS |

---

## 4. 字段（OKF）

**Frontmatter（10 必填）**：`type` · `title` · `description` · `tags` · `timestamp` · `full_id` · `perspective` · `hierarchy` · `parent_id` · `layer_scope`（本层固定 `system`）。详见 [okf-spec](../../../agent/knowledge/okf-spec.md) §2。

**正文四段**：`## 关系` · `## 跨视角` · `## 详细说明` · `## 依据与证据`。

### 各层专属（正文 / 扩展）

| 层级 | 字段 | 建议段落 |
| --- | --- | --- |
| MDG | `definition_scope: reference`、`governance_owner` | FM 扩展 / 详细说明 |
| DS | 存储 `type`、`config_key`、`owned_by_app_id`、`authoritative_mdg_id`（推荐） | 详细说明 / 跨视角 |
| ENT | `logical_name`、`physical_table`、`maps_to_aggregate_id`（推荐） | 详细说明 / 跨视角 |

---

## 5. 跨视角引用

| 源字段 | 目标 | 说明 |
| --- | --- | --- |
| MDG（reference） | company MDG.full_id | 上游公司 SSOT |
| DS.authoritative_mdg_id | MDG.full_id | 数据源归属主数据域 |
| DS.owned_by_app_id | APP.full_id | 数据源归属应用 |
| AGG.persisted_as_entity_ids | ENT.full_id | 聚合持久化 |
| ENT.maps_to_aggregate_id | AGG.full_id | 实体归属聚合 |

---

## 6. 关联文档

| 路径 | 说明 |
| --- | --- |
| [README.md](README.md) | 叙事文档索引 |
| [../index.md](../index.md) | MDG/DS/ENT 实例 SSOT |
| [../../DESIGN.md](../../DESIGN.md) | 系统库设计契约 |
| [../../../company/knowledge/data/data-meta.md](../../../company/knowledge/data/data-meta.md) | 公司级 MDG 元数据 |
| [../../../agent/knowledge/naming-conventions.md](../../../agent/knowledge/naming-conventions.md) | ID 命名 SSOT |

**索引**：`readme_index_table: false`；变更 ID 时同步 index.md 与 narrative 章节（按需）。
