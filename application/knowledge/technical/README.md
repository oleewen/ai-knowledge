---
type: Documentation
title: 技术架构
---
# 技术架构

[返回 · knowledge](../README.md)

应用侧技术入口：MW/CMP SSOT；TPL 公司、TSD 解决方案首次定义。实体以 per-entity 与 [../index.md](../index.md) §5 为准。本 README 表仅登记本层 SSOT 样例；reference 见 §5。归档目标章 ∈ `chapters/`。

## 章节

| 章节 | 文件 | 概述 |
|------|------|------|
| 技术概述 | [chapters/technical-overview.md](chapters/technical-overview.md) | 本应用选型 |
| 部署架构 | [chapters/technical-infrastructure.md](chapters/technical-infrastructure.md) | 部署与交付 |
| 中间件 | [chapters/technical-middleware.md](chapters/technical-middleware.md) | MW 绑定 |
| 性能扩展 | [chapters/technical-performance-scalability.md](chapters/technical-performance-scalability.md) | 容量 |
| 高可用与容灾 | [chapters/technical-ha-and-dr.md](chapters/technical-ha-and-dr.md) | 可用性 |
| 可观测性 | [chapters/technical-observability.md](chapters/technical-observability.md) | 指标日志链路 |

## 实体

| 链序 | 层级 | ID | 名称 | 文件/目录 |
|------|------|----|------|-----------|
| L2 | MW | MW-EXAMPLE | 示例中间件绑定 | [MW-EXAMPLE/MW-EXAMPLE.md](MW-EXAMPLE/MW-EXAMPLE.md) |
| L3 | CMP | CMP-EXAMPLE | 示例组件 | [MW-EXAMPLE/CMP-EXAMPLE.md](MW-EXAMPLE/CMP-EXAMPLE.md) |
