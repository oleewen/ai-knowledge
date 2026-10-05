---
type: Product
title: 示例产品服务
description: 解决方案层 PD；与 SYS 1:1 maps_to；implements_to 公司 PL。
tags: [product, PD]
timestamp: "2026-10-04T00:00:00+08:00"
id: PD-EXAMPLE
perspective: product
hierarchy: PD
parent_id: PL-EXAMPLE
layer_scope: solution
maps_to:
  - SYS-EXAMPLE
  - BSD-EXAMPLE-L2
---
## 关系

- implements_to: PL-EXAMPLE
- maps_to:
  - SYS-EXAMPLE
  - BSD-EXAMPLE-L2
- implemented_by: PM-EXAMPLE（系统库）

## 跨视角

- 对标系统：SYS-EXAMPLE（系统库 SSOT）

## 详细说明

- definition_scope: local

## 依据与证据

chapters/product-architecture.md（示例）
