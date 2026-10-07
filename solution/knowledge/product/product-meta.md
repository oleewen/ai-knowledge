---
type: Perspective Meta
title: 产品视角元数据（solution/knowledge/product）
---
# 产品视角元数据（solution/knowledge/product）

**结论**：本层 SSOT 是 PL、PD、BP、BSP。PM 及以下在系统层。

## 1. 概览

| 字段 | 值 |
| --- | --- |
| meta_id | `DIR-SOLUTION-KNOWLEDGE-PRODUCT` |
| 视角 | product |
| 层级范围 | solution |
| 说明 | PL / PD / BP / BSP 本层 SSOT。PM 及以下不落。 |

## 2. 层级链

| 链序 | 代码 | 本层 |
| --- | --- | --- |
| — | PL | 本层 SSOT |
| — | PD | 本层 SSOT |
| — | BP | 本层 SSOT |
| — | BSP | 本层 SSOT |
| — | PM 及以下 | 系统；本层不落 |

## 3. 层定义

| order | key | code | id_pattern | parent |
| --- | --- | --- | --- | --- |
| — | pl | PL | `PL-{NAME}` | — |
| — | pd | PD | `PD-{NAME}` | —（`implements_to` PL，非 parent） |
| — | bp | BP | `BP-{NAME}` | —（`implements_to` SLN，非 parent） |
| — | bsp | BSP | `BSP-{NAME}` | BP |

## 4. 字段（OKF）

| 层级 | 字段 | 说明 |
| --- | --- | --- |
| PL | `maps_to` | → 公司 BL，1:1 |
| PD | `implements_to`、`maps_to` | `implements_to` → PL；`maps_to` → BS，1:1 |
| BP | `implements_to` | → SLN |
| BSP | `parent`、`implements_to` | `parent` → BP；`implements_to` → PD |

## 5. 跨视角引用

| 源字段 | 目标 | 说明 |
| --- | --- | --- |
| PL.maps_to | 公司 BL.id | 1:1 |
| PD.implements_to | PL.id | 归属产品线 |
| PD.maps_to | BS.id | 1:1 |
| BP.implements_to | SLN.id | 归属方案 |
| BSP.parent | BP.id | 上级主流程 |
| BSP.implements_to | PD.id | 归属产品服务 |

## 6. 关联文档

| 路径 | 说明 |
| --- | --- |
| [README.md](README.md) | 叙事索引 |
| [index.md](../index.md) | 实例索引 |
