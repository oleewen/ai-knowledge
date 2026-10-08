---
type: Bounded Context
title: 示例限界上下文
description: 示例业务实体。
tags: [business, BC]
timestamp: "2026-06-21T00:00:00+08:00"
id: BC-EXAMPLE
perspective: business
hierarchy: BC
layer_scope: system
---
## 关系

- implements_to: [BSD-EXAMPLE-L3](../BSD-EXAMPLE-L3.md)
- implemented_by:
  - [AGG-EXAMPLE](AGG-EXAMPLE/AGG-EXAMPLE.md)

## 跨视角

- supported_by: [APP-EXAMPLE](../../../application/APP-EXAMPLE/APP-EXAMPLE.md)
- mapped_by:
  - [PM-EXAMPLE](../../../product/PD-EXAMPLE/PM-EXAMPLE/PM-EXAMPLE.md)

## 详细说明

- (none)

## 依据与证据

[../../chapters/business-capability-map.md](../../chapters/business-capability-map.md#限界上下文)（示例）
