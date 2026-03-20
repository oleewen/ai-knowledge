# ID 命名规范

知识库中所有**知识实体**必须拥有**全局唯一**的 ID，用于跨视角引用与追溯。本规范为必遵项。

---

## 1. 格式约定

- **通用格式**：`{TYPE}-{NAME}`，其中 `TYPE` 为下表所列前缀，`NAME` 为英文短名（建议大写+连字符）。
- **示例**：`BD-ORDER`、`BC-ORDER-MGMT`、`FT-ADD-TO-CART`、`APP-ORDER-SERVICE`、`ENT-T_ORDER`。

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
| MS- | Microservice | 微服务 |
| API- | API Endpoint | 接口端点 |

### 数据视角 (data)

| 前缀 | 英文全称 | 含义 |
|------|----------|------|
| DS- | Data Store | 数据存储 |
| ENT- | Entity | 数据实体（表/集合） |

---

## 3. 文件与目录命名

- **目录**：与实体 ID 一致（如 `BD-ORDER`、`PL-ECOMMERCE`），或与 ID 中 NAME 部分对应（如 `order` 与 `BD-ORDER` 对应时，以 ID 为准在索引中查找）。
- **实体定义文件**：应用注册等可为 `{id}.yaml`（如 `APP-ORDER-SERVICE.yaml`）；数据实体在系统库中推荐 `{ENT-ID}_ENT_meta.yaml`（如 `ENT-T_ORDER_ENT_meta.yaml`），与业务视角 `AGG_meta.yaml` 等并列约定。
- **元数据文件（目录索引）**：
  - **`system/` 根**：`system_meta.yaml`（阶段子目录与 `knowledge/` 指针、`INDEX`/`DESIGN` 等导航约定摘要）。
  - **`system/knowledge/` 根**：`knowledge_meta.yaml`（本树 SSOT 索引说明）。
  - **`system/knowledge/constitution/` 根**：`constitution_meta.yaml`（宪法层总索引，与四视角根目录 `business_meta.yaml` 等并列）。
  - **宪法层一级子树**（与根 meta 分工、避免重复）：`principles/principles_meta.yaml`、`standards/standards_meta.yaml`、`adr/adr_corpus_meta.yaml`；ADR 模板级约定仍为 `standards/adr_meta.yaml`。
  - **`system/` 下阶段目录**：与目录名一致的 `{dirname}_meta.yaml`，例如 `specs/specs_meta.yaml`、`solutions/solutions_meta.yaml`、`analysis/analysis_meta.yaml`、`requirements/requirements_meta.yaml`、`changelogs/changelogs_meta.yaml`。
  - **应用知识库根目录**（`applications/{app}/`）：`application_meta.yaml`（联邦单元根索引）；子目录同模式，如 `knowledge/knowledge_meta.yaml`、`requirements/requirements_meta.yaml`、`changelogs/changelogs_meta.yaml`；`knowledge/constitution/` 下子树 meta 与中央库同构。
  - **系统知识库四视角**在 `system/knowledge/{perspective}/` 采用「视角索引 + 层级实体」命名（`business_meta.yaml`、`PL_meta.yaml` 等），**集中放在该视角根目录**（子目录仅作导航锚点）。
- **系统知识库业务视角**（`system/knowledge/business/`）：`business_meta.yaml`、`BD_meta.yaml`、`BSD_meta.yaml`、`BC_meta.yaml`、`AGG_meta.yaml`；`{BD-ID}/` 等子目录作层级锚点。
- **系统知识库产品视角**（`system/knowledge/product/`）：`product_meta.yaml`、`PL_meta.yaml`、`PM_meta.yaml`、`FT_meta.yaml`；`{PL-ID}/{PM-ID}/` 作层级锚点。
- **系统知识库技术视角**（`system/knowledge/technical/`）：`technical_meta.yaml`、`SYS_meta.yaml`；`{SYS-ID}/` 为系统锚点，其下为应用注册 YAML。
- **系统知识库数据视角**（`system/knowledge/data/`）：`data_meta.yaml`、`DS_meta.yaml`、`{ENT-ID}_ENT_meta.yaml`；`{DS-ID}/` 作存储锚点。
- **宪法层 ADR 标准**：`constitution/standards/adr_meta.yaml` 与 [adr-template.md](./adr-template.md) 配套，描述模板结构、状态值与 `adr/ADR-{序号}-{短标题}.md` 落盘约定。

---

## 4. 引用规则

- 跨文件、跨视角引用**只写 ID 字符串**，不写名称或路径。
- 例如：在聚合中写 `persisted_as_entity_ids: ["ENT-T_ORDER"]`，在功能中写 `invokes_api_ids: ["API-CART-ADD-ITEM"]`。

---

*本规范与仓库根目录 [DESIGN.md](../../../../../system/DESIGN.md) 中的「ID 命名规范」一致。*
