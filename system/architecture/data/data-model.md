# 数据模型

[返回上一级 · 数据架构目录](README.md)

本节沉淀本系统数据源与物理层数据结构，支撑跨服务一致性与演进治理。

> **数据模型 SSOT**：公司级 CDM/LDM/PDM 标准见 [`data-model.md`](../../../company/ea/data/data-model.md)。

与 [`application-domain-model.md`](../application/application-domain-model.md)、[`business-glossary.md`](../business/business-glossary.md#概念模型) 交叉对齐。

## 物理模型

### 数据源

<!-- **应写内容**：本系统主要数据源类型与归属（OLTP、缓存、消息、对象存储等）；与 [`data-storage.md`](data-storage.md)、[`data-flow.md`](data-flow.md) 的对应；读写边界与 SSOT 约定。 -->

<!-- **产出建议**：数据源清单（名称 × 类型 × 用途 × 归属服务）；与存储/流转文档交叉引用。 -->

### 数据实体

<!-- **应写内容**：本系统持久化数据实体定义（业务含义、关键属性、关系）；与 [`application-domain-model.md`](../application/application-domain-model.md) 聚合/实体的对应；跨服务共享实体的主数据归属。 -->

<!-- **产出建议**：按域或主题的数据实体清单或 ER 片段；实体与领域模型追溯关系。 -->

### 数据表

<!-- **应写内容**：本系统表结构、索引、分区与存储参数；与数据实体的映射；DDL 版本管理入口。 -->

<!-- **产出建议**：核心表 DDL 或 ER 图；Migration 脚本索引。 -->

## 服务实体映射

<!-- **应写内容**：本系统各服务核心数据实体（含关键属性、关系、索引要点）；跨服务引用的处理方式；与 [`application-domain-model.md`](../application/application-domain-model.md) 领域模型的对应。 -->

<!-- **产出建议**：按服务分组的数据实体清单；关键 ER 图（可链路至 dbdocs 或 ERD 工具）。 -->

| 服务 | 数据实体 | 说明 |
| --- | --- | --- |
| 示例：order-service | 示例：Order | 示例：订单主实体 |

## 模型版本

<!-- **应写内容**：本系统 Migration 工具与命名规范；向前/向后兼容策略；生产变更审批与回滚；与公司模型版本流程对齐。 -->

<!-- **产出建议**：本系统 Migration 脚本目录；变更审批流程说明。 -->
