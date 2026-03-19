> **模板示例**：本文件为知识库模板示例，实际项目请按需替换内容与 ID。

# 全局软件系统知识文档库 — 设计方案摘录

本文档是《全局软件系统知识文档库设计方案》（精简版），作为本知识库的设计依据与演进参考。

---

## 1. 设计哲学与核心原则

### 1.1 核心原则


| 原则               | 说明                                                                               |
| ---------------- | -------------------------------------------------------------------------------- |
| **单一事实源 (SSOT)** | 每个知识实体（业务域、API、数据表等）仅在一处定义，其他地方通过 ID 引用。                                         |
| **联邦治理**         | **系统级仓库**：集中管理宏观架构（业务域、产品线、系统边界）及跨域关系索引。**应用级仓库**：分散管理微观设计（API、Schema、代码），并向上注册。 |
| **全链路闭环**         | **业务知识** -新的诉求-> **解决方案** -深度研究-> **需求分析** -分版交付-> **需求交付** -需求归档-> **业务知识**。每轮需求的提出、拆解、交付与归档均形成闭环反馈，实现持续演进。 |
| **四大视角**         | 通过**业务、产品、技术、数据**四个维度描述系统业务知识，视角间通过显式 ID 映射关联。                                       |


### 1.2 总体架构

- **知识建模层**：knowledge/business、knowledge/product、knowledge/technical、knowledge/data 四视角独立建模。
- **知识融合**：不维护独立“映射矩阵文件”，而在各实体的 `_meta.yaml` 或定义文件中通过**目标实体 ID** 建立关联。
- **协同机制**：应用级在代码库维护 `/docs` 与 `manifest.yaml`；系统级在 CI/CD 中抓取 manifest，更新 knowledge/technical 下的应用元数据，并做一致性检查。

---

## 2. 目录结构与元模型规范

元模型通过**目录结构**与 **`_meta.yaml`** 体现，节点属性与关联均在 YAML 中描述。仓库根目录与 [README.md](./README.md) 保持一致。

### 2.1 根目录结构

