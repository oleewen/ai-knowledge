---
type: Documentation
title: 应用架构
---
# 应用架构

[返回 · knowledge](../README.md)

应用侧应用入口：API SSOT；SYS 公司首次定义，APP/MS 系统首次定义。实体以 per-entity 与 [../index.md](../index.md) §3 为准。本 README 表仅登记本层 SSOT 样例；reference 见 §3。归档目标章 ∈ `chapters/`。

## 章节

| 章节 | 文件 | 概述 |
|------|------|------|
| 系统概述 | [chapters/application-overview.md](chapters/application-overview.md) | 本应用一页纸 |
| 应用架构 | [chapters/application-architecture.md](chapters/application-architecture.md) | 结构与边界 |
| 领域模型 | [chapters/application-domain-model.md](chapters/application-domain-model.md) | 实现侧模型 |
| 服务设计 | [chapters/application-service-design.md](chapters/application-service-design.md) | 服务拆分 |
| 领域能力 | [chapters/application-domain-capability.md](chapters/application-domain-capability.md) | 能力与 SLA |
| 集成架构 | [chapters/application-integration.md](chapters/application-integration.md) | 第三方（按需） |
| 服务间交互 | [chapters/application-inter-service.md](chapters/application-inter-service.md) | 同步/异步（按需） |
| 接口管理 | [chapters/application-interface-management.md](chapters/application-interface-management.md) | API 与版本（按需） |
| 多租户多环境 | [chapters/application-multi-tenant-environment.md](chapters/application-multi-tenant-environment.md) | 租户与环境（按需） |
| ADR | — | 应用层决策见 `adr/` |

## 实体

| 链序 | 层级 | ID | 名称 | 文件/目录 |
|------|------|----|------|-----------|
| L4 | API | API-EXAMPLE | 示例 API：创建 | [MS-EXAMPLE/API-EXAMPLE.md](MS-EXAMPLE/API-EXAMPLE.md) |
