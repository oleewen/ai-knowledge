---
type: Microservice
title: 示例微服务
description: null
tags: [application, MS]
timestamp: "2026-06-21T00:00:00Z"
full_id: MS-EXAMPLE
perspective: application
hierarchy: MS
parent_id: APP-EXAMPLE
layer_scope: application
---
## 关系

- parent: APP-EXAMPLE
- children:
  - API-EXAMPLE-001

## 跨视角

- cross_references:
  - BC-EXAMPLE
  - PM-EXAMPLE
  - API-EXAMPLE-001

## 详细说明

- 上游主定义：`APP-EXAMPLE`（系统层 OKF SSOT）
- host_class: ExampleApiImpl
- host_module: example-module
- protocol: HTTP
- definition_scope: reference

## 依据与证据

示例数据
