---
type: Architecture Chapter
tags: [architecture, chapter]
title: 数据模型
---
# 数据模型

[返回 · 数据架构](../README.md)

本应用数据源与物理层结构。

> **本章口径**：本应用实现落地（`docs-extract` / `docs-archive`）。本层首次定义仅 **API / TBL / MW / CMP**。上游公司 / 解决方案 / 系统实体用纯 ID 或 parent HTTP，不重复字段语义。

与 [领域模型](../../application/chapters/application-domain-model.md)、[概念模型](../../business/chapters/business-glossary.md#概念模型) 交叉对齐。

## 物理模型

### 数据源

列出 OLTP、缓存、消息、对象存储等类型、用途与 SSOT 归属。

### 数据实体

写持久化实体定义及与领域模型/主数据的对应。

### 数据表

写表结构、索引、分区与 DDL 版本入口。本层 **TBL** 为 SSOT。

## 主数据

主数据域（`MDG-*`）首次定义在解决方案层。本章只写本应用表如何落实权威源，不重复 MDG 字段语义。

## 服务实体映射

按服务列出核心数据实体及跨服务引用处理方式。

## 模型版本

写 Migration 规范、兼容策略与生产变更审批。
