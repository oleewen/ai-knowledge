---
name: sdx-design
description: >
  技术方案设计：基于产品需求与架构/领域文档进行技术方案设计，输出 ADD 与规约文件。
  在用户执行 /sdx-design、编写 ADD 与规约时使用。产出 system/requirements/REQUIREMENT-{ID}/MVP-{N}/ADD-{ID}-{N}.md，模板见 .ai/skills/sdx-design/assets/add-template.md。
---

# 方案设计阶段（sdx-design）

基于产品需求文档，结合系统架构与领域模型，进行技术方案设计，输出架构设计文档（ADD）和规约文件（Spec），为后续测试设计与开发阶段提供技术蓝图。

## 输入与输出

**输入**：产品需求（`system/requirements/REQUIREMENT-{ID}/MVP-{N}/PRD-{ID}-{N}.md`）、需求分析当前 MVP 章节（`system/analysis/ANALYSIS-{ID}.md`）、系统架构与 ADR（`knowledge/technical/`、`knowledge/constitution/adr/`）、领域模型（`knowledge/business/`）
**输出**：ADD `system/requirements/REQUIREMENT-{ID}/MVP-{N}/ADD-{ID}-{N}.md`、规约 `.../specs/`

| 类型 | 内容 |
|------|------|
| 硬输入 | 产品需求文档（`system/requirements/REQUIREMENT-{ID}/MVP-{N}/PRD-{ID}-{N}.md`） |
| 可选输入 | 需求分析文档、`knowledge/technical/`、`knowledge/business/`、`knowledge/constitution/adr/`、同包 `specs/`、AGENTS.md |
| 固定输出 | `system/requirements/REQUIREMENT-{ID}/MVP-{N}/ADD-{ID}-{N}.md`、`system/requirements/REQUIREMENT-{ID}/MVP-{N}/specs/{service-name}/` |
| 不产出 | 测试设计、代码（使用下游 sdx-test / dev） |

## 参数

| 参数 | 必需 | 默认值 | 说明 |
|------|------|--------|------|
| `--id` | 否 | `{REQUIREMENT-ID}-MVP{N}` | ADD 文档编号 |
| `--doc-root` | 否 | `system` | 文档根目录；校验脚本在 `${DOC_ROOT}/requirements` 下查找 ADD；旧布局可用 `docs` |
| `--prd` | 否 | — | 上游 PRD 编号，自动定位对应文件 |
| `--mvp` | 否 | `1` | 目标 MVP 阶段编号 |
| `--depth` | 否 | `standard` | 设计深度（quick / standard / deep），影响步骤 1–2 粒度 |

## 适用场景

| 场景 | 使用本技能 |
|------|-----------|
| 已有 PRD，需进行技术方案设计输出 ADD 与规约 | 是 |
| 需设计系统架构、接口协议、领域模型、数据架构 | 是 |
| 需生成 API / 领域 / 数据 / 集成规约（YAML） | 是 |
| 收到业务需求/工单，需先输出解决方案文档 | 否 → **sdx-solution** |
| 已有解决方案，需进行需求分析与 MVP 拆分 | 否 → **sdx-analysis** |
| 已有需求分析，需编写 PRD | 否 → **sdx-prd** |
| 已有 PRD 与 ADD，需测试设计 | 否 → **sdx-test** |

## 核心概念

- **架构设计**：系统/服务架构与调用关系、接口协议设计、领域模型与领域事件、数据架构与迁移方案、发布与回滚方案
- **详细设计**：应用架构（集成与容器）、API 详细设计（签名、参数、容错、幂等）、核心类图与状态机、业务逻辑伪代码/流程图、一致性设计（事务与并发）、数据访问设计（DDL、索引、分页、缓存）、非功能性设计（安全、可观测）
- **规约生成**：按服务生成 API / 领域 / 数据 / 集成规约（YAML），路径规范 `system/requirements/REQUIREMENT-{ID}/MVP-{N}/specs/{service-name}/`
- **ADD 文档**：遵循 [.ai/skills/sdx-design/assets/add-template.md](assets/add-template.md) 的五章结构（设计概述→架构设计→详细设计→需求规约→附录）

