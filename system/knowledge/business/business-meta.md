---
type: Perspective Meta
title: 业务视角元数据（system/knowledge/business）
---
# 业务视角元数据（system/knowledge/business）

**结论**：BSD-L3→BC→AGG→AB 本层 SSOT。BSD-L1 为公司纯 ID。BSD-L2 为解决方案纯 ID。本层不落 L1、L2 文件。实例：[index.md](../index.md)。

## 1. 概览

| 字段 | 值 |
| --- | --- |
| meta_id | `DIR-SYSTEM-KNOWLEDGE-BUSINESS` |
| 视角 | business |
| 层级范围 | system |
| 说明 | BSD-L3→BC→AGG→AB = 本层 SSOT。BSD-L1 公司纯 ID；BSD-L2 解决方案纯 ID。本层不落 L1、L2 文件。 |

## 2. 层级链

| 链序 | 层级代码 | 说明 |
| --- | --- | --- |
| 1 | BD | 业务域（公司 SSOT；本层不落文件） |
| 2 | BSD-L1 | 业务子域（公司 SSOT；本层不落文件；`level: 1`） |
| — | BSD-L2 | 业务子域（解决方案 SSOT；本层不落文件；纯 ID；`level: 2`） |
| 3 | BSD-L3 | 业务子域（本层 SSOT；`parent`→解决方案 BSD-L2；`level: 3`） |
| 4 | BC | 限界上下文（本层 SSOT；`implements_to`→BSD-L3） |
| 5 | AGG | 聚合根（本层 SSOT） |
| 6 | AB | 领域能力（本层 SSOT） |

## 3. 层定义

| order | key | code | id_pattern | parent |
| --- | --- | --- | --- | --- |
| 1 | bd | BD | `BD-{NAME}` | —（公司纯 ID） |
| 2 | bsd1 | BSD | `BSD-{NAME}` | BD（`level: 1`；公司纯 ID） |
| — | bsd2 | BSD | `BSD-{NAME}-L2` | BSD-L1（`level: 2`；解决方案纯 ID） |
| 3 | bsd3 | BSD | `BSD-{NAME}-L3` | BSD-L2（`level: 3`；本层 SSOT） |
| 4 | bc | BC | `BC-{NAME}` | BSD-L3 |
| 5 | agg | AGG | `AGG-{NAME}` | BC |
| 6 | ab | AB | `AB-{NAME}` | AGG |

## 4. BD 落盘例外

| 层级 | 路径 | 说明 |
| --- | --- | --- |
| company | `BD-{NAME}.md` | 公司 SSOT |
| system | `knowledge/business/BSD-{L3}/BSD-{L3}.md` | 本层 SSOT（例：`BSD-EXAMPLE-L3/`）；其下 BC→AGG→AB |
| system | — | 不落 BD、BSD-L1、BSD-L2 文件 |
| application | `BD-*.md` | 应用 reference |

## 5. 字段（OKF）

Frontmatter 10 必填 + 正文四段见 [okf-spec](../../../agent/knowledge/okf-spec.md) §2；`layer_scope` = `system`。关系字段见 [glossary § 映射关系](../../../agent/knowledge/glossary.md#映射关系常用)。

| 层级 | 字段 | 建议段落 |
| --- | --- | --- |
| BSD-L3 | `level: 3`、`parent`、`implemented_by` | FM / 关系 |
| BC | `implements_to`、`implemented_by`、`supported_by` | 关系 / 跨视角 |
| AGG | `implements_to`、`implemented_by`、`maps_to` | 关系 / 跨视角 |
| AB | `implements_to`、`capability`、`maps_to` | 详细说明 / 跨视角 |

## 6. 跨视角引用

| 源字段 | 目标 | 说明 |
| --- | --- | --- |
| BSD-L3.parent | 解决方案 BSD-L2.id | 上级纯 ID，本层不落文件 |
| BC.supported_by | APP.id | 上下文由应用支撑（对端 APP.supports_to） |
| AGG.maps_to | ENT.id \| MS.id | 聚合对标实体 / 入口簇 |
| 应用层 AB.maps_to | API.id | 能力对标 API（下游） |

## 7. 关联文档

| 路径 | 说明 |
| --- | --- |
| [README.md](README.md) | 叙事索引 |
| [index.md](../index.md) | 实例 SSOT |
| [knowledge-governance](../../../agent/knowledge/knowledge-governance.md) | 系统库契约 |
| BD-* / CAP-* | 公司业务 SSOT（纯 ID） |
| [naming-conventions](../../../agent/knowledge/naming-conventions.md) | ID 命名 |

**索引**：`readme_index_table: false`；变更 ID 时同步 index.md 与 narrative（按需）。
