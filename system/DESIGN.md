# 系统知识库设计（精简版）

本文件定义 `system/` 的设计边界、目录契约、映射闭环与演进策略。  
`system/` 负责系统知识库的治理编排，并承接系统层首次定义实体的主语义；`application/` 继续承接应用层接口、物理表、组件与实现映射。

---

## 阅读顺序

1. [README.md](README.md) — 系统知识库定位与目录说明
2. 本文 — 设计边界、映射与治理流程
3. [agent/knowledge/knowledge-governance.md](../agent/knowledge/knowledge-governance.md) — 治理层职责
4. [architecture/README.md](architecture/README.md) — 架构聚合视图入口
5. [../application/DESIGN.md](../application/DESIGN.md) — 应用侧 SSOT 设计依据

---

## 1. 定位与边界

`system/DESIGN.md` 的定位是系统知识库的设计说明，核心职责是定义 `system/` 的治理结构、联邦槽位与上下行同步机制。

- `system/` 是系统级索引治理层，同时承接 `BSD/BC/AGG/AB/PM/FT/UC/BP/BR/APP/MS/DS/ENT/TSD` 等系统层首次定义实体的主语义；
- `application/` 承接 `API/TBL/MW/CMP` 等应用层首次定义实体，以及对上游实体的实现映射与实例登记；
- `system/` 与 `application/` 可相互引用，但不得形成字段语义双源。

边界约束：

- **结构边界**：`architecture/`、`application-{name}/` 职责分离；命名与术语 SSOT 在 [agent/knowledge/](../agent/knowledge/knowledge-governance.md)；流程闸门在 [agent/rules/](../agent/rules/CONVENTIONS.md)；
- **流程边界**：应用镜像经 `docs-pull` 下行；架构知识经 `docs-distill` / `docs-archive` 上行；SDD 阶段链见 §2.2；
- **事实边界**：`system` 维护系统层实体主定义与治理事实，`application` 维护应用层实体主定义与实现事实。

---

## 2. 元模型与目录契约

`system/` 采用“治理层 -> 架构层 -> 联邦层”三层模型，聚焦治理编排，并承接系统层首次定义实体的治理语义与架构表达。

| 层级 | 目录 | 职责 |
| --- | --- | --- |
| 根导航 | [README.md](README.md)、[INDEX_GUIDE.md](INDEX_GUIDE.md)、[docs_meta.yaml](docs_meta.yaml) | 人类入口、Agent 九章索引、目录元数据 |
| 治理规则 | [agent/knowledge/](../agent/knowledge/knowledge-governance.md) | 术语边界、命名 SSOT、ADR 模板与原则（全仓库） |
| ADR 正文 | [adr/](adr/README.md) | 系统层架构决策记录正文 |
| 架构层 | `architecture/` | 五架构视角聚合视图；含 `overview/` 蒸馏缓冲区 |
| SDD 阶段 | [solutions/](solutions/README.md)、[analysis/](analysis/README.md)、[requirements/](requirements/README.md) | 方案 → 分析 → 需求交付（PRD/ASD/DSD/TDD） |
| 联邦层 | `application-{name}/` | 应用镜像挂载槽位，承接 `/docs-pull` 内容并支持归档追溯 |
| 建联清单 | [knowledge-links.yaml](knowledge-links.yaml) | 联邦应用建联登记（见 [scripts/README.md](../scripts/README.md)） |
| 运维 | [changelogs/](changelogs/README.md) | `CHANGE-LOG.md`、`INDEXING-LOG.md` |

#### SDD 阶段链（system 模式）

| 阶段 | 目录 | 产出 | 下游 |
| --- | --- | --- | --- |
| 方案 | `solutions/` | `SOLUTION-{IDEA-ID}.md` | `analysis/` |
| 分析 | `analysis/` | `ANALYSIS-{IDEA-ID}.md` | `requirements/` |
| 交付 | `requirements/` | `REQUIREMENT-{IDEA-ID}/MVP-Phase-*/` 下 PRD/ASD/DSD/TDD | 应用库详设可经 `/sdx-design` 落盘 |

公司侧跨系统 SDD 见 [../company/DESIGN.md](../company/DESIGN.md)；路径 SSOT 见 [agent/references/knowledge-layout.md](../agent/references/knowledge-layout.md)。

#### 五架构视角

| 视角 | 回答什么问题 | 入口 |
| --- | --- | --- |
| **业务** | 做什么业务、边界与流程 | [architecture/business/](architecture/business/README.md) |
| **产品** | 用户、功能组织与发布 | [architecture/product/](architecture/product/README.md) |
| **应用** | 服务拆分与集成边界 | [architecture/application/](architecture/application/README.md) |
| **数据** | 建模、存储与治理 | [architecture/data/](architecture/data/README.md) |
| **技术** | 运行、扩展、观测与交付 | [architecture/technical/](architecture/technical/README.md) |

