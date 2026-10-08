---
type: Application
title: 示例应用
description: null
tags: [application, APP]
timestamp: "2026-06-21T00:00:00+08:00"
id: APP-EXAMPLE
perspective: application
hierarchy: APP
layer_scope: system
---
## 关系

- implements_to: [SYS-EXAMPLE](../SYS-EXAMPLE.md)
- implemented_by:
  - [MS-EXAMPLE](MS-EXAMPLE/MS-EXAMPLE.md)

## 跨视角

- supports_to: [BC-EXAMPLE](../../business/BSD-EXAMPLE-L3/BC-EXAMPLE/BC-EXAMPLE.md)
- uses_to:
  - [DS-EXAMPLE](../../data/DS-EXAMPLE/DS-EXAMPLE.md)
  - MW-EXAMPLE

## 详细说明

- startup_class: ExampleApp
- maven_module: example-module
- repo_url: `git@example.com:org/example.git`

## 依据与证据

[../chapters/application-architecture.md](../chapters/application-architecture.md#应用)（示例）
