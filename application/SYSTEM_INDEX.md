# 全局软件系统知识文档库 — 索引

本页描述 **`application/` 树内**的入口、阶段关系与映射速查。全仓库七段 Index Guide、环境变量与未索引声明见仓库根目录 [INDEX_GUIDE.md](../INDEX_GUIDE.md)。

---

## 零、SDD 文档流（一页纸）

```text
knowledge（SSOT）
    ↑ 归档 / 回写（如 docs-archive）
    │
solutions ──→ analysis ──→ requirements
    │              │              │
    └──────────────┴──────────────┴──→ 规约：需求包内 specs/ 或 knowledge/technical/（可选）
```

**推荐落地顺序**

1. 查 / 补 **knowledge** 实体与 ID（先读 [DESIGN.md](DESIGN.md)、[CONTRIBUTING.md](CONTRIBUTING.md)）
2. 写 **solutions** / `SOLUTION-{IDEA-ID}.md`
3. 写 **analysis** / `ANALYSIS-{IDEA-ID}.md`，`parent` 指向对应 Solution
4. 建 **requirements** / `REQUIREMENT-{IDEA-ID}/`，按阶段放 PRD / ADD / TDD
5. 接口/数据等规约放在各 **requirements/REQUIREMENT-{IDEA-ID}/…/specs/** 或 **knowledge/technical/**，各阶段用与 `ANALYSIS-*` 对齐的 **IDEA-ID** 引用，避免重复定义

---

## 一、业务知识 (knowledge)

知识库主体，包含宪法层与四视角（业务、产品、技术、数据）。

### 1.1 宪法与治理层 (constitution)

| 入口 | 说明 |
|------|------|
| [knowledge/constitution/README.md](knowledge/constitution/README.md) | 宪法层使命与核心组件 |
| [knowledge/constitution/GLOSSARY.md](knowledge/constitution/GLOSSARY.md) | 全局术语表 |
| [knowledge/constitution/principles](knowledge/constitution/principles) | 架构原则 |
| [knowledge/constitution/standards](knowledge/constitution/standards) | 命名规范、ADR 模板等 |
| [knowledge/constitution/adr](knowledge/constitution/adr) | 架构决策记录 (ADR) |

### 1.2 业务视角 (business)

| 入口 | 说明 |
|------|------|
| [knowledge/business/README.md](knowledge/business/README.md) | 业务视角说明、层级与映射字段 |
| 层级 | 业务域 (BD) → 子域 (BSD) → 限界上下文 (BC) → 聚合 (AGG) |
| 示例（命名演示，非本仓必存路径） | `BD-ORDER` → `BC-ORDER-MGMT` → [knowledge/business/business_meta.yaml](knowledge/business/business_meta.yaml)（`layers` / `integration`） |

**关键映射字段**：限界上下文 → 技术 `implemented_by_app_id`；聚合 → 数据 `persisted_as_entity_ids`。

### 1.3 产品视角 (product)

| 入口 | 说明 |
|------|------|
| [knowledge/product/README.md](knowledge/product/README.md) | 产品视角说明、层级与映射字段 |
| 层级 | 产品线 (PL) → 模块 (PM) → 功能 (FT) → 用例 (UC) |
| 示例（命名演示） | `PL-ECOMMERCE` → `PM-SHOPPING-CART` → [knowledge/product/product_meta.yaml](knowledge/product/product_meta.yaml)（`layers`） |

**关键映射字段**：产品模块 → 业务 `relies_on_context_ids`；功能 → 技术 `invokes_api_ids`、`realizes_use_case_ids`。

### 1.4 技术视角 (technical)

| 入口 | 说明 |
|------|------|
| [knowledge/technical/README.md](knowledge/technical/README.md) | 技术视角说明、层级与映射字段 |
| 层级 | 系统 (SYS) → 应用 (APP) → 微服务 (MS) |
| 示例（命名演示） | `SYS-ECOMMERCE-BACKEND` → `APP-ORDER-SERVICE.yaml`（见各应用 `technical_knowledge.json` / 宿主 YAML 约定） |

**关键映射字段**：应用 `repo_url`、`docs_manifest_path`、`service_ids`；限界上下文的 `implemented_by_app_id` 指向本层 APP。

### 1.5 数据视角 (data)

| 入口 | 说明 |
|------|------|
| [knowledge/data/README.md](knowledge/data/README.md) | 数据视角说明、层级与映射字段 |
| 层级 | 数据存储 (DS) → 数据实体 (ENT) |
| 示例（命名演示） | `DS-ORDER-MYSQL-PRIMARY` → [knowledge/data/data_meta.yaml](knowledge/data/data_meta.yaml)（`layers`） |

**关键映射字段**：数据实体 `maps_to_aggregate_id`；数据存储在 `data_meta.yaml` → `layers`（`key: ds`）的 `fields` 中约定 `owned_by_app_id`（或 `app_id`）。

### 1.6 核心映射关系速查

| 关系方向 | 源 | 目标 | 关键字段/含义 |
|----------|-----|------|----------------|
| 落地实现 | 限界上下文 (BC) | 应用 (APP) | `implemented_by_app_id` |
| 需求支撑 | 产品模块 (PM) | 限界上下文 (BC) | `relies_on_context_ids` |
| 接口实现 | 功能 (FT) | API | `invokes_api_ids` |
| 数据持久化 | 聚合 (AGG) | 数据实体 (ENT) | `persisted_as_entity_ids` |
| 数据归属 | 数据实体 (ENT) | 微服务 (MS) | 通过 DS 的 `owned_by_app_id` / `app_id` 或 ENT 的 owned_by |

### 1.7 贡献与规范

- [CONTRIBUTING.md](CONTRIBUTING.md) — 如何新增/修改知识条目与 ADR  
- [DESIGN.md](DESIGN.md) — 设计方案与演进路线  

---

## 二、解决方案 (solutions)

业务诉求的解决方案文档，对应 AI SDD 解决方案阶段产出。

| 入口 | 说明 |
|------|------|
| [solutions/README.md](solutions/README.md) | 解决方案说明、命名与阶段规范 |
| 阶段规范 | [../.agent/skills/sdx-solution/SKILL.md](../.agent/skills/sdx-solution/SKILL.md) |
| 文档模板 | [../.agent/skills/sdx-solution/assets/solution-template.md](../.agent/skills/sdx-solution/assets/solution-template.md) |

- **输出**：`solutions/SOLUTION-{IDEA-ID}.md`。  
- **输入**：业务描述与知识库 (knowledge)。

---

## 三、需求分析 (analysis)

需求细化与 MVP 拆分文档，对应 AI SDD 需求分析阶段产出。

| 入口 | 说明 |
|------|------|
| [analysis/README.md](analysis/README.md) | 需求分析说明、命名与阶段规范 |
| 阶段规范 | [../.agent/skills/sdx-analysis/SKILL.md](../.agent/skills/sdx-analysis/SKILL.md) |
| 文档模板 | [../.agent/skills/sdx-analysis/assets/analysis-template.md](../.agent/skills/sdx-analysis/assets/analysis-template.md) |

- **输出**：`analysis/ANALYSIS-{IDEA-ID}.md`；文档内 `parent` 指向对应 SOLUTION。  
- **输入**：解决方案 (solutions) 与知识库 (knowledge)。


---

## 四、需求交付 (requirements)

MVP 阶段化需求交付文档，对应 AI SDD 的需求落地与分阶段交付产出。

| 入口 | 说明 |
|------|------|
| [requirements/README.md](requirements/README.md) | 需求交付阶段目标、结构说明 |
| 示例结构 | [requirements/REQUIREMENT-EXAMPLE](requirements/REQUIREMENT-EXAMPLE) |
| 阶段规范 | [../.agent/skills/sdx-prd/SKILL.md](../.agent/skills/sdx-prd/SKILL.md)、[../.agent/skills/sdx-design/SKILL.md](../.agent/skills/sdx-design/SKILL.md)、[../.agent/skills/sdx-test/SKILL.md](../.agent/skills/sdx-test/SKILL.md) |
| 文档模板 | PRD：[../.agent/skills/sdx-prd/assets/prd-template.md](../.agent/skills/sdx-prd/assets/prd-template.md)；ADD：[../.agent/skills/sdx-design/assets/add-template.md](../.agent/skills/sdx-design/assets/add-template.md)；TDD：[../.agent/skills/sdx-test/assets/tdd-template.md](../.agent/skills/sdx-test/assets/tdd-template.md) |

- **输出**：`requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-*/` 按阶段组织，含 `PRD-{IDEA-ID}.md`、`ADD-{IDEA-ID}.md`、`TDD-{IDEA-ID}.md` 等交付物（或阶段内固定名 `PRD.md` 等，见 [requirements/README.md](requirements/README.md)）。  
- **输入**：上游 analysis/ANALYSIS-{IDEA-ID}.md、solutions/SOLUTION-{IDEA-ID}.md 及模板/规范。

> 详见 [requirements/README.md](requirements/README.md) 获悉推荐目录结构和工作流。

---

## 五、中央知识库接入工程

本节用于在本仓库（中央知识库）登记各目标工程的接入信息，便于追溯与映射。

| APP ID | 工程路径（Git 或绝对路径） | 文档目录 |
|--------|---------------------------|----------|
| APP-TEST | /private/tmp/test-central | /private/tmp/test-central/docs |

---

## 六、全库构建与索引（AI 工作流）

面向在本仓库内 **组合完成全库知识落盘**（`docs-indexing` → `agent-guide` → `docs-build` 等；无单独编排 Skill）时的入口对齐（**Doc Root** 以根目录 [README.md](../README.md) 为准：系统级知识库体系统辖 **`application/`**）。

以下均为 **Skill**（`SKILL.md`），由 Agent 执行；**不是** `scripts/` 可执行脚本。

| 说明 | 路径 |
|------|------|
| 文档索引（产出根 `INDEX_GUIDE.md` + `changelogs/indexing-log.jsonl`） | [../.agent/skills/docs-indexing/SKILL.md](../.agent/skills/docs-indexing/SKILL.md) |
| 根入口契约（`AGENTS.md` / `README.md`） | [../.agent/skills/agent-guide/SKILL.md](../.agent/skills/agent-guide/SKILL.md) |
| 知识抽取与落盘（`application/knowledge`） | [../.agent/skills/docs-build/SKILL.md](../.agent/skills/docs-build/SKILL.md) |
| 变更索引（产出 `changes-index.*`；与 docs-indexing 增量配合） | [../.agent/skills/docs-change/SKILL.md](../.agent/skills/docs-change/SKILL.md) |
| 人类/Agent 根入口 | [README.md](../README.md)、[AGENTS.md](../AGENTS.md) |
| 本目录变更记录与索引运维说明 | [changelogs/README.md](changelogs/README.md)、[changelogs/CHANGELOG.md](changelogs/CHANGELOG.md) |
