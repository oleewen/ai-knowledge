---
type: Product Line
title: 示例产品线
description: 产品线；解决方案首次定义；maps_to BL 一对一。
tags: [product, PL]
timestamp: "2026-10-06T00:00:00+08:00"
id: PL-EXAMPLE
perspective: product
hierarchy: PL
parent_id: null
layer_scope: solution
maps_to: BL-EXAMPLE
mapped_by:
  - SLN-EXAMPLE
implemented_by:
  - PD-EXAMPLE
---
## 关系

- maps_to: BL-EXAMPLE
- mapped_by:
  - SLN-EXAMPLE
- implemented_by:
  - PD-EXAMPLE

## 跨视角

- 对标业务线：BL-EXAMPLE

## 详细说明

- target_users: [内部运营, 业务方]
- definition_scope: local
- 一条 SLN 对标一条 PL。多个 PD 用 `implements_to` 挂在这条 PL 上。

## 依据与证据

chapters/product-line.md（示例）
