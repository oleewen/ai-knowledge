---
type: Documentation
title: 业务架构
---
# 业务架构

[返回 · 系统知识库 — 架构文档](../README.md)

**本层 SSOT**：BSD-L3→BC→AGG→AB。BSD-L1、BSD-L2 不落文件。企业标准只引用公司 business。方案 SSOT 只引用解决方案 business。台账 [../index.md](../index.md) §1；字段 [business-meta.md](business-meta.md)。

## 章节

| 章节 | 文件 | 概述 |
|------|------|------|
| 业务概述 | [chapters/business-overview.md](chapters/business-overview.md) | 本系统纳入的 BSD-L3。公司背景、目标、范围与方案范围、二级子域只引用 |
| 能力地图 | [chapters/business-capability-map.md](chapters/business-capability-map.md) | 三级子域、限界上下文、聚合与领域能力。公司能力成熟度只引用 |
| 业务术语 | [chapters/business-glossary.md](chapters/business-glossary.md) | 概念模型与业务术语 |

## 实体

| 链序 | 层级 | ID | 名称 | 文件/目录 |
|------|------|----|------|-----------|
| 3 | BSD-L3 | BSD-EXAMPLE-L3 | 示例三级业务子域 | [BSD-EXAMPLE-L3/BSD-EXAMPLE-L3.md](BSD-EXAMPLE-L3/BSD-EXAMPLE-L3.md) |
| 4 | BC | BC-EXAMPLE | 示例限界上下文 | [BSD-EXAMPLE-L3/BC-EXAMPLE/BC-EXAMPLE.md](BSD-EXAMPLE-L3/BC-EXAMPLE/BC-EXAMPLE.md) |
| 5 | AGG | AGG-EXAMPLE | 示例聚合 | [BSD-EXAMPLE-L3/BC-EXAMPLE/AGG-EXAMPLE/AGG-EXAMPLE.md](BSD-EXAMPLE-L3/BC-EXAMPLE/AGG-EXAMPLE/AGG-EXAMPLE.md) |
| 6 | AB | AB-EXAMPLE | 示例能力 | [BSD-EXAMPLE-L3/BC-EXAMPLE/AGG-EXAMPLE/AB-EXAMPLE.md](BSD-EXAMPLE-L3/BC-EXAMPLE/AGG-EXAMPLE/AB-EXAMPLE.md) |
