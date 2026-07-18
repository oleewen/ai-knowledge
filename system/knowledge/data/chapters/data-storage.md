---
type: Architecture Chapter
tags: [architecture, chapter]
title: 数据存储方案
---
# 数据存储方案

[返回 · 数据架构](../README.md)

本系统存储选型、分布与扩展策略.

> **数据存储 SSOT**：公司级数据治理框架见 [company/knowledge/data/README.md](../../../../company/knowledge/data/README.md)。

## 库选型

写关系型/文档/宽列等选型、实例拓扑与 SLA 匹配.

## 分库分表

写分片键、路由、全局 ID 与扩容再均衡.

## 读写分离

写主从/只读副本、复制延迟容忍与一致性读法.

## 冷热分离

写冷热判定、存储介质与查询路由.

## 数据归档

写归档触发、介质、可检索性与恢复路径.

## 服务存储分布

列出 DS-ID、服务、存储类型、数据域与 SLA.
