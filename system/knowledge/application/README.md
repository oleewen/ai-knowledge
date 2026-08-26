---
type: Documentation
title: 应用架构
---
<!-- markdownlint-disable-next-line MD025 -->
# 应用架构

[返回 · 系统知识库 — 架构文档](../README.md)

系统层应用入口：APP/MS SSOT；SYS 为 company reference；API 在 application。

| 章节 | 文件 | 概述 |
|------|------|------|
| 系统概述 | [chapters/application-overview.md](chapters/application-overview.md) | 一页纸语境 |
| 应用架构 | [chapters/application-architecture.md](chapters/application-architecture.md) | 结构与边界 |
| 领域模型 | [chapters/application-domain-model.md](chapters/application-domain-model.md) | BC/AGG 落地 |
| 服务设计 | [chapters/application-service-design.md](chapters/application-service-design.md) | MS 拆分 |
| 领域能力 | [chapters/application-domain-capability.md](chapters/application-domain-capability.md) | AB 与 SLA |
| 集成架构 | [chapters/application-integration.md](chapters/application-integration.md) | 第三方与遗留集成（按需） |
| 服务间交互 | [chapters/application-inter-service.md](chapters/application-inter-service.md) | 同步/异步协作（按需） |
| 接口管理 | [chapters/application-interface-management.md](chapters/application-interface-management.md) | 内外 API 与版本（按需） |
| 多租户多环境 | [chapters/application-multi-tenant-environment.md](chapters/application-multi-tenant-environment.md) | 租户隔离与环境（按需） |
| ADR | [../../adr/README.md](../../adr/README.md) | 系统层决策（无强制 EXAMPLE） |

## 实体

* 元数据：[application-meta.md](application-meta.md)
* 样例：`SYS-EXAMPLE.md`（ref）· [APP-EXAMPLE/](APP-EXAMPLE/index.md)（内含 MS）

对照：[company/knowledge/application](../../../company/knowledge/application/README.md)
