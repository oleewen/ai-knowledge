---
type: Documentation
title: 应用架构
---
# 应用架构

[返回 · 系统知识库](../README.md)

**本层 SSOT**：SYS→APP→MS（SYS.`implements_to`→解决方案 SLN）。下层实体不涉及。企业标准只引用公司 application。方案 SSOT 只引用解决方案 application。字段 [application-meta.md](../../../agent/knowledge/application-meta.md)。

目录与阅读顺序见 [index.md](index.md)。

上一级索引：[../index.md](../index.md)。

## 章节

| 章节 | 文件 | 概述 |
|------|------|------|
| 系统概述 | [chapters/application-overview.md](chapters/application-overview.md) | 相对方案的使命、场景、范围差异。SYS 登记在系统范围 |
| 应用架构 | [chapters/application-architecture.md](chapters/application-architecture.md) | 应用与微服务。上下文与分层见公司，职责边界、能力矩阵、演进见方案 |
| 领域模型 | [chapters/application-domain-model.md](chapters/application-domain-model.md) | APP/MS 如何使用已登记的 BC、AGG |
| 服务设计 | [chapters/application-service-design.md](chapters/application-service-design.md) | 拆分、契约与 C4。MS 编号以应用架构为准 |
| 集成架构 | [chapters/application-integration.md](chapters/application-integration.md) | 本系统外部对接 |

系统层决策见 [adr/](../../adr/README.md)，不进 chapters。

## 实体

| 链序 | 层级 | ID | 名称 | 文件/目录 |
|------|------|----|------|-----------|
| L2 | SYS | SYS-EXAMPLE | 示例系统 | [SYS-EXAMPLE.md](SYS-EXAMPLE.md) |
| L3 | APP | APP-EXAMPLE | 示例应用 | [APP-EXAMPLE/APP-EXAMPLE.md](APP-EXAMPLE/APP-EXAMPLE.md) |
| L4 | MS | MS-EXAMPLE | 示例微服务 | [APP-EXAMPLE/MS-EXAMPLE/MS-EXAMPLE.md](APP-EXAMPLE/MS-EXAMPLE/MS-EXAMPLE.md) |
