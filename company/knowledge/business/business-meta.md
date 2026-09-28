---
type: Perspective Meta
title: 业务视角元数据（company/knowledge/business）
---
# 业务视角元数据（company/knowledge/business）

**结论**：VC / BD / BSD(L1) / CAP 视角元数据 SSOT。BA：VC→CAP 能力目录 ∥ BD 域模型；BSD(L1) 桥接 CAP 与 PL。实例：[index.md](../index.md)。

## 1. 概览

| 字段 | 值 |
| --- | --- |
| meta_id | `DIR-COMPANY-KNOWLEDGE-BUSINESS` |
| 视角 | business |
| 层级范围 | company |
| 说明 | BA：VC→CAP 能力目录 ∥ BD 域模型；BSD(L1) 桥接 CAP 与 PL。 |

## 2. 层级链

| 链序 | 层级代码 | 说明 |
| --- | --- | --- |
| 1 | VC | 价值链（能力目录根） |
| 2 | BD | 业务域（支撑 VC） |
| 3 | BSD(L1) | 业务子域（`level: 1`；挂 BD；对标 PL） |
| 4 | CAP | 业务能力（实现 VC；一对一映射 BSD(L1)） |

## 3. 层定义

| order | key | code | id_pattern | parent |
| --- | --- | --- | --- | --- |
| 1 | vc | VC | `VC-{NAME}` | — |
| 2 | bd | BD | `BD-{NAME}` | —（平铺单文件） |
| 3 | bsd1 | BSD | `BSD-{NAME}` | BD（`level: 1`） |
| 4 | cap | CAP | `CAP-{NAME}` | VC（经 `implements_to`，非同类树 `parent`） |

目录：`VC-{NAME}/VC-{NAME}.md` + `VC-{NAME}/CAP-*.md`；`BD-{NAME}.md`、一级 `BSD-{NAME}.md` 平铺。

## 4. 字段（OKF）

Frontmatter 10 必填 + 正文四段见 [okf-spec](../../../agent/knowledge/okf-spec.md) §2；`layer_scope` = `company`。关系字段见 [glossary § 映射关系](../../../agent/knowledge/glossary.md#映射关系常用)。

| 层级 | 字段 | 说明 |
| --- | --- | --- |
| VC | `supported_by`、`implemented_by` | 列表必填；与 BD/CAP 双向同步 |
| BD | `supports_to`、`children` | 单值/列表必填；children 仅 BSD(L1) |
| BSD(L1) | `level`、`parent`、`maps_to` | `level` 固定 `1`；`maps_to` 混列 PL\|CAP（前缀辨型） |
| CAP | `implements_to`、`maps_to` | 均单值必填；`maps_to` 目标必须为 BSD(L1) |
| BD | `strategic_classification` | 正文扩展 |

## 5. 跨视角引用

| 源字段 | 目标 | 说明 |
| --- | --- | --- |
| CAP.implements_to | VC.id | CAP 实现价值链 |
| CAP.maps_to | BSD(L1).id | CAP 与 BSD(L1) 一对一 |
| BD.supports_to | VC.id | BD 支撑价值链 |
| BSD(L1).maps_to | PL.id \| CAP.id | BSD(L1) 对标产品线 / 能力 |

## 6. 关联文档

| 路径 | 说明 |
| --- | --- |
| [README.md](README.md) | 叙事索引 |
| [index.md](../index.md) | 实例 SSOT |
| [naming-conventions](../../../agent/knowledge/naming-conventions.md) | ID 命名 |
