---
name: sdx-design
description: >
  技术方案设计：基于产品需求与架构/领域文档进行技术方案设计，输出 ADD 与规约摘录文档。
  在用户执行 /sdx-design、编写 ADD 与规约摘录时使用。产出 system/requirements/REQUIREMENT-{ID}/MVP-{N}/ADD-{ID}-{N}.md，模板见 .ai/skills/sdx-design/assets/add-template.md。
---

# 方案设计阶段（sdx-design）

基于产品需求文档，结合系统架构与领域模型，输出**架构设计说明书（ADD）**与**规约文件（specs）**，为测试设计与开发提供技术蓝图。**主要读者为研发与架构**；业务验收口径仍以 PRD 为准，见 [reference/audience-and-language.md](reference/audience-and-language.md)。

**执行顺序建议**：先读本文件与 [gotchas.md](gotchas.md) → 步骤 1–4 按需打开 [reference/workflow-spec.md](reference/workflow-spec.md) → 输出前打开 [assets/add-template.md](assets/add-template.md) 与 [reference/quality-checklist.md](reference/quality-checklist.md)。

## 输入与输出

**输入**：PRD（`system/requirements/REQUIREMENT-{ID}/MVP-{N}/PRD-{ID}-{N}.md`）、需求分析当前 MVP 上下文（`system/analysis/ANALYSIS-{ID}.md`）、按需 `knowledge/technical/`、`knowledge/business/`、`knowledge/constitution/adr/`。  
**输出**：ADD、规约文件 `.../specs/spec-{ID}-{N}-{service-name}.md`。

| 类型 | 内容 |
|------|------|
| 硬输入 | 产品需求文档（`system/requirements/REQUIREMENT-{ID}/MVP-{N}/PRD-{ID}-{N}.md`） |
| 可选输入 | 需求分析文档、`knowledge/technical/`、`knowledge/business/`、`knowledge/constitution/adr/`、同包 `specs/`、AGENTS.md |
| 固定输出 | `system/requirements/REQUIREMENT-{ID}/MVP-{N}/ADD-{ID}-{N}.md`、基于 `spec-template.md` 的规约摘录文档（如 `system/requirements/REQUIREMENT-{ID}/MVP-{N}/specs/spec-{ID}-{N}-{service-name}.md`） |
| 不产出 | 测试设计、代码（使用下游 sdx-test / dev） |

## 参数

| 参数 | 必需 | 默认值 | 说明 |
|------|------|--------|------|
| `--id` | 否 | `{REQUIREMENT-ID}-MVP{N}` | ADD 文档编号 |
| `--doc-root` | 否 | `system` | 文档根目录 |
| `--prd` | 否 | — | 上游 PRD 编号，自动定位对应文件 |
| `--mvp` | 否 | `1` | 目标 MVP 阶段编号 |
| `--depth` | 否 | `standard` | 设计深度（quick / standard / deep），影响步骤 1–2 粒度 |

## 适用场景

| 场景 | 使用本技能 |
|------|-----------|
| 已有 PRD，需进行技术方案设计输出 ADD 与规约 | 是 |
| 需设计系统架构、接口协议、领域模型、数据架构 | 是 |
| 需生成规约摘录文档（Spec 汇总 Markdown） | 是 |
| 收到业务需求/工单，需先输出解决方案文档 | 否 → **sdx-solution** |
| 已有解决方案，需进行需求分析与 MVP 拆分 | 否 → **sdx-analysis** |
| 已有需求分析，需编写 PRD | 否 → **sdx-prd** |
| 已有 PRD 与 ADD，需测试设计 | 否 → **sdx-test** |

## 核心概念

- **架构设计**：系统/服务架构与调用关系、接口协议设计、领域模型与领域事件、数据架构与迁移方案、发布与回滚方案
- **详细设计**：应用架构（集成与容器）、API 详细设计（签名、参数、容错、幂等）、核心类图与状态机、业务逻辑伪代码/流程图、一致性设计（事务与并发）、数据访问设计（DDL、索引、分页、缓存）、非功能性设计（安全、可观测）
- **规约生成**：生成规约摘录 Markdown，总结本次变更范围内的 API/领域/数据变更，严格遵循 `.ai/skills/sdx-design/assets/spec-template.md`
- **ADD 文档**：遵循 [add-template.md](assets/add-template.md) 的五章结构（设计概述→架构设计→详细设计→需求规约→附录）

