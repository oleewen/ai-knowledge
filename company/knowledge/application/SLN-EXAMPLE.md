---
type: Solution
title: 示例解决方案
description: 解决方案（对应 PL）；maps_to_pl_id→PL；SYS.parent_id→本 SLN。
tags: [application, SLN]
timestamp: "2026-09-13T00:00:00Z"
full_id: SLN-EXAMPLE
perspective: application
hierarchy: SLN
parent_id: null
layer_scope: company
maps_to_pl_id: PL-EXAMPLE
---
## 关系

- maps_to_pl_id: PL-EXAMPLE

## 跨视角

- uses_mdg_ids: [MDG-EXAMPLE]
- 下游系统：SYS-EXAMPLE（系统库；parent_id→本 SLN）

## 详细说明

- definition_scope: local
- 一 PL 一 SLN 同建；可挂多个 SYS

## 依据与证据

chapters/application-architecture.md（示例）
