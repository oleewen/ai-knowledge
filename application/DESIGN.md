# 应用知识文档库 — 设计方案摘录

本文件是《应用知识文档库设计方案》的**精简版**：治理依据与演进参考。细节与入口仍以 [README.md](README.md)、[INDEX_GUIDE.md](INDEX_GUIDE.md) 及仓库根 [INDEX_GUIDE.md](../INDEX_GUIDE.md) 为准。

---

## 阅读顺序

1. [README.md](README.md) — 应用知识库定位与 SDD 主线
2. 本文 — 原则、元模型、映射、演进
3. [constitution/standards/naming-conventions.md](constitution/standards/naming-conventions.md) — ID 规则
4. 各视角 [knowledge/README.md](knowledge/README.md) — 落盘与字段

---

## 1. 原则与约定


| 原则       | 说明                                                                                   |
| -------- | ------------------------------------------------------------------------------------ |
| **SSOT** | 实体只在一处定义；他处仅 **ID 引用**                                                               |
| **联邦治理** | 系统库管边界与索引；应用库管实现细节并 **上行对齐**                                                         |
| **闭环**   | knowledge ← 归档回写；阶段上 solutions → analysis → requirements；规约落在需求包内 specs/ 或 knowledge/application/ |
| **四视角**  | 业务 / 产品 / 应用 / 数据；关联写在各视角 YAML，**不**维护独立映射矩阵文件                                       |
| **与系统层视角** | 应用层四视角为实体 SSOT；系统层在此基础上增加 **technical（技术）** 五架构视角，用于聚合与治理，见 [../system/DESIGN.md](../system/DESIGN.md) |


**目录索引 YAML（约定）**：

- ***应用知识库根目录**：使用 [docs_meta.yaml](docs_meta.yaml) 概括 `application/` 树与子目录 meta 指针
  - `knowledge/knowledge_meta.yaml` 描述知识树；
  - `constitution/constitution_meta.yaml` 描述宪法层组件与产出；
  - **`solutions/`、`analysis/`、`requirements/`、`changelogs/`** 阶段约定均收敛于各目录 **`README.md`**（无 `{dirname}_meta.yaml`）。宪法层、`knowledge/` 四视角等仍使用 `{dirname}_meta.yaml`（见 [constitution/standards/naming-conventions.md](constitution/standards/naming-conventions.md)）。
- 细则见 [constitution/standards/naming-conventions.md](constitution/standards/naming-conventions.md)。

**协同（目标态）**：应用仓维护 `/docs` 与 `manifest.yaml`；系统侧可抓取 manifest 更新 `knowledge` 并做一致性检查。

---

## 2. `application/` 目录与元模型

> 规范与 Agent 配置在仓库根目录 `agent/` 等，**不在** `application/` 内。

### 2.1 `application/` 内目录


