---
type: Documentation
title: 产品架构
---
# 产品架构

[返回 · 系统知识库 — 架构文档](../README.md)

**本层 SSOT**：PM→FT→FR→UC/BR。PD / BP 不落文件，纯 ID `PD-EXAMPLE` / `BP-EXAMPLE`（解决方案首次定义）。PL、SLN 仅纯 ID。企业标准只引用公司 product。方案 SSOT 只引用解决方案 product。台账 [../index.md](../index.md) §2；字段 [product-meta.md](product-meta.md)。

## 章节

| 章节 | 文件 | 概述 |
|------|------|------|
| 产品概述 | [chapters/product-overview.md](chapters/product-overview.md) | 本系统纳入的 PM。公司定位、度量、体验与方案产品线、产品服务、流程只引用 |
| 产品架构 | [chapters/product-architecture.md](chapters/product-architecture.md) | 产品模块 |
| 信息架构 | [chapters/product-information-architecture.md](chapters/product-information-architecture.md) | 导航与页面层级。设计规范与页面原型见公司层 product · product-ux |
| 产品功能 | [chapters/product-feature.md](chapters/product-feature.md) | 功能点与功能需求 |
| 用户旅程与场景 | [chapters/product-user-journeys.md](chapters/product-user-journeys.md) | 旅程、用例与业务规则 |

## 实体

| 链序 | 层级 | ID | 名称 | 文件/目录 |
|------|------|----|------|-----------|
| L2 | PM | PM-EXAMPLE | 示例产品模块 | [PD-EXAMPLE/PM-EXAMPLE/PM-EXAMPLE.md](PD-EXAMPLE/PM-EXAMPLE/PM-EXAMPLE.md) |
| L3 | FT | FT-EXAMPLE | 示例功能 | [PD-EXAMPLE/PM-EXAMPLE/FT-EXAMPLE/FT-EXAMPLE.md](PD-EXAMPLE/PM-EXAMPLE/FT-EXAMPLE/FT-EXAMPLE.md) |
| L4 | FR | FR-EXAMPLE | 示例功能需求 | [PD-EXAMPLE/PM-EXAMPLE/FT-EXAMPLE/FR-EXAMPLE/FR-EXAMPLE.md](PD-EXAMPLE/PM-EXAMPLE/FT-EXAMPLE/FR-EXAMPLE/FR-EXAMPLE.md) |
| L5 | UC | UC-EXAMPLE | 示例用例 | [PD-EXAMPLE/PM-EXAMPLE/FT-EXAMPLE/FR-EXAMPLE/UC-EXAMPLE.md](PD-EXAMPLE/PM-EXAMPLE/FT-EXAMPLE/FR-EXAMPLE/UC-EXAMPLE.md) |
| L6 | BR | BR-EXAMPLE | 示例规则 | [PD-EXAMPLE/PM-EXAMPLE/FT-EXAMPLE/FR-EXAMPLE/BR-EXAMPLE.md](PD-EXAMPLE/PM-EXAMPLE/FT-EXAMPLE/FR-EXAMPLE/BR-EXAMPLE.md) |
