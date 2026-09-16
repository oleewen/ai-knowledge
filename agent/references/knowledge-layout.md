# 知识库布局契约（Agent SSOT）

> **定位**：三层 `{DOC_DIR}` **路径**、文件/目录落点、overview 缓冲区、联邦流水线与 SDD×`KNOWLEDGE_TYPE` 的唯一 Agent 侧真源。  
> **不分管**：文件四类分型、per-entity Profile、frontmatter/正文结构 → [okf-spec.md](../knowledge/okf-spec.md)；ID **语法** / IDEA-ID 字面 → [naming-conventions.md](../knowledge/naming-conventions.md)；缩写/短义/映射字段 → [glossary.md](../knowledge/glossary.md)；首次定义 / 引用边界 → [knowledge-governance.md](../knowledge/knowledge-governance.md)。  
> 会话工作稿见 [session-spec-path.md](session-spec-path.md)；闸门总表见 [CONVENTIONS.md](../rules/CONVENTIONS.md#artifact-gates)；推进环见 [unit-cycle-protocol.md](unit-cycle-protocol.md)。写前 hook 已空；技能清单见 [skills/README.md](../skills/README.md)。

**最后更新**: 2026-09-15

---

## 三层文档根

| 文档根 `{DOC_DIR}` | 人类入口 | 五视角知识 | overview 缓冲区 | 联邦镜像槽位 |
| --- | --- | --- | --- | --- |
| `application/` | [README](../../application/README.md) · [DESIGN](../../application/DESIGN.md) | [application/knowledge/](../../application/knowledge/README.md) | — | — |
| `system/` | [README](../../system/README.md) · [DESIGN](../../system/DESIGN.md) | [system/knowledge/](../../system/knowledge/README.md) | [system/knowledge/overview/](../../system/knowledge/overview/NAME-overview.md) | `system/application-slots/application-{NAME}/` |
| `company/` | [README](../../company/README.md) · [DESIGN](../../company/DESIGN.md) | [company/knowledge/](../../company/knowledge/README.md) | [company/knowledge/overview/](../../company/knowledge/overview/NAME-overview.md) | `company/system-slots/system-{NAME}/` |

**路径约定**：三层五视角均为 **`{DOC_DIR}/knowledge/`**（legacy `architecture/` / `ea/` 已废弃）。应用层无 overview；本层首次实体（API/TBL/MW/CMP）见 [knowledge-governance.md](../knowledge/knowledge-governance.md#各层聚焦摘要)。

---

## 文件与目录落点

- **目录**：与实体 ID 一致（如 `BD-CHARGING-APPEAL`、`PL-BILLING-APPEAL`），或以 ID 为准在索引中查找。
- **实体定义文件**：应用注册等可为 `{id}.yaml`；字段模板见各视角 `{perspective}-meta.md` §4；逐实体增量可用 `{ENT-ID}_ENT_meta.yaml`；业务字段模板收敛于 **`business-meta.md`** §4。实体正文默认 OKF per-entity `{ID}.md`（见 [okf-spec.md](../knowledge/okf-spec.md)）。
- **元数据 / 索引**：
  - **`{DOC_DIR}` 根**：`docs-meta.md`（阶段子目录与 `knowledge/` 指针；层设计见 [knowledge-governance.md](../knowledge/knowledge-governance.md)）
  - **`{DOC_DIR}/knowledge/` 根**：`knowledge-meta.md`
  - **Agent 治理 SSOT**：`agent/knowledge/`（见该目录 [README.md](../knowledge/README.md)）
  - **阶段目录**（solutions / analysis / requirements / changelogs）：约定在各目录 `README.md`（无 `{dirname}_meta.yaml`）
  - **五视角**：`{perspective}-meta.md` + per-entity `{ID}.md`；`knowledge/index.md` 目录导航（docs-okf）；实体表 ∈ `{DOC_DIR}/INDEX-GUIDE.md` 第五章（docs-build）。legacy `*-entities.md` 已废弃
  - **联邦应用根**（`applications/{app}/`）：`application_meta.yaml`；子目录同模式；规则引用系统库 `agent/knowledge/`
- **系统库五视角**（`system/knowledge/{perspective}/`；应用层同构）：
  | 视角 | 落点要点 |
  | --- | --- |
  | business | `business-meta.md`；`BD-*.md` = company reference；`BSD-*/` 起为系统 SSOT |
  | product | `product-meta.md`；不落 PL/SLN；`PD-*/` 本层 SSOT（`parent_id→公司 PL`，`maps_to_sys_id`）；下挂 `PM-*/`→FT→FR→UC/BR |
  | application | `application-meta.md`；`SYS-*.md` 本层 SSOT（`parent_id→公司 SLN`）；`APP-*/APP-*.md`；`APP-*/MS-*/MS-*.md` |
  | data | `data-meta.md`；`MDG-*.md` 本层 SSOT；`DS-*/` 含 DS/ENT；SYS 经 `uses_mdg_ids` |
  | technical | `technical-meta.md`；`TSD-*.md` 系统 SSOT；`MW-*/` 可为 application MW reference；AA `uses_*` |
- **公司层五视角**（`company/knowledge/{perspective}/`）：叙事 + `{perspective}-meta.md` + 公司级实体（`BU-*`/BD/CAP、`PL-*.md`、**`application/SLN-*.md`**、TPL）；**无 PD/SYS/MDG**
- **系统阶段目录**：
  | 目录 | 约定 |
  | --- | --- |
  | `system/requirements/` | `REQUIREMENT-{IDEA-ID}/` 交付包（与 `ANALYSIS-{IDEA-ID}.md` 同 IDEA-ID） |
  | `system/solutions/` | 平铺 `SOLUTION-{IDEA-ID}.md`；`archive/` 归档 |
  | `system/analysis/` | 平铺 `ANALYSIS-{IDEA-ID}.md` |
  | `system/changelogs/` | `INDEXING-LOG.md`；变更溯源 `git log` / `git diff` |
- **IDEA-ID 字面格式**：见 [naming-conventions.md § IDEA-ID](../knowledge/naming-conventions.md#2-idea-id)
- **ADR 落盘**：`application|system|company/adr/`；命名/落盘见 [adr-template.md](../knowledge/adr-template.md)；章节/状态见 [adr-guidelines.md](../knowledge/adr-guidelines.md)；SDX 运行时见 [sdx-adr-protocol.md](sdx-adr-protocol.md)

典型 concept 路径模式见 [okf-spec.md](../knowledge/okf-spec.md) 与各层 `knowledge/` 样例树。

---

## overview

| 库 | 路径模式 | 新建模板 | 第三列写入技能 |
| --- | --- | --- | --- |
| 系统库 | `system/knowledge/overview/{APPNAME}-overview.md` | 拷 `NAME-overview.md`，替换 `NAME`/`APPNAME` | **docs-distill**（application 槽位上行）、**docs-extract**、**docs-tag** |
| 公司库 | `company/knowledge/overview/{NAME}-overview.md` | 拷 `NAME-overview.md`，替换 `NAME` | **docs-distill**（system 槽位上行）、**docs-extract**、**docs-archive**、**docs-tag** |

**表行真源**：同层 `overview/NAME-overview.md` 五视角表 ↔ 同层五视角 **README 表行**；副标题锚点与各章 `##` 标题对齐。

**第三列规则**（去重、delta、A/U/D）：[federation-spec.md](../skills/docs-distill/references/federation-spec.md)「规则（第三列）」。

**系统库主标题行序**（自上而下逐节，勿跳行）：

- 业务：概述 → 域划分 → 术语 → 流程 → 能力地图 → 业务规则与策略
- 产品：概述 → 产品架构 → 信息架构 → 产品功能 → 用户旅程与场景 → 版本管理与发布 → 产品运营支撑 → 多端策略
- 应用：系统概述 → 应用架构 → 领域模型 → 服务设计 → 领域能力 → 集成架构 → 服务间交互 → 接口管理 → 多租户多环境 → ADR
- 技术：技术概述 → 基础设施 → 中间件 → **性能扩展 → 高可用** → 可观测性
- 数据：数据概述 → 数据模型 → 数据存储 → 数据分析 → 数据流转

公司库行序见 `company/knowledge/overview/NAME-overview.md` 与同层 README。

---

## 知识流水线

```text
应用库（本地 path，HEAD） ──docs-link──► system/knowledge-links.yaml（建联 + 建槽位）
                              └──► 应用库 knowledge-parent.yaml（1:1 上级 identity）
应用库（本地 path，HEAD） ──docs-pull──► system/application-slots/application-{NAME}/（联邦槽位，不可被 knowledge 引用）
系统库（本地 path，HEAD） ──docs-link──► company/knowledge-links.yaml（建联 + 建槽位）
                              └──► 系统库 knowledge-parent.yaml
系统库（本地 path，HEAD） ──docs-pull──► company/system-slots/system-{NAME}/（联邦槽位，不可被 knowledge 引用）
         │
         ▼ docs-distill（槽位上行全量；不写 DISTILL-LOG）
system/knowledge/overview/{APPNAME}-overview.md
company/knowledge/overview/{NAME}-overview.md
         │ docs-extract（非槽位任意源 → 系统/公司 overview）
         │ docs-tag（关键词 ✅、架构摘录）
         ▼ docs-archive
system/knowledge/{business,product,application,data,technical}/
company/knowledge/{business,product,application,data,technical}/
```

---

## SDD 与 KNOWLEDGE_TYPE

| 模式 | 方案/分析落盘 | 架构输入 | PRD/ASD/DSD |
| --- | --- | --- | --- |
| `application`（默认） | `{DOC_DIR}/solutions/`、`analysis/` | 应用上下文 | `{DOC_DIR}/requirements/**/` |
| `system` | `system/solutions/`、`system/analysis/` | [system/knowledge/](../../system/knowledge/README.md) | 联邦 ASD 概要；详设 → 应用库 `/sdx-design` |
| `company` | `company/solutions/`、`company/analysis/` | [company/knowledge/](../../company/knowledge/README.md) | 公司 ANALYSIS 拆解系统归属；各系统 PRD/ASD/DSD 在对应 **`system/requirements/`** |

详见 [sdx-architect/references/knowledge-type-modes.md](../skills/sdx-architect/references/knowledge-type-modes.md)。
