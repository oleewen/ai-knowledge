---
id: "knowledge-glossary"
title: "全局术语表"
version: "0.2.0"
status: "draft"
created: "2025-03-13"
updated: "2026-09-13"
tags: ["glossary", "terminology", "governance"]
---

# 全局术语表

本文件存放业务与技术术语的统一定义，便于跨团队沟通无歧义。可扩展为 `business-glossary.yaml`、`technical-glossary.yaml` 等。

> **统一术语表**：AI Agent 在理解本系统文档时，所有术语以本表定义为准。同一概念禁止使用不同名称，避免歧义。

## 使用说明

- 每个术语有唯一的 `term-id`（如 BT-xxx、TT-xxx），其他文档通过 ID 引用
- 术语分为：业务术语、技术术语、缩写

---

## 知识库相关

| 术语     | 英文                                 | 定义                                 |
| ------ | ---------------------------------- | ---------------------------------- |
| 单一事实源  | SSOT (Single Source of Truth)      | 每个知识实体只在一处定义，其他地方通过 ID 引用。         |
| 联邦治理   | Federated Governance               | 系统级仓库集中管理宏观架构与索引，应用级仓库分散管理微观设计并上报。 |
| 限界上下文  | Bounded Context                    | DDD 中明确边界的业务上下文，拥有统一语言与领域模型。       |
| 聚合根    | Aggregate Root                     | DDD 中聚合的根实体，保证聚合内一致性边界。            |
| 架构决策记录 | ADR (Architecture Decision Record) | 记录架构决策的上下文、决定与后果的文档。               |

## 视角与层级

| 术语   | 含义                                                                                              |
| ---- | ----------------------------------------------------------------------------------------------- |
| 业务视角 | 业务单元（BU）、业务域（BD）、业务能力（CAP）、子域、限界上下文、聚合等；BU∥BD 为 BA 两张图。 |
| 产品视角 | 产品线（PL）、产品能力（PD，系统首次定义）、模块、功能点、用例、业务流程、业务规则。 |
| 应用视角 | 解决方案（SLN，公司 AA 台账）、系统（SYS，系统首次定义；挂 SLN）、应用、**MS（入口能力簇）**、API。 |
| 数据视角 | 数据存储、数据实体、主数据域目录、字段、敏感级别、数据流向。 |
| 技术视角 | 技术平台能力（TPL）、技术域（TSD）、中间件绑定（MW）、关键组件（CMP）；叙事与实体 ID 并存，见 [naming-conventions.md](naming-conventions.md)。 |

## 业务术语（带 ID）

| ID     | 术语  | 英文        | 定义                     | 所属上下文 | 易混淆项                         |
| ------ | --- | --------- | ---------------------- | ----- | ---------------------------- |
| BT-001 | 订单  | Order     | 用户提交的一次购买请求，包含一个或多个订单项 | 订单上下文 | ≠ 交易(Transaction)，交易是支付层面的概念 |
| BT-002 | 商品  | Product   | 可售卖的最小单元，具有唯一SKU       | 商品上下文 | ≠ SPU，SPU是商品的抽象集合            |
| BT-003 | 库存  | Inventory | 某商品在某仓库的可用数量           | 库存上下文 | 区分"可用库存"和"物理库存"              |

## 技术术语（带 ID）

| ID     | 术语    | 定义                       | 使用场景   |
| ------ | ----- | ------------------------ | ------ |
| TT-001 | 限界上下文 | DDD中的边界划分单元，一个上下文内术语含义唯一 | 领域建模   |
| TT-002 | 聚合根   | 一组关联对象的访问入口，保证事务一致性边界    | 领域模型设计 |

## 缩写对照

| 缩写   | 全称                           | 说明     |
| ---- | ---------------------------- | ------ |
| ADR  | Architecture Decision Record | 架构决策记录 |
| OMS  | Order Management System      | 订单管理系统 |
| SKU  | Stock Keeping Unit           | 库存量单位  |
| SSOT | Single Source of Truth       | 单一事实源  |
| BU   | Business Unit                | 业务单元   |
| CAP  | Business Capability          | 业务能力   |
| SLN  | Solution                     | 解决方案   |
| MDG  | Master Data Domain           | 主数据域   |
| TPL  | Technology Platform          | 技术平台能力 |
| TSD  | Technical Domain             | 技术域     |
| MW   | Middleware Binding           | 中间件绑定  |
| CMP  | Component                    | 关键组件   |

