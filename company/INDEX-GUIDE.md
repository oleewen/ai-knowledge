---
type: Documentation
title: company INDEX-GUIDE
---
# company INDEX-GUIDE

> **最后更新**: 2026-10-05  
> **定位**: `company/` 九章索引指南。目录索引：[index.md](index.md)。契约见 [DESIGN.md](DESIGN.md)。

---

## 一、项目概览

### 1.1 速查

* [README.md](README.md) — 人类入口  
* [index.md](index.md) — OKF 目录索引  
* [DESIGN.md](DESIGN.md) — 本层设计入口  
* [knowledge/README.md](knowledge/README.md) — 五视角  
* [knowledge-links.yaml](knowledge-links.yaml) — 建联清单  
* [changelogs/README.md](changelogs/README.md) — 变更/索引  

### 1.2 元信息

* **角色**: 公司知识库；`knowledge/` = VC/BD/BSD(L1)/CAP/PL/TPL SSOT（无 SLN/PD/SYS/BSD(L2)/MDG/TSD）；`solution-slots/solution-{NAME}` = 解决方案联邦槽位（软链）  
* **栈**: Markdown、YAML  
* **范围**: `knowledge/` · `domains/` · `adr/` · `solution-slots/` · `changelogs/`  
* **规模**（本轮 full/d3，排除 `.agents`）：约 **83** 文件（`.md` 80 · `.yaml` 1 · `viz.html` 1）  

---

## 二、架构视图

### 2.1 模块结构

```text
company/
├── README.md / DESIGN.md / INDEX-GUIDE.md / index.md / docs-meta.md
├── knowledge-links.yaml
├── knowledge/ · domains/ · adr/
├── solution-slots/
│   ├── solution-{NAME}         # 软链 → 解决方案 DOC_ROOT
│   └── changelogs/
└── changelogs/
```

### 2.2 依赖关系

* `knowledge/` ↔ `solution/knowledge/`：公司实体参照（禁止直指系统槽位）
* `domains/` → 各解决方案 `solutions/` → 各系统 `analysis/` → `features/` → `requirements/`
* `knowledge-links.yaml` → `solution-slots/solution-{NAME}/`  

门禁与同步：[DESIGN.md](DESIGN.md) § 同步与门禁。

### 2.3 包结构

不适用：本层为 Markdown/YAML 知识库，无应用包名 / FQCN 树。

### 2.4 文档目录

入口：[knowledge/](knowledge/README.md) · [domains/](domains/README.md) · [adr/](adr/README.md) · [solution-slots/](solution-slots/README.md)

---

## 三、接口清单

无运行时 API。契约 = 目录 + Markdown + `knowledge-links.yaml`（细则 [DESIGN.md](DESIGN.md)）。

### 3.1 服务接口

| 小节 | 状态 | 说明 |
|------|------|------|
| 3.1 服务接口 | 不适用 | 无 Dubbo/gRPC |
| 3.2 HTTP 接口 | 不适用 | 无 REST（人类读 Markdown / 本地 `viz.html`） |
| 3.3 定时任务 | 不适用 | 无内嵌调度 |
| 3.4 消息队列 | 不适用 | 无 Topic/消费者 |

### 3.2 CLI / Slash 入口

| 入口 | 类型 | 路径/命令 | 说明 |
|------|------|-----------|------|
| `/docs-okf` | Slash | [docs-okf/SKILL.md](../agent/skills/docs-okf/SKILL.md) | 刷新本层 `index.md` / `viz.html` |
| `/docs-indexing` | Slash | [docs-indexing/SKILL.md](../agent/skills/docs-indexing/SKILL.md) | 九章骨架（须保留 entity-index） |
| `/docs-build` | Slash | [docs-build/SKILL.md](../agent/skills/docs-build/SKILL.md) | 刷新 §4.5 视角导航块 |
| `/docs-link` · `/docs-pull` | Slash | `agent/skills/docs-link` · `docs-pull` | 联邦建联与槽位同步 |

---

## 四、领域模型

### 4.1 业务术语

不适用贴表：术语 SSOT ∈ [glossary.md](../agent/knowledge/glossary.md) / [knowledge-governance.md](../agent/knowledge/knowledge-governance.md)；本层只引不抄。

### 4.2 聚合根（知识组织）

| 聚合 | 职责 | 关键落点 |
|------|------|----------|
| 公司级实体 | VC / BD / BSD(L1) / CAP / PL / TPL | [knowledge/](knowledge/README.md)；台账 ∈ 各视角 README |
| overview 缓冲 | distill / extract / archive / tag | [knowledge/overview/](knowledge/overview/README.md) |
| SDD 上游 | 域架构 | `domains/`（无 solutions/analysis/requirements） |
| 联邦槽位 | 解决方案 DOC_ROOT 软链 | `solution-slots/solution-{NAME}/` · [knowledge-links.yaml](knowledge-links.yaml) |

### 4.3 领域服务

不适用运行时服务：协作能力见根 [INDEX-GUIDE.md](../INDEX-GUIDE.md) §4.3 与本层 Skill 入口（§3.2 / §9.3）。

### 4.4 领域事件

不适用运行时事件：索引运行见 [changelogs/INDEXING-LOG.md](changelogs/INDEXING-LOG.md)；归档见 `solution-slots/changelogs/`。

