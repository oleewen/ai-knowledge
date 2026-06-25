---
type: Design Document
title: 应用知识文档库 — 设计方案摘录
---
# 应用知识文档库 — 设计方案摘录

本文件是《应用知识文档库设计方案》的**精简版**：治理依据与演进参考。细节与入口仍以 [README.md](README.md)、[INDEX-GUIDE.md](INDEX-GUIDE.md) 及仓库根 [INDEX-GUIDE.md](../INDEX-GUIDE.md) 为准。

---

## 阅读顺序

1. [README.md](README.md) — 应用知识库定位与 SDD 主线
2. 本文 — 原则、元模型、映射、演进
3. [agent/knowledge/naming-conventions.md](../agent/knowledge/naming-conventions.md) — ID 规则
4. 各视角 [knowledge/README.md](knowledge/README.md) — 落盘与字段

---

## 1. 原则与约定


| 原则       | 说明                                                                                   |
| -------- | ------------------------------------------------------------------------------------ |
| **SSOT** | 实体只在一处定义；他处仅 **ID 引用**                                                               |
| **联邦治理** | 系统库管边界与索引；应用库管实现细节并 **上行对齐**                                                         |
| **闭环**   | knowledge ← 归档回写；阶段上 solutions → analysis → requirements；规约落在需求包内 specs/ 或 knowledge/application/ |
| **五视角**  | 业务 / 产品 / 应用 / 数据 / 技术；关联写在各视角 meta 与 **实体文件 `{ID}.md`**（OKF 概念实体），**不**维护独立映射矩阵文件；legacy `*-entities.md` 已废弃                                       |
| **与系统/公司层视角** | 五视角在各层同构；公司/系统/应用按 [naming-conventions.md](../agent/knowledge/naming-conventions.md) 与 §2.2.1 分层首次定义实体 |


**目录索引（约定）**：

- ***应用知识库根目录**：使用 [docs-meta.md](docs-meta.md) 概括 `application/` 树与子目录 meta 指针
  - `knowledge/knowledge-meta.md` 描述知识树；
  - 治理与命名 SSOT 见 [agent/knowledge/knowledge-governance.md](../agent/knowledge/knowledge-governance.md)；
- **`solutions/`、`analysis/`、`requirements/`、`changelogs/`** 阶段约定均收敛于各目录 **`README.md`**。`knowledge/` 五视角采用 `{perspective}-meta.md` + **实体文件 `{ID}.md`**（OKF SSOT）；`KNOWLEDGE-INDEX.md` 由扫描生成。
- 细则见 [agent/knowledge/naming-conventions.md](../agent/knowledge/naming-conventions.md)。

**协同（目标态）**：应用仓维护 `/docs` 与 `manifest.md`；系统侧可抓取 manifest 更新 `knowledge` 并做一致性检查。

### OKF 实体文件（per-entity）SSOT

