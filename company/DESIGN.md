---
type: Design Document
title: 公司知识库设计
---
<!-- markdownlint-disable-next-line MD025 -->
# 公司知识库设计

本文件 = `company/` 层契约短表 + 治理引用；不写系统实现。定位见 [README](README.md)；语义 SSOT ∈ `agent/knowledge/`。

## 阅读顺序

1. [README.md](README.md) — 定位与导航  
2. 本文 — 契约、同步门禁、治理链  
3. [knowledge/README.md](knowledge/README.md) — 五视角  

索引：[INDEX-GUIDE.md](INDEX-GUIDE.md) · [index.md](index.md) · [system-slots/](system-slots/README.md) · [knowledge-links.yaml](knowledge-links.yaml)

## 本层契约

| 目录 | 职责 |
| --- | --- |
| `knowledge/` | 公司级实体正文 SSOT；[`overview/`](knowledge/overview/NAME-overview.md) = distill / extract / archive / tag 缓冲区（非实体 SSOT） |
| `solutions/` · `analysis/` | 跨系统 SDD 上游；**无** `requirements/` |
| `adr/` | 公司层跨系统决策 + `CONTEXT.md` |
| `system-slots/system-{NAME}/` | 系统联邦槽位入口（软链） |
| `knowledge-links.yaml` | 建联与同步编排（可空） |
| `changelogs/` | INDEXING-LOG；变更溯源 git |

路径总则：[knowledge-layout § 三层文档根](../agent/references/knowledge-layout.md#三层文档根) · [§ 文件与目录落点](../agent/references/knowledge-layout.md#文件与目录落点) · [§ SDD 与 KNOWLEDGE_TYPE](../agent/references/knowledge-layout.md#sdd-与-knowledge_type)。

## 同步与门禁

冲突以下游事实源为准；company 只修映射与导航。

1. 下游 `system/` 整理可同步内容  
2. docs-pull → 校验/修复 `system-slots/system-{NAME}` 软链  
3. 校核 `knowledge/` 与 `knowledge-links.yaml`  
4. 可记 `SYNC_OK`（含 commit）；溯源 `git log` / `git diff`  

约束：禁止实现细节入 company 正文；改目录语义先改**本元库模板**再 upgrade。全图：[knowledge-layout § 知识流水线](../agent/references/knowledge-layout.md#知识流水线)。

## 治理引用

| 主题 | 链 |
| --- | --- |
| 三层职责 | [knowledge-governance § 三层职责边界](../agent/knowledge/knowledge-governance.md#三层职责边界) |
| 本层聚焦 / 首次定义 | [knowledge-governance § 公司层](../agent/knowledge/knowledge-governance.md#公司层) |
| 5A 映射 | [knowledge-governance § 核心映射（5A 方向）](../agent/knowledge/knowledge-governance.md#核心映射5a方向) |
| 引用边界 | [knowledge-governance § 业务 knowledge 引用边界](../agent/knowledge/knowledge-governance.md#业务-knowledge-引用边界) |
| 术语 / 5A 短义 | [glossary § 知识库术语](../agent/knowledge/glossary.md#知识库术语) |
| 映射字段语义 | [glossary § 映射关系（常用）](../agent/knowledge/glossary.md#映射关系常用) |
| 实体 ID | [naming-conventions § 实体 ID 格式](../agent/knowledge/naming-conventions.md#1-实体-id-格式) |
| 文件分型 | [okf-spec § 文件分类方式](../agent/knowledge/okf-spec.md#1-文件分类方式) |
| 本层 OKF 模板要点 | [okf-spec § 10.1 company](../agent/knowledge/okf-spec.md#101-company) |
| ADR | [adr-guidelines](../agent/knowledge/adr-guidelines.md) · [adr-template](../agent/knowledge/adr-template.md) |