## 工作流（四步）

按顺序执行；每步算法、角色、`--depth` 与产出落位见 [reference/workflow-spec.md](reference/workflow-spec.md)。概念口径见 [reference/core-concepts.md](reference/core-concepts.md)。

1. **架构设计** — 系统/服务变更与交互、接口协议概要、领域模型、数据架构、发布与回滚；DD-n 与 Mermaid；对照 `knowledge/` 与 INDEX_GUIDE 中的架构索引。
2. **详细设计** — 应用架构、API 详设、业务逻辑与一致性、数据访问、非功能（安全、可观测）。
3. **规约生成** — 按服务写入 `specs/spec-{ID}-{N}-{service-name}.md` 。
4. **文档输出与评审** — 按 [assets/add-template.md](assets/add-template.md) 整合；按 [reference/quality-checklist.md](reference/quality-checklist.md) 自查。

可使用辅助脚本验证文档结构：

```bash
scripts/validate-design.sh --doc-root docs
```

## 核心约束

| 约束 | 说明 |
|------|------|
| 模板驱动 | 输出严格遵循 add-template.md 五章结构（设计概述→架构设计→详细设计→需求规约→附录） |
| 证据优先 | 架构决策与设计须引用 PRD、需求分析与 `knowledge/` 事实，禁止臆测 |
| 按需加载 | 仅在本轮需要时打开文件，禁止为完整性通读全仓 |
| 歧义标注 | 不确定项标为待澄清，禁止自行假设 |
| 范围清晰 | 仅产出 ADD 与规约摘录文档，不涉及测试设计 / 代码 |
| 可追溯 | API / 数据变更可追溯到产品需求与功能需求；规约摘录可追溯到技术设计 |
| MVP 聚焦 | 仅覆盖目标 MVP 范围内的功能需求，不超越 MVP 边界 |

设计原则完整版与反模式清单见 [reference/design-principles.md](reference/design-principles.md)。

## 依赖关系

| 类型 | 技能/组件 | 说明 |
|------|-----------|------|
| 上游（必需） | `sdx-prd` | 提供产品需求文档作为核心输入 |
| 上游（必需） | `sdx-analysis` | 提供需求分析文档与 MVP 上下文 |
| 上游（可选） | `knowledge-extract` | 提供 `knowledge/*/*_knowledge.json` 与 `knowledge/KNOWLEDGE_INDEX.md` 基线 |
| 下游 | `sdx-test` | 基于 PRD 与 ADD 进行测试设计 |

## 参考

| 资源 | 路径 |
|------|------|
| 四步工作流（算法、depth、数据流） | [reference/workflow-spec.md](reference/workflow-spec.md) |
| 核心概念口径 | [reference/core-concepts.md](reference/core-concepts.md) |
| 受众与文档语言 | [reference/audience-and-language.md](reference/audience-and-language.md) |
| 设计原则、反模式、错误处理 | [reference/design-principles.md](reference/design-principles.md) |
| 质量验收清单 | [reference/quality-checklist.md](reference/quality-checklist.md) |
| ADD 文档模板 | [assets/add-template.md](assets/add-template.md) |
| 规约摘录模板 | [assets/spec-template.md](assets/spec-template.md) |
| 常见陷阱与防错 | [gotchas.md](gotchas.md) |
| 文档结构校验脚本 | [scripts/validate-design.sh](scripts/validate-design.sh) |
| 上游：产品需求 | `.ai/skills/sdx-prd/SKILL.md` |
| 上游：需求分析 | `.ai/skills/sdx-analysis/SKILL.md` |
| 下游：测试设计 | `.ai/skills/sdx-test/SKILL.md` |
| 知识库 | `knowledge/technical/`、`knowledge/business/`、`knowledge/constitution/adr/` |
