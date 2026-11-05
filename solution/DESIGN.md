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
| `solutions/` | `/sdx-solution` 写 `SOLUTION-*.md`（七章解决方案分析），覆盖业务目标、产品服务边界、跨系统协作与方案级交付计划。保留 solutions/；无 analysis/features/requirements，系统需求与实现详设由下游承接 |
| `adr/` | 解决方案层决策 + `CONTEXT.md` |
| `system-slots/system-{NAME}/` | 系统联邦槽位（软链） |
| `knowledge-links.yaml` | parent 一条，为公司；child 为系统；键均为 `name` / `label`，不写层前缀 |
| `TODO-LIST.md` | 烤干未闭合代办（本目录 = `{DOC_DIR}`）；变更溯源用 git。元仓全书仍在仓根 |

共享系统由 PD 声明消费、SLN 汇总，SYS 的唯一治理归属保持不变；见 [消费关系](../agent/knowledge/entity-relations.md#共享系统消费)。消费定位登记及旧工具兼容边界见 [联邦配置](../agent/knowledge/federation-config.md)。

路径总则：[knowledge-layout § 四层文档根](../agent/references/knowledge-layout.md#四层文档根) · [§ 文件与目录落点](../agent/references/knowledge-layout.md#文件与目录落点) · [§ SDD 与 KNOWLEDGE_TYPE](../agent/references/knowledge-layout.md#sdd-与-knowledge_type)。

## 同步与门禁

验收统一按 [知识校验](../agent/knowledge/knowledge-validation.md) 区分本地、跨库与事实状态；来源关联按 [知识证据](../agent/knowledge/knowledge-evidence.md) 保存。内容版本一致不代表真实实体已兼容，尚未接入的工具能力不得宣称已实现。

1. **docs-link --check / --repair** → 校验/修复 `system-slots/system-{NAME}`
2. 校核 `knowledge/` 与治理约定  
3. **本层接收**：在解决方案侧用 docs-distill 读取系统槽位，写解决方案 overview；再由本层 docs-archive 写章节并回写 overview
4. **进一步上行**：由公司侧读取解决方案槽位，蒸馏到公司 overview，再在公司侧归档
5. 内容更新按各仓 Git 工作流处理；改目录语义先改**本元库模板**再 upgrade

`DOC_DIR` 与知识层均取接收方，参数见 [distill 工作流](../agent/skills/docs-distill/references/workflow.md#参数与路径)；archive 消费同层 overview，不承担跨层搬运。

全图：[knowledge-layout § 知识流水线](../agent/references/knowledge-layout.md#知识流水线)。

## 治理引用

| 主题 | 链 |
| --- | --- |
| 本层聚焦 / 首次定义 | [knowledge-governance § 解决方案层](../agent/knowledge/knowledge-governance.md#解决方案层) |
| 引用边界 | [knowledge-governance § 业务 knowledge 引用边界](../agent/knowledge/knowledge-governance.md#业务-knowledge-引用边界) |
| 本层 OKF 模板要点 | [okf-spec § 10.2 solution](../agent/knowledge/okf-spec.md#102-solution) |
| 其余语义 | [knowledge-governance](../agent/knowledge/knowledge-governance.md) · [glossary](../agent/knowledge/glossary.md) · [okf-spec](../agent/knowledge/okf-spec.md) |
