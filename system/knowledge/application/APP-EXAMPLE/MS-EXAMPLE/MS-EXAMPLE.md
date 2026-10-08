---
type: Microservice
title: 示例微服务
description: null
tags: [application, MS]
timestamp: "2026-06-21T00:00:00+08:00"
id: MS-EXAMPLE
perspective: application
hierarchy: MS
layer_scope: system
---
## 关系

- implements_to: [APP-EXAMPLE](../APP-EXAMPLE.md)

## 跨视角

- maps_to: [AGG-EXAMPLE](../../../business/BSD-EXAMPLE-L3/BC-EXAMPLE/AGG-EXAMPLE/AGG-EXAMPLE.md)
- uses_to: []
- cross_references:
  - [BC-EXAMPLE](../../../business/BSD-EXAMPLE-L3/BC-EXAMPLE/BC-EXAMPLE.md)
  - [PM-EXAMPLE](../../../product/PD-EXAMPLE/PM-EXAMPLE/PM-EXAMPLE.md)

## 详细说明

- host_class: ExampleApiImpl
- host_module: example-module
- protocol: HTTP

## 依据与证据

[../../chapters/application-architecture.md](../../chapters/application-architecture.md#微服务)（示例）
