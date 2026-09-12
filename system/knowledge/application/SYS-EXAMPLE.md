---
type: System
title: 示例系统
description: 系统首次定义；parent_id→公司 SLN；与 PD、首层 BSD 同建。
tags: [application, SYS]
timestamp: "2026-09-13T00:00:00Z"
full_id: SYS-EXAMPLE
perspective: application
hierarchy: SYS
parent_id: SLN-EXAMPLE
layer_scope: system
---
## 关系

- parent: SLN-EXAMPLE
- children:
  - APP-EXAMPLE

## 跨视角

- maps 产品能力：PD-EXAMPLE（经 PD.maps_to_sys_id）
- uses_tsd_ids: [TSD-EXAMPLE]

## 详细说明

- definition_scope: local
- architecture:
  - apps: [APP-EXAMPLE]
  - external_dependencies: [ExternalExample/HTTP]
  - ddd_layers: [interface, application, domain, infrastructure]

## 依据与证据

chapters/application-overview.md（示例）
