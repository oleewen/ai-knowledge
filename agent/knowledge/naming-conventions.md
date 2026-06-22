# ID 命名规范

知识库中所有**知识实体**必须拥有**全局唯一**的 ID，用于跨视角引用与追溯。本规范为必遵项；SSOT 位于本仓库 `agent/knowledge/naming-conventions.md`。

**适用范围**：系统库 `application/`、`system/`、`company/` 及各联邦镜像 `applications/app-APPNAME/` 下的 `knowledge/` 实体均遵循本规范；治理叙事与 Agent 规则见 [`knowledge-governance.md`](knowledge-governance.md)。

---

## 1. 格式约定

- **通用格式**：`{TYPE}-{NAME}`，其中 `TYPE` 为下表所列前缀，`NAME` 为英文短名（建议大写+连字符）。
- **示例（本仓库）**：`BD-CHARGING-APPEAL`、`CAP-ORDER-FULFILL`、`BC-BILLING-APPEAL-CORE`、`FT-BILLING-APPEAL-LIFECYCLE`、`APP-BILLING-APPEAL-SERVICE`、`ENT-T_BILLING_APPEAL`、`TPL-K8S-PLATFORM`、`TSD`、`MW-KAFKA-ORDER-EVENTS`、`CMP-DUBBO-CLIENT`。

---

## 2. 各视角前缀一览

五视角：**业务 / 产品 / 应用 / 数据 / 技术**。跨层实体首次定义层级见 [application/DESIGN.md](../../../application/DESIGN.md) §2.2.1；公司层目录语义见 [company/DESIGN.md](../../../company/DESIGN.md)。

> 说明：**首次定义** 指该实体的治理语义、字段口径与上游主定义层级；下游层可继续做实例登记、实现映射、物理锚点或引用，不等同于“只允许在该层出现”。

### 业务视角 (business)

| 前缀   | 英文全称   | 含义    | 首次定义 |
| ---- | ------------------ | ----- | ---- |
| BD-  | Business Domain    | 业务域   | 公司 |
| CAP- | Business Capability | 业务能力（L1/L2/L3 能力目录） | 公司 |
| BSD- | Business Subdomain | 业务子域  | 系统 |
| BC-  | Bounded Context    | 限界上下文 | 系统 |
| AGG- | Aggregate | 聚合根   | 系统 |
| AB-  | Ability   | 领域能力（能力边界） | 系统 |

### 产品视角 (product)

| 前缀  | 英文全称 | 含义   | 首次定义 |
| --- | ---------------- | ---- | ---- |
| PL- | Product Line     | 产品线  | 公司 |
| PM- | Product Module   | 产品模块 | 系统 |
| BP- | Business Process | 业务流程 | 系统 |
| FT- | Feature | 功能点  | 系统 |
| UC- | Use Case         | 用例   | 系统 |
| BR- | Business Rule    | 业务规则 | 系统 |

### 应用视角 (application)

| 前缀   | 英文全称    | 含义       | 首次定义 |
| ---- | -------------------------- | ------------------------------------------------------------------------------------------------------- | ---- |
| SYS- | System  | 系统       | 公司 |
| APP- | Application    | 应用（代码仓库/部署单元）   | 系统 |
| MS-  | Microservice | 微服务（**入口簇**） | 系统 |
| API- | API Endpoint   | 接口端点     | 应用 |

### 数据视角 (data)

| 前缀   | 英文全称       | 含义         | 首次定义 |
| ---- | ---------- | ---------- | ---- |
| MDG- | Master Data Domain | 主数据域（治理目录，非 DS/ENT 替代） | 公司 |
| DS-  | Data Store | 数据存储       | 系统 |
| ENT- | Entity     | 数据实体（表/集合） | 系统 |
| TBL- | Table      | 数据表（物理表锚点） | 应用 |

### 技术视角 (technical)

| 前缀   | 英文全称  | 含义 | 首次定义 |
| ---- | ----------------- | ---- | ---- |
| TPL- | Technology Platform | 公司级平台能力目录（云/DevOps/安全/开发环境） | 公司 |
| TSD- | Technical Domain    | 系统级技术域落地（中间件域、可观测域等） | 系统 |
| MW-  | Middleware Binding  | 应用内中间件绑定实例（连接串、集群、Topic 等） | 应用 |
| CMP- | Component  | 关键 Maven 依赖 / 共享运行时组件 | 应用 |

层级链：`TPL → TSD → MW`；`CMP` 挂 `MW` 或 `APP`（`parent_mw_id` / `parent_app_id`）。**MW** 登记基础设施绑定；**MS/API** 仍登记业务入口宿主，二者不互替。

---

## 3. 文件与目录命名

