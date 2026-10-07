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

- parent: APP-EXAMPLE

## 跨视角

- maps_to: AGG-EXAMPLE
- uses_to: []
- cross_references:
  - BC-EXAMPLE
  - PM-EXAMPLE

## 详细说明

- host_class: ExampleApiImpl
- host_module: example-module
- protocol: HTTP

## 依据与证据

chapters/application-architecture.md（示例）
