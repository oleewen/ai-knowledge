---
type: Documentation
title: 数据架构
---
<!-- markdownlint-disable-next-line MD025 -->
# 数据架构

[返回 · 系统知识库 — 架构文档](../README.md)

系统层数据入口：DS/ENT SSOT；MDG 为 company reference；TBL 在 application。实体以 per-entity 与 [../index.md](../index.md) §4 为准。本 README 表仅登记本层 SSOT 样例；reference 见 §4。

| 章节 | 文件 | 概述 |
|------|------|------|
| 数据概述 | [chapters/data-overview.md](chapters/data-overview.md) | 原则与生命周期 |
| 数据模型 | [chapters/data-model.md](chapters/data-model.md) | 源与结构 |
| 数据存储 | [chapters/data-storage.md](chapters/data-storage.md) | 选型与分布 |
| 数据分析 | [chapters/data-analytics.md](chapters/data-analytics.md) | 主题与口径 |
| 数据流转 | [chapters/data-flow.md](chapters/data-flow.md) | 管道（按需） |

## 实体

| 链序 | 层级 | ID | 名称 | 文件/目录 |
|------|------|----|------|-----------|
| L2 | DS | DS-EXAMPLE | 示例数据源 | [DS-EXAMPLE/DS-EXAMPLE.md](DS-EXAMPLE/DS-EXAMPLE.md) |
| L3 | ENT | ENT-EXAMPLE | 示例实体 | [DS-EXAMPLE/ENT-EXAMPLE.md](DS-EXAMPLE/ENT-EXAMPLE.md) |
