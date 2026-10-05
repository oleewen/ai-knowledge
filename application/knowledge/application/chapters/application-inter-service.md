---
type: Architecture Chapter
tags: [architecture, chapter]
title: 服务间交互
---
# 服务间交互

[返回 · 应用架构](../README.md)

本应用同步/异步协作、编排与依赖治理。

> **本章口径**：本应用实现落地（`docs-extract` / `docs-archive`）。本层首次定义仅 **API / TBL / MW / CMP**。上游公司 / 解决方案 / 系统实体用纯 ID 或 parent HTTP，不重复字段语义。

## 同步链路

写主要调用链、超时/重试/熔断与 Trace 约定。

## 事件流

写主题/队列命名、发布订阅、版本与幂等要求。

## 服务编排

写长事务编排模式、补偿与业务流程对应。

## 依赖矩阵

写服务间依赖类型、方向、循环依赖与禁止模式。
