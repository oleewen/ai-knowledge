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

- parent: SLN-EXAMPLE
- children:
  - APP-EXAMPLE

## 跨视角

- maps_to: PD-EXAMPLE
- uses_to:
  - MDG-EXAMPLE
  - TSD-EXAMPLE

## 详细说明

- definition_scope: local
- architecture:
  - apps: [APP-EXAMPLE]
  - external_dependencies: [ExternalExample/HTTP]
  - ddd_layers: [interface, application, domain, infrastructure]

## 依据与证据

chapters/application-overview.md（示例）
