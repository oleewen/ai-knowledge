---
type: System
title: 示例系统
description: 演示公司级 SYS 结构。
tags: [application, SYS]
timestamp: "2026-06-21T00:00:00Z"
full_id: SYS-EXAMPLE
perspective: application
hierarchy: SYS
parent_id: null
layer_scope: company
---
## 关系

- (none)

## 跨视角

- (none)

## 详细说明

- definition_scope: local
- architecture:
  - apps: [APP-EXAMPLE]
  - external_dependencies: [ExternalExample/HTTP]
  - ddd_layers: [interface, application, domain, infrastructure]

## 依据与证据

chapters/application-overview.md（示例）
