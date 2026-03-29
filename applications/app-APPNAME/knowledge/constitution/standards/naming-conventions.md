# ID 命名规范

知识库中所有**知识实体**必须拥有**全局唯一**的 ID，用于跨视角引用与追溯。本规范为必遵项。

**适用范围（应用模板）**：本文件位于应用知识库模板 `applications/app-APPNAME/knowledge/constitution/standards/` 时，下文**路径**中的 **`system/`** 指仓库内**中央库目录**（不可改名为 `application/`）；**当前联邦单元**下的 `knowledge/` 即**应用知识库**，与 `system/knowledge/` 同构、命名规则一致。

---

## 1. 格式约定

- **通用格式**：`{TYPE}-{NAME}`，其中 `TYPE` 为下表所列前缀，`NAME` 为英文短名（建议大写+连字符）。
- **示例（本仓库）**：`BD-CHARGING-APPEAL`、`BC-BILLING-APPEAL-CORE`、`FT-BILLING-APPEAL-LIFECYCLE`、`APP-BILLING-APPEAL-SERVICE`、`ENT-T_BILLING_APPEAL`。

---

## 2. 各视角前缀一览

### 业务视角 (business)

| 前缀 | 英文全称 | 含义 |
|------|----------|------|
| BD- | Business Domain | 业务域 |
| BSD- | Business Subdomain | 业务子域 |
| BC- | Bounded Context | 限界上下文 |
| AGG- | Aggregate | 聚合根 |

### 产品视角 (product)

| 前缀 | 英文全称 | 含义 |
|------|----------|------|
| PL- | Product Line | 产品线 |
| PM- | Product Module | 产品模块 |
| FT- | Feature | 功能点 |
| UC- | Use Case | 用例 |
| BP- | Business Process | 业务流程 |
| BR- | Business Rule | 业务规则 |

### 技术视角 (technical)

| 前缀 | 英文全称 | 含义 |
|------|----------|------|
| SYS- | System | 系统 |
| APP- | Application | 应用（代码仓库/部署单元） |
| MS- | Microservice（技术视图 **入口簇**） | **对外入口**（HTTP/Dubbo/MQ/Job）**宿主类**按 **knowledge-extract §8.1.1** 聚类；**不**对应 Maven `artifactId`/子模块（**§8.1.2**） |
| API- | API Endpoint | 接口端点 |

### 数据视角 (data)

| 前缀 | 英文全称 | 含义 |
|------|----------|------|
| DS- | Data Store | 数据存储 |
| ENT- | Entity | 数据实体（表/集合） |

---

## 3. 文件与目录命名

- **目录**：与实体 ID 一致（如 `BD-CHARGING-APPEAL`、`PL-BILLING-APPEAL`），或以 ID 为准在索引中查找。
- **实体定义文件**：应用注册等可为 `{id}.yaml`（如 `APP-BILLING-APPEAL-SERVICE.yaml`）；数据实体字段模板见 **`data_meta.yaml`** 的 **`layers`**（`key: ent`）；若需逐实体落盘（如应用侧增量），可采用 `{ENT-ID}_ENT_meta.yaml` 约定；业务各层字段模板收敛于 **`business_meta.yaml`** 的 **`layers`** 数组。
- **元数据文件（目录索引）**：
  - **`system/` 根**：`system_meta.yaml`（阶段子目录与 `knowledge/` 指针、`INDEX`/`DESIGN` 等导航约定摘要）。
  - **`system/knowledge/` 根**：`knowledge_meta.yaml`（本树 SSOT 索引说明）。
  - **`system/knowledge/constitution/` 根**：`constitution_meta.yaml`（宪法层总索引，与四视角根目录 `business_meta.yaml` 等并列）。
  - **宪法层一级子树**（与根 meta 分工、避免重复）：`principles/principles_meta.yaml`、`standards/standards_meta.yaml`、`adr/adr_meta.yaml`（及同目录 `adr-template.md`）；ADR 正文为 `adr/ADR-{序号}-{短标题}.md`。
  - **`system/` 下阶段目录**：与目录名一致的 `{dirname}_meta.yaml`（含 `schema_version`、`layers` 等 SSOT 结构），例如 `solutions/solutions_meta.yaml`、`analysis/analysis_meta.yaml`、`requirements/requirements_meta.yaml`、`changelogs/changelogs_meta.yaml`。
  - **应用知识库根目录**（`applications/{app}/`）：`application_meta.yaml`（联邦单元根索引）；子目录同模式，如 `knowledge/knowledge_meta.yaml`、`requirements/requirements_meta.yaml`、`changelogs/changelogs_meta.yaml`；`knowledge/constitution/` 子树 meta 与中央库同构。
  - **中央库四视角**（`system/knowledge/{perspective}/`）：与**应用知识库** `applications/{app}/knowledge/{perspective}/` 同构；采用「视角索引 + 层级实体」命名（`business_meta.yaml`、`product_meta.yaml`、`technical_meta.yaml`、`data_meta.yaml` 等单文件 SSOT），**集中放在该视角根目录**（子目录仅作导航锚点）。
- **中央库 · 业务视角**（`system/knowledge/business/`）：`business_meta.yaml`（含 `layers`：BD/BSD/BC/AGG/AB）；`{BD-ID}/` 等子目录作层级锚点。
- **中央库 · 产品视角**（`system/knowledge/product/`）：`product_meta.yaml`（含 `layers`：PL/PM/FT/UC）；`{PL-ID}/{PM-ID}/` 作层级锚点。
- **中央库 · 技术视角**（`system/knowledge/technical/`）：`technical_meta.yaml`（含 `layers`：SYS/APP/MS/API）；`{SYS-ID}/` 为系统锚点，其下为应用注册 YAML。
- **中央库 · 数据视角**（`system/knowledge/data/`）：`data_meta.yaml`（含 `layers`：DS/ENT）；`{DS-ID}/` 作存储锚点。
- **中央库 · requirements 阶段**（`system/requirements/`）：`requirements_meta.yaml`（含 `layers`：REQ / MVP_PHASE）；`REQUIREMENT-{ID}/` 为交付包锚点，不在包内并列根级 `*_meta.yaml` 拷贝。
- **中央库 · solutions 阶段**（`system/solutions/`）：`solutions_meta.yaml`（含 `layers`：SOLUTION）；根目录平铺 `SOLUTION-{ID}.md`。
- **中央库 · analysis 阶段**（`system/analysis/`）：`analysis_meta.yaml`（含 `layers`：ANALYSIS）；根目录平铺 `ANALYSIS-{ID}.md`。
- **中央库 · changelogs**（`system/changelogs/`）：`changelogs_meta.yaml`（含 `layers`：CHANGELOG / INDEX_OPS）；`CHANGELOG.md` 与可选 Skill 索引文件同目录。
- **宪法层 ADR 标准**：`constitution/adr/adr_meta.yaml` 与 [applications/app-APPNAME/knowledge/constitution/adr/adr-template.md](../adr/adr-template.md) 配套，描述模板结构、状态值与 `adr/ADR-{序号}-{短标题}.md` 落盘约定。

---

## 4. 引用规则

- 跨文件、跨视角引用**只写 ID 字符串**，不写名称或路径。
- 例如：在聚合中写 `persisted_as_entity_ids: ["ENT-T_BILLING_APPEAL"]`，在功能中写 `invokes_api_ids: ["API-BILLING-APPEAL-CREATE"]`。

---

*本规范与中央库 [system/DESIGN.md](../../../../../system/DESIGN.md) 中的「ID 命名规范」一致。*
