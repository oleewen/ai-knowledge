---
type: Architecture Chapter
tags: [architecture, chapter]
title: 数据模型
---
# 数据模型

[返回 · 数据架构](../README.md)

本系统数据源与物理层结构。

> **数据模型 SSOT**：公司级数据原则见 [`data-overview.md`](../../../../company/knowledge/data/chapters/data-overview.md)。

与 [领域模型](../../application/chapters/application-domain-model.md)、[概念模型](../../business/chapters/business-glossary.md#概念模型) 交叉对齐。

## 物理模型

### 数据源

列出 OLTP、缓存、消息、对象存储等类型、用途与 SSOT 归属。

### 数据实体

写持久化实体定义及与领域模型/主数据的对应。

### 数据表

写表结构、索引、分区与 DDL 版本入口。

## 服务实体映射

按服务列出核心数据实体及跨服务引用处理方式。

## 模型版本

写 Migration 规范、兼容策略与生产变更审批。
