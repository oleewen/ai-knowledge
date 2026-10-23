---
id: "knowledge-glossary"
title: "全局术语表"
version: "0.4.0"
status: "draft"
created: "2025-03-13"
updated: "2026-10-23"
tags: ["glossary", "terminology", "governance"]
---

# 全局术语表

> **定位**：词义、别名、易混区分与实体 `hierarchy` / `type` / `perspective` 登记的唯一真源。
> **不分管**：首次定义层 → [knowledge-governance.md](knowledge-governance.md)；关系 → [entity-relations.md](entity-relations.md)；引用边界 → [knowledge-reference-rules.md](knowledge-reference-rules.md)；ID 语法 `{TYPE}-{NAME}` → [naming-conventions.md](naming-conventions.md)；路径树 → [knowledge-layout.md](../references/knowledge-layout.md)。

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
| 技术架构 | TA (Technology Architecture) | 平台能力/技术服务/中间件绑定/组件；对应五视角 `technical/`。 |
| 五视角 | Five Perspectives | 业务 / 产品 / 应用 / 数据 / 技术 五个 `knowledge/<perspective>/` 目录；[INDEX-GUIDE.md](../../INDEX-GUIDE.md) §4.1 亦称 **五架构视角**（同义，偏目录组织语境）。 |

## 实体缩写登记

本表唯一登记知识实体的 `hierarchy`、精确 `type`、`perspective` 与短义。仅实体缩写可作 ID 前缀；首次定义层见 [治理规则](knowledge-governance.md#各层聚焦摘要)，字面语法见 [命名规范](naming-conventions.md)。

| hierarchy | type | perspective | 短义 |
| --- | --- | --- | --- |
| VC | `Value Chain` | business | 价值链 |
| BD | `Business Domain` | business | 业务域 |
| CAP | `Business Capability` | business | 业务能力 |
| BL | `Business Line` | business | 业务线 |
| BS | `Business Service` | business | 业务服务 |
| PL | `Product Line` | product | 产品线 |
| SLN | `Solution` | application | 解决方案 |
| MDG | `Master Data Domain` | data | 主数据域 |
| TPL | `Technical Platform` | technical | 技术平台能力 |
| BSD | `Business Subdomain` | business | 业务子域 |
| BC | `Bounded Context` | business | 限界上下文 |
| AGG | `Aggregate` | business | 聚合根 |
| AB | `Ability` | business | 领域能力 |
| PD | `Product` | product | 产品服务 |
| PM | `Product Module` | product | 产品模块 |
| BP | `Business Process` | product | 业务流程 |
| BSP | `Business Subprocess` | product | 业务子流程 |
| FT | `Feature` | product | 功能点 |
| FR | `Functional Requirement` | product | 功能需求 |
| UC | `Use Case` | product | 用例 |
| BR | `Business Rule` | product | 业务规则 |
| SYS | `System` | application | 系统 |
| APP | `Application` | application | 应用 |
| MS | `Microservice` | application | 微服务 |
| DS | `Data Store` | data | 数据存储 |
| ENT | `Entity` | data | 数据实体 |
| TS | `Technical Service` | technical | 技术服务 |
| API | `API Endpoint` | application | 接口端点 |
| TBL | `Data Table` | data | 数据表 |
| MW | `Middleware Binding` | technical | 中间件绑定 |
| CMP | `Component` | technical | 关键组件 |

易混区分：`SYS` 又称应用服务；`APP` 是代码仓库/部署单元；`MS` 是业务入口能力簇；`MW` 是实例级基础设施绑定；`MDG` 是逻辑模型与数据主权边界；`ENT` 表示实体/集合，`TBL` 表示物理表锚点。`AGG` 在本库登记为聚合根。

## 映射关系（常用）

动词、允许边、双向要求与废弃字段统一见 [实体关系模型](entity-relations.md)。本节仅保留旧入口。
