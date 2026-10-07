---
type: Business Subprocess
title: 示例业务子流程
description: 业务子流程；parent → BP；implements_to PD；kind = core。
tags: [product, BSP]
timestamp: "2026-10-06T00:00:00+08:00"
id: BSP-EXAMPLE
perspective: product
hierarchy: BSP
parent_id: BP-EXAMPLE
layer_scope: solution
kind: core
implements_to: PD-EXAMPLE
---
## 关系

- parent: BP-EXAMPLE
- implements_to: PD-EXAMPLE

## 跨视角

（none）

## 详细说明

- definition_scope: local
- kind: core（核心流程）。一个 PD 一条 core；branch 与 exception 可多条。每条 BSP 的 `implements_to` 指向一个 PD。

## 依据与证据

chapters/product-architecture.md（示例）
