---
type: Documentation
title: 数据架构
---
# 数据架构

[返回 · 应用知识库](../README.md)

应用侧数据入口：TBL SSOT；MDG 解决方案首次定义，DS/ENT 系统首次定义。实体台账见下方「实体」表。上游实体不建本层文件，只写纯 ID。归档目标章 ∈ `chapters/`。存储类型与分片在系统层 data · 数据存储。

目录与阅读顺序见 [index.md](index.md)。

上一级索引：[../index.md](../index.md)。

## 章节

| 章节 | 文件 | 概述 |
|------|------|------|
| 数据模型 | [chapters/data-model.md](chapters/data-model.md) | 物理表与模型版本 |

## 实体

| 链序 | 层级 | ID | 名称 | 文件/目录 |
|------|------|----|------|-----------|
| L4 | TBL | TBL-EXAMPLE | 示例数据表 | [ENT-EXAMPLE/TBL-EXAMPLE.md](ENT-EXAMPLE/TBL-EXAMPLE.md) |
