# 系统知识文档库 — 设计方案摘录

本文件是《全局软件系统知识文档库设计方案》的**精简版**：治理依据与演进参考。细节与入口仍以 [README.md](README.md)、[SYSTEM_INDEX.md](SYSTEM_INDEX.md) 为准。

---

## 阅读顺序

1. [README.md](README.md) — `application/` 定位与 SDD 主线
2. 本文 — 原则、元模型、映射、演进
3. [knowledge/constitution/standards/NAMING-CONVENTIONS.md](knowledge/constitution/standards/NAMING-CONVENTIONS.md) — ID 规则
4. 各视角 [knowledge/README.md](knowledge/README.md) — 落盘与字段

---

## 1. 原则与约定

| 原则       | 说明                                                                  |
| -------- | ------------------------------------------------------------------- |
| **SSOT** | 实体只在一处定义；他处仅 **ID 引用**                                              |
| **联邦治理** | 系统库管边界与索引；应用库管实现细节并 **上行对齐**                                        |
| **闭环**   | knowledge ← 归档回写；阶段上 solutions → analysis → requirements；规约落在需求包内 specs/ 或 technical |
| **四视角**  | 业务 / 产品 / 技术 / 数据；关联写在各视角 YAML，**不**维护独立映射矩阵文件  |

**目录索引 YAML（约定）**：

- ***系统知识库根目录**：使用[system_meta.yaml](system_meta.yaml) 概括 `application/` 树与子目录 meta 指针
  - `knowledge/knowledge_meta.yaml` 描述知识树；
  - `knowledge/constitution/constitution_meta.yaml` 描述宪法层组件与产出；
  - `solutions/`、`analysis/`、`requirements/`、`changelogs/` 各阶段目录根使用与目录同名的 `{dirname}_meta.yaml`（如 `solutions_meta.yaml`）。
- **应用知识库根目录**：使用 [../applications/app-APPNAME/application_meta.yaml](../applications/app-APPNAME/application_meta.yaml)（及同目录 [APPNAME_manifest.yaml](../applications/app-APPNAME/APPNAME_manifest.yaml)）概括 `knowledge/`、`requirements/`、`changelogs/` 与中央库指针对照（模板路径以本仓为准；落地时可拷贝更名）。
- 细则见 [knowledge/constitution/standards/NAMING-CONVENTIONS.md](knowledge/constitution/standards/NAMING-CONVENTIONS.md)。

**协同（目标态）**：应用仓维护 `/docs` 与 `manifest.yaml`；系统侧可抓取 manifest 更新 `knowledge` 并做一致性检查。

---

## 2. `application/` 目录与元模型

> 规范与 Agent 配置在仓库根目录 `.agent/` 等，**不在** `application/` 内。

### 2.1 `application/` 内目录

| 目录                | 说明                          |
| ----------------- | --------------------------- |
| **knowledge/**    | 宪法层 + 业务 / 产品 / 技术 / 数据     |
| **solutions/**    | `SOLUTION-{IDEA-ID}.md`          |
| **analysis/**     | `ANALYSIS-{IDEA-ID}.md`          |
| **requirements/** | `REQUIREMENT-{IDEA-ID}/` 按阶段交付（规约可在各包内 `specs/`）   |
| **changelogs/**   | 变更记录与索引运维（可选）               |

### 2.2 系统知识库

#### 宪法层 (constitution)

使命：术语、原则、标准、ADR。ID 与命名见 `standards/NAMING-CONVENTIONS.md`。目录总索引见 `constitution_meta.yaml`；`principles/`、`standards/`、`adr/` 各有轻量子树 meta（表见该层 README），ADR 模板与字段约定以 `adr/adr_meta.yaml` 为准。

#### 业务 (business)

- **层级**：BD → BSD → BC → AGG → AB  
- **约定**：`business_meta.yaml` 在 `knowledge/business/` 根目录（单文件 SSOT：`identity`、`repository`、`pipeline`、`integration`、`layers[]`）；`{BD-ID}/…` 为锚点目录。AGG 含 `persisted_as_entity_ids` 等；AB 为能力（Ability）缩写，`implemented_by_api_id` 映射 API。

#### 产品 (product)

- **层级**：PL → PM → FT → UC  
- **约定**：`product_meta.yaml` 在根目录（单文件 SSOT：`identity`、`repository`、`pipeline`、`integration`、`layers[]`）；`{PL-ID}/{PM-ID}/` 为锚点。FT 含 `invokes_api_ids`、`realizes_use_case_ids` 等；UC 含 `map_to_api_id` 等。

#### 技术 (technical)

- **层级**：SYS → APP → MS → API  
- **约定**：`technical_meta.yaml` 在根目录（单文件 SSOT：`identity`、`repository`、`pipeline`、`integration`、`layers[]`）；`{SYS-ID}/{APP目录}/{APP-ID}.yaml` 登记 `repo_url`、`docs_manifest_path`、`service_ids` 等。

#### 数据 (data)

- **层级**：DS → ENT  
- **约定**：`data_meta.yaml` 在根目录（单文件 SSOT：`identity`、`repository`、`pipeline`、`integration`、`layers[]`）；`{DS-ID}/` 为存储锚点。ENT 含 `maps_to_aggregate_id`、敏感级别等。

### 2.3 阶段目录

| 阶段               | 约定                                                |
| ---------------- | ------------------------------------------------- |
| **solutions**    | `solutions_meta.yaml`（`layers`：SOLUTION）；根目录 `SOLUTION-{IDEA-ID}.md` |
| **analysis**     | `analysis_meta.yaml`（`layers`：ANALYSIS）；`ANALYSIS-{IDEA-ID}.md`；`parent` → Solution |
| **requirements** | `requirements_meta.yaml`（`layers`：交付包 → MVP 分阶段）；`REQUIREMENT-{IDEA-ID}/MVP-Phase-*/` 下 PRD / ADD / TDD；规约 YAML 等见同包 `specs/`（按 add-template） |
| **changelogs**   | `changelogs_meta.yaml`（`layers`：人类 CHANGELOG → 可选索引产物）；`CHANGELOG.md`；可选 `changes-index.*`、`indexing-log.jsonl`（Skill） |

---

## 3. 核心映射（分布式引用）

在源实体 YAML 中写**目标实体 ID**。

| 方向   | 源        | 目标       | 字段                                 | 含义            |
| ---- | -------- | -------- | ---------------------------------- | ------------- |
| 实现 | BC       | APP      | `implemented_by_app_id`            | 上下文由哪个APP实现       |
| 实现 | AGG     | MS       | `implemented_by_service_ids`            | 聚合根被哪些 MS 实现 |
| 实现 | AB     | API       | `implemented_by_api_id`            | 能力被哪个API实现 |
| 需求支撑 | PM       | BC       | `relies_on_context_ids`            | 模块依赖哪些上下文（组件） |
| 接口   | FT       | API      | `invokes_api_ids`                  | 功能调用的 API     |
| 接口   | UC       | API      | `map_to_api_id`                  | 用例映射的 API |
| 持久化  | AGG      | ENT      | `persisted_as_entity_ids`          | 模型落哪些表        |
| 归属   | ENT / DS | MS / APP | `owned_by_service_id` / `app_id` 等 | 写入与归属         |

---

## 4. ADR 与 ID 前缀

- **ADR**：`knowledge/constitution/adr/ADR-{序号}-{标题}.md`；结构见 `adr/adr-template.md`  
- **前缀（摘录）**：BD、BSD、BC、AGG、AB、PL、PM、FT、UC、SYS、APP、MS、API、DS、ENT — 全文见 NAMING-CONVENTIONS.md

---
