---
type: Perspective Meta
title: 业务视角元数据（company/knowledge/business）
---
# 业务视角元数据（company/knowledge/business）

**结论**：VC / BD / BL / BSD-L1 / CAP 视角元数据 SSOT。BA：VC→CAP 能力目录 ∥ BD 域模型；BL 无 parent，`maps_to` BSD-L1 一对一；BSD-L1 `maps_to` CAP。实例：[README.md](README.md#实体)。

## 1. 概览

| 字段 | 值 |
| --- | --- |
| meta_id | `DIR-COMPANY-KNOWLEDGE-BUSINESS` |
| 视角 | business |
| 层级范围 | company |

## 2. 层级链

能力目录与域模型各成一条链。BL 不进链。

| 链 | 链序 | 层级代码 |
| --- | --- | --- |
| 能力目录 | 1 | VC |
| 能力目录 | 2 | CAP |
| 域模型 | 1 | BD |
| 域模型 | 2 | BSD-L1 |

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
| VC | `supported_by`、`implemented_by` | 列表必填 |
| BD | `supports_to`、`children` | `supports_to` 单值必填；`children` 列表必填，仅 BSD-L1 |
| BL | `maps_to`、`mapped_by` | `maps_to` 单值必填；`mapped_by` 列表，含解决方案 PL（纯 ID） |
| BSD-L1 | `level`、`parent`、`children`、`maps_to`、`mapped_by` | `level` 固定 `1`；`children` 仅 BSD-L2；`maps_to` 单值必填；`mapped_by` 列表必填 |
| CAP | `implements_to`、`mapped_by` | `implements_to` 单值必填；`mapped_by` 列表必填 |
| BD | `strategic_classification` | 正文扩展 |

## 5. 跨视角引用

同视角边的方向见 glossary。此处只留跨层约束。

| 源字段 | 目标 | 说明 |
| --- | --- | --- |
| BSD-L1.children | BSD-L2.id | 仅 L2 |

## 6. 关联文档

| 路径 | 说明 |
| --- | --- |
| [README.md](README.md) | 叙事索引 |
| [README.md](README.md#实体) | 实例台账 |
| naming-conventions | ID 命名 |
