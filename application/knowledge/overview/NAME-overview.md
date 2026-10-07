---
type: Architecture Overview Buffer
tags: [overview, distill]
title: "{域名称}架构概览（{slug}-overview）"
---
<!-- markdownlint-disable-next-line MD025 -->
# {域名称}架构概览（{slug}-overview）

> **维护**：`docs-tag` phase 2（✅）→ phase 3（架构摘录，勿手改摘录行）。表行 ↔ 视角章节 `##`。应用 overview **非** docs-distill 目标；供 `docs-extract` / `docs-archive`。占位 `{域名称}`/`{slug}` 实例化时替换。

## 架构摘录

| 架构视角 | 主标题 | 副标题 |
| --- | --- | --- |
| _（运行 `--phase 3` 后填充）_ | | |

## [业务架构](../business/README.md)

本视角无章。标准在上游。此处只写纯 ID。

## [产品架构](../product/README.md)

本视角无章。标准在上游。API 对 FT 的绑定写在 API 实体。

## [应用架构](../application/README.md)

| 主标题 | 副标题 | 归档业务知识 |
| --- | --- | --- |
| [接口管理](../application/chapters/application-interface-management.md) | [内部 API](../application/chapters/application-interface-management.md#内部-api) | — |
| [接口管理](../application/chapters/application-interface-management.md) | [开放 API](../application/chapters/application-interface-management.md#开放-api) | — |
| [接口管理](../application/chapters/application-interface-management.md) | [版本策略](../application/chapters/application-interface-management.md#版本策略) | — |
| [接口管理](../application/chapters/application-interface-management.md) | [变更日志](../application/chapters/application-interface-management.md#变更日志) | — |
| ADR | 应用层决策见 `adr/` | — |

## [技术架构](../technical/README.md)

| 主标题 | 副标题 | 归档业务知识 |
| --- | --- | --- |
| [中间件与基础组件](../technical/chapters/technical-middleware.md) | [消息队列](../technical/chapters/technical-middleware.md#消息队列) | — |
| [中间件与基础组件](../technical/chapters/technical-middleware.md) | [缓存](../technical/chapters/technical-middleware.md#缓存) | — |
| [中间件与基础组件](../technical/chapters/technical-middleware.md) | [搜索引擎](../technical/chapters/technical-middleware.md#搜索引擎) | — |
| [中间件与基础组件](../technical/chapters/technical-middleware.md) | [配置注册](../technical/chapters/technical-middleware.md#配置注册) | — |
| [中间件与基础组件](../technical/chapters/technical-middleware.md) | [任务调度](../technical/chapters/technical-middleware.md#任务调度) | — |
| [中间件与基础组件](../technical/chapters/technical-middleware.md) | [对象存储](../technical/chapters/technical-middleware.md#对象存储) | — |
| [性能与扩展性](../technical/chapters/technical-performance-scalability.md) | [性能基线](../technical/chapters/technical-performance-scalability.md#性能基线) | — |
| [性能与扩展性](../technical/chapters/technical-performance-scalability.md) | [容量规划](../technical/chapters/technical-performance-scalability.md#容量规划) | — |
| [性能与扩展性](../technical/chapters/technical-performance-scalability.md) | [扩展策略](../technical/chapters/technical-performance-scalability.md#扩展策略) | — |
| [性能与扩展性](../technical/chapters/technical-performance-scalability.md) | [性能测试](../technical/chapters/technical-performance-scalability.md#性能测试) | — |

## [数据架构](../data/README.md)

| 主标题 | 副标题 | 归档业务知识 |
| --- | --- | --- |
| [数据模型](../data/chapters/data-model.md) | [物理模型](../data/chapters/data-model.md#物理模型) | — |
| [数据模型](../data/chapters/data-model.md) | [模型版本](../data/chapters/data-model.md#模型版本) | — |

---

## 附录

### 文档关键词

`yaml
keywords:
  - SYSNAME
  - 示例术语A
  - 示例术语B
`
