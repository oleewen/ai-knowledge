---
type: Product
title: 示例产品服务
description: 解决方案层 PD；implements_to PL；maps_to BS 一对一。
tags: [product, PD]
timestamp: "2026-10-06T00:00:00+08:00"
id: PD-EXAMPLE
perspective: product
hierarchy: PD
parent_id: null
layer_scope: solution
implements_to: PL-EXAMPLE
maps_to: BS-EXAMPLE
mapped_by:
  - SYS-EXAMPLE
implemented_by:
  - PM-EXAMPLE
  - BSP-EXAMPLE
---
## 关系

- implements_to: PL-EXAMPLE
- maps_to: BS-EXAMPLE
- mapped_by:
  - SYS-EXAMPLE
- implemented_by:
  - PM-EXAMPLE（系统库）
  - BSP-EXAMPLE

## 跨视角

- 对标业务服务：BS-EXAMPLE
- 对端系统：SYS-EXAMPLE（系统库）

## 详细说明

- definition_scope: local
- 与 BS、以及 BS 所对标的 BSD(L2) 均为一对一。

## 依据与证据

chapters/product-architecture.md（示例）
