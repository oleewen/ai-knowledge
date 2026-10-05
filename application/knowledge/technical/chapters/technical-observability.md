---
type: Architecture Chapter
tags: [architecture, chapter]
title: 可观测性
---
# 可观测性

[返回 · 技术架构](../README.md)

本应用指标、日志、链路与告警约定。

> **本章口径**：本应用实现落地（`docs-extract` / `docs-archive`）。本层首次定义仅 **API / TBL / MW / CMP**。上游公司 / 解决方案 / 系统实体用纯 ID 或 parent HTTP，不重复字段语义。

## 指标

写 RED/USE 或业务 KPI、采集路径与保留周期。

## 日志

写结构化字段、级别、关联 ID 与采样策略。

## 链路追踪

写 Trace 边界、采样率与跨服务传播约定。

## 告警与值班

写告警分级、路由、抑制与值班升级。
