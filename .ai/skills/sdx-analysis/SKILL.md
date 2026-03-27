---
name: sdx-analysis
description: >
  需求分析：基于解决方案文档与知识库进行深度研究、需求细化、MVP 拆分与依赖/风险评估，输出需求分析文档。
  在用户执行 /sdx-analysis、编写需求分析文档、或进行方案→需求分析时使用。输出至 docs/analysis/ANALYSIS-{ID}.md，模板见 .cursor/rules/analysis/analysis-template.md。
---

# 需求分析阶段（sdx-analysis）

基于解决方案文档和系统知识库进行深度研究与探索，将高层解决方案细化为具体、可执行的需求分析，合理拆分为多个 MVP 阶段，确保每个 MVP 具备独立交付价值。

## 输入与输出

**输入**：解决方案文档（`docs/solutions/`）、知识库（`knowledge/`）；已有规约见各 `requirements/.../specs/` 或 `knowledge/technical/`（按需）
**输出**：`docs/analysis/ANALYSIS-{ID}.md`（结构遵循 [analysis-template.md](../../rules/analysis/analysis-template.md)）

| 类型 | 内容 |
|------|------|
| 硬输入 | 解决方案文档（`docs/solutions/SOLUTION-{ID}.md`） |
| 可选输入 | `knowledge/`、`requirements/.../specs/`、`knowledge/technical/`、AGENTS.md |
| 固定输出 | `docs/analysis/ANALYSIS-{ID}.md` |
| 不产出 | PRD、ADD、测试设计、代码（使用下游 sdx-prd / sdx-design / sdx-test） |

## 参数

| 参数 | 必需 | 默认值 | 说明 |
|------|------|--------|------|
| `--id` | 否 | `YYYYMMDD-SEQ` | 需求分析文档编号 |
| `--doc-root` | 否 | `docs` | 文档根目录 |
| `--depth` | 否 | `standard` | 分析深度（quick / standard / deep），影响步骤 1–2 粒度 |
| `--solution` | 否 | — | 上游解决方案编号，自动定位对应文件 |

## 适用场景

| 场景 | 使用本技能 |
|------|-----------|
| 已有解决方案，需要进行需求分析与 MVP 拆分 | 是 |
| 需将高层方案细化为可度量的功能/非功能需求 | 是 |
| 收到业务需求/工单，需先输出解决方案文档 | 否 → **sdx-solution** |
| 已有需求分析，需要编写 PRD | 否 → **sdx-prd** |
| 已有 PRD，需技术方案设计 | 否 → **sdx-design** |

## 核心概念

- **深度研究**：从领域边界、核心规则、跨域交互、行业实践四个维度研究业务领域，探索可复用组件与技术债务
- **需求细化**：将解决方案中的高层描述分解为带优先级（P0–P3）的功能需求与非功能需求，提取业务规则与数据需求
- **MVP 拆分**：按独立业务价值、可独立部署、依赖单向原则将需求划分为多个 MVP 阶段
- **需求分析文档**：遵循 [analysis-template.md](../../rules/analysis/analysis-template.md) 的八章结构

## 工作流（五步）

按顺序执行，每步产出作为下一步输入；最终文档需通过质量门禁。详细算法与决策点见 [reference/workflow-spec.md](reference/workflow-spec.md)。

### 步骤 1：深度研究与探索

业务领域研究（领域边界、核心概念与规则、跨领域交互）；现有实现探索（可复用组件、技术债务）；行业实践参考；边界场景探索（高并发、一致性、幂等性等）。

### 步骤 2：需求细化与建模

功能需求细化（输入/处理/输出、优先级 P0–P3）；非功能需求明确（性能、可用性、安全、可观测性、兼容性）；业务规则提取；数据需求分析（实体、生命周期、一致性）。

### 步骤 3：MVP 拆分与规划

按独立业务价值、可独立部署、依赖单向原则拆分 MVP；为每个 MVP 定义范围、功能清单、验收标准与工作量；按业务价值、技术依赖与风险排序。

### 步骤 4：依赖分析与风险评估

分析 MVP 间功能/数据/接口及外部依赖；评估技术/业务/进度/质量风险；为高风险项制定应对与监控策略。

### 步骤 5：文档输出与评审

将步骤 1–4 的产出整合为需求分析文档，严格采用 [analysis-template.md](../../rules/analysis/analysis-template.md) 的章节与格式；执行质量门禁自查。

质量门禁清单见 [assets/quality-gate-checklist.md](assets/quality-gate-checklist.md)。

可使用辅助脚本验证文档结构：

```bash
scripts/validate-analysis.sh --doc-root docs
```

## 核心约束

| 约束 | 说明 |
|------|------|
| 模板驱动 | 输出严格遵循 analysis-template.md 八章结构 |
| 证据优先 | 需求分析须引用解决方案文档与 `knowledge/` 事实，禁止臆测 |
| 按需加载 | 仅在本轮需要时打开文件，禁止为完整性通读全仓 |
| 歧义标注 | 不确定项标为待澄清，禁止自行假设 |
| 范围清晰 | 仅产出需求分析文档，不涉及 PRD / ADD / 代码 |
| 可追溯 | 每个功能需求可追溯到解决方案中的业务目标，每个 MVP 可追溯到功能需求清单 |

设计原则完整版与反模式清单见 [reference/design-principles.md](reference/design-principles.md)。

## 依赖关系

| 类型 | 技能/组件 | 说明 |
|------|-----------|------|
| 上游（必需） | `sdx-solution` | 提供解决方案文档作为核心输入 |
| 上游（可选） | `knowledge-extract` | 提供 `knowledge/*/*_knowledge.json` 与 `knowledge/KNOWLEDGE_INDEX.md` 基线 |
| 下游 | `sdx-prd` | 基于需求分析转化为产品需求文档 |
| 下游 | `sdx-design` | 基于 PRD 进行技术方案设计 |
| 下游 | `sdx-test` | 基于 PRD 与 ADD 进行测试设计 |

## 参考

| 资源 | 路径 |
|------|------|
| 设计原则与反模式 | [reference/design-principles.md](reference/design-principles.md) |
| 五步工作流详细规范 | [reference/workflow-spec.md](reference/workflow-spec.md) |
| 质量门禁验收清单 | [assets/quality-gate-checklist.md](assets/quality-gate-checklist.md) |
| 文档结构校验脚本 | [scripts/validate-analysis.sh](scripts/validate-analysis.sh) |
| 需求分析文档模板 | [.cursor/rules/analysis/analysis-template.md](../../rules/analysis/analysis-template.md) |
| 上游：解决方案 | `.cursor/skills/sdx-solution/SKILL.md` |
| 下游：产品需求 | `.cursor/skills/sdx-prd/SKILL.md` |
| 下游：技术设计 | `.cursor/skills/sdx-design/SKILL.md` |
| 知识库 | `knowledge/`、`requirements/.../specs/`、`knowledge/technical/` |
