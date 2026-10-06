# 知识库布局契约（Agent SSOT）

> **定位**：四层 `{DOC_DIR}` **路径**、文件/目录落点、overview 缓冲区、联邦流水线与 SDD×`KNOWLEDGE_TYPE` 的唯一 Agent 侧真源。  
> **不分管**：文件四类分型、per-entity Profile、frontmatter/正文结构 → [okf-spec.md](../knowledge/okf-spec.md)；ID **语法** / IDEA-ID 字面 → [naming-conventions.md](../knowledge/naming-conventions.md)；缩写/短义/映射字段 → [glossary.md](../knowledge/glossary.md)；首次定义 / 引用边界 → [knowledge-governance.md](../knowledge/knowledge-governance.md)。  
> 会话工作稿见 [session-spec-path.md](session-spec-path.md)；闸门总表见 [CONVENTIONS.md](../rules/CONVENTIONS.md#artifact-gates)；推进环见 [unit-cycle-protocol.md](unit-cycle-protocol.md)。写前 hook 已空；技能清单见 [skills/README.md](../skills/README.md)。

**最后更新**: 2026-10-05

> **阶段目录**：公司只 `domains/`（BD/BSD(L1) 如何支撑 VC，不放 SLN，不建 `solutions/`）。解决方案只 `solutions/`（SA 第五至八章在此，第一至四章进 `knowledge/`）。系统与应用同构：`analysis/` → `features/` → `requirements/`，不建 `solutions/`。联邦三跳：公司 `solution-slots/` → 解决方案 `system-slots/` → 系统 `application-slots/`。

---

## 四层文档根

| 文档根 `{DOC_DIR}` | 人类入口 | 五视角知识 | overview 缓冲区 | 联邦镜像槽位 |
| --- | --- | --- | --- | --- |
| `application/` | [README](../../application/README.md) · [DESIGN](../../application/DESIGN.md) | [application/knowledge/](../../application/knowledge/README.md) | [application/knowledge/overview/](../../application/knowledge/overview/NAME-overview.md) | — |
| `system/` | [README](../../system/README.md) · [DESIGN](../../system/DESIGN.md) | [system/knowledge/](../../system/knowledge/README.md) | [system/knowledge/overview/](../../system/knowledge/overview/NAME-overview.md) | `system/application-slots/application-{NAME}/` |
| `solution/` | [README](../../solution/README.md) · [DESIGN](../../solution/DESIGN.md) | `solution/knowledge/`（五视角同构） | `solution/knowledge/overview/{NAME}-overview.md` | `solution/system-slots/system-{NAME}/` |
| `company/` | [README](../../company/README.md) · [DESIGN](../../company/DESIGN.md) | [company/knowledge/](../../company/knowledge/README.md) | `company/knowledge/overview/{NAME}-overview.md` | `company/solution-slots/solution-{NAME}/` |

**路径约定**：四层五视角均为 **`{DOC_DIR}/knowledge/`**。四层均有 `{NAME}-overview.md`。应用 overview **非** distill 目标。本层首次实体见 [knowledge-governance.md](../knowledge/knowledge-governance.md#各层聚焦摘要)。

**parent**：`application → system → solution → company`（向上 1:1）。公司不挂 `system-slots`。

---

## 文件与目录落点

- **目录**：与实体 ID 一致，或以 ID 为准在索引中查找。
- **实体定义文件**：应用注册等可为 `{id}.yaml`；字段模板见各视角 `{perspective}-meta.md` §4；实体正文默认 OKF per-entity `{ID}.md`（见 [okf-spec.md](../knowledge/okf-spec.md)）。
- **元数据 / 索引**：
  - **`{DOC_DIR}` 根**：`docs-meta.md`
  - **`{DOC_DIR}/knowledge/` 根**：`knowledge-meta.md`
  - **Agent 治理 SSOT**：`agent/knowledge/`（见该目录 [README.md](../knowledge/README.md)）
  - **阶段目录**：约定在各目录 `README.md`
  - **五视角**：`{perspective}-meta.md` + per-entity `{ID}.md`；`knowledge/index.md` 目录导航（docs-okf）；实体台账 ∈ 各视角 README；视角导航 ∈ `{DOC_DIR}/INDEX-GUIDE.md` 第四章（docs-build）
- **解决方案层五视角**（`solution/knowledge/{perspective}/`）：
  | 视角 | 落点要点 |
  | --- | --- |
  | business | BSD(L2) 本层 SSOT（`parent`→公司 L1）；BS 本层 SSOT（无 parent，`maps_to`→BSD(L2)） |
  | product | PL、PD、BP、BSP 本层 SSOT |
  | application | SLN 本层 SSOT；不落 SYS 正文 |
  | data | MDG 本层 SSOT |
  | technical | TSD 本层 SSOT（`implements_to`→公司 TPL） |
- **系统层五视角**（`system/knowledge/{perspective}/`）：
  | 视角 | 落点要点 |
  | --- | --- |
  | business | BC/AGG/AB 本层 SSOT；BD/L1/L2 = 上层 reference |
  | product | PM→FT→FR→UC/BR 本层 SSOT；不落 PL/PD/BP 正文 |
  | application | SYS 本层 SSOT（`maps_to`→PD，`implements_to`→SLN）；APP/MS |
  | data | DS/ENT 本层 SSOT；MDG = 解决方案 reference |
  | technical | MW 可为 application reference；TSD = 解决方案 reference |
- **公司层五视角**（`company/knowledge/{perspective}/`）：VC、BD、BL、BSD(L1)、CAP、TPL；产品视角无实体（概述、度量、体验）；**无** SLN/PD/PL/SYS/BSD(L2)/MDG/TSD
- **应用层**：API/TBL/MW/CMP 本层 SSOT；其余为 reference 或纯 ID
- **阶段目录（目标态）**：
  | 库 | 目录 |
  | --- | --- |
  | 公司 | `domains/`（`/sdx-domains`：总图 + `DOMAIN-{BD-ID}.md`；只写 BD/BSD(L1) 如何支撑 VC，不放 SLN）；`adr/`；**无** solutions/analysis/features/requirements |
  | 解决方案 | `solutions/`（仅 `/sdx-solution`）；`adr/`；**无** analysis/features/requirements |
  | 系统、应用 | `analysis/`（原 solutions）→ `features/`（原 analysis）→ `requirements/REQUIREMENT-{IDEA-ID}/`；`adr/` |
  | 迁徙样例 | 系统/应用 `analysis/ANALYSIS-EXAMPLE.md`、`features/FEATURE-EXAMPLE.md`（目录改名后文件已对齐） |
- **IDEA-ID 字面格式**：见 [naming-conventions.md § IDEA-ID](../knowledge/naming-conventions.md#2-idea-id)
- **ADR 落盘**：`application|system|solution|company/adr/`；命名/落盘见 [adr-template.md](../knowledge/adr-template.md)；章节/状态见 [adr-guidelines.md](../knowledge/adr-guidelines.md)；SDX 运行时见 [sdx-adr-protocol.md](sdx-adr-protocol.md)

---

## overview

| 库 | 路径模式 | 第三列写入技能 |
| --- | --- | --- |
| 应用库 | `application/knowledge/overview/{NAME}-overview.md` | **docs-extract**、**docs-archive**、**docs-tag** |
| 系统库 | `system/knowledge/overview/{NAME}-overview.md` | **docs-distill**（application 槽位）、**docs-extract**、**docs-archive**、**docs-tag** |
| 解决方案库 | `solution/knowledge/overview/{NAME}-overview.md` | **docs-distill**（system 槽位）、**docs-extract**、**docs-archive**、**docs-tag** |
| 公司库 | `company/knowledge/overview/{NAME}-overview.md` | **docs-distill**（solution 槽位）、**docs-extract**、**docs-archive**、**docs-tag** |

**表行真源**：同层 `overview/` 五视角表 ↔ 同层五视角 **README 表行**。

**第三列规则**：[federation-spec.md](../skills/docs-distill/references/federation-spec.md)「规则（第三列）」。

公司第三列只收 SLN 级共性，不收单 SYS 实现细节。应用第三列只收本应用实现要点，不替代实体 `{ID}.md`。

系统库主标题行序（自上而下逐节，勿跳行）；**应用库同行序**（实现侧落盘，归档入本层 `chapters/`）：

- 业务：概述 → 域划分 → 术语 → 流程 → 能力地图 → 业务规则与策略
- 产品：概述 → 产品架构 → 信息架构 → 产品功能 → 用户旅程与场景 → 版本管理与发布 → 产品运营支撑 → 多端策略
- 应用：系统概述 → 应用架构 → 领域模型 → 服务设计 → 领域能力 → 集成架构 → 服务间交互 → 接口管理 → 多租户多环境 → ADR
- 技术：技术概述 → 基础设施 → 中间件 → **性能扩展 → 高可用** → 可观测性
- 数据：数据概述 → 数据模型 → 数据存储 → 数据分析 → 数据流转

解决方案 overview 行序对齐 SA 第一至四章落 knowledge 的视角：业务范围、应用与集成、数据主权、技术选型。公司库行序见 `company/knowledge/overview/` 与同层 README。

---

## 知识流水线

```text
应用库（本地 path，HEAD） ──docs-link──► system/knowledge-links.yaml（建联 + 建槽位）
系统库（本地 path，HEAD） ──docs-link──► solution/knowledge-links.yaml
解决方案库（本地 path，HEAD） ──docs-link──► company/knowledge-links.yaml
         │
         ▼ docs-pull
system/application-slots/application-{NAME}/
solution/system-slots/system-{NAME}/
company/solution-slots/solution-{NAME}/
（槽位不可被 knowledge 引用）
         │
         ▼ docs-distill（槽位上行全量；不写 DISTILL-LOG；**不含** application overview）
system/knowledge/overview/{NAME}-overview.md
solution/knowledge/overview/{NAME}-overview.md
company/knowledge/overview/{NAME}-overview.md
         │ docs-extract（非槽位任意源 → 四层 `{NAME}-overview.md`，含 `application/knowledge/overview/`）
         │ docs-tag（关键词 ✅、架构摘录）
         ▼ docs-archive
各层 knowledge/{business,product,application,data,technical}/
```

允许边：`company→solution`、`solution→system`、`system→application`。禁止公司直连系统。

---

## SDD 与 KNOWLEDGE_TYPE

| 模式 | 方案/分析落盘 | 架构输入 | PRD/ASD/DSD |
| --- | --- | --- | --- |
| `application` | `{DOC_DIR}/analysis/`、`features/` | 应用上下文 | `{DOC_DIR}/requirements/**/` |
| `system` | `system/analysis/`、`system/features/` | [system/knowledge/](../../system/knowledge/README.md) | 联邦 ASD 概要；详设 → 应用库 `/sdx-design` |
| `solution` | `solution/solutions/` 仅此 | [solution knowledge](../../solution/DESIGN.md) | 本层不落 PRD/DSD；拆到各 SYS 的 `system/requirements/` |
| `company` | `company/domains/`（`/sdx-domains`） | [company/knowledge/](../../company/knowledge/README.md) | 域架构拆到哪个 SLN；不直拆系统 PRD |

`/sdx-solution` 仅 `KNOWLEDGE_TYPE=solution`。`/sdx-prd` `/sdx-architect` `/sdx-design` `/sdx-test` 仍写系统/应用 `requirements/`。

详见 [sdx-architect/references/knowledge-type-modes.md](../skills/sdx-architect/references/knowledge-type-modes.md)。