| 目录                | 说明                                               |
| ----------------- | ------------------------------------------------ |
| **constitution/** | 宪法层：术语、原则、标准、ADR                                  |
| **knowledge/**    | 业务 / 产品 / 应用 / 数据 四视角                             |
| **solutions/**    | `SOLUTION-{IDEA-ID}.md`                          |
| **analysis/**     | `ANALYSIS-{IDEA-ID}.md`                          |
| **requirements/** | `REQUIREMENT-{IDEA-ID}/` 按阶段交付（规约可在各包内 `specs/`） |
| **changelogs/**   | 变更记录与索引运维（可选）                                    |


### 2.2 应用知识库

#### 宪法层 (constitution)

使命：术语、原则、标准、ADR。ID 与命名见 `standards/naming-conventions.md`。目录总索引见 `constitution_meta.yaml`；`principles/`、`standards/`、`adr/` 各有轻量子树 meta（表见该层 README），ADR 模板与字段约定以 `adr/adr_meta.yaml` 为准。

#### 业务 (business)

- **层级**：BD → BSD → BC → AGG → AB  
- **约定**：`business_meta.yaml` 在 `knowledge/business/` 根目录（单文件 SSOT：`identity`、`repository`、`pipeline`、`integration`、`layers[]`）；`{BD-ID}/…` 为锚点目录。AGG 含 `persisted_as_entity_ids` 等；AB 为能力（Ability）缩写，`implemented_by_api_id` 映射 API。

#### 产品 (product)

- **层级**：PL → PM → FT → UC  
- **约定**：`product_meta.yaml` 在根目录（单文件 SSOT：`identity`、`repository`、`pipeline`、`integration`、`layers[]`）；`{PL-ID}/{PM-ID}/` 为锚点。FT 含 `invokes_api_ids`、`realizes_use_case_ids` 等；UC 含 `map_to_api_id` 等。

#### 应用 (application)

- **层级**：SYS → APP → MS → API  
- **约定**：`application_meta.yaml` 在根目录（单文件 SSOT：`identity`、`repository`、`pipeline`、`integration`、`layers[]`）；`{SYS-ID}/{APP目录}/{APP-ID}.yaml` 登记 `repo_url`、`docs_manifest_path`、`service_ids` 等。

#### 数据 (data)

- **层级**：DS → ENT  
- **约定**：`data_meta.yaml` 在根目录（单文件 SSOT：`identity`、`repository`、`pipeline`、`integration`、`layers[]`）；`{DS-ID}/` 为存储锚点。ENT 含 `maps_to_aggregate_id`、敏感级别等。

### 2.2.1 跨层实体首次定义层级

实体在联邦三层中**首次定义**的层级如下；他处仅 ID 引用，不重复定义字段语义。

| 视角 | 实体 | 首次定义层级 |
| --- | --- | --- |
| **业务** business | 业务域 BD | 公司 [company/](../company/DESIGN.md) |
| | 业务子域 BSD | 系统 [system/](../system/DESIGN.md) |
| | 限界上下文 BC | 应用（本层） |
| | 聚合 AGG | 应用（本层） |
| | 能力 AB | 应用（本层） |
| **产品** product | 产品线 PL | 公司 |
| | 产品模块 PM | 系统 |
| | 产品功能 FT | 应用（本层） |
| | 用户场景 UC | 应用（本层） |
| | 业务规则 BR | 应用（本层） |
| **应用** application | 系统层 SYS | 公司 |
| | 应用层 APP | 系统 |
| | 模块层 MS | 应用（本层） |
| | 接口层 API | 应用（本层） |
| **数据** data | 数据层 DS | 系统 |
| | 实体 ENT | 应用（本层） |
| | 数据表 TBL | 应用（本层） |

### 2.3 阶段目录


| 阶段               | 约定                                                                                                                                            |
| ---------------- | --------------------------------------------------------------------------------------------------------------------------------------------- |
| **solutions**    | `README.md`（阶段约定 SSOT）；根目录平铺 `SOLUTION-{IDEA-ID}.md`；`archive/` 归档；文末元数据可选 `parent`/`dependencies`（无 `solutions_meta.yaml`）                                                                          |
| **analysis**     | `README.md`（阶段约定 SSOT）；根目录平铺 `ANALYSIS-{IDEA-ID}.md`；文末元数据 `parent` → Solution（单层交付物）                                                           |
| **requirements** | `README.md`（阶段约定 SSOT）；`REQUIREMENT-{IDEA-ID}/MVP-Phase-*/` 下 PRD / ASD / DSD / TDD；**详设正文**仅为 **`DSD-*.md`**；**`spec-asd-*.md`** 仅在各阶段 `specs/`（无 `requirements_meta.yaml`） |
| **changelogs**   | `README.md`（阶段约定 SSOT）；`CHANGE-LOG.md`（docs-change）；`INDEXING-LOG.md`（docs-indexing）；无 `changelogs_meta.yaml`                        |


---

## 3. 核心映射（分布式引用）

在源实体 YAML 中写**目标实体 ID**。


| 方向   | 源        | 目标       | 字段                                 | 含义            |
| ---- | -------- | -------- | ---------------------------------- | ------------- |
| 实现   | BC       | APP      | `implemented_by_app_id`            | 上下文由哪个APP实现   |
| 实现   | AGG      | MS       | `implemented_by_service_ids`       | 聚合根被哪些 MS 实现  |
| 实现   | AB       | API      | `implemented_by_api_id`            | 能力被哪个API实现    |
| 需求支撑 | PM       | BC       | `relies_on_context_ids`            | 模块依赖哪些上下文（组件） |
| 接口   | FT       | API      | `invokes_api_ids`                  | 功能调用的 API     |
| 接口   | UC       | API      | `map_to_api_id`                    | 用例映射的 API     |
| 持久化  | AGG      | ENT      | `persisted_as_entity_ids`          | 模型落哪些表        |
| 归属   | ENT / DS | MS / APP | `owned_by_service_id` / `app_id` 等 | 写入与归属         |


---

## 4. ADR 与 ID 前缀

- **ADR**：`constitution/adr/ADR-{序号}-{标题}.md`；结构见 `constitution/adr/adr-template.md`  
- **前缀（摘录）**：BD、BSD、BC、AGG、AB、PL、PM、FT、UC、SYS、APP、MS、API、DS、ENT — 全文见 `constitution/standards/naming-conventions.md`

---