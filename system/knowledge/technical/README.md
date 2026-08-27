---
type: Documentation
title: 技术架构
---
<!-- markdownlint-disable-next-line MD025 -->
# 技术架构

[返回 · 系统知识库 — 架构文档](../README.md)

系统层技术入口：TSD SSOT；MW/CMP 首次在 application（本层可 reference）。

| 章节 | 文件 | 概述 |
|------|------|------|
| 技术概述 | [chapters/technical-overview.md](chapters/technical-overview.md) | 选型与决策基线 |
| 部署架构 | [chapters/technical-infrastructure.md](chapters/technical-infrastructure.md) | 计算、网络与交付 |
| 中间件 | [chapters/technical-middleware.md](chapters/technical-middleware.md) | 平台能力与绑定（指向 MW） |
| 性能扩展 | [chapters/technical-performance-scalability.md](chapters/technical-performance-scalability.md) | 容量与扩展 |
| 高可用与容灾 | [chapters/technical-ha-and-dr.md](chapters/technical-ha-and-dr.md) | 可用性与韧性 |
| 可观测性 | [chapters/technical-observability.md](chapters/technical-observability.md) | 指标、日志、链路与告警 |

## 实体

* 元数据：[technical-meta.md](technical-meta.md)
* 样例：[TSD-EXAMPLE.md](TSD-EXAMPLE.md) · [MW-EXAMPLE/](MW-EXAMPLE/index.md)（ref → application）

上层 reference：TPL-*
