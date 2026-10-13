---
type: Product
title: 示例产品服务
description: 解决方案层 PD；implements_to PL；maps_to BS 一对一。
tags: [product, PD]
timestamp: "2026-10-06T00:00:00+08:00"
id: PD-EXAMPLE
perspective: product
hierarchy: PD
layer_scope: solution
---
## 关系

- implements_to: [PL-EXAMPLE](PL-EXAMPLE.md)
- maps_to: [BS-EXAMPLE](../../business/BS/BS-EXAMPLE.md)
- implemented_by:
  - [BSP-EXAMPLE](../BP/BSP-EXAMPLE.md)
  - PM-EXAMPLE

## 跨视角

- uses_to:
  - [MDG-EXAMPLE](../../data/MDG-EXAMPLE.md)
  - [TSD-EXAMPLE](../../technical/TSD-EXAMPLE.md)

## 详细说明

- 解决方案层 PD；implements_to PL；maps_to BS 一对一。

## 依据与证据

[../chapters/product-architecture.md](../chapters/product-architecture.md#产品服务)（示例）
