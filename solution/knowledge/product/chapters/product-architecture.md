---
type: Architecture Chapter
tags: [architecture, chapter]
title: 产品架构
---
# 产品架构

[返回 · 产品架构](../README.md)

本方案的产品服务、业务流程与业务子流程。

PM、FT、UC、BR 不在本层。本层不出现 SYS。

## 产品服务

写 PD 的 ID、`implements_to`（PL）、`maps_to`（BS）。

## 业务流程

写本方案的 BP。一个 SLN 一条，`implements_to` SLN。

## 业务子流程

写 BSP 的 `parent`（BP）、`implements_to`（PD）、kind（核心 / 分支 / 异常）。
