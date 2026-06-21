# 知识库布局契约（Agent SSOT）

> **定位**：`system/`、`company/` 路径、overview 缓冲区与表行对齐的**唯一 Agent 侧真源**。  
> 会话 spec 路径见 [session-spec-path.md](session-spec-path.md)；闸门总表见 [CONVENTIONS.md](../rules/CONVENTIONS.md#artifact-gates)。

**最后更新**: 2026-06-15

---

## 三层文档根

| 文档根 `{DOC_DIR}` | 人类入口 | 架构五视角 | overview 缓冲区 | 联邦镜像槽位 |
| --- | --- | --- | --- | --- |
| `application/` | [application/README.md](../../application/README.md) | `{DOC_DIR}/architecture/`（应用库若有） | — | — |
| `system/` | [system/README.md](../../system/README.md) | [system/knowledge/](../../system/knowledge/README.md) | [system/knowledge/overview/](../../system/knowledge/overview/NAME-overview.md) | `system/application-{APPNAME}/` |
| `company/` | [company/README.md](../../company/README.md) | [company/knowledge/](../../company/knowledge/README.md) | [company/knowledge/overview/](../../company/knowledge/overview/NAME-overview.md) | `company/system-{SYSNAME}/` |

**公司侧企业架构**目录为 **`company/knowledge/`**（非 `company/architecture/`）。

---

## overview 缓冲区

| 库 | 路径模式 | 新建模板 | 第三列写入技能 |
| --- | --- | --- | --- |
| 系统库 | `system/knowledge/overview/{APPNAME}-overview.md` | 拷 `NAME-overview.md`，替换 `NAME`/`APPNAME` | **docs-distill**（上行）、**docs-extract**、**docs-tag** |
| 公司库 | `company/knowledge/overview/{NAME}-overview.md` | 拷 `NAME-overview.md`，替换 `NAME` | **docs-extract**、**docs-archive**、**docs-tag**（**非** docs-distill 落盘目标） |

**表行真源**：同层 `overview/NAME-overview.md` 五视角表 ↔ 同层五视角 **README 表行**；副标题锚点与各章 `##` 标题对齐。

**第三列规则**（A/U/D、禁止来源脚注）：详见 [docs-distill/references/federation-spec.md](../skills/docs-distill/references/federation-spec.md)。

---

## 系统库 overview 主标题行序（摘要）

自上而下逐节，勿跳行：

- 业务：概述 → 域划分 → 术语 → 流程 → 能力地图
- 产品：概述 → 产品架构 → 信息架构 → 产品功能 → 用户旅程
- 应用：系统概述 → 应用架构 → 领域模型 → 服务设计 → 领域能力 → ADR
- 技术：技术概述 → 基础设施 → 中间件 → **性能扩展 → 高可用** → 可观测性
- 数据：数据概述 → 数据模型 → 数据存储 → 数据分析 → 数据流转

公司库行序见 `company/knowledge/overview/NAME-overview.md` 与同层 README。

---

## 知识流水线

```text
应用远端 SSOT ──docs-pull──► applications/app-{APPNAME}/
                                    │
system/application-{APPNAME}/ ◄──────┘（联邦槽位，可选 fetch）
         │
         ▼ docs-distill（仅系统 overview）
system/knowledge/overview/{APPNAME}-overview.md
         │ docs-extract（任意源 → 系统/公司 overview）
         │ docs-tag（关键词 ✅、架构摘录）
         ▼ docs-archive
system/knowledge/{business,product,application,data,technical}/
company/knowledge/{business,product,application,data,technical}/
```

---

## 闸门与 hook 范围

| 技能 | hook 拦截写入路径 | 说明 |
| --- | --- | --- |
| docs-distill / docs-extract | `system/knowledge/overview/*.md`、`company/knowledge/overview/*.md` | 第三列与 overview 回写 |
| docs-archive | 同上（overview 回写） | **章节落盘**靠会话**方案确认书** HARD-GATE；hook **不**拦截 `knowledge/` 或 `ea/` 下视角章节 |
| docs-indexing | 各 `INDEX_GUIDE.md`、`*/changelogs/INDEXING-LOG.md` | 见 CONVENTIONS |

---

## SDD 与 KNOWLEDGE_TYPE

| 模式 | 方案/分析落盘 | 架构输入 | PRD/ASD/DSD |
| --- | --- | --- | --- |
| `application`（默认） | `{DOC_DIR}/solutions/`、`analysis/` | 应用上下文 | `{DOC_DIR}/requirements/**/` |
| `system` | `system/solutions/`、`system/analysis/` | [system/knowledge/](../../system/knowledge/README.md) | 联邦 ASD 概要；详设 → 应用库 `/sdx-design` |
| `company` | `company/solutions/`、`company/analysis/` | [company/knowledge/](../../company/knowledge/README.md) | 公司 ANALYSIS 拆解系统归属；各系统 PRD/ASD/DSD 在对应 **`system/requirements/`** |

详见 [sdx-architect/references/knowledge-type-modes.md](../skills/sdx-architect/references/knowledge-type-modes.md)。

---

## 相关 Skill

| 场景 | 技能 |
| --- | --- |
| 上行蒸馏 | docs-distill |
| 任意源 → overview | docs-extract |
| overview → 视角章节 | docs-archive |
| 关键词 / 摘录 | docs-tag |
| 索引地图 | docs-indexing |
| 入口契约 | docs-agent |
