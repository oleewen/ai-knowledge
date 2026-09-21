---
id: "knowledge-glossary"
title: "全局术语表"
version: "0.4.0"
status: "draft"
created: "2025-03-13"
updated: "2026-09-15"
tags: ["glossary", "terminology", "governance"]
---

# 全局术语表

> **定位**：词义、别名、易混区分、**实体缩写/类型登记**，以及**跨视角映射字段语义** SSOT。  
> **不分管**：首次定义层 / 5A 边类 / 引用边界 → [knowledge-governance.md](knowledge-governance.md)；ID 语法 `{TYPE}-{NAME}` → [naming-conventions.md](naming-conventions.md)；路径树 → [knowledge-layout.md](../references/knowledge-layout.md)。

## 知识库术语

| 术语 | 英文 | 定义 |
| --- | --- | --- |
| 单一事实源 | SSOT (Single Source of Truth) | 每个知识实体只在一处定义，其他地方通过 ID 引用。 |
| 联邦治理 | Federated Governance | 系统级仓库集中管理宏观架构与索引，应用级仓库分散管理微观设计并上报。 |
| 限界上下文 | Bounded Context | DDD 中明确边界的业务上下文，拥有统一语言与领域模型。 |
| 聚合根 | Aggregate Root | DDD 中聚合的根实体，保证聚合内一致性边界。 |
| 架构决策记录 | ADR (Architecture Decision Record) | 记录架构决策的上下文、决定与后果的文档。 |
| 业务架构 | BA (Business Architecture) | 业务能力目录 ∥ 域模型等；对应五视角 `business/`。 |
| 产品架构 | PA (Product Architecture) | 产品线/服务/模块等；对应五视角 `product/`。 |
| 应用架构 | AA (Application Architecture) | 解决方案/系统/应用/入口簇/接口；对应五视角 `application/`。 |
| 数据架构 | DA (Data Architecture) | 主数据域/存储/实体/表；对应五视角 `data/`。 |
| 技术架构 | TA (Technology Architecture) | 平台能力/技术域/中间件绑定/组件；对应五视角 `technical/`。 |

## 实体缩写登记

仅登记可作 `{TYPE}-{NAME}` 的知识实体前缀（非 ADR/SSOT/5A 等术语）。按 5A：BA → PA → AA → DA → TA。

| 所属视角 | 缩写 | 英文全称 | 短义 | 说明 |
| --- | --- | --- | --- | --- |
| BA | VC | Value Chain | 价值链 | 能力目录根；下挂 CAP，并由 BD 支撑 |
| BA | BD | Business Domain | 业务域 | 支撑 VC；下挂 BSD(L1)；勿与 BSD 混淆 |
| BA | CAP | Business Capability | 业务能力 | 实现价值链；与 BSD(L1) 一对一映射 |
| BA | BSD | Business Subdomain | 业务子域 | 仅一级 / 二级；一级对应 PL，二级对应 PD |
| BA | BC | Bounded Context | 限界上下文 | — |
| BA | AGG | Aggregate | 聚合根 | — |
| BA | AB | Ability | 领域能力 | 能力边界 |
| PA | PL | Product Line | 产品线 | 对应 BSD(L1) |
| PA | PD | Product | 产品服务 | 别名：业务服务 |
| PA | PM | Product Module | 产品模块 | — |
| PA | BP | Business Process | 业务流程 | — |
| PA | FT | Feature | 功能点 | — |
| PA | FR | Functional Requirement | 功能需求 | — |
| PA | UC | Use Case | 用例 | — |
| PA | BR | Business Rule | 业务规则 | — |
| AA | SLN | Solution | 解决方案 | 对应 PL；企业 AA 台账 |
| AA | SYS | System | 系统 | 别名：应用服务 |
| AA | APP | Application | 应用 | 代码仓库/部署单元 |
| AA | MS | Microservice | 微服务 | 入口能力簇；非 MW 替代 |
| AA | API | API Endpoint | 接口端点 | — |
| DA | MDG | Master Data Domain | 主数据域 | 治理目录；非 DS/ENT 替代 |
| DA | DS | Data Store | 数据存储 | — |
| DA | ENT | Entity | 数据实体 | 表/集合 |
| DA | TBL | Data Table | 数据表 | 物理锚点 |
| TA | TPL | Technology Platform | 技术平台能力 | 公司级 |
| TA | TSD | Technical Domain | 技术域 | 系统级 |
| TA | MW | Middleware Binding | 中间件绑定 | 实例级；非 MS/API 替代 |
| TA | CMP | Component | 关键组件 | Maven / 共享运行时 |

ID 前缀写作 `VC-` / `BD-` 等，语法见 [naming-conventions.md](naming-conventions.md)。

## 映射关系（常用）

> 本表为跨视角映射字段语义 **SSOT**。源实体写目标实体 ID；边类方向见 [knowledge-governance.md § 核心映射](knowledge-governance.md#核心映射5a方向)。他处（governance / `*-meta.md`）只引用，不复制全文。

| 关系 | 含义 |
| --- | --- |
| implements_to_vc | **CAP-*** 实现哪个 **VC-***（单值必填）；VC 侧 `implemented_by_cap` 多值必填。 |
| implemented_by_cap | **VC-*** 被哪些 **CAP-*** 实现（多值必填）。 |
| supported_by_bd | **VC-*** 由哪些 **BD-*** 支撑（多值必填）。 |
| supports_to_vc | **BD-*** 支撑哪个 **VC-***（单值必填）；VC 侧 `supported_by_bd` 多值必填。 |
| maps_to_bsd | **CAP-*** 与**BSD-L1-*** 一对一映射（单值必填）；BSD(L1) 侧同名单值必填。 |
| maps_to_cap | **BSD-L1-*** 与 **CAP-*** 一对一映射（单值必填）。 |
| maps_to_pl | **BSD-L1-*** 对标 **PL-***（单值必填）；PL 侧 `maps_to_bsd` 同值。 |
| maps_to_bsd | **PL-*** 对标**BSD-L1-***（单值必填）；BSD(L1) 侧 `maps_to_pl` 同值。 |
| maps_to_pd | **BSD-L2-*** 对标 **PD-***（单值必填）；PD 侧 `maps_to_bsd` 同值。 |
| maps_to_bsd | **PD-*** 对标**BSD-L2-***（单值必填）；BSD(L2) 侧 `maps_to_pd` 同值。 |
| maps_to_pl_id | **SLN-*** 对标 **PL-***（必填同建）。 |
| maps_to_sys_id | **PD-*** 对标的本库 **SYS-***（与 BSD(L2) 同建）。 |
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
