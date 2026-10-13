---
type: System
title: 示例系统
description: 系统（别名应用服务）；implements_to 解决方案 SLN；maps_to PD。
tags: [application, SYS]
timestamp: "2026-09-13T00:00:00+08:00"
id: SYS-EXAMPLE
perspective: application
hierarchy: SYS
layer_scope: system
---
## 关系

- implements_to: SLN-EXAMPLE
- implemented_by: [APP-EXAMPLE](APP-EXAMPLE/APP-EXAMPLE.md)

## 跨视角

- maps_to: PD-EXAMPLE

## 详细说明

- 系统（别名应用服务）；implements_to 解决方案 SLN（纯 ID）；maps_to PD。解决方案层不回写这条边。

## 依据与证据

[chapters/application-overview.md](chapters/application-overview.md)（示例）
