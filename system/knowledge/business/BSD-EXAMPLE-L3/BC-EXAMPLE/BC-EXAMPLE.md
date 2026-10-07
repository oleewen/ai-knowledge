---
type: Bounded Context
title: 示例限界上下文
description: 示例业务实体。
tags: [business, BC]
timestamp: "2026-06-21T00:00:00+08:00"
id: BC-EXAMPLE
perspective: business
hierarchy: BC
parent_id: BSD-EXAMPLE-L3
layer_scope: system
---
## 关系

- implements_to: BSD-EXAMPLE-L3
- implemented_by:
  - AGG-EXAMPLE

## 跨视角

- supported_by: APP-EXAMPLE
- mapped_by:
  - PM-EXAMPLE

## 详细说明

- (none)

## 依据与证据

chapters/business-capability-map.md（示例）
