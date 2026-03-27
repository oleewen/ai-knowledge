---
name: sdx-solution
description: >
  解决方案制定：从业务描述提取结构化需求，评估影响面，识别并化解冲突，制定解决方案并输出解决方案文档。
  在用户执行 /sdx-solution、编写解决方案文档、或进行需求→方案分析时使用。输出至 docs/solutions/SOLUTION-{ID}.md，模板见 .cursor/rules/solution/solution-template.md。
---

# 解决方案阶段（sdx-solution）

从海量、模糊甚至矛盾的业务描述中提取结构化需求，结合现存系统状态，评估业务影响面，识别潜在冲突，确立业务目标和解决思路，输出高质量的解决方案文档。

## 输入与输出

**输入**：业务需求描述（邮件、会议纪要、工单等）、`knowledge/`；已有规约见各 `requirements/.../specs/` 或 `knowledge/technical/`（按需）
**输出**：`docs/solutions/SOLUTION-{ID}.md`（结构遵循 [solution-template.md](../../rules/solution/solution-template.md)）

| 类型 | 内容 |
|------|------|
| 硬输入 | 业务需求描述（至少一种原始来源） |
| 可选输入 | `knowledge/`、`requirements/.../specs/`、`knowledge/technical/`、AGENTS.md |
| 固定输出 | `docs/solutions/SOLUTION-{ID}.md` |
| 不产出 | PRD、ADD、测试设计、代码（使用下游 sdx-analysis / sdx-prd / sdx-design） |

## 参数

| 参数 | 必需 | 默认值 | 说明 |
|------|------|--------|------|
| `--id` | 否 | `YYYYMMDD-SEQ` | 解决方案文档编号 |
| `--doc-root` | 否 | `docs` | 文档根目录 |
| `--depth` | 否 | `standard` | 分析深度（quick / standard / deep），影响步骤 2–3 粒度 |
| `--skip-conflict` | 否 | `false` | 跳过冲突分析（仅新增场景、无已有系统冲突时） |

## 适用场景

| 场景 | 使用本技能 |
|------|-----------|
| 收到业务需求/工单，需输出解决方案文档 | 是 |
| 需求模糊或矛盾，需结构化提取与冲突分析 | 是 |
| 已有解决方案，需做需求分析或 PRD | 否 → **sdx-analysis** / **sdx-prd** |
| 已有 PRD，需技术方案设计 | 否 → **sdx-design** |

## 核心概念

- **结构化需求提取**：从非结构化描述中萃取业务背景、目标、场景、角色、约束、优先级
- **影响面评估**：列出受影响功能并标注影响传播路径（直接 → 间接）
- **冲突化解**：识别业务冲突（规则/流程/数据）与系统冲突（模型/接口/资源），给出化解方案
- **解决方案文档**：遵循 [solution-template.md](../../rules/solution/solution-template.md) 的九章结构

## 工作流（五步）

按顺序执行，每步产出作为下一步输入；最终文档需通过质量门禁。详细算法与决策点见 [reference/workflow-spec.md](reference/workflow-spec.md)。

### 步骤 1：需求提取与结构化

从业务描述中萃取：业务背景与动机、目标与期望价值、核心场景、用户角色、关键约束、时间与优先级。标注歧义与待澄清项，区分功能/非功能、新增/变更/修复、业务/技术需求。

### 步骤 2：影响面评估与分析

列出受影响功能及影响程度（高/中/低），标注影响传播路径（直接→间接），参照 `knowledge/` 与现有架构文档。`--depth=quick` 时可合并入步骤 4。

### 步骤 3：冲突识别与化解

识别业务冲突（与现有规则、进行中需求、上下游流程）与系统冲突（模型、契约、资源竞争）；对每项冲突给出化解方案及成本/风险评估。`--skip-conflict` 时跳过。

### 步骤 4：方案制定与评估

明确可度量业务目标与价值；阐述整体解决思路、关键决策与备选对比；评估技术/资源可行性及风险；界定范围边界与 MVP-Phase 拆分建议。

### 步骤 5：文档输出与评审

将步骤 1–4 的产出整合为解决方案文档，严格采用 [solution-template.md](../../rules/solution/solution-template.md) 的章节与格式；执行质量门禁自查。

质量门禁清单见 [assets/quality-gate-checklist.md](assets/quality-gate-checklist.md)。

可使用辅助脚本验证文档结构：

```bash
scripts/validate-solution.sh --doc-root docs
```

## 核心约束

| 约束 | 说明 |
|------|------|
| 模板驱动 | 输出严格遵循 solution-template.md 九章结构 |
| 证据优先 | 影响面与冲突分析须引用 `knowledge/` 或工程事实，禁止臆测 |
| 按需加载 | 仅在本轮需要时打开文件，禁止为完整性通读全仓 |
| 歧义标注 | 不确定项标为待澄清，禁止自行假设 |
| 范围清晰 | 仅产出解决方案文档，不涉及 PRD / ADD / 代码 |
| 可追溯 | 每个业务目标可追溯到原始需求，每个影响点可追溯到具体服务/模块 |

设计原则完整版与反模式清单见 [reference/design-principles.md](reference/design-principles.md)。

## 依赖关系

| 类型 | 技能/组件 | 说明 |
|------|-----------|------|
| 上游（可选） | `knowledge-extract` | 提供 `knowledge/*/*_knowledge.json` 与 `knowledge/KNOWLEDGE_INDEX.md` 基线 |
| 下游 | `sdx-analysis` | 基于解决方案进行需求分析与 MVP 拆分 |
| 下游 | `sdx-prd` | 将需求分析转化为 PRD |
| 下游 | `sdx-design` | 基于 PRD 进行技术方案设计 |

## 参考

| 资源 | 路径 |
|------|------|
| 设计原则与反模式 | [reference/design-principles.md](reference/design-principles.md) |
| 五步工作流详细规范 | [reference/workflow-spec.md](reference/workflow-spec.md) |
| 质量门禁验收清单 | [assets/quality-gate-checklist.md](assets/quality-gate-checklist.md) |
| 文档结构校验脚本 | [scripts/validate-solution.sh](scripts/validate-solution.sh) |
| 解决方案文档模板 | [.cursor/rules/solution/solution-template.md](../../rules/solution/solution-template.md) |
| 下游：需求分析 | `.cursor/skills/sdx-analysis/SKILL.md` |
| 下游：产品需求 | `.cursor/skills/sdx-prd/SKILL.md` |
| 下游：技术设计 | `.cursor/skills/sdx-design/SKILL.md` |
| 知识库 | `knowledge/`、`requirements/.../specs/`、`knowledge/technical/` |
