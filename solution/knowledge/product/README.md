---
type: Documentation
title: 产品架构
---
# 产品架构

[返回 · 解决方案知识库](../README.md)

**本层 SSOT**：PL、PD、BP、BSP。下层不建实体文件。反向边只写纯 ID。企业标准只引用公司 product。章节见 [chapters/index.md](chapters/index.md)。字段 [product-meta.md](../../../agent/knowledge/product-meta.md)。

目录与阅读顺序见 [index.md](index.md)。

## 章节

| 章节 | 文件 | 概述 |
|------|------|------|
| 产品概述 | [chapters/product-overview.md](chapters/product-overview.md) | 本方案纳入的 PL、PD、BP、BSP。公司定位、路线、度量、体验只引用 |
| 产品线 | [chapters/product-line.md](chapters/product-line.md) | 产品线清单、职责边界与关系 |
| 产品架构 | [chapters/product-architecture.md](chapters/product-architecture.md) | 产品服务、业务流程与业务子流程。PM 以下不在本层 |

## 实体

| 链序 | 层级 | ID | 名称 | 文件/目录 |
|------|------|----|------|-----------|
| L1 | PL | PL-EXAMPLE | 示例产品线 | [PL-EXAMPLE/PL-EXAMPLE.md](PL-EXAMPLE/PL-EXAMPLE.md) |
| L2 | PD | PD-EXAMPLE | 示例产品服务 | [PL-EXAMPLE/PD-EXAMPLE.md](PL-EXAMPLE/PD-EXAMPLE.md) |
| L1 | BP | BP-EXAMPLE | 示例业务流程 | [BP/BP-EXAMPLE.md](BP/BP-EXAMPLE.md) |
| L2 | BSP | BSP-EXAMPLE | 示例业务子流程 | [BP/BSP-EXAMPLE.md](BP/BSP-EXAMPLE.md) |
