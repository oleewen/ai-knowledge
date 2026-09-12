---
type: Documentation
title: 产品架构
---
<!-- markdownlint-disable-next-line MD025 -->
# 产品架构

[返回 · 系统知识库 — 架构文档](../README.md)

系统层产品入口：PD→PM→FT→FR→UC/BR、BP；PL 公司产品 SSOT；SLN 公司 AA（本层不落盘）。

| 章节 | 文件 | 概述 |
|------|------|------|
| 产品概述 | [chapters/product-overview.md](chapters/product-overview.md) | 定位、用户与路线 |
| 产品架构 | [chapters/product-architecture.md](chapters/product-architecture.md) | 板块与 PD/PM/SYS 映射 |
| 信息架构 | [chapters/product-information-architecture.md](chapters/product-information-architecture.md) | 导航与内容模型 |
| 产品功能 | [chapters/product-feature.md](chapters/product-feature.md) | FT 与优先级 |
| 用户旅程与场景 | [chapters/product-user-journeys.md](chapters/product-user-journeys.md) | 触点与用例 |
| 版本管理与发布 | [chapters/product-release.md](chapters/product-release.md) | 版本、灰度与功能开关（按需） |
| 产品运营支撑 | [chapters/product-operations-support.md](chapters/product-operations-support.md) | 运营、内容与触达（按需） |
| 多端策略 | [chapters/product-multi-platform.md](chapters/product-multi-platform.md) | 端覆盖与差异（按需） |

## 实体

| 链序 | 层级 | ID | 名称 | 文件/目录 |
|------|------|----|------|-----------|
| L1 | PD | PD-EXAMPLE | 示例产品能力 | [PD-EXAMPLE/PD-EXAMPLE.md](PD-EXAMPLE/PD-EXAMPLE.md) |
| L2 | PM | PM-EXAMPLE | 示例产品模块 | [PD-EXAMPLE/PM-EXAMPLE/PM-EXAMPLE.md](PD-EXAMPLE/PM-EXAMPLE/PM-EXAMPLE.md) |
| L3 | FT | FT-EXAMPLE | 示例功能 | [PD-EXAMPLE/PM-EXAMPLE/FT-EXAMPLE/FT-EXAMPLE.md](PD-EXAMPLE/PM-EXAMPLE/FT-EXAMPLE/FT-EXAMPLE.md) |
| L4 | FR | FR-EXAMPLE | 示例功能需求 | [PD-EXAMPLE/PM-EXAMPLE/FT-EXAMPLE/FR-EXAMPLE/FR-EXAMPLE.md](PD-EXAMPLE/PM-EXAMPLE/FT-EXAMPLE/FR-EXAMPLE/FR-EXAMPLE.md) |
| L5 | UC | UC-EXAMPLE | 示例用例 | [PD-EXAMPLE/PM-EXAMPLE/FT-EXAMPLE/FR-EXAMPLE/UC-EXAMPLE.md](PD-EXAMPLE/PM-EXAMPLE/FT-EXAMPLE/FR-EXAMPLE/UC-EXAMPLE.md) |
| L6 | BR | BR-EXAMPLE | 示例规则 | [PD-EXAMPLE/PM-EXAMPLE/FT-EXAMPLE/FR-EXAMPLE/BR-EXAMPLE.md](PD-EXAMPLE/PM-EXAMPLE/FT-EXAMPLE/FR-EXAMPLE/BR-EXAMPLE.md) |
| L7 | BP | BP-EXAMPLE | 示例业务流程（BP） | [BP-EXAMPLE.md](BP-EXAMPLE.md) |
