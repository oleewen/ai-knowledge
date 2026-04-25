# 系统知识库（顶层 `system/`）

本目录为 **目标态下的「系统知识库」语义**：组织级视图、架构文档与 **`application-{name}/`** 联邦槽位（后续可通过 fetch 同步应用镜像）。

> 四视角实体、阶段交付（solutions/analysis/requirements）等 **SSOT** 在仓库 **[`../application/`](../application/)**。

## 子目录

| 路径 | 说明 |
|------|------|
| [`constitution/`](constitution/README.md) | 系统级宪法与治理：术语边界、槽位约定；与 `application/constitution/` 职责划分见该目录 README |
| [`architecture/`](architecture/README.md) | 架构视图文档（模板与索引见下表）；体例统一为「二级章节导语 + 三级小节 + 应写内容 / 产出建议」 |
| [`application-APPNAME/`](application-APPNAME/README.md) | 占位槽位；真实应用名替换 `APPNAME`，内容可由 fetch 填入 |

## 架构文档（`architecture/`）

下列文件与 [`architecture/README.md`](architecture/README.md) 同目录；建议先读 **[架构总览](architecture/OVERVIEW.md)**，再按需深入各视角。

| 文档 | 说明 |
|------|------|
| [OVERVIEW.md](architecture/OVERVIEW.md) | **架构总览**：一页纸简介、架构视角关系、治理与变更、团队与协作、规范索引、FAQ 与故障案例 |
| [BUSINESS-ARCHITECTURE.md](architecture/BUSINESS-ARCHITECTURE.md) | **业务架构**：业务概述、业务域、流程、角色与组织、规则与策略、术语、能力地图、商业模式与价值链 |
| [PRODUCT-ARCHITECTURE.md](architecture/PRODUCT-ARCHITECTURE.md) | **产品架构**：产品概述、功能架构、用户旅程与场景、信息架构、交互与体验、多端策略、运营支撑、度量、版本与发布 |
| [APPLICATION-ARCHITECTURE.md](architecture/APPLICATION-ARCHITECTURE.md) | **应用架构**：应用概述、应用全景与服务设计、服务间交互、接口管理、集成、多租户与环境、ADR |
| [DATA-ARCHITECTURE.md](architecture/DATA-ARCHITECTURE.md) | **数据架构**：数据概述、数据模型、存储、流转、数仓与数据湖、治理、安全与隐私、数据分析与应用 |
| [TECHNICAL-ARCHITECTURE.md](architecture/TECHNICAL-ARCHITECTURE.md) | **技术架构**：技术概述、基础设施、中间件、高可用与容灾、性能与扩展、安全、可观测性、DevOps、开发环境与工具链 |

与公司知识库侧 [`../company/architecture/`](../company/architecture/README.md) 对照阅读。

## 建议阅读顺序

1. [OVERVIEW.md](architecture/OVERVIEW.md) — 对齐视角与治理入口  
2. [BUSINESS-ARCHITECTURE.md](architecture/BUSINESS-ARCHITECTURE.md) / [PRODUCT-ARCHITECTURE.md](architecture/PRODUCT-ARCHITECTURE.md) — 业务与产品语境  
3. [APPLICATION-ARCHITECTURE.md](architecture/APPLICATION-ARCHITECTURE.md) / [DATA-ARCHITECTURE.md](architecture/DATA-ARCHITECTURE.md) / [TECHNICAL-ARCHITECTURE.md](architecture/TECHNICAL-ARCHITECTURE.md) — 系统、数据与技术落地  
