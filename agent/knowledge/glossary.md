---
id: "knowledge-glossary"
title: "全局术语表"
version: "0.3.0"
status: "draft"
created: "2025-03-13"
updated: "2026-09-15"
tags: ["glossary", "terminology", "governance"]
---

# 全局术语表

本文件存放**释义、别名、易混区分**与**跨视角映射字段**语义，便于跨团队与 Agent 无歧义引用。

> 统一术语表：释义与映射字段以本表为准。前缀、首次定义层、路径见 [naming-conventions.md](naming-conventions.md)；分层角色见 [knowledge-governance.md](knowledge-governance.md) / 各层 `*-meta.md`（字段语义回链本节）。

## 使用说明

- OKF 实体缩写见「缩写对照」；治理词见「知识库相关」
- 映射字段语义 **SSOT** 在「映射关系（常用）」；[knowledge-governance.md](knowledge-governance.md#核心映射5a方向) 与各层 `*-meta.md` 引用本表，不另写字段全文
- 前缀与首次定义层不在本表展开（见 naming）

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

| 术语   | 含义 |
| ---- | --- |
| 5A | **BA**（业务）· **PA**（产品）· **AA**（应用）· **DA**（数据）· **TA**（技术）；经典 4A + **PA**。边方向见 [knowledge-governance §5A](knowledge-governance.md#核心映射5a方向)。 |
| BA | Business Architecture；业务架构（能力目录 ∥ 域模型等）。 |
| PA | Product Architecture；产品架构（PL/PD/PM…；与五视角 `product/` 对齐）。 |
| AA | Application Architecture；应用架构（SLN/SYS/APP/MS/API）。 |
| DA | Data Architecture；数据架构（MDG/DS/ENT/TBL）。 |
| TA | Technology Architecture；技术架构（TPL/TSD/MW/CMP）。 |
| 业务视角 | 业务单元（BU）、业务域（BD）、业务能力（CAP）、子域、限界上下文、聚合等；BU∥BD 为 BA 两张图。 |
| 产品视角 | 产品线（PL）、产品服务（PD）、模块、功能点、用例、业务流程、业务规则；对应 **PA**。 |
| 应用视角 | 解决方案（SLN）、系统（SYS）、应用、**MS（入口能力簇）**、API。 |
| 数据视角 | 数据存储、数据实体、主数据域目录、字段、敏感级别、数据流向。 |
| 技术视角 | 技术平台能力（TPL）、技术域（TSD）、中间件绑定（MW）、关键组件（CMP）；叙事与实体 ID 并存，见 [naming-conventions.md](naming-conventions.md)。 |

## 缩写对照

| 缩写 | 全称 | 说明 |
| --- | --- | --- |
| ADR | Architecture Decision Record | 架构决策记录 |
| SSOT | Single Source of Truth | 单一事实源 |
| BU | Business Unit | 业务单元 |
| BD | Business Domain | 业务域（∥BU） |
| CAP | Business Capability | 业务能力（由 BD 支撑） |
| BSD | Business Subdomain | 业务子域 |
| BC | Bounded Context | 限界上下文 |
| AGG | Aggregate | 聚合根 |
| AB | Ability | 领域能力 |
| PL | Product Line | 产品线（支持 BD） |
| PD | Product | 产品服务（别名：业务服务） |
| PM | Product Module | 产品模块 |
| BP | Business Process | 业务流程 |
| FT | Feature | 功能点 |
| FR | Functional Requirement | 功能需求 |
| UC | Use Case | 用例 |
| BR | Business Rule | 业务规则 |
| SLN | Solution | 解决方案（对应 PL） |
| SYS | System | 系统（别名：应用服务） |
| APP | Application | 应用 |
| MS | Microservice | 微服务（入口簇） |
| API | API Endpoint | 接口端点 |
| MDG | Master Data Domain | 主数据域 |
| DS | Data Store | 数据存储 |
| ENT | Entity | 数据实体 |
| TBL | Data Table | 数据表（物理锚点） |
| TPL | Technology Platform | 技术平台能力 |
| TSD | Technical Domain | 技术域 |
| MW | Middleware Binding | 中间件绑定 |
| CMP | Component | 关键组件 |

## 映射关系（常用）

> 本表为跨视角映射字段语义 **SSOT**。他处（knowledge-governance / `*-meta.md`）只引用，不复制全文。

| 关系 | 含义 |
| --- | --- |
| maps_to_bd_id | **CAP-*** 由哪个 **BD-*** 支撑（单值必填）。 |
| maps_to_pl_id | **BD-***：由 **PL-*** 提供产品支撑（必填同建）；**SLN-***：对标 **PL-***（必填同建）。 |
| maps_to_pd_id | 首层 **BSD-*** 对标的本库 **PD-***（与 PD/SYS 同建）。 |
| maps_to_sys_id | **PD-*** 对标的本库 **SYS-***（与首层 BSD 同建）。 |
| implements_bc_ids | **APP-*** 实现哪些 **BC-***（AA implements BA；SSOT 在 AA）。 |
| implements_agg_ids | **MS-*** 实现哪些 **AGG-***（AA implements BA）。 |
| uses_mdg_ids / uses_ds_ids / uses_ent_ids / uses_tbl_ids | AA **uses** DA（`uses_mdg_ids` 挂 SYS；细粒度挂 APP/MS）。 |
| uses_tsd_ids / uses_mw_ids / uses_tpl_ids / uses_cmp_ids | AA **uses** TA。 |
| implemented_by_app_id | （过渡）限界上下文由哪个应用实现；SSOT 迁至 `implements_bc_ids`。 |
| implemented_by_service_ids | （过渡）聚合由哪些 MS 实现；SSOT 迁至 `implements_agg_ids`。 |
| relies_on_context_ids | 产品模块依赖哪些限界上下文。 |
| depends_pm_ids | 消费方产品模块依赖的其它 PM（同 PD 或跨 PD）；主属仍看 `parent_id→PD`。 |
| invokes_api_ids | 功能点调用的 API 列表。 |
| apis | 能力（AB）绑定的 API 列表；跨视角引用见 `apis[].id` → API.id。 |
| map_to_api_id | 用例（UC）映射到 API 的关系。 |
| persisted_as_entity_ids | 聚合持久化对应的数据实体 ID。 |
| maps_to_aggregate_id | 数据实体对应的业务聚合根。 |
| owned_by_app_id / bound_app_id | （过渡）旧 DA/TA→AA 归属字段；SSOT 迁至 AA `uses_*`。 |
| maps_to_cap_ids | （可选）系统或域能力映射到公司级 **CAP-***。 |
| authoritative_mdg_id | 主数据权威域对应的 **MDG-*** 实体（DA 内边）。 |
| implements_tpl_ids | **APP-*** 使用/实现的公司级 **TPL-***（归入 AA uses TA）。 |
| parent_tsd_id | **MW-*** 归属的系统级 **TSD-*** 技术域。 |
| related_ds_id | **MW-*** 关联的 **DS-*** 数据源（可选）。 |
| parent_mw_id | **CMP-*** 挂载的 **MW-*** 中间件绑定。 |
| parent_app_id | **CMP-*** 挂载的 **APP-***（与 `parent_mw_id` 二选一）。 |
| maven_coordinates | **CMP-*** 的 Maven 坐标 `groupId:artifactId:version`。 |
| parent_tpl_id | **TSD-*** 归属的公司级 **TPL-*** 平台能力。 |

## 术语变更记录

| 日期 | 术语ID | 变更类型 | 变更说明 |
| --- | --- | --- | --- |
| 2026-09-15 | — | 修订 | 4A→5A：增加 PA（产品架构）；映射节锚点同步 |
| 2026-09-14 | — | 修订 | 删 BT/TT 样例与 OMS/SKU；补全 OKF 缩写；映射节定为字段 SSOT |

---

*可在此目录下新增 YAML 格式的术语表，便于机器可读与检索。*
