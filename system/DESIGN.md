---
type: Design Document
title: 系统知识库设计
---
# 系统知识库设计

`system/`：系统层知识编排、架构聚合与应用槽位治理。本文件 = 层根人类入口（契约短表 + 引用）；语义 SSOT ∈ `agent/knowledge/`。

## 阅读顺序

1. [README.md](README.md) — 定位  
2. 本文 — 本层契约、同步门禁、治理引用  
3. [knowledge/README.md](knowledge/README.md) — 五视角  

索引：[INDEX-GUIDE.md](INDEX-GUIDE.md) · [index.md](index.md) · [application-slots/](application-slots/README.md) · [knowledge-links.yaml](knowledge-links.yaml)

## 本层契约

| 目录 | 职责 |
| --- | --- |
| `knowledge/` | SYS 与实现链 SSOT + 五视角；上层实体可薄 reference；[`overview/`](knowledge/overview/NAME-overview.md) = 蒸馏缓冲区 |
| `analysis/` → `features/` → `requirements/` | 系统 SDD；交付 ∈ `REQUIREMENT-{IDEA-ID}/` |
| `adr/` | 系统层决策 + `CONTEXT.md` |
| `application-slots/application-{NAME}/` | 应用镜像软链入口 |
| `knowledge-links.yaml` | parent = 解决方案（`solution_*`）；child 应用用 `app_*` |
| `changelogs/` | INDEXING-LOG；变更溯源 git |

路径总则：[knowledge-layout § 四层文档根](../agent/references/knowledge-layout.md#四层文档根) · [§ 文件与目录落点](../agent/references/knowledge-layout.md#文件与目录落点) · [§ overview](../agent/references/knowledge-layout.md#overview) · [§ SDD 与 KNOWLEDGE_TYPE](../agent/references/knowledge-layout.md#sdd-与-knowledge_type)。

## 同步与门禁

1. **docs-pull** → 校验/修复 `application-slots/application-{NAME}` 软链  
2. 校核 `knowledge/` 与治理约定  
3. **docs-distill / docs-archive** 上行解决方案 overview（不再直蒸公司）  
4. `application-slots/changelogs/` 蒸馏锚点；同步追溯 git / `SYNC_OK`  

全图：[knowledge-layout § 知识流水线](../agent/references/knowledge-layout.md#知识流水线)。跨层无双份主定义；脏工作区不得 pull；改目录语义先改**本元库模板**再 upgrade。

## 治理引用

| 主题 | 链 |
| --- | --- |
| 本层聚焦 / 首次定义 | [knowledge-governance § 系统层](../agent/knowledge/knowledge-governance.md#系统层) |
| 引用边界 | [knowledge-governance § 业务 knowledge 引用边界](../agent/knowledge/knowledge-governance.md#业务-knowledge-引用边界) |
| 本层 OKF 模板要点 | [okf-spec § 10.3 system](../agent/knowledge/okf-spec.md#103-system) |
| 其余语义 | [knowledge-governance](../agent/knowledge/knowledge-governance.md)（四层 · 5A）· [glossary](../agent/knowledge/glossary.md) · [naming-conventions](../agent/knowledge/naming-conventions.md) · [okf-spec](../agent/knowledge/okf-spec.md) · [adr-guidelines](../agent/knowledge/adr-guidelines.md) |
