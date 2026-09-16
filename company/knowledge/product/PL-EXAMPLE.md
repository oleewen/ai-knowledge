---
type: Product Line
title: 示例产品线
description: 产品线（支持 BD）；一 PL 一 SLN（SLN 在 AA）。
tags: [product, PL]
timestamp: "2026-09-13T00:00:00Z"
full_id: PL-EXAMPLE
perspective: product
hierarchy: PL
parent_id: null
layer_scope: company
---
## 关系

- (none)

## 跨视角

- 对标业务域：BD-EXAMPLE（经 BD.maps_to_pl_id）
- 对标解决方案：SLN-EXAMPLE（经 SLN.maps_to_pl_id，AA）

## 详细说明

- target_users: [内部运营, 业务方]
- definition_scope: local
- 支撑 CAP：由 CAP.maps_to_bd_id + BD.maps_to_pl_id 推导；不列 PD ID

## 依据与证据

chapters/product-architecture.md（示例）
