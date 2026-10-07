---
type: Architecture Chapter
tags: [architecture, chapter]
title: 能力地图
---
# 能力地图

[返回 · 业务架构](../README.md)

本系统的三级子域、限界上下文、聚合与领域能力。

> **能力地图 SSOT**：公司级能力框架与成熟度见公司层 business · business-capability。

## 三级子域

写 BSD-L3 的编号、名称，各 `parent` 哪条解决方案 BSD-L2。

## 限界上下文

写 BC 的编号、名称，各 `implements_to` 本层 BSD-L3，`mapped_by` 哪个 PM。

## 聚合

写 AGG 的编号、名称，各 `implements_to` 哪个 BC。

## 领域能力

写 AB 的编号、名称，各 `implements_to` 哪个 AGG。
