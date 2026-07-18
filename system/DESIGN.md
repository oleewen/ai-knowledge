---
type: Design Document
title: 系统知识库设计
---
<!-- markdownlint-disable-next-line MD025 -->
# 系统知识库设计

`system/`：系统层知识编排、架构聚合与应用槽位治理。路径 SSOT 见 [knowledge-layout](../agent/references/knowledge-layout.md)。首次定义矩阵见 [application/DESIGN.md](../application/DESIGN.md) §2.2.1。

## 阅读顺序

1. [README.md](README.md) — 定位  
2. 本文 — 边界、契约、同步  
3. [knowledge/README.md](knowledge/README.md) — 五视角  
4. [../company/DESIGN.md](../company/DESIGN.md) / [../application/DESIGN.md](../application/DESIGN.md) — 上下游对照  

## 1. 定位与边界

| 层 | 职责 |
|----|------|
| `company/` | 公司级实体正文 SSOT（BD/CAP/PL/SYS/MDG/TPL） |
| `system/` | 系统层首次定义实体 SSOT + 五视角落地叙事 + `application-{name}/` 槽位 |
| `application/` | 应用层首次定义（API/TBL/MW/CMP）+ 实现映射与实例登记 |

- **系统层 SSOT**：`BSD/BC/AGG/AB/PM/FT/FR/UC/BP/BR/APP/MS/DS/ENT/TSD`  
- **公司层 reference**：视角根单文件 `BD/PL/SYS/MDG-*.md`（正文 SSOT 在 company）  
- **应用层 reference**：`MW` 等可在本层留 reference，指向 application SSOT  
- **禁止**：跨层字段语义双源  

## 2. 目录契约

| 层级 | 目录 | 职责 |
| --- | --- | --- |
| 根导航 | README / INDEX-GUIDE / index / docs-meta | 入口与索引 |
| ADR | [adr/](adr/README.md) | 系统层决策正文 |
| 架构 | `knowledge/` | 五视角 + [`overview/`](knowledge/overview/NAME-overview.md) 蒸馏缓冲区 |
| SDD | solutions → analysis → requirements | 系统方案链；交付在 `REQUIREMENT-*/MVP-Phase-*/` |
| 槽位 | `application-{name}/` | docs-pull 镜像 |
| 清单 | [knowledge-links.yaml](knowledge-links.yaml) | 建联 |
| 运维 | [changelogs/](changelogs/README.md) | CHANGE-LOG / INDEXING-LOG |

### SDD（system 模式）

| 阶段 | 目录 | 产出 |
| --- | --- | --- |
| 方案 | `solutions/` | `SOLUTION-{IDEA-ID}.md` |
| 分析 | `analysis/` | `ANALYSIS-{IDEA-ID}.md` |
| 交付 | `requirements/` | `REQUIREMENT-{IDEA-ID}/MVP-Phase-*/` 下 PRD/ASD/DSD/TDD |

跨系统上游见 [company/DESIGN.md](../company/DESIGN.md)。

### 五视角（系统层聚焦）

| 视角 | 系统层聚焦 | 入口 |
| --- | --- | --- |
| 业务 | BSD→AB；BD 为 company reference | [knowledge/business/](knowledge/business/README.md) |
| 产品 | PM→FT→FR→UC/BR、BP；PL 为 company reference | [knowledge/product/](knowledge/product/README.md) |
| 应用 | APP/MS；SYS 为 company reference；API 在 application | [knowledge/application/](knowledge/application/README.md) |
| 数据 | DS/ENT；MDG 为 company reference；TBL 在 application | [knowledge/data/](knowledge/data/README.md) |
| 技术 | TSD；MW/CMP 在 application（本层可 reference） | [knowledge/technical/](knowledge/technical/README.md) |

### 关键路径约定

| 实体 | system 路径 |
| --- | --- |
| BD（ref） | `knowledge/business/BD-{NAME}.md` |
| BSD→AB | `knowledge/business/BSD-{NAME}/…` |
| APP | `knowledge/application/APP-{NAME}/APP-{NAME}.md` |
| MS | `knowledge/application/MS-{NAME}/MS-{NAME}.md` |
| MW（ref） | `knowledge/technical/MW-{NAME}/MW-{NAME}.md` → application SSOT |

#### 系统层 BD 落盘

公司 SSOT：`company/knowledge/business/BD-{NAME}/`。本层仅视角根单文件 reference（`definition_scope: reference`），路径见上表 BD 行；BSD→AB 为本层域树 SSOT。

### Overview

`knowledge/overview/*-overview.md` = distill/extract 缓冲区，非实体 SSOT。归档后落入各视角 chapters。核心行序见 [knowledge-layout](../agent/references/knowledge-layout.md)；📎 按需章可不进 overview。

### ADR

`adr/` 存系统层决策正文；**无强制 EXAMPLE**。overview 应用视角末行链 [adr/](adr/README.md)，不进 `knowledge/*/chapters/`。

### 章节 SSOT 继承

| 类型 | 规则 |
| --- | --- |
| 公司对齐 | 有同名 company 章 → 引用为上游 |
| 框架参照 | 无同名 → 本层 SSOT，链 company 视角 README |
| 实体字段 | 不重复铺字段表；见 application/DESIGN §2.2.1 |

## 3. 同步闭环

1. **docs-pull** → `application-{name}/`  
2. 校核 `knowledge/` 与治理约定  
3. **docs-distill / docs-archive** 上行  
4. **changelogs** 追溯  

## 4. 门禁

- 术语/目录/链接与 README、INDEX-GUIDE、index 一致  
- 跨层无双份主定义  
- 槽位更新记来源与回写策略  
- 改目录语义先改本文  

## 参考

[README](README.md) · [knowledge/](knowledge/README.md) · [knowledge-links.yaml](knowledge-links.yaml) · [knowledge-layout](../agent/references/knowledge-layout.md) · [naming-conventions](../agent/knowledge/naming-conventions.md) · [company/DESIGN](../company/DESIGN.md) · [application/DESIGN](../application/DESIGN.md)
