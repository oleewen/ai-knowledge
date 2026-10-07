---
type: Business Process
title: 示例解决方案主流程
description: 一个 SLN 一条主流程；implements_to SLN。
tags: [product, BP]
timestamp: "2026-10-06T00:00:00+08:00"
id: BP-EXAMPLE
perspective: product
hierarchy: BP
parent_id: null
layer_scope: solution
implements_to: SLN-EXAMPLE
children:
  - BSP-EXAMPLE
---
## 关系

- implements_to: SLN-EXAMPLE
- children:
  - BSP-EXAMPLE

## 跨视角

（none）

## 详细说明

- definition_scope: local
- 一个 SLN 一条 BP。与 PD 之间无 `maps_to`。

## 依据与证据

chapters/product-architecture.md（示例）
