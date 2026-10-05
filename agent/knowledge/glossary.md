---
id: "knowledge-glossary"
title: "全局术语表"
version: "0.4.0"
status: "draft"
created: "2025-03-13"
updated: "2026-10-04"
tags: ["glossary", "terminology", "governance"]
---

# 全局术语表

> **定位**：词义、别名、易混区分、**实体缩写/类型登记**，以及**跨视角映射字段语义** SSOT。  
> **不分管**：首次定义层 / 5A 边类 / 引用边界 → [knowledge-governance.md](knowledge-governance.md)；ID 语法 `{TYPE}-{NAME}` → [naming-conventions.md](naming-conventions.md)；路径树 → [knowledge-layout.md](../references/knowledge-layout.md)。

## 知识库术语

| 术语 | 英文 | 定义 |
| --- | --- | --- |
| 单一事实源 | SSOT (Single Source of Truth) | 每个知识实体只在一处定义，其他地方通过 ID 引用。 |
| 联邦治理 | Federated Governance | 四层 parent（application→system→solution→company）；下级实现、上级索引与共性，蒸馏按层上收。 |
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
| BA | BSD | Business Subdomain | 业务子域 | 仅一级 / 二级；L1 公司（对标 PL）；L2 解决方案（对标 PD） |
| BA | BC | Bounded Context | 限界上下文 | — |
| BA | AGG | Aggregate | 聚合根 | — |
| BA | AB | Ability | 领域能力 | 能力边界 |
| PA | PL | Product Line | 产品线 | 对应 BSD(L1) |
| PA | PD | Product | 产品服务 | 别名：业务服务；解决方案层 SSOT；与 SYS 1:1 |
| PA | PM | Product Module | 产品模块 | — |
| PA | BP | Business Process | 业务流程 | 解决方案主流程；`implements_to` SLN |
| PA | FT | Feature | 功能点 | — |
| PA | FR | Functional Requirement | 功能需求 | — |
| PA | UC | Use Case | 用例 | — |
| PA | BR | Business Rule | 业务规则 | — |
| AA | SLN | Solution | 解决方案 | 交付包锚点；一仓一 SLN；`maps_to` PL |
| AA | SYS | System | 系统 | 别名：应用服务；系统层 SSOT；`maps_to` PD 且 `implements_to` SLN |
| AA | APP | Application | 应用 | 代码仓库/部署单元 |
| AA | MS | Microservice | 微服务 | 入口能力簇；非 MW 替代 |
| AA | API | API Endpoint | 接口端点 | — |
| DA | MDG | Master Data Domain | 主数据域 | 解决方案层 SSOT；一 SLN 可多条；非 DS/ENT 替代 |
| DA | DS | Data Store | 数据存储 | — |
| DA | ENT | Entity | 数据实体 | 表/集合 |
| DA | TBL | Data Table | 数据表 | 物理锚点 |
| TA | TPL | Technology Platform | 技术平台能力 | 公司级企业准入 |
| TA | TSD | Technical Domain | 技术域 | 解决方案级选用与例外；`implements_to` TPL |
| TA | MW | Middleware Binding | 中间件绑定 | 实例级；非 MS/API 替代 |
| TA | CMP | Component | 关键组件 | Maven / 共享运行时 |

ID 前缀写作 `VC-` / `BD-` 等，语法见 [naming-conventions.md](naming-conventions.md)。

## 映射关系（常用）

> 本表为关系字段语义 **SSOT**。字段名短化；目标类型靠 ID 前缀。边类方向见 [knowledge-governance.md § 核心映射](knowledge-governance.md#核心映射5a方向)。他处（governance / `*-meta.md`）只引用，不复制全文。  
> **总则**：不设单侧 SSOT；关系两边均必填（树根省略 `parent` 除外）。混列目标靠前缀辨型。

### 动词族

| 动词对 | 场景 |
| --- | --- |
| `parent` / `children` | 仅**同类**树（BD↔BSD(L1)、BSD(L1)↔BSD(L2)） |
| `implements_to` / `implemented_by` | 同视角不同类上下级（组成链）；及 SYS↔SLN、TSD↔TPL、MW↔TSD、CMP↔MW 等 |
| `maps_to` / `maps_to` | 同级对标（两边同名；含同视角） |
| `supports_to` / `supported_by` | 支撑（BD↔VC；APP↔BC；API→FT） |
| `uses_to` / `used_by` | 使用（第五动词） |
| `depends_to` / `depended_by` | PM↔PM 依赖（第六动词） |

### 允许边（宿主 → 目标）

| 字段（出边） | 宿主 → 目标（摘要） |
| --- | --- |
| `parent` / `children` | BSD(L1)↔BD；BSD(L2)↔BSD(L1) |
| `implements_to` | CAP→VC；AGG→BC；AB→AGG；BC→BSD(L2)；PD→PL；PM→PD；FT→PM；FR→FT；UC\|BR→FR；BP→SLN；APP→SYS；MS→APP；API→MS；DS→MDG；ENT→DS；TBL→ENT；SYS→SLN；TSD→TPL；MW→TSD；CMP→MW |
| `implemented_by` | 上表对端 |
| `maps_to` | CAP↔BSD(L1)；BSD(L1)↔PL；BSD(L2)↔PD；SLN↔PL；PD↔SYS；BP 可→多 PD；MS↔AGG；AB↔API；AGG↔ENT；PM↔BC；UC↔API |
| `supports_to` | BD→VC；APP→BC；API→FT |
| `supported_by` | VC→BD；BC→APP；FT→API |
| `uses_to` | SYS→MDG\|TSD；APP→DS\|MW；MS→ENT\|TBL\|CMP；MW→DS（可空仍双写） |
| `used_by` | 上表对端 |
| `depends_to` / `depended_by` | PM↔PM |

### 非边属性

| 字段 | 含义 |
| --- | --- |
| `maven_coordinates` | **CMP-*** 的 Maven 坐标 `groupId:artifactId:version` |

### 已废（勿再用）

`implements_*_ids`、`implements_to_vc`、`implemented_by_cap`、`implemented_by_app_id`、`implemented_by_service_ids`、`supports_to_vc`、`supported_by_bd`、`maps_to_*` 带后缀旧名、`uses_*_ids`、`apis`、`aggregates`、`abilities`、`persisted_as_*`、`owned_by_app_id`、`bound_app_id`、`parent_tsd_id` / `parent_tpl_id` / `parent_mw_id` / `parent_app_id`（关系语义改 `implements_to`）、`relies_on_context_ids`、`invokes_api_ids`、`depends_pm_ids`、`map_to_api_id`、`maps_to_cap_ids`、`authoritative_mdg_id`、`root_entity` / `entities`、APP/SYS↔TPL 直连、APP↔CMP、FT↔UC 直连。

OKF frontmatter 技术键 `parent_id`（路径/校验）可与关系段 `implements_to`/`parent` 并存，目标须一致。
