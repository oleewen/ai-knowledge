---
type: Perspective Meta
title: 数据视角元数据（system/knowledge/data）
---
# 数据视角元数据（system/knowledge/data）

系统级数据版图（MDG→DS→ENT）视角元数据 SSOT。实例索引：[index.md](../index.md)。

---

## 1. 概览

| 字段 | 值 |
| --- | --- |
| meta_id | `DIR-SYSTEM-KNOWLEDGE-DATA` |
| 层级范围 | system |
| 视角 | data |
| 说明 | MDG/DS/ENT = 本层 SSOT；应用层补 TBL。SYS 经 `uses_mdg_ids` 声明使用。 |

---

## 2. 层级链

| 链序 | 层级代码 | 说明 |
| --- | --- | --- |
| 1 | MDG | 主数据域（本层首次定义） |
| 2 | DS | 数据存储（本层首次定义） |
| 3 | ENT | 数据实体（表/集合，本层首次定义） |

---

## 3. 层定义

| order | key | code | id_pattern | parent |
| --- | --- | --- | --- | --- |
| 1 | mdg | MDG | `MDG-{NAME}` | — |
| 2 | ds | DS | `DS-{NAME}` | MDG（逻辑归属，`authoritative_mdg_id`） |
| 3 | ent | ENT | `ENT-{NNN}` 或 `ENT-{NAME}` | DS |

落盘：`MDG-{NAME}.md` 平铺；`DS-{NAME}/` 含 DS/ENT。

---

## 4. 字段（OKF）

Frontmatter 10 必填 + 正文四段见 [okf-spec](../../../agent/knowledge/okf-spec.md) §2；本层 `layer_scope` 固定 `system`。

### 各层专属（正文 / 扩展）

| 层级 | 字段 | 建议段落 |
| --- | --- | --- |
| MDG | `governance_owner` | 详细说明 |
| DS | 存储 `type`、`config_key`、`owned_by_app_id`、`authoritative_mdg_id`（推荐） | 详细说明 / 跨视角 |
| ENT | `logical_name`、`physical_table`、`maps_to_aggregate_id`（推荐） | 详细说明 / 跨视角 |

---

## 5. 跨视角引用

| 源字段 | 目标 | 说明 |
| --- | --- | --- |
| SYS.uses_mdg_ids | MDG.id | 系统声明使用的主数据域 |
| DS.authoritative_mdg_id | MDG.id | 数据源归属主数据域 |
| DS.owned_by_app_id | APP.id | 数据源归属应用 |
| AGG.persisted_as_entity_ids | ENT.id | 聚合持久化 |
| ENT.maps_to_aggregate_id | AGG.id | 实体归属聚合 |

---

## 6. 关联文档

| 路径 | 说明 |
| --- | --- |
| [README.md](README.md) | 叙事文档索引 |
| [index.md](../index.md) | MDG/DS/ENT 实例 SSOT |
| [knowledge-governance](../../../agent/knowledge/knowledge-governance.md) | 系统库设计契约 |
| [naming-conventions](../../../agent/knowledge/naming-conventions.md) | ID 命名 SSOT |

**索引**：`readme_index_table: false`；变更 ID 时同步 index.md 与 narrative 章节（按需）。
