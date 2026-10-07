---
type: Documentation
title: 数据架构
---
# 数据架构

[返回 · 系统知识库 — 架构文档](../README.md)

**本层 SSOT**：DS/ENT。MDG 不落文件，纯 ID `MDG-EXAMPLE`（解决方案首次定义）。TBL ∈ application。企业标准只引用公司 data。方案 SSOT 只引用解决方案 data。台账 [../index.md](../index.md) §4；字段 [data-meta.md](data-meta.md)。

## 章节

| 章节 | 文件 | 概述 |
|------|------|------|
| 数据模型 | [chapters/data-model.md](chapters/data-model.md) | 数据源与数据实体。主数据见方案，表见应用 |
| 数据存储 | [chapters/data-storage.md](chapters/data-storage.md) | 存储类型与数据分片 |

## 实体

| 链序 | 层级 | ID | 名称 | 文件/目录 |
|------|------|----|------|-----------|
| L2 | DS | DS-EXAMPLE | 示例数据源 | [DS-EXAMPLE/DS-EXAMPLE.md](DS-EXAMPLE/DS-EXAMPLE.md) |
| L3 | ENT | ENT-EXAMPLE | 示例实体 | [DS-EXAMPLE/ENT-EXAMPLE.md](DS-EXAMPLE/ENT-EXAMPLE.md) |