五视角实体按公司 / 系统 / 应用三层分治：公司层负责 `BD/CAP/PL/SYS/MDG/TPL`，系统层负责 `BSD/BC/AGG/AB/PM/FT/UC/BP/BR/APP/MS/DS/ENT/TSD`，应用层负责 `API/TBL/MW/CMP`；应用侧 [knowledge/](../application/knowledge/) 继续承接实现映射与实例登记。技术视角层级链仍为 `TPL → TSD → MW → CMP`。

#### Overview 蒸馏区

`architecture/overview/*-overview.md` 是**从散落知识到结构化架构章节的缓冲区**，不是最终 SSOT——最终 SSOT 在 `architecture/` 各视角章节与 [application/knowledge/](../application/knowledge/)。

| 阶段 | Skill | 产出 |
| --- | --- | --- |
| 抽取 | `/docs-extract` | overview 第三列草稿（段落筛选） |
| 蒸馏 | `/docs-distill` | 自应用镜像上行已核实内容至 overview 第三列 |
| 归档 | `/docs-archive` | 核实后落入 `architecture/` 各视角对应章节 |

原则：先 overview 缓冲区，再 archive，再 [docs-build](../application/knowledge/) 实体 — 不要一步到位硬造 YAML。

#### SSOT 继承矩阵（system/architecture ↔ company/ea）

`company/ea/` 聚焦**公司级治理叙事**；`system/architecture/` 聚焦**本系统落地叙事**。章节首段 SSOT 声明须与下表一致，**禁止**链接到不存在的 `company/ea/` 同名文件。

| 继承类型 | 说明 | 示例 |
| --- | --- | --- |
| **公司对齐** | 存在同名 `company/ea/{视角}/*.md` 时，系统章节引用其为上游标准 | `business-overview` → `company/ea/business/business-overview.md` |
| **框架参照** | 无同名公司文件时，系统章节为 SSOT，仅链至 `company/ea/{视角}/README.md` 或最近似公司章节 | `business-glossary`、`data-model` |
| **能力框架** | 系统能力落地参照公司 CAP 框架 | `business-capability-map` → `company/ea/business/business-capability.md` |
| **ADR** | 系统 ADR 正文在 `system/adr/` 或应用视角章节；模板见 `agent/knowledge/adr-*.md` | `application-adr.md` |
| **实体字段** | 跨层实体首次定义矩阵见 [application/DESIGN.md](../application/DESIGN.md) §2.2.1；`system/DESIGN.md` 不再逐字段重复铺开 | — |

目录契约：

- `system/` 维护目录语义、映射关系与流程约束；
- `application` 侧字段规则仅作为引用，不在 `system` 重复定义；
- 目录扩展优先更新契约，再落地内容。

---

## 3. system 与 application 映射与同步闭环

两者关系定义为“**索引治理层 ↔ 实体事实层**”。

- **事实来源**：公司 / 系统 / 应用三层实体按首次定义矩阵分层负责；应用层接口、数据表、组件及实现映射仍以 `application/` 为准；
- **治理映射**：`system/` 通过 `architecture/` 与 `application-{name}/` 维护跨应用可读视图与镜像挂载关系；
- **引用方式**：优先路径引用与 ID 引用，避免在 `system` 冗余复制实体正文。

同步闭环：

1. **下行拉取（docs-pull）**：同步目标应用文档至 `system/application-{name}/`（技能见 [agent/skills/docs-pull/SKILL.md](../agent/skills/docs-pull/SKILL.md)）；
2. **治理校核（system 层）**：在 `architecture/` 与 [agent/knowledge/knowledge-governance.md](../agent/knowledge/knowledge-governance.md) 约定下执行一致性检查；
3. **上行蒸馏（docs-distill）**：将已核实内容归并到系统主库结构；
4. **追溯记录（changelogs）**：保留索引与变更日志用于审计和回放。

---

## 4. 质量门禁与演进策略

质量门禁采用“轻规范、强可追溯”：

- **一致性门禁**：术语、目录职责与引用路径应与 `README.md`、`AGENTS.md`、`INDEX_GUIDE.md` 对齐；
- **边界门禁**：跨层实体不得在 `system` 与 `application` 形成双份主定义；应用层仅补实现映射与下游锚点；
- **同步门禁**：涉及 `application-{name}/` 更新须记录来源、影响范围与回写策略；
- **演进门禁**：新增目录或流程，先更新本文件契约，再更新实现文档。

演进顺序：

1. 稳定三层模型（治理/架构/联邦槽位）；
2. 增补模板与自动化检查（术语巡检、引用完整性检查）；
3. 对系统层首次定义实体，先更新本文件与命名 / 设计契约，再决定是否补充更细字段规则。

---

## 参考

- [README.md](README.md)
- [INDEX_GUIDE.md](INDEX_GUIDE.md)
- [agent/knowledge/knowledge-governance.md](../agent/knowledge/knowledge-governance.md)
- [architecture/README.md](architecture/README.md)
- [agent/references/knowledge-layout.md](../agent/references/knowledge-layout.md)
- [../company/DESIGN.md](../company/DESIGN.md)
- [../application/DESIGN.md](../application/DESIGN.md)