| 目录 | 说明 |
|------|------|
| **knowledge/** | 知识库（宪法层 + 业务/产品/技术/数据四视角） |
| **solutions/** | 解决方案文档（SOLUTION-{ID}.md，含 archive/） |
| **analysis/** | 需求分析文档（REQUIREMENT-{ID}.md） |
| **requirements/** | 需求交付（REQUIREMENT-{ID}/ 按 MVP 阶段，PRD/ADD/TDD） |
| **specs/** | 需求规约（服务/接口等规格，供 solutions、analysis 引用） |
| **changelogs/** | 变更日志（CHANGELOG.md） |
| **.ai/** | AI 助手配置（rules、prompts、context、workflows） |

### 2.2 宪法层 (constitution)

- **定位**：治理层使命、ADR、架构原则、命名规范与术语表。
- **约定**：`adr/`、`principles/`、`standards/`；实体 ID 与命名遵循 `standards/naming-conventions.md`。

### 2.3 业务视角 (business)

- **定位**：业务版图、领域逻辑与规则，不依赖具体技术实现。
- **层级**：`业务域 (BD)` → `子域 (BSD)` → `限界上下文 (BC)` → `聚合 (AGG)`。
- **约定**：每层目录可有 `_meta.yaml`；聚合在 `aggregates/{agg_id}.yaml`，内容含聚合根、实体、不变量、`persisted_as_entity_ids` 等。

### 2.4 产品视角 (product)

- **定位**：产品功能、用户旅程与需求规格。
- **层级**：`产品线 (PL)` → `模块 (PM)` → `功能 (FT)` → 用例 (UC)。
- **约定**：功能点在 `features/{feature_id}.yaml`，含优先级、验收标准、`invokes_api_ids`、`realizes_use_case_ids` 等。

### 2.5 技术视角 (technical)

- **定位**：物理实现、部署架构与服务接口。
- **层级**：`系统 (SYS)` → `应用 (APP)` → 微服务 (MS)。
- **约定**：应用以 `{app_id}.yaml` 登记，含 `repo_url`、`docs_manifest_path`、`service_ids` 等。

### 2.6 数据视角 (data)

- **定位**：数据存储结构、流向与治理属性。
- **层级**：`数据存储 (DS)` → `数据实体 (ENT)`。
- **约定**：存储目录含 `_meta.yaml`（类型、归属 app_id）；实体在 `schema/{entity_id}.yaml`，含字段、敏感级别、`maps_to_aggregate_id` 等。

### 2.7 解决方案 (solutions)

- **定位**：业务诉求的解决方案文档，对应 AI SDD 解决方案阶段产出；作为需求分析阶段的输入。
- **约定**：`SOLUTION-{ID}.md` 命名；已完结方案可移入 `archive/`。

### 2.8 需求分析 (analysis)

- **定位**：需求分析文档与 MVP 拆分，对应 AI SDD 需求分析阶段产出；作为需求交付阶段的输入。
- **约定**：`REQUIREMENT-{ID}.md` 命名；通过 frontmatter 的 `parent` 关联到 solutions。

### 2.9 需求交付 (requirements)

- **定位**：按 MVP 阶段组织的交付物（PRD/ADD/TDD 等），将分析阶段的高层次需求落地为可执行文档。
- **约定**：`REQUIREMENT-{ID}/` 目录，其下按阶段建子目录（如 `MVP-Phase-1/`），内含 PRD.md、ADD.md、TDD.md 等。

### 2.10 需求规约 (specs)

- **定位**：服务/接口等规格定义，供 solutions、analysis 引用，与 knowledge/technical 可互补。
- **约定**：按服务或规约类型建子目录（如 `example-service/`），具体格式由项目约定。

---

## 3. 核心映射机制（分布式引用）

在源实体的 `_meta.yaml` 或定义文件中直接写目标实体 ID，无需单独映射矩阵。


| 关系方向  | 源实体                      | 目标实体                       | 关键字段                             | 业务含义         |
| ----- | ------------------------ | -------------------------- | -------------------------------- | ------------ |
| 落地实现  | Bounded Context          | Application                | `implemented_by_app_id`          | 业务上下文由哪个应用实现 |
| 需求支撑  | Product Module           | Bounded Context            | `relies_on_context_ids`          | 产品模块依赖哪些业务能力 |
| 接口实现  | Feature                  | API Endpoint               | `invokes_api_ids`                | 功能调用的 API    |
| 数据持久化 | Aggregate                | Data Entity                | `persisted_as_entity_ids`        | 领域模型落在哪些表    |
| 数据归属  | Data Entity / Data Store | Microservice / Application | `owned_by_service_id` / `app_id` | 谁唯一写入 / 归属应用 |


---

## 4. 协同与演进治理

### 4.1 系统级与应用级协同

1. **应用级**：在代码仓库维护 `/docs`；基于代码生成 OpenAPI/AsyncAPI；生成 `manifest.yaml`（当前版本暴露的 API、事件、数据库变更）。
2. **系统级**：CI/CD 在应用构建成功后抓取 `manifest.yaml`，更新 `knowledge/technical/{system}/{app}.yaml` 的元数据快照，并触发一致性检查（如 API 变更是否破坏关联 Feature 契约）。

### 4.2 架构决策记录 (ADR)

- 所有跨域、跨系统或影响深远的架构变更，在 **knowledge/constitution/adr/** 下提交 ADR。
- 格式：`ADR-{序号}-{标题}.md`。
- 内容：背景、决策、后果（正向/负向）、状态（提议/通过/废弃）。

### 4.3 ID 命名规范

所有实体使用全局唯一 ID，推荐格式 `{TYPE}-{NAME}`：


| 前缀   | 含义       |
| ---- | -------- |
| BD-  | 业务域      |
| BSD- | 业务子域     |
| BC-  | 限界上下文    |
| AGG- | 聚合根      |
| PL-  | 产品线      |
| PM-  | 产品模块     |
| FT-  | 功能点      |
| UC-  | 用例       |
| SYS- | 系统       |
| APP- | 应用       |
| MS-  | 微服务      |
| DS-  | 数据存储     |
| ENT- | 数据实体（表级） |


---

## 5. 演进路线

1. **阶段一（当前）：静态治理** — 建立目录与核心实体 ID 化、YAML 化；人工维护核心映射。
2. **阶段二：自动化集成** — 接入 CI/CD 同步应用级元数据；CLI 校验 ID 引用有效性。
3. **阶段三：知识图谱化** — YAML 导入图数据库（如 Neo4j）；支持变更影响分析、可视化查询。