## 工作流（四步）

按顺序执行，每步产出作为下一步输入；最终文档需通过质量门禁。详细算法与决策点见 [.ai/skills/sdx-design/reference/workflow-spec.md](reference/workflow-spec.md)。

### 步骤 1：架构设计

从 PRD 的业务流程与功能模块出发，设计系统架构（服务变更与交互）、接口协议、领域模型（聚合/实体/值对象/领域事件）、数据架构（ER 图、分片、迁移）、发布与回滚方案；使用 Mermaid 可视化；记录关键设计决策（DD-n）。

### 步骤 2：详细设计

应用架构（集成与容器关系）；API 详细设计（签名、参数、响应、错误码、幂等性）；核心类图（DDD 分层）与状态机；业务逻辑流程图与伪代码；一致性设计（锁、事务）；数据访问设计（DDL、索引、分页、缓存）；非功能性设计（安全、可观测）。

### 步骤 3：规约生成

按服务生成 YAML 规约文件：API 规约（`specs/{service}/api/`）、领域规约（`specs/{service}/domain/`）、数据规约（`specs/{service}/data/`）、集成规约（`specs/{service}/integration/`）。每个规约须可追溯到 ADD 中的设计条目。

### 步骤 4：文档输出与评审

将步骤 1–3 的产出整合为 ADD 文档，严格采用 [.ai/skills/sdx-design/assets/add-template.md](assets/add-template.md) 的章节与格式；执行质量门禁自查。

质量门禁清单见 [.ai/skills/sdx-design/assets/quality-gate-checklist.md](assets/quality-gate-checklist.md)。

可使用辅助脚本验证文档结构：

```bash
# 于仓库根目录执行；默认 doc-root 为 system
.ai/skills/sdx-design/scripts/validate-design.sh
```

## 核心约束

| 约束 | 说明 |
|------|------|
| 模板驱动 | 输出严格遵循 add-template.md 五章结构（设计概述→架构设计→详细设计→需求规约→附录） |
| 证据优先 | 架构决策与设计须引用 PRD、需求分析与 `knowledge/` 事实，禁止臆测 |
| 按需加载 | 仅在本轮需要时打开文件，禁止为完整性通读全仓 |
| 歧义标注 | 不确定项标为待澄清，禁止自行假设 |
| 范围清晰 | 仅产出 ADD 与规约文件，不涉及测试设计 / 代码 |
| 可追溯 | API / 数据变更可追溯到产品需求与功能需求；规约可追溯到技术设计 |
| MVP 聚焦 | 仅覆盖目标 MVP 范围内的功能需求，不超越 MVP 边界 |

设计原则完整版与反模式清单见 [.ai/skills/sdx-design/reference/design-principles.md](reference/design-principles.md)。

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
| 设计原则与反模式 | [.ai/skills/sdx-design/reference/design-principles.md](reference/design-principles.md) |
| 四步工作流详细规范 | [.ai/skills/sdx-design/reference/workflow-spec.md](reference/workflow-spec.md) |
| 质量门禁验收清单 | [.ai/skills/sdx-design/assets/quality-gate-checklist.md](assets/quality-gate-checklist.md) |
| 文档结构校验脚本 | [.ai/skills/sdx-design/scripts/validate-design.sh](scripts/validate-design.sh) |
| ADD 文档模板 | [.ai/skills/sdx-design/assets/add-template.md](assets/add-template.md) |
| 上游：产品需求 | `.ai/skills/sdx-prd/SKILL.md` |
| 上游：需求分析 | `.ai/skills/sdx-analysis/SKILL.md` |
| 下游：测试设计 | `.ai/skills/sdx-test/SKILL.md` |
| 知识库 | `knowledge/technical/`、`knowledge/business/`、`knowledge/constitution/adr/` |