## 映射关系（常用）

| 关系                         | 含义                                                                  |
| -------------------------- | ------------------------------------------------------------------- |
| maps_to_bd_id              | **CAP-*** 由哪个 **BD-*** 提供（单值必填）。 |
| maps_to_pl_id              | **BD-*** / **SLN-*** 对标的 **PL-***（必填；与 PL 同建）。 |
| maps_to_pd_id              | 首层 **BSD-*** 对标的本库 **PD-***（与 PD/SYS 同建）。 |
| maps_to_sys_id             | **PD-*** 对标的本库 **SYS-***（与首层 BSD 同建）。 |
| implements_bc_ids          | **APP-*** 实现哪些 **BC-***（AA implements BA；SSOT 在 AA）。 |
| implements_agg_ids         | **MS-*** 实现哪些 **AGG-***（AA implements BA）。 |
| uses_mdg_ids / uses_ds_ids / uses_ent_ids / uses_tbl_ids | AA **uses** DA（挂 SLN/APP/MS）。 |
| uses_tsd_ids / uses_mw_ids / uses_tpl_ids / uses_cmp_ids | AA **uses** TA。 |
| implemented_by_app_id      | （过渡）限界上下文由哪个应用实现；SSOT 迁至 `implements_bc_ids`。 |
| implemented_by_service_ids | （过渡）聚合由哪些 MS 实现；SSOT 迁至 `implements_agg_ids`。 |
| relies_on_context_ids      | 产品模块依赖哪些限界上下文。                                                      |
| depends_pm_ids             | 消费方产品模块依赖的其它 PM（同 PD 或跨 PD）；主属仍看 `parent_id→PD`。              |
| invokes_api_ids            | 功能点调用的 API 列表。                                                      |
| apis                       | 能力（AB）绑定的 API 列表；跨视角引用见 `apis[].id` → API.id。 |
| map_to_api_id              | 用例（UC）映射到 API 的关系。                                                  |
| persisted_as_entity_ids    | 聚合持久化对应的数据实体 ID。                                                    |
| maps_to_aggregate_id       | 数据实体对应的业务聚合根。                                                       |
| owned_by_app_id / bound_app_id | （过渡）旧 DA/TA→AA 归属字段；SSOT 迁至 AA `uses_*`。 |
| maps_to_cap_ids            | （可选）系统或域能力映射到公司级 **CAP-***。 |
| authoritative_mdg_id       | 主数据权威域对应的 **MDG-*** 实体（DA 内边）。 |
| implements_tpl_ids         | **APP-*** 使用/实现的公司级 **TPL-***（归入 AA uses TA）。 |
| parent_tsd_id              | **MW-*** 归属的系统级 **TSD-*** 技术域。                                          |
| related_ds_id              | **MW-*** 关联的 **DS-*** 数据源（可选）。                                         |
| parent_mw_id               | **CMP-*** 挂载的 **MW-*** 中间件绑定。                                            |
| parent_app_id              | **CMP-*** 挂载的 **APP-***（与 `parent_mw_id` 二选一）。                          |
| maven_coordinates          | **CMP-*** 的 Maven 坐标 `groupId:artifactId:version`。                            |
| parent_tpl_id              | **TSD-*** 归属的公司级 **TPL-*** 平台能力。                                       |

## 术语变更记录

| 日期         | 术语ID   | 变更类型 | 变更说明                  |
| ---------- | ------ | ---- | --------------------- |
| 2024-01-15 | BT-001 | 修改   | 明确订单不包含退款信息，退款归属售后上下文 |
| 2026-06-15 | —      | 修订   | 五视角：技术 MW/CMP/TSD；CAP/MDG/TPL 并入各视角前缀表 |

---

*可在此目录下新增 YAML 格式的术语表，便于机器可读与检索。*
