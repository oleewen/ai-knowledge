---
type: Design Document
title: 系统知识库设计
---
<!-- markdownlint-disable-next-line MD025 -->
# 系统知识库设计

`system/`：系统层知识编排、架构聚合与应用槽位治理。本文件 = 层根人类入口（契约短表 + 引用）；语义 SSOT ∈ `agent/knowledge/`。

## 阅读顺序

1. [README.md](README.md) — 定位  
2. 本文 — 本层契约、同步门禁、治理引用  
3. [knowledge/README.md](knowledge/README.md) — 五视角  
4. [../company/DESIGN.md](../company/DESIGN.md) / [../application/DESIGN.md](../application/DESIGN.md) — 上下游对照  

## 本层契约

| 目录 | 职责 |
| --- | --- |
| `knowledge/` | 系统层实体 SSOT + 五视角；[`overview/`](knowledge/overview/NAME-overview.md) = 蒸馏缓冲区（非实体 SSOT） |
| `solutions/` → `analysis/` → `requirements/` | 系统 SDD；交付 ∈ `REQUIREMENT-{IDEA-ID}/` |
| `adr/` | 系统层决策 + `CONTEXT.md`（无强制 EXAMPLE） |
| `application-slots/application-{NAME}/` | 应用镜像软链入口 |
| `knowledge-links.yaml` | 建联 |
| `changelogs/` | INDEXING-LOG；变更溯源 git |

路径总则：[knowledge-layout § 三层文档根](../agent/references/knowledge-layout.md#三层文档根) · [§ 文件与目录落点](../agent/references/knowledge-layout.md#文件与目录落点) · [§ overview](../agent/references/knowledge-layout.md#overview) · [§ SDD 与 KNOWLEDGE_TYPE](../agent/references/knowledge-layout.md#sdd-与-knowledge_type)。

## 同步与门禁

1. **docs-pull** → 校验/修复 `application-slots/application-{NAME}` 软链  
2. 校核 `knowledge/` 与治理约定  
3. **docs-distill / docs-archive** 上行  
4. `application-slots/changelogs/` 蒸馏锚点；同步追溯 git / `SYNC_OK`  

流水线全图：[knowledge-layout § 知识流水线](../agent/references/knowledge-layout.md#知识流水线)。跨层无双份主定义；脏工作区不得 pull；改目录语义先改**本元库模板**再 upgrade。

## 治理引用

| 主题 | 链 |
| --- | --- |
| 三层职责 | [knowledge-governance § 三层职责边界](../agent/knowledge/knowledge-governance.md#三层职责边界) |
| 本层聚焦 / 首次定义 | [knowledge-governance § 系统层](../agent/knowledge/knowledge-governance.md#系统层) |
| 5A 映射 | [knowledge-governance § 核心映射（5A 方向）](../agent/knowledge/knowledge-governance.md#核心映射5a方向) |
| 引用边界 | [knowledge-governance § 业务 knowledge 引用边界](../agent/knowledge/knowledge-governance.md#业务-knowledge-引用边界) |
| 术语 / 5A 短义 | [glossary § 知识库术语](../agent/knowledge/glossary.md#知识库术语) |
| 映射字段语义 | [glossary § 映射关系（常用）](../agent/knowledge/glossary.md#映射关系常用) |
| 实体 ID | [naming-conventions § 实体 ID 格式](../agent/knowledge/naming-conventions.md#1-实体-id-格式) |
| IDEA-ID | [naming-conventions § IDEA-ID](../agent/knowledge/naming-conventions.md#2-idea-id) |
| 文件分型 | [okf-spec § 文件分类方式](../agent/knowledge/okf-spec.md#1-文件分类方式) |
| 本层 OKF 模板要点 | [okf-spec § 10.2 system](../agent/knowledge/okf-spec.md#102-system) |
| ADR | [adr-guidelines](../agent/knowledge/adr-guidelines.md) · [adr-template](../agent/knowledge/adr-template.md) |

## 参考

[README](README.md) · [INDEX-GUIDE](INDEX-GUIDE.md) · [index.md](index.md) · [knowledge/](knowledge/README.md) · [application-slots](application-slots/README.md) · [knowledge-links.yaml](knowledge-links.yaml) · [company/DESIGN](../company/DESIGN.md) · [application/DESIGN](../application/DESIGN.md)
