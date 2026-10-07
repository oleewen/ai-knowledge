---
type: Perspective Meta
title: 业务视角元数据（company/knowledge/business）
---
# 业务视角元数据（company/knowledge/business）

**结论**：VC / BD / BL / BSD-L1 / CAP 视角元数据 SSOT。BA：VC→CAP 能力目录 ∥ BD 域模型；BL 无 parent，`maps_to` BSD-L1 一对一；BSD-L1 `maps_to` CAP。实例：[index.md](../index.md)。

## 1. 概览

| 字段 | 值 |
| --- | --- |
| meta_id | `DIR-COMPANY-KNOWLEDGE-BUSINESS` |
| 视角 | business |
| 层级范围 | company |
| 说明 | BA：VC→CAP 能力目录 ∥ BD 域模型；BL 无 parent，`maps_to` BSD-L1 一对一；BSD-L1 `maps_to` CAP。 |

## 2. 层级链

| 链序 | 层级代码 | 说明 |
| --- | --- | --- |
| 1 | VC | 价值链（能力目录根） |
| 2 | BD | 业务域（支撑 VC） |
| 3 | BSD-L1 | 业务子域（`level: 1`；挂 BD；由 BL 一对一映射；`maps_to` CAP） |
| 4 | CAP | 业务能力（实现 VC；由 BSD-L1 一对一映射） |

BL 不进上表序号。

| 层级代码 | 说明 |
| --- | --- |
| BL | 业务线；无 parent；`maps_to` BSD-L1 一对一 |

## 3. 层定义

| order | key | code | id_pattern | parent |
| --- | --- | --- | --- | --- |
| 1 | vc | VC | `VC-{NAME}` | — |
| 2 | bd | BD | `BD-{NAME}` | —（无 parent） |
| 3 | bsd1 | BSD | `BSD-{NAME}` | BD（`level: 1`） |
| 4 | cap | CAP | `CAP-{NAME}` | VC（经 `implements_to`，非同类树 `parent`） |
| — | bl | BL | `BL-{NAME}` | —（无 parent） |

目录：`VC-{NAME}/VC-{NAME}.md` + `VC-{NAME}/CAP-*.md`；`BD-{NAME}/BD-{NAME}.md` + `BD-{NAME}/BSD-*.md`；`BL/BL-{NAME}.md`（单文件）。

## 4. 字段（OKF）

Frontmatter 9 必填 + 正文四段见 okf-spec §2；`layer_scope` = `company`。关系字段见 glossary § 映射关系。

| 层级 | 字段 | 说明 |
| --- | --- | --- |
| VC | `supported_by`、`implemented_by` | 列表必填；与 BD/CAP 双向同步 |
| BD | `supports_to`、`children` | 单值/列表必填；children 仅 BSD-L1 |
| BL | `maps_to`、`mapped_by` | `maps_to` 单值必填，目标为 BSD-L1，一对一；`mapped_by` 列表，含解决方案 PL（纯 ID） |
| BSD-L1 | `level`、`parent`、`children`、`maps_to`、`mapped_by` | `level` 固定 `1`；`children` 仅 BSD-L2；`maps_to` 单值 CAP；`mapped_by` 列表，含 BL |
| CAP | `implements_to`、`mapped_by` | `implements_to` 单值必填，目标为 VC；`mapped_by` 列表，含 BSD-L1 |
| BD | `strategic_classification` | 正文扩展 |

## 5. 跨视角引用

| 源字段 | 目标 | 说明 |
| --- | --- | --- |
| CAP.implements_to | VC.id | CAP 实现价值链 |
| CAP.mapped_by | BSD-L1.id | 对端列表 |
| BD.supports_to | VC.id | BD 支撑价值链 |
| BL.maps_to | BSD-L1.id | 一对一 |
| BSD-L1.mapped_by | BL.id | 对端列表 |
| BSD-L1.maps_to | CAP.id | 一对一 |
| BSD-L1.children | BSD-L2.id | 仅 L2 |

## 6. 关联文档

| 路径 | 说明 |
| --- | --- |
| [README.md](README.md) | 叙事索引 |
| [index.md](../index.md) | 实例 SSOT |
| naming-conventions | ID 命名 |
