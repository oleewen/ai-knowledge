---
id: "constitution-glossary"
title: "全局术语表"
version: "0.1.0"
status: "draft"
created: "2025-03-13"
updated: "2025-03-15"
tags: ["glossary", "terminology", "constitution"]
---

# 全局术语表

本目录存放业务与技术术语的统一定义，便于跨团队沟通无歧义。可扩展为 `business-glossary.yaml`、`technical-glossary.yaml` 等。

> **统一术语表**：AI Agent 在理解本系统文档时，所有术语以本表定义为准。同一概念禁止使用不同名称，避免歧义。

## 使用说明

- 每个术语有唯一的 `term-id`（如 BT-xxx、TT-xxx），其他文档通过 ID 引用
- 术语分为：业务术语、技术术语、缩写

---

## 知识库相关

| 术语 | 英文 | 定义 |
|------|------|------|
| 单一事实源 | SSOT (Single Source of Truth) | 每个知识实体只在一处定义，其他地方通过 ID 引用。 |
| 联邦治理 | Federated Governance | 系统级仓库集中管理宏观架构与索引，应用级仓库分散管理微观设计并上报。 |
| 限界上下文 | Bounded Context | DDD 中明确边界的业务上下文，拥有统一语言与领域模型。 |
| 聚合根 | Aggregate Root | DDD 中聚合的根实体，保证聚合内一致性边界。 |
| 架构决策记录 | ADR (Architecture Decision Record) | 记录架构决策的上下文、决定与后果的文档。 |

## 视角与层级

| 术语 | 含义 |
|------|------|
| 业务视角 | 业务域、子域、限界上下文、聚合等，不依赖技术实现。 |
| 产品视角 | 产品线、模块、功能点、用例、业务流程、业务规则。 |
| 技术视角 | 系统、应用、**MS（入口能力簇）**、API；其中 **MS-*** 为 **对外入口宿主类聚类**，**不**等于 Maven 子模块（见 **docs-build §8.1.2**）。 |
| 数据视角 | 数据存储、数据实体、字段、敏感级别、数据流向。 |

## 业务术语（带 ID）

| ID | 术语 | 英文 | 定义 | 所属上下文 | 易混淆项 |
|----|------|------|------|------------|----------|
| BT-001 | 订单 | Order | 用户提交的一次购买请求，包含一个或多个订单项 | 订单上下文 | ≠ 交易(Transaction)，交易是支付层面的概念 |
| BT-002 | 商品 | Product | 可售卖的最小单元，具有唯一SKU | 商品上下文 | ≠ SPU，SPU是商品的抽象集合 |
| BT-003 | 库存 | Inventory | 某商品在某仓库的可用数量 | 库存上下文 | 区分"可用库存"和"物理库存" |

## 技术术语（带 ID）

| ID | 术语 | 定义 | 使用场景 |
|----|------|------|----------|
| TT-001 | 限界上下文 | DDD中的边界划分单元，一个上下文内术语含义唯一 | 领域建模 |
| TT-002 | 聚合根 | 一组关联对象的访问入口，保证事务一致性边界 | 领域模型设计 |

## 缩写对照

| 缩写 | 全称 | 说明 |
|------|------|------|
| ADR | Architecture Decision Record | 架构决策记录 |
| OMS | Order Management System | 订单管理系统 |
| SKU | Stock Keeping Unit | 库存量单位 |
| SSOT | Single Source of Truth | 单一事实源 |

## 映射关系（常用）

| 关系 | 含义 |
|------|------|
| implemented_by_app_id | 限界上下文由哪个应用（代码库）实现。 |
| implemented_by_service_ids | 聚合根由哪些 **MS-*（入口簇）** 实现；**MS-*** 须可指回 **API 宿主类**，**非** artifactId。 |
| relies_on_context_ids | 产品模块依赖哪些限界上下文。 |
| invokes_api_ids | 功能点调用的 API 列表。 |
| implemented_by_api_id | 能力（Ability）由哪个 API 实现。 |
| map_to_api_id | 用例（UC）映射到 API 的关系。 |
| persisted_as_entity_ids | 聚合持久化对应的数据实体 ID。 |
| maps_to_aggregate_id | 数据实体对应的业务聚合根。 |
| owned_by_service_id | 数据存储/数据实体归属到哪些 **MS-*（入口簇）**。 |

## 术语变更记录

| 日期 | 术语ID | 变更类型 | 变更说明 |
|------|--------|----------|----------|
| 2024-01-15 | BT-001 | 修改 | 明确订单不包含退款信息，退款归属售后上下文 |

---

*可在此目录下新增 YAML 格式的术语表，便于机器可读与检索。*
