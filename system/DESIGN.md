---
type: Design Document
title: 系统知识库设计
version: 2026.1111.0
---
# 系统知识库设计

## 版本

版本号表示四层知识库的统一内容发布版本，格式为 `YYYY.MMdd.patch`。版本由维护者人工发布；发布时，四层 `DESIGN.md` 的 `version` 必须同步为同一值。

`system/`：系统层知识编排、架构聚合与应用槽位治理。本文件 = 层根人类入口（契约短表 + 引用）；语义 SSOT ∈ `agent/knowledge/`。

## 阅读顺序

1. [README.md](README.md) — 定位  
2. 本文 — 本层契约、同步门禁、治理引用  
3. [knowledge/README.md](knowledge/README.md) — 五视角  

索引：[INDEX-GUIDE.md](INDEX-GUIDE.md) · [index.md](index.md) · [application-slots/](application-slots/README.md) · [knowledge-links.yaml](knowledge-links.yaml)

## 本层契约

| 目录 | 职责 |
| --- | --- |
| `knowledge/` | SYS 与实现链 SSOT + 五视角；不建上层 reference 文件，引用遵[统一规则](../agent/knowledge/knowledge-reference-rules.md)，SYS 两条上游边保留纯 ID 特例；[`overview/`](knowledge/overview/NAME-overview.md) = 蒸馏缓冲区 |
| `analysis/` → `features/` → `requirements/` | 系统 SDD；PRD/ASD/TDD ∈ `REQUIREMENT-{IDEA-ID}/`，ASD 列应用承接，DSD 正文归应用；见 [交付入口](requirements/README.md) |
| `adr/` | 系统层决策 + `CONTEXT.md` |
| `application-slots/application-{NAME}/` | 应用镜像软链入口 |
| `knowledge-links.yaml` | parent 一条，为解决方案；child 为应用；键均为 `name` / `label`，不写层前缀 |
| `TODO-LIST.md` | 烤干未闭合代办（本目录 = `{DOC_DIR}`）；变更溯源用 git。元仓全书仍在仓根 |

路径总则：[knowledge-layout § 四层文档根](../agent/references/knowledge-layout.md#四层文档根) · [§ 文件与目录落点](../agent/references/knowledge-layout.md#文件与目录落点) · [§ overview](../agent/references/knowledge-layout.md#overview) · [§ SDD 与 KNOWLEDGE_TYPE](../agent/references/knowledge-layout.md#sdd-与-knowledge_type)。

## 同步与门禁

验收统一按 [知识校验](../agent/knowledge/knowledge-validation.md) 区分本地、跨库与事实状态；来源关联按 [知识证据](../agent/knowledge/knowledge-evidence.md) 保存。内容版本一致不代表真实实体已兼容，尚未接入的工具能力不得宣称已实现。

1. **docs-link --check / --repair** → 校验/修复 `application-slots/application-{NAME}` 软链
2. 校核 `knowledge/` 与治理约定  
3. **本层接收**：在系统侧用 docs-distill 读取应用槽位，写系统 overview；再由系统侧 docs-archive 写本层章节并回写 overview
4. **进一步上行**：由解决方案侧读取系统槽位，蒸馏到解决方案 overview，再在解决方案侧归档；不直蒸公司
5. 内容更新遵循各仓 Git 工作流；溯源 `git log` / `git diff`

`DOC_DIR` 与知识层均取接收方，参数见 [distill 工作流](../agent/skills/docs-distill/references/workflow.md#参数与路径)；archive 消费同层 overview，不承担跨层搬运。

全图：[knowledge-layout § 知识流水线](../agent/references/knowledge-layout.md#知识流水线)。跨层无双份主定义；内容更新按各仓 Git 工作流处理；改目录语义先改**本元库模板**再 upgrade。

## 治理引用

| 主题 | 链 |
| --- | --- |
| 本层聚焦 / 首次定义 | [knowledge-governance § 系统层](../agent/knowledge/knowledge-governance.md#系统层) |
| 引用边界 | [knowledge-governance § 业务 knowledge 引用边界](../agent/knowledge/knowledge-governance.md#业务-knowledge-引用边界) |
| 本层 OKF 模板要点 | [okf-spec § 10.3 system](../agent/knowledge/okf-spec.md#103-system) |
| 其余语义 | [knowledge-governance](../agent/knowledge/knowledge-governance.md)（四层 · 5A）· [glossary](../agent/knowledge/glossary.md) · [naming-conventions](../agent/knowledge/naming-conventions.md) · [okf-spec](../agent/knowledge/okf-spec.md) · [adr-guidelines](../agent/knowledge/adr-guidelines.md) |
