---
type: Product Line
title: 示例产品线
description: 产品线；与一级 BSD 一对一，SLN 仍对标 PL（SLN 在 AA）。
tags: [product, PL]
timestamp: "2026-09-13T00:00:00Z"
full_id: PL-EXAMPLE
perspective: product
hierarchy: PL
parent_id: null
layer_scope: company
maps_to_bsd: BSD-EXAMPLE
---
## 关系

- maps_to_bsd: BSD-EXAMPLE

## 跨视角

- 对标一级业务子域：BSD-EXAMPLE（经 maps_to_bsd）
- 对标解决方案：SLN-EXAMPLE（经 SLN.maps_to_pl_id，AA）

## 详细说明

- target_users: [内部运营, 业务方]
- definition_scope: local
- 不直接对应二级 BSD / PD；产品服务自系统层 PD 起

## 依据与证据

chapters/product-architecture.md（示例）
