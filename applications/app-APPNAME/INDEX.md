# 应用知识库根目录 — 应用级索引

本页描述 **应用知识库根目录**（模板物理路径 `applications/app-APPNAME/`）内的入口、与中央库 **system/** 的分工及映射速查。全仓库七段 Index Guide 见仓库根目录 [../../INDEX.md](../../INDEX.md)；applications 聚合见 [../INDEX.md](../INDEX.md)。

---

## 零、与中央库的文档流（一页纸）

根级机器可读索引：[application_meta.yaml](./application_meta.yaml)（字段以 YAML 为准）。

```text
system/knowledge（中央 SSOT）
    ↑ 归档 / 回写（如 knowledge-archive）
    │
应用知识库根目录/knowledge（联邦补充）
    │
应用知识库根目录/requirements（交付包）
    │
应用知识库根目录/changelogs（应用侧变更记录）
```

**中央库 SDD 主线**（本应用目录通常**不**自带这三段，用 ID 追溯即可）：

```text
system: solutions ──→ analysis ──→ requirements（规约见 specs/，可选）
```

**推荐顺序**

1. 对齐 **ID** 与命名：[../../system/knowledge/constitution/standards/naming-conventions.md](../../system/knowledge/constitution/standards/naming-conventions.md)  
2. 维护 **[knowledge/](./knowledge/)** 本应用事实与映射  
3. 在 **[requirements/](./requirements/)** 建 `REQUIREMENT-{ID}/`，与上游 `system/analysis`、`system/solutions` 或兄弟仓文档对齐  
4. 规约与跨域接口优先引用 **[system/specs/](../../system/specs/)**，避免重复定义  
5. 里程碑记入 **[changelogs/](./changelogs/)**

---

## 一、知识库 (knowledge)

与 `system/knowledge` **同构**：宪法层 + 业务 / 产品 / 技术 / 数据。元数据与治理以中央库为准，见 [knowledge/knowledge_meta.yaml](./knowledge/knowledge_meta.yaml)。

### 1.1 宪法与治理层 (constitution)

| 入口 | 说明 |
|------|------|
| [knowledge/constitution/README.md](./knowledge/constitution/README.md) | 宪法层使命与核心组件 |
| [knowledge/constitution/constitution_meta.yaml](./knowledge/constitution/constitution_meta.yaml) | 本层目录元数据 |
| [knowledge/constitution/GLOSSARY.md](./knowledge/constitution/GLOSSARY.md) | 术语表 |
| [knowledge/constitution/principles/](./knowledge/constitution/principles/) | 架构原则 · [principles_meta.yaml](./knowledge/constitution/principles/principles_meta.yaml) |
| [knowledge/constitution/standards/](./knowledge/constitution/standards/) | 命名规范、ADR 模板 · [standards_meta.yaml](./knowledge/constitution/standards/standards_meta.yaml) · [adr_meta.yaml](./knowledge/constitution/standards/adr_meta.yaml) |
| [knowledge/constitution/adr/](./knowledge/constitution/adr/) | ADR 文集 · [adr_corpus_meta.yaml](./knowledge/constitution/adr/adr_corpus_meta.yaml) |

### 1.2～1.5 四视角

| 视角 | README | 元数据 | 说明 |
|------|--------|--------|------|
| 业务 | [knowledge/business/README.md](./knowledge/business/README.md) | [business_meta.yaml](./knowledge/business/business_meta.yaml) | BD → BSD → BC → AGG |
| 产品 | [knowledge/product/README.md](./knowledge/product/README.md) | [product_meta.yaml](./knowledge/product/product_meta.yaml) | PL → PM → FT → UC |
| 技术 | [knowledge/technical/README.md](./knowledge/technical/README.md) | [technical_meta.yaml](./knowledge/technical/technical_meta.yaml) | SYS → APP → MS |
| 数据 | [knowledge/data/README.md](./knowledge/data/README.md) | [data_meta.yaml](./knowledge/data/data_meta.yaml) | DS → ENT |

**映射字段速查**（与 system 一致）：`implemented_by_app_id`、`relies_on_context_ids`、`invokes_api_ids`、`persisted_as_entity_ids`、`maps_to_aggregate_id` 等；详见各视角 README 与 [system/DESIGN.md](../../system/DESIGN.md)。

### 1.6 贡献与规范

- [../../system/CONTRIBUTING.md](../../system/CONTRIBUTING.md) — 修改知识条目与 ADR 的通用规则  
- [../../system/DESIGN.md](../../system/DESIGN.md) — 元模型与联邦治理  

---

## 二、需求交付 (requirements)

| 入口 | 说明 |
|------|------|
| [requirements/README.md](./requirements/README.md) | 交付包结构与工作流 |
| [requirements/requirements_meta.yaml](./requirements/requirements_meta.yaml) | 目录元数据 |
| [requirements/REQUIREMENT-EXAMPLE/](./requirements/REQUIREMENT-EXAMPLE/) | 结构示例 |
| 模板 | [../../.ai/rules/requirement/](../../.ai/rules/requirement/) |
| 中央对照 | [../../system/requirements/README.md](../../system/requirements/README.md) |

---

## 三、变更日志 (changelogs)

| 入口 | 说明 |
|------|------|
| [changelogs/README.md](./changelogs/README.md) | 可选索引运维与 Skill 指针 |
| [changelogs/changelogs_meta.yaml](./changelogs/changelogs_meta.yaml) | 目录元数据 |
| [changelogs/CHANGELOG.md](./changelogs/CHANGELOG.md) | 应用侧变更记录 |
| 中央对照 | [../../system/changelogs/](../../system/changelogs/) |

---

## 四、中央库阶段与规约（引用）

以下目录在 **system/**，本应用不强制镜像：

| 阶段 / 目录 | 入口 |
|-------------|------|
| 解决方案 | [../../system/solutions/README.md](../../system/solutions/README.md) |
| 需求分析 | [../../system/analysis/README.md](../../system/analysis/README.md) |
| 中央需求交付树 | [../../system/requirements/README.md](../../system/requirements/README.md) |
| 规约 specs | [../../system/specs/README.md](../../system/specs/README.md) |
| 中央索引 | [../../system/INDEX.md](../../system/INDEX.md) |

---

## 五、全库构建与索引（AI 工作流）

面向在**仓库根**执行 knowledge-build / document-indexing 时的对齐（Doc Root 语义见根 [README.md](../../README.md)）。

| 说明 | 路径 |
|------|------|
| 四阶段构建 | [../../.cursor/skills/knowledge-build/SKILL.md](../../.cursor/skills/knowledge-build/SKILL.md) |
| 应用级增量 | [../../.cursor/skills/knowledge-upgrade/SKILL.md](../../.cursor/skills/knowledge-upgrade/SKILL.md) |
| 归档上行 | [../../.cursor/skills/knowledge-archive/SKILL.md](../../.cursor/skills/knowledge-archive/SKILL.md) |
| 根入口 | [../../README.md](../../README.md)、[../../AGENTS.md](../../AGENTS.md) |
