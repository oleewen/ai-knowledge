# 应用架构

[返回上一级 · 架构文档索引](../README.md)

本目录为应用架构**目录与入口**。🔑 核心文件为必维护项；📎 补充文件按系统复杂度按需启用；📐 决策记录与架构变更同步。

| 类型 | 章节 | 文件 | 概述 |
|------|------|------|------|
| 🔑 | 系统概述 | [application-overview.md](application-overview.md) | 一页纸 SSOT，为全景图、服务设计与集成提供语境。 |
| 🔑 | 应用架构 | [application-architecture.md](application-architecture.md) | 应用结构、职责边界与分层演进。 |
| 🔑 | 领域模型 | [application-domain-model.md](application-domain-model.md) | 聚合/实体边界、类图及关键属性。 |
| 🔑 | 服务设计 | [application-service-design.md](application-service-design.md) | 服务单元拆分至容器与组件粒度。 |
| 🔑 | 领域能力 | [application-domain-capability.md](application-domain-capability.md) | 领域能力及 SLA，对应业务能力承载。 |
| 📎 | 集成架构 | [application-integration.md](application-integration.md) | 第三方与遗留系统集成及防腐边界。 |
| 📎 | 服务交互 | [application-inter-service.md](application-inter-service.md) | 同步/异步协作、编排与依赖治理。 |
| 📎 | 接口管理 | [application-interface-management.md](application-interface-management.md) | 内外接口的发现、规范与演进。 |
| 📎 | 多租户环境 | [application-multi-tenant-environment.md](application-multi-tenant-environment.md) | 租户隔离、环境拓扑与发布控制。 |

> ADR 正文见 [system/adr/README.md](../../adr/README.md)、[application/adr/README.md](../../../application/adr/README.md)；模板见 [agent/knowledge/adr-guidelines.md](../../../agent/knowledge/adr-guidelines.md)。
