---
type: Perspective Meta
title: 产品视角元数据（system/knowledge/product）
---
# 产品视角元数据（system/knowledge/product）

**结论**：PM→FT→FR→UC/BR 本层 SSOT。PD / BP 为解决方案 reference。PL 解决方案 SSOT（仅引用）。SLN 解决方案 SSOT（仅引用）。实例：[index.md](../index.md)。

## 1. 概览

| 字段 | 值 |
| --- | --- |
| meta_id | `DIR-SYSTEM-KNOWLEDGE-PRODUCT` |
| 视角 | product |
| 层级范围 | system |
| 说明 | PD / BP 为解决方案 reference。PL / SLN 仅引用。PM 须与 PD 同库。 |

## 2. 层级链

| 链序 | 层级代码 | 说明 |
| --- | --- | --- |
| — | PL | 解决方案产品 SSOT；仅引用 |
| — | SLN | 解决方案 SSOT；仅引用 |
| — | PD | 产品服务（解决方案 SSOT；本层 reference） |
| 2 | PM | 产品模块 |
| 3 | FT | 功能点 |
| 4 | FR | 功能需求 |
| 5 | UC / BR | 用例 / 业务规则 |
| — | BP | 业务流程（解决方案 SSOT；本层 reference） |

## 3. 层定义

| order | key | code | id_pattern | parent |
| --- | --- | --- | --- | --- |
| — | pd | PD | `PD-{NAME}` | PL（解决方案；本层 reference） |
| 2 | pm | PM | `PM-{NAME}` | PD（只许本库 PD） |
| 3 | ft | FT | `FT-{NAME}` | PM |
| 4 | fr | FR | `FR-{NAME}` | FT |
| 5 | uc | UC | `UC-{NAME}` | FR |
| 6 | br | BR | `BR-{NAME}` | FR |
| — | bp | BP | `BP-{NAME}` | SLN（解决方案；本层 reference） |

目录：`PD-{NAME}/PD-{NAME}.md` + 其下 `PM-{NAME}/` 树。

**硬约束**：`SYS.maps_to` PD 与 `PD.maps_to` BS **成对填写**；禁跨系统 `PM→PD`。组成链用 `implements_to`/`implemented_by`（非同类树 `parent`）。BSP→BP 使用 `parent`。

## 4. 字段（OKF）

| 层级 | 字段 | 说明 |
| --- | --- | --- |
| PD | `implements_to`、`maps_to`、`implemented_by`、`mapped_by` | `implements_to`→PL；`maps_to`→BS；`implemented_by`→PM；`mapped_by`→SYS。本层不重复字段语义 |
| PM | `implements_to`、`implemented_by`、`maps_to`、`depends_to` | 组成 / 对标 BC / 模块依赖 |
| FT | `implements_to`、`implemented_by`、`supported_by` | 组成 / 支撑对端 API |
| BP | `implements_to` | →SLN；本层不重复字段语义 |

## 5. 跨视角引用

| 源字段 | 目标 | 说明 |
| --- | --- | --- |
| PD.implements_to | 解决方案 PL.id | 归属产品线 |
| PD.maps_to | 解决方案 BS.id | 对标业务服务（[glossary](../../../agent/knowledge/glossary.md#映射关系常用)） |
| PM.implements_to | 本库 PD.id | 模块归属产品服务 |
| PM.maps_to | BC.id | 模块对标限界上下文 |
| PM.depends_to | PM.id | 模块依赖其它模块 |
| FT.supported_by | API.id | 功能由 API 支撑（对端 API.supports_to） |

## 6. 关联文档

| 路径 | 说明 |
| --- | --- |
| [README.md](README.md) | 叙事索引 |
| [index.md](../index.md) | 实例 SSOT |
| 解决方案 PL-* | 上游产品线 |
| 解决方案 SLN-* | 上游解决方案（AA） |