### 4.5 视角导航

<!-- docs-build:entity-index:begin -->
> 本块由 `/docs-build` 写入；实体台账 ∈ 各视角 README；正文 ∈ per-entity `{ID}.md`；九章骨架 ∈ `/docs-indexing`。

> 本层登记 **VC / BD / BSD(L1) / CAP / PL / TPL**。无 SLN/PD/BSD(L2)/MDG/TSD/SYS（见解决方案/系统）。

### 视角入口

- [知识库总说明](knowledge/README.md)
- [目录索引](knowledge/index.md)
- [业务](knowledge/business/README.md)
- [产品](knowledge/product/README.md)
- [应用](knowledge/application/README.md)
- [数据](knowledge/data/README.md)
- [技术](knowledge/technical/README.md)
<!-- docs-build:entity-index:end -->

---

## 五、业务逻辑

不适用运行时状态机 / 枚举。SDD 上游样例：

| 路径 | 说明 |
|------|------|
| [domains/DOMAIN-MAP.md](domains/DOMAIN-MAP.md) | 域架构总图 |
| [domains/DOMAIN-EXAMPLE.md](domains/DOMAIN-EXAMPLE.md) | 分域样例 |
| [adr/CONTEXT.md](adr/CONTEXT.md) | ADR 索引入口 |

流程叙事章 ∈ 各视角 `knowledge/*/chapters/`（如 business 六章）；不在九章展开正文。

---

## 六、数据映射

### 6.1 数据源

| 数据源 | 类型 | 用途 |
|--------|------|------|
| `{ID}.md` | Markdown + YAML | 公司实体 SSOT |
| `knowledge/overview/` | Markdown | overview 缓冲；入口 [overview/README.md](knowledge/overview/README.md) |
| `knowledge-links.yaml` | YAML | 联邦建联 |
| `viz.html` | HTML | OKF 可视化 |

### 6.2 实体映射

不适用贴表：字段与 ID 链 SSOT ∈ 治理 / 各视角 README；样例实体如 `VC-EXAMPLE` / `BD-EXAMPLE` 落在 `knowledge/business/`。

### 6.3 关系映射

跨视角以 ID + 关系动词（`implements_to` / `maps_to` / `supports_to` 等）维护；入口 [knowledge/README.md](knowledge/README.md) · [glossary.md](../agent/knowledge/glossary.md)。

### 6.4 SQL 索引

不适用：无 RDBMS 表结构。

---

## 七、配置中心

不适用运行时配置中心。装机与联邦：

| 项 | 落点 |
|------|------|
| 文档根 / 类型 | 仓库根 [`.docsconfig`](../.docsconfig)（`DOC_DIR=company`，`KNOWLEDGE_TYPE=meta`） |
| 建联清单 | [knowledge-links.yaml](knowledge-links.yaml)（现 `links: []`） |
| 装机 | `/docs-install` · `/docs-link` |

---

## 八、索引边界

### 8.1 覆盖范围

本轮 **full / depth 3** 覆盖 `company/` 可读文本（约 83 文件）。九章已消减 `[未索引]`；实体台账仍以各视角 README 与 per-entity 为准，不在此贴全表。

### 8.2 排除列表

| 排除 | 原因 |
|------|------|
| `company/.agents/` | Agent 软链树，非知识正文 |
| `.git/` · IDE · `node_modules/` | 常规 |
| 槽位目标仓正文 | 经软链外指；以对端仓 INDEX / git 为准 |
| `viz.html` 内嵌快照 | 生成物；源以 Markdown 为准 |

### 8.3 维护规则

* [changelogs/](changelogs/README.md)：`INDEXING-LOG`；溯源 git  
* 槽位日志 ∈ `solution-slots/changelogs/ARCHIVE-LOG.md`  
* 大目录或契约变更后跑 `/docs-indexing`；索引后按需 `/docs-okf`

---

## 九、扩展资源

### 9.1 核心文档

| 文档 | 路径 | 描述 |
|------|------|------|
| 本层九章 | [INDEX-GUIDE.md](INDEX-GUIDE.md) | 本文 |
| 目录索引 | [index.md](index.md) | OKF 渐进披露 |
| 设计入口 | [DESIGN.md](DESIGN.md) | 契约与门禁 |
| OKF 可视化 | [viz.html](viz.html) | 图视图 |
| 索引运行日志 | [INDEXING-LOG.md](changelogs/INDEXING-LOG.md) | docs-indexing 基线 |

### 9.2 相关项目

| 关系 | 状态 |
|------|------|
| `knowledge-links.yaml` child | **空**（`links: []`，合法未挂载态） |
| `solution-slots/solution-*` | **无**现成软链；仅有槽位 README / `changelogs/` |
| 同仓邻层 | [solution/](../solution/README.md) · [system/](../system/README.md) · [application/](../application/README.md)（非联邦 path，开发元库并列） |

### 9.3 工具链

| 工具 | 说明 |
|------|------|
| `/docs-okf` | [docs-okf/SKILL.md](../agent/skills/docs-okf/SKILL.md) |
| `/docs-indexing` | 九章骨架（须保留 entity-index 标记块） |
| `/docs-build` | 刷新 §4.5 标记块 |
