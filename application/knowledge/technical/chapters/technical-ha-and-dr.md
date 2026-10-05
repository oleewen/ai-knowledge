---
type: Architecture Chapter
tags: [architecture, chapter]
title: 高可用与容灾
---
# 高可用与容灾

[返回 · 技术架构](../README.md)

本应用可用性目标、容灾与韧性实践。

> **本章口径**：本应用实现落地（`docs-extract` / `docs-archive`）。本层首次定义仅 **API / TBL / MW / CMP**。上游公司 / 解决方案 / 系统实体用纯 ID 或 parent HTTP，不重复字段语义。

## 高可用设计

写同城双活/异地多活/主备模式、复制方向与 RTO/RPO。

## 容灾方案

写灾难场景、恢复目标、备份异地复制与演练频率。

## 熔断降级

写网关/服务/依赖三层限流、熔断条件与降级预案。

## 混沌工程

写实验范围、安全护栏、回滚与结论沉淀。
