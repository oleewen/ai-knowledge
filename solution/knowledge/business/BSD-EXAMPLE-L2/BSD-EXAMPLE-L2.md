---
type: Business Subdomain
title: 示例二级业务子域
description: BSD-L2；parent→公司 L1；mapped_by → BS 一对一。
tags: [business, BSD]
timestamp: "2026-10-04T00:00:00+08:00"
id: BSD-EXAMPLE-L2
perspective: business
hierarchy: BSD
layer_scope: solution
level: 2
mapped_by:
  - BS-EXAMPLE
---
## 关系

- parent: BSD-EXAMPLE（公司 BSD-L1，示例 ID）
- children:
  - BSD-EXAMPLE-L3（系统库）
- mapped_by:
  - [BS-EXAMPLE](../BS/BS-EXAMPLE.md)

## 跨视角

（none）

## 详细说明

- definition_scope: local
- level: 2

## 依据与证据

[../chapters/business-domain-division.md](../chapters/business-domain-division.md#二级子域)（示例）
