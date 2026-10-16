---
type: Documentation
title: 技术架构
---
# 技术架构

[返回 · 应用知识库](../README.md)

应用侧技术入口：MW/CMP SSOT；TPL 公司、TS 解决方案首次定义。实体台账见下方「实体」表。上游实体不建本层文件，只写纯 ID。归档目标章 ∈ `chapters/`。选型、高可用、可观测在上游。

目录与阅读顺序见 [index.md](index.md)。

上一级索引：[../index.md](../index.md)。

## 章节

| 章节 | 文件 | 概述 |
|------|------|------|
| 中间件 | [chapters/technical-middleware.md](chapters/technical-middleware.md) | 集群、TTL、索引、配置 |
| 性能扩展 | [chapters/technical-performance-scalability.md](chapters/technical-performance-scalability.md) | 只填本应用数字 |

## 实体

| 链序 | 层级 | ID | 名称 | 文件/目录 |
|------|------|----|------|-----------|
| L3 | MW | MW-EXAMPLE | 示例中间件绑定 | [MW-EXAMPLE/MW-EXAMPLE.md](MW-EXAMPLE/MW-EXAMPLE.md) |
| L4 | CMP | CMP-EXAMPLE | 示例组件 | [MW-EXAMPLE/CMP-EXAMPLE.md](MW-EXAMPLE/CMP-EXAMPLE.md) |
