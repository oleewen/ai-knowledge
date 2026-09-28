---
type: Perspective Meta
title: 数据视角元数据（system/knowledge/data）
---
# 数据视角元数据（system/knowledge/data）

**结论**：MDG→DS→ENT 视角元数据 SSOT；应用层补 TBL。SYS 经 `uses_to` 声明使用。实例：[index.md](../index.md)。

## 1. 概览

| 字段 | 值 |
| --- | --- |
| meta_id | `DIR-SYSTEM-KNOWLEDGE-DATA` |
| 视角 | data |
| 层级范围 | system |
| 说明 | MDG/DS/ENT = 本层 SSOT；应用层补 TBL。 |

## 2. 层级链

| 链序 | 层级代码 | 说明 |
| --- | --- | --- |
| 1 | MDG | 主数据域（本层首次） |
| 2 | DS | 数据存储（本层首次） |
| 3 | ENT | 数据实体（表/集合，本层首次） |

## 3. 层定义

| order | key | code | id_pattern | parent |
| --- | --- | --- | --- | --- |
| 1 | mdg | MDG | `MDG-{NAME}` | — |
| 2 | ds | DS | `DS-{NAME}` | MDG（逻辑归属，`implements_to`） |
| 3 | ent | ENT | `ENT-{NNN}` 或 `ENT-{NAME}` | DS |

落盘：`MDG-{NAME}.md` 平铺；`DS-{NAME}/` 含 DS/ENT。

## 4. 字段（OKF）

Frontmatter 10 必填 + 正文四段见 [okf-spec](../../../agent/knowledge/okf-spec.md) §2；`layer_scope` = `system`。

| 层级 | 字段 | 建议段落 |
| --- | --- | --- |
| MDG | `governance_owner`、`implemented_by` | 详细说明 / 关系 |
| DS | 存储 `type`、`config_key`、`implements_to`、`used_by` | 详细说明 / 关系 / 跨视角 |
| ENT | `logical_name`、`physical_table`、`implements_to`、`maps_to` | 详细说明 / 跨视角 |

## 5. 跨视角引用

| 源字段 | 目标 | 说明 |
| --- | --- | --- |
| SYS.uses_to | MDG.id | 系统声明使用的主数据域 |
| DS.implements_to | MDG.id | 数据源归属主数据域 |
| DS.used_by | APP.id | 数据源被应用使用（对端 APP.uses_to） |
| AGG.maps_to | ENT.id | 聚合对标实体 |
| ENT.maps_to | AGG.id | 实体对标聚合 |

## 6. 关联文档

| 路径 | 说明 |
| --- | --- |
| [README.md](README.md) | 叙事索引 |
| [index.md](../index.md) | 实例 SSOT |
| [knowledge-governance](../../../agent/knowledge/knowledge-governance.md) | 系统库契约 |
| [naming-conventions](../../../agent/knowledge/naming-conventions.md) | ID 命名 |

**索引**：`readme_index_table: false`；变更 ID 时同步 index.md 与 narrative（按需）。