- **目录**：与实体 ID 一致（如 `BD-CHARGING-APPEAL`、`PL-BILLING-APPEAL`），或以 ID 为准在索引中查找。
- **实体定义文件**：应用注册等可为 `{id}.yaml`（如 `APP-BILLING-APPEAL-SERVICE.yaml`）；数据实体字段模板见各视角 `{perspective}-meta.md` §4 必填字段；若需逐实体落盘（如应用侧增量），可采用 `{ENT-ID}_ENT_meta.yaml` 约定；业务各层字段模板收敛于 **`business-meta.md`** §4。
- **元数据文件（目录索引）**：
  - **`application/`、`system/`、`company/` 根**：`docs-meta.md`（阶段子目录与 `knowledge/` 指针、`INDEX_GUIDE`/`DESIGN` 等导航约定摘要）。
  - **`{DOC_DIR}/knowledge/` 根**：`knowledge-meta.md`（本树 SSOT 索引说明）。
  - **治理与命名 SSOT**：`agent/knowledge/`（`naming-conventions.md`、`glossary.md`、`architecture-principles.md`、`adr-template.md`、`adr-guidelines.md`）；ADR 正文为 `application/adr/ADR-{序号}-{短标题}.md` 或 `system/adr/ADR-{序号}-{短标题}.md`（按决策范围）。
  - **`{DOC_DIR}/` 下阶段目录**：**solutions**、**analysis**、**requirements**、**changelogs** 约定收敛于各目录 `README.md`（无 `{dirname}_meta.yaml`）。`knowledge/` 五视角等使用 `{perspective}-meta.md` + `{perspective}-entities.md`。
  - **应用知识库根目录**（`applications/{app}/`）：`application_meta.yaml`（联邦单元根索引）；子目录同模式，如 `knowledge/knowledge-meta.md`、`requirements/README.md`、`changelogs/README.md`；命名与治理规则引用系统库 `agent/knowledge/`。
  - **系统库五视角**（`system/knowledge/{perspective}/`）：与**应用知识库** `applications/{app}/knowledge/{perspective}/` 同构；采用 `{perspective}-meta.md` + `{perspective}-entities.md`，**集中放在该视角根目录**（子目录仅作导航锚点）。
- **系统库 · 业务视角**（`system/knowledge/business/`）：`business-meta.md`；域文件夹 `{登记入口-ID}/`（示例 `BD-EXAMPLE/`）内扁平 `{ID}.md` + `index.md`。
- **系统库 · 产品视角**（`application/knowledge/product/`）：`product-meta.md`（PL/PM/FT/UC）；`{PL-ID}/{PM-ID}/` 作层级锚点。
- **系统库 · 应用视角**（`system/knowledge/application/`）：`application-meta.md`（SYS/APP/MS/API）；`{SYS-ID}/` 为系统锚点，其下为应用注册 YAML。
- **系统库 · 数据视角**（`system/knowledge/data/`）：`data-meta.md`（DS/ENT）；`{DS-ID}/` 作存储锚点。
- **系统库 · 技术视角**（`system/knowledge/technical/`）：`technical-meta.md`（MW/CMP）；`technical-entities.md` 为实体 SSOT。
- **公司层五视角**（`company/knowledge/{perspective}/`）：叙事 Markdown + `{perspective}-meta.md` + `{perspective}-entities.md`（公司级实体：BD/CAP、PL、SYS、MDG、TPL）。
- **IDEA-ID（需求链统一标识）**：统一命名格式 `*-{YYMMDD}-{主题slug}` 中的 `{YYMMDD}-{主题slug}` 段；各阶段类型前缀为 `SOLUTION` / `ANALYSIS` / `REQUIREMENT`（目录）/ `PRD` / `ASD` / `DSD` / `TDD` 等。
- **系统库 · requirements 阶段**（`system/requirements/`）：`README.md` 为阶段约定入口；`REQUIREMENT-{IDEA-ID}/` 为交付包锚点（与 `ANALYSIS-{IDEA-ID}.md` 共用同一 **IDEA-ID**），不在包内并列根级 `*_meta.yaml` 拷贝。
- **系统库 · solutions 阶段**（`system/solutions/`）：`README.md` 为阶段约定入口；根目录平铺 `SOLUTION-{IDEA-ID}.md`；`archive/` 归档。
- **系统库 · analysis 阶段**（`system/analysis/`）：`README.md` 为阶段约定入口；根目录平铺 `ANALYSIS-{IDEA-ID}.md`。
- **系统库 · changelogs**（`system/changelogs/`）：`README.md` 为阶段约定入口；`CHANGE-LOG.md`（变更聚合）；`INDEXING-LOG.md`（索引运行日志）。
- **ADR 落盘**：结构见 [adr-guidelines.md](adr-guidelines.md) 与 [adr-template.md](adr-template.md)；正文目录为 `application/adr/` 或 `system/adr/`。

### OKF concept 路径与 type 映射

`application/` bundle 内实体 SSOT 为 **per-entity `{ID}.md`**（frontmatter 含 `full_id`、`type`、`perspective`、`hierarchy`）。legacy `{perspective}-entities.md` 已废弃。路径与 OKF `type` 对照：

| 视角 | 典型 concept 路径 | OKF `type`（摘录） |
|------|-------------------|-------------------|
| business | `knowledge/business/BSD-EXAMPLE/{ID}.md`（域扁平树） | `Business Domain` / … |
| product | `knowledge/product/PM-EXAMPLE/{ID}.md` | `Product Line` / … |
| application | `knowledge/application/MS-EXAMPLE/{ID}.md` | `System` / … |
| data | `knowledge/data/ENT-EXAMPLE/{ID}.md` | `Data Store` / `Entity` |
| technical | `knowledge/technical/MW-EXAMPLE/{ID}.md` | `Middleware Binding` / `Component` |

---

## 4. 引用规则

- 跨文件、跨视角引用**只写 ID 字符串**，不写名称或路径。
- 例如：在聚合中写 `persisted_as_entity_ids: ["ENT-T_BILLING_APPEAL"]`，在功能中写 `invokes_api_ids: ["API-BILLING-APPEAL-CREATE"]`，在能力地图中写 `maps_to_cap_ids: ["CAP-ORDER-FULFILL"]`，在中间件绑定中写 `parent_tsd_id: "TSD"`，在组件中写 `maven_coordinates: "org.apache.dubbo:dubbo:3.x"`。

---

*本规范与系统库 [application/DESIGN.md](../../../application/DESIGN.md) 中的「ID 命名规范」一致。*
