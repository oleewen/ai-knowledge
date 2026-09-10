---
type: Documentation
title: 业务架构
---
<!-- markdownlint-disable-next-line MD025 -->
# 业务架构

[返回 · 系统知识库 — 架构文档](../README.md)

系统层业务入口：BSD→AB SSOT；BD 为 company reference。实体以 per-entity 与 [../index.md](../index.md) §1 为准。本 README 表仅登记本层 SSOT 样例；reference 见 §1。

| 章节 | 文件 | 概述 |
|------|------|------|
| 业务概述 | [chapters/business-overview.md](chapters/business-overview.md) | 本系统业务定位与范围 |
| 业务域划分 | [chapters/business-domain-division.md](chapters/business-domain-division.md) | 域清单与父级关系 |
| 业务术语 | [chapters/business-glossary.md](chapters/business-glossary.md) | 术语与概念模型 |
| 业务流程 | [chapters/business-processes.md](chapters/business-processes.md) | 主责流程与能力映射 |
| 能力地图 | [chapters/business-capability-map.md](chapters/business-capability-map.md) | 能力落地与成熟度 |
| 业务规则与策略 | [chapters/business-rules-and-strategies.md](chapters/business-rules-and-strategies.md) | 策略与合规（按需） |

## 实体

| 链序 | 层级 | ID | 名称 | 文件/目录 |
|------|------|----|------|-----------|
| L2 | BSD | BSD-EXAMPLE | 示例业务子域 | [BSD-EXAMPLE/BSD-EXAMPLE.md](BSD-EXAMPLE/BSD-EXAMPLE.md) |
| L3 | BC | BC-EXAMPLE | 示例限界上下文 | [BSD-EXAMPLE/BC-EXAMPLE/BC-EXAMPLE.md](BSD-EXAMPLE/BC-EXAMPLE/BC-EXAMPLE.md) |
| L4 | AGG | AGG-EXAMPLE | 示例聚合 | [BSD-EXAMPLE/BC-EXAMPLE/AGG-EXAMPLE/AGG-EXAMPLE.md](BSD-EXAMPLE/BC-EXAMPLE/AGG-EXAMPLE/AGG-EXAMPLE.md) |
| L5 | AB | AB-EXAMPLE | 示例能力 | [BSD-EXAMPLE/BC-EXAMPLE/AGG-EXAMPLE/AB-EXAMPLE.md](BSD-EXAMPLE/BC-EXAMPLE/AGG-EXAMPLE/AB-EXAMPLE.md) |
