---
type: Design Document
title: 应用知识库设计
---
<!-- markdownlint-disable-next-line MD025 -->
# 应用知识库设计

`application/`：实现级实体与应用 SDD；上行对齐系统 overview，**不**回写本库 knowledge。本文件 = 层根人类入口（契约短表 + 引用）；语义 SSOT ∈ `agent/knowledge/`。

## 阅读顺序

1. [README.md](README.md) — 定位与 mode 路由  
2. 本文 — 本层契约、同步门禁、治理引用  
3. [knowledge/README.md](knowledge/README.md) — 五视角；字段见各 `*-meta.md`  
4. [../system/DESIGN.md](../system/DESIGN.md) / [../company/DESIGN.md](../company/DESIGN.md) — 上游对照  

## 本层契约

| 目录 | 职责 |
| --- | --- |
| `knowledge/` | 五视角；本层首次实体 **API / TBL / MW / CMP** |
| `solutions/` → `analysis/` → `requirements/` | 应用 SDD；交付 ∈ `REQUIREMENT-{IDEA-ID}/` |
| `adr/` | 应用层 ADR + `CONTEXT.md` |
| `changelogs/` | INDEXING-LOG（可选）；变更溯源 git |
| `CONTRIBUTING.md` | 贡献约定（与本文分工：贡献流程 vs 设计入口） |
| `manifest.md` | 应用仓清单（协同目标态） |

路径总则：[knowledge-layout § 三层文档根](../agent/references/knowledge-layout.md#三层文档根) · [§ 文件与目录落点](../agent/references/knowledge-layout.md#文件与目录落点) · [§ SDD 与 KNOWLEDGE_TYPE](../agent/references/knowledge-layout.md#sdd-与-knowledge_type)。无联邦槽位（槽位在 system）。

## 同步与门禁

1. 本库维护文档树与实体 SSOT  
2. 系统侧 docs-link / docs-pull 建应用槽位（本库为源）  
3. 上行：pull → distill（**仅**系统 overview）→ archive；**不**回写本库 `knowledge/`  
4. 术语/目录/链接与 README、INDEX-GUIDE、index 一致；跨层无双份主定义  

流水线全图：[knowledge-layout § 知识流水线](../agent/references/knowledge-layout.md#知识流水线)。改目录语义先改**本元库模板**再 upgrade。

## 治理引用

| 主题 | 链 |
| --- | --- |
| 三层职责 | [knowledge-governance § 三层职责边界](../agent/knowledge/knowledge-governance.md#三层职责边界) |
| 本层聚焦 / 首次定义 | [knowledge-governance § 应用层](../agent/knowledge/knowledge-governance.md#应用层) |
| 5A 映射 | [knowledge-governance § 核心映射（5A 方向）](../agent/knowledge/knowledge-governance.md#核心映射5a方向) |
| 引用边界 | [knowledge-governance § 业务 knowledge 引用边界](../agent/knowledge/knowledge-governance.md#业务-knowledge-引用边界) |
| 术语 / 5A 短义 | [glossary § 知识库术语](../agent/knowledge/glossary.md#知识库术语) |
| 映射字段语义 | [glossary § 映射关系（常用）](../agent/knowledge/glossary.md#映射关系常用) |
| 实体 ID | [naming-conventions § 实体 ID 格式](../agent/knowledge/naming-conventions.md#1-实体-id-格式) |
| IDEA-ID | [naming-conventions § IDEA-ID](../agent/knowledge/naming-conventions.md#2-idea-id) |
| 文件分型 | [okf-spec § 文件分类方式](../agent/knowledge/okf-spec.md#1-文件分类方式) |
| 本层 OKF 模板要点 | [okf-spec § 10.3 application](../agent/knowledge/okf-spec.md#103-application) |
| ADR | [adr-guidelines](../agent/knowledge/adr-guidelines.md) · [adr-template](../agent/knowledge/adr-template.md) |

## 参考

[README](README.md) · [INDEX-GUIDE](INDEX-GUIDE.md) · [index.md](index.md) · [CONTRIBUTING](CONTRIBUTING.md) · [knowledge/](knowledge/README.md) · [system/DESIGN](../system/DESIGN.md) · [company/DESIGN](../company/DESIGN.md)
