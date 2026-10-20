---
type: Design Document
title: 解决方案知识库设计
version: 2026.1020.1
---
# 解决方案知识库设计

## 版本

版本号表示四层知识库的统一内容发布版本，格式为 `YYYY.MMdd.patch`。版本由维护者人工发布；发布时，四层 `DESIGN.md` 的 `version` 必须同步为同一值。

`solution/`：一个交付包（一仓一 SLN）的共性知识与 SA。本文件 = 层根契约短表 + 引用；语义 SSOT ∈ `agent/knowledge/`。

## 阅读顺序

1. [README.md](README.md) — 定位  
2. 本文 — 本层契约、同步门禁、治理引用  
3. [knowledge/README.md](knowledge/README.md) — 五视角

索引：`INDEX-GUIDE.md` · `index.md` · `knowledge-links.yaml`（装机后）

## 本层契约

| 目录 | 职责 |
| --- | --- |
| `knowledge/` | SLN/PL/PD/BP/BSP/BSD-L2/BS/MDG/TS 首次定义；五视角同构；`overview/{NAME}-overview.md` = 蒸馏缓冲区 |
| `solutions/` | `/sdx-solution` 写 `SOLUTION-*.md`（交付包切分叙事）。**无** analysis/features/requirements。七章需求分析不在本层 |
| `adr/` | 解决方案层决策 + `CONTEXT.md` |
| `system-slots/system-{NAME}/` | 系统联邦槽位（软链） |
| `knowledge-links.yaml` | parent 一条，为公司；child 为系统；键均为 `name` / `label`，不写层前缀 |
| `TODO-LIST.md` | 烤干未闭合代办（本目录 = `{DOC_DIR}`）；变更溯源用 git。元仓全书仍在仓根 |

路径总则：[knowledge-layout § 四层文档根](../agent/references/knowledge-layout.md#四层文档根) · [§ 文件与目录落点](../agent/references/knowledge-layout.md#文件与目录落点) · [§ SDD 与 KNOWLEDGE_TYPE](../agent/references/knowledge-layout.md#sdd-与-knowledge_type)。

## 同步与门禁

1. **docs-pull** → 校验/修复 `system-slots/system-{NAME}`  
2. 校核 `knowledge/` 与治理约定  
3. **docs-distill / docs-archive** 上行公司 overview  
4. 脏工作区不得 pull；改目录语义先改**本元库模板**再 upgrade  

全图：[knowledge-layout § 知识流水线](../agent/references/knowledge-layout.md#知识流水线)。

## 治理引用

| 主题 | 链 |
| --- | --- |
| 本层聚焦 / 首次定义 | [knowledge-governance § 解决方案层](../agent/knowledge/knowledge-governance.md#解决方案层) |
| 引用边界 | [knowledge-governance § 业务 knowledge 引用边界](../agent/knowledge/knowledge-governance.md#业务-knowledge-引用边界) |
| 本层 OKF 模板要点 | [okf-spec § 10.2 solution](../agent/knowledge/okf-spec.md#102-solution) |
| 其余语义 | [knowledge-governance](../agent/knowledge/knowledge-governance.md) · [glossary](../agent/knowledge/glossary.md) · [okf-spec](../agent/knowledge/okf-spec.md) |
