---
type: Product
title: 示例产品服务
description: 产品服务（别名业务服务）；与 SYS、二级 BSD 同建对标。
tags: [product, PD]
timestamp: "2026-09-13T00:00:00Z"
full_id: PD-EXAMPLE
perspective: product
hierarchy: PD
parent_id: PL-EXAMPLE
layer_scope: system
maps_to_sys_id: SYS-EXAMPLE
maps_to_bsd: BSD-EXAMPLE-SUB
---
## 关系

- parent: PL-EXAMPLE
- maps_to_sys_id: SYS-EXAMPLE
- maps_to_bsd: BSD-EXAMPLE-SUB
- children:
  - PM-EXAMPLE

## 跨视角

- 对标系统：SYS-EXAMPLE
- 二级业务子域：BSD-EXAMPLE-SUB（经 maps_to_bsd）

## 详细说明

- definition_scope: local
- 5A：PD∈PA；与 BA 二级 BSD、AA SYS 原子对齐

## 依据与证据

chapters/product-architecture.md（示例）
