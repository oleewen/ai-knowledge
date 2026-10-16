---
type: Documentation
title: 数据架构
---
# 数据架构

[返回 · 系统知识库](../README.md)

**本层 SSOT**：DS/ENT。MDG 正文在解决方案；本层仅 **目录宿主** `MDG-EXAMPLE/`（不落 MDG 实体）。下层不建实体文件。反向边只写纯 ID。企业标准只引用公司 data。方案 SSOT 只引用解决方案 data。字段 [data-meta.md](../../../agent/knowledge/data-meta.md)。

目录与阅读顺序见 [index.md](index.md)。

上一级索引：[../index.md](../index.md)。

## 章节

| 章节 | 文件 | 概述 |
|------|------|------|
| 数据模型 | [chapters/data-model.md](chapters/data-model.md) | 数据源与数据实体。主数据见方案。下层不建实体文件。反向边只写纯 ID。 |
| 数据存储 | [chapters/data-storage.md](chapters/data-storage.md) | 存储类型与数据分片 |

## 实体

| 链序 | 层级 | ID | 名称 | 文件/目录 |
|------|------|----|------|-----------|
| L2 | DS | DS-EXAMPLE | 示例数据源 | [MDG-EXAMPLE/DS-EXAMPLE/DS-EXAMPLE.md](MDG-EXAMPLE/DS-EXAMPLE/DS-EXAMPLE.md) |
| L3 | ENT | ENT-EXAMPLE | 示例实体 | [MDG-EXAMPLE/DS-EXAMPLE/ENT-EXAMPLE.md](MDG-EXAMPLE/DS-EXAMPLE/ENT-EXAMPLE.md) |
