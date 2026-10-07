---
type: Business Service
title: 示例业务服务
description: 业务服务；无 parent；maps_to BSD-L2 一对一。
tags: [business, BS]
timestamp: "2026-10-06T00:00:00+08:00"
id: BS-EXAMPLE
perspective: business
hierarchy: BS
layer_scope: solution
maps_to: BSD-EXAMPLE-L2
mapped_by:
  - PD-EXAMPLE
---
## 关系

- maps_to: BSD-EXAMPLE-L2
- mapped_by:
  - PD-EXAMPLE

## 跨视角

- 对端产品服务：PD-EXAMPLE

## 详细说明

- definition_scope: local
- 无 parent，不进 BD 树。与 PD、BSD-L2 均为一对一。

## 依据与证据

chapters/business-domain-division.md（示例）