`application/` 已对齐 [Open Knowledge Format v0.1](https://github.com/GoogleCloudPlatform/knowledge-catalog/blob/main/okf/SPEC.md)：**每个知识实体**为一概念实体文件（`{ID}.md` + YAML frontmatter + bundle-relative 跨链）；各级 `index.md` 供 RAG 渐进下钻；`KNOWLEDGE-INDEX.md` 由工具扫描生成而非手写聚合表。路径与 type 见 [agent/knowledge/naming-conventions.md](../agent/knowledge/naming-conventions.md) §OKF；工具链见 `/docs-okf`。

---

## 2. `application/` 目录与元模型

> 规范与 Agent 配置在仓库根目录 `agent/` 等，**不在** `application/` 内。

### 2.1 `application/` 内目录


| 目录                | 说明                                               |
| ----------------- | ------------------------------------------------ |
| **knowledge/**    | 业务 / 产品 / 应用 / 数据 / 技术 五视角                             |
| **solutions/**    | `SOLUTION-{IDEA-ID}.md`                          |
| **analysis/**     | `ANALYSIS-{IDEA-ID}.md`                          |
| **requirements/** | `REQUIREMENT-{IDEA-ID}/` 按阶段交付（规约可在各包内 `specs/`） |
| **changelogs/**   | 变更记录与索引运维（可选）                                    |
| **adr/**          | 应用层 ADR 正文（`ADR-{序号}-{标题}.md`）                      |


### 2.2 应用知识库

治理与命名 SSOT 见仓库根 [agent/knowledge/knowledge-governance.md](../agent/knowledge/knowledge-governance.md)（术语、原则、命名、ADR 已自 `constitution/` 迁入 `agent/knowledge/`）。

#### 业务 (business)

> 该视角回答：做什么业务、边界在哪、流程与能力如何组织。

- **层级**：BD → BSD → BC → AGG → AB  
- **约定**：`business-meta.md` 在 `knowledge/business/` 根目录；**域扁平树** `BSD-EXAMPLE/`（登记入口）内扁平存放 `BD-EXAMPLE.md`(reference) 与 BSD→AB 全链 `{ID}.md`。

#### 产品 (product)

> 该视角回答：用户是谁、功能如何组织、旅程与场景。

- **层级**：PL → PM → FT → UC  
- **约定**：`product-meta.md` 在根目录；`{PL-ID}/{PM-ID}/` 为锚点。实例为实体文件 `{ID}.md`（OKF 概念实体）；索引见 [KNOWLEDGE-INDEX.md](knowledge/KNOWLEDGE-INDEX.md) §2。FT 含 `invokes_api_ids`、`realizes_use_case_ids` 等；UC 含 `map_to_api_id` 等。

#### 应用 (application)

> 该视角回答：系统如何拆分、服务如何协作、领域与集成边界。

- **层级**：SYS → APP → MS → API  
- **约定**：`application-meta.md` 在根目录；`{SYS-ID}/{APP目录}/` 为锚点。APP/MS/API 等实体以实体文件 `{ID}.md` frontmatter 登记 `repo_url`、`docs_manifest_path`、`service_ids` 等；索引见 [KNOWLEDGE-INDEX.md](knowledge/KNOWLEDGE-INDEX.md) §3。

#### 数据 (data)

> 该视角回答：数据如何建模、存储、流转与治理。

- **层级**：DS → ENT  
- **约定**：`data-meta.md` 在根目录；`{DS-ID}/` 为存储锚点。实例为实体文件 `{ID}.md`；索引见 [KNOWLEDGE-INDEX.md](knowledge/KNOWLEDGE-INDEX.md) §4。ENT 含 `maps_to_aggregate_id`、敏感级别等。

#### 技术 (technical)

> 该视角回答：如何运行、扩展、观测与交付。

- **层级**：MW → CMP（公司 **TPL**、系统 **TSD** 在对应层 `technical/` 登记）  
- **约定**：`technical-meta.md` 在 `knowledge/technical/` 根目录。中间件绑定与关键组件见实体文件 `{ID}.md`；索引见 [KNOWLEDGE-INDEX.md](knowledge/KNOWLEDGE-INDEX.md) §5。MW 含 `parent_tsd_id`、`bound_app_id`；CMP 含 `maven_coordinates`、`parent_mw_id` 或 `parent_app_id`。

> 系统层五视角关注域见 [system/DESIGN.md](../system/DESIGN.md) §五架构视角；公司层五视角见 [company/DESIGN.md](../company/DESIGN.md) §公司层五视角聚焦范围；跨层实体首次定义见 §2.2.1。

### 2.2.1 跨层实体首次定义层级

实体在联邦三层中**首次定义**的层级如下；他处仅 ID 引用，不重复定义字段语义。

| 视角 | 实体 | 首次定义层级 |
| --- | --- | --- |
| **业务** business | 业务域 BD | 公司 [company/](../company/DESIGN.md) |
| | 业务能力 CAP | 公司 |
| | 业务子域 BSD | 系统 [system/](../system/DESIGN.md) |
| | 限界上下文 BC | 系统 |
| | 聚合 AGG | 系统 |
| | 能力 AB | 系统 |
| **产品** product | 产品线 PL | 公司 |
| | 产品模块 PM | 系统 |
| | 产品功能 FT | 系统 |
| | 用户场景 UC | 系统 |
| | 业务流程 BP | 系统 |
| | 业务规则 BR | 系统 |
| **应用** application | 系统层 SYS | 公司 |
| | 应用层 APP | 系统 |
| | 模块层 MS | 系统 |
| | 接口层 API | 应用（本层） |
| **数据** data | 主数据域 MDG | 公司 |
| | 数据层 DS | 系统 |
| | 实体 ENT | 系统 |
| | 数据表 TBL | 应用（本层） |
| **技术** technical | 技术平台能力 TPL | 公司 |
| | 技术域 TSD | 系统 |
| | 中间件绑定 MW | 应用（本层） |
| | 组件 CMP | 应用（本层） |

### 2.3 阶段目录


| 阶段               | 约定                                                                                                                                            |
| ---------------- | --------------------------------------------------------------------------------------------------------------------------------------------- |
| **solutions**    | `README.md`（阶段约定 SSOT）；根目录平铺 `SOLUTION-{IDEA-ID}.md`；`archive/` 归档；文末元数据可选 `parent`/`dependencies`（无 `solutions_meta.yaml`）                                                                          |
| **analysis**     | `README.md`（阶段约定 SSOT）；根目录平铺 `ANALYSIS-{IDEA-ID}.md`；文末元数据 `parent` → Solution（单层交付物）                                                           |
| **requirements** | `README.md`（阶段约定 SSOT）；`REQUIREMENT-{IDEA-ID}/MVP-Phase-*/` 下 PRD / ASD / DSD / TDD；**详设正文**仅为 **`DSD-*.md`**；**`spec-asd-*.md`** 仅在各阶段 `specs/`（无 `requirements_meta.yaml`） |
| **changelogs**   | `README.md`（阶段约定 SSOT）；`CHANGE-LOG.md`（docs-change）；`INDEXING-LOG.md`（docs-indexing）；无 `changelogs_meta.yaml`                        |


---

## 3. 核心映射（分布式引用）

在源实体 frontmatter 中写**目标实体 ID**。


| 方向   | 源        | 目标       | 字段                                 | 含义            |
| ---- | -------- | -------- | ---------------------------------- | ------------- |
| 实现   | BC       | APP      | `implemented_by_app_id`            | 上下文由哪个APP实现   |
| 实现   | AGG      | MS       | `implemented_by_service_ids`       | 聚合根被哪些 MS 实现  |
| 实现   | AB       | API      | `apis`（`apis[].id`）              | 能力绑定的 API 列表（单 API 时仅一项）    |
| 需求支撑 | PM       | BC       | `relies_on_context_ids`            | 模块依赖哪些上下文（组件） |
| 接口   | FT       | API      | `invokes_api_ids`                  | 功能调用的 API     |
| 接口   | UC       | API      | `map_to_api_id`                    | 用例映射的 API     |
| 持久化  | AGG      | ENT      | `persisted_as_entity_ids`          | 模型落哪些表        |
| 归属   | ENT / DS | MS / APP | `owned_by_service_id` / `app_id` 等 | 写入与归属         |


---

## 4. ADR 与 ID 前缀

- **ADR**：应用层 `application/adr/ADR-{序号}-{标题}.md`；系统层 `system/adr/`；结构见 [agent/knowledge/adr-template.md](../agent/knowledge/adr-template.md)
- **前缀（摘录）**：BD、BSD、BC、AGG、AB、CAP、PL、PM、FT、UC、SYS、APP、MS、API、MDG、DS、ENT、TPL、TSD、MW、CMP — 全文见 [agent/knowledge/naming-conventions.md](../agent/knowledge/naming-conventions.md)

---
