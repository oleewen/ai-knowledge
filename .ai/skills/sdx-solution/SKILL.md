---
name: sdx-solution
description: >
  解决方案制定：从业务描述提取结构化诉求，评估影响面，识别并化解冲突，形成共识级解决方案文档。
  在用户执行 /sdx-solution、编写解决方案文档、或进行需求→方案分析时使用。
  输出至 system/solutions/SOLUTION-{YYYYMMDD}-{SEQ}.md；九章结构，完整骨架见 assets/solution-template.md；
  正文使用业务语言，技术细节留给下游 sdx-analysis / sdx-design。
---

# 解决方案阶段（sdx-solution）

从海量、模糊甚至矛盾的业务描述中提取结构化诉求，评估业务影响面，识别潜在冲突，确立业务目标与解决思路，输出**可供业务与产品评审、对齐共识**的解决方案文档。

## 输入与输出

**输入**：业务需求描述（邮件、会议纪要、工单等原始来源）；内部对齐可按需查阅 `knowledge/`、`requirements/.../specs/`（**勿将技术细节原样写入正文**）  
**输出**：`system/solutions/SOLUTION-{YYYYMMDD}-{SEQ}.md`

| 类型 | 内容 |
|------|------|
| 硬输入 | 业务需求描述（至少一种原始来源） |
| 可选输入 | `knowledge/`、`requirements/.../specs/`、`knowledge/technical/`、AGENTS.md |
| 固定输出 | `system/solutions/SOLUTION-{YYYYMMDD}-{SEQ}.md` |
| 不产出 | PRD、ADD、测试设计、代码（使用下游 sdx-analysis / sdx-prd / sdx-design） |

## 参数

| 参数 | 必需 | 默认值 | 说明 |
|------|------|--------|------|
| `--id` | 否 | `YYYYMMDD-SEQ` | 解决方案文档编号 |
| `--doc-root` | 否 | `docs` | 文档根目录 |
| `--depth` | 否 | `standard` | 分析深度（quick / standard / deep），影响步骤 2–3 粒度 |
| `--skip-conflict` | 否 | `false` | 跳过冲突分析（仅当需求与现有规则/协作基本无交叉时） |

## 适用场景

| 场景 | 使用本技能 |
|------|-----------|
| 收到业务需求/工单，需输出解决方案文档 | 是 |
| 需求模糊或矛盾，需结构化提取与冲突分析 | 是 |
| 已有解决方案，需做需求分析或 PRD | 否 → **sdx-analysis** / **sdx-prd** |
| 已有 PRD，需技术方案设计 | 否 → **sdx-design** |

## 工作流（五步）

按顺序执行，每步产出作为下一步输入；最终文档需通过质量门禁。详细算法与决策点见 [reference/workflow-spec.md](reference/workflow-spec.md)。

### 步骤 1：诉求提取与结构化

从业务描述中萃取：背景与动机、目标与期望价值、核心场景、用户角色、关键约束、时间与优先级。标注歧义与待澄清项（Q-n），区分新增/变更/修复类诉求；**不在此步骤展开实现手段**。

提取完 Q-n 列表后，**逐一向用户提问**，每题提供 3–4 个具体选项（含「其他，请说明」兜底），等待用户确认后再继续。交互格式与处理规则见 [reference/workflow-spec.md](reference/workflow-spec.md)。

### 步骤 2：影响面评估与分析

列出受影响的业务能力或用户旅程及影响程度（高/中/低），用业务流程或协作链说明「谁、在什么环节、如何被影响」。可内部参照知识库校准范围，**写入文档时避免罗列系统或模块名称**。`--depth=quick` 时合并入步骤 4。

### 步骤 3：冲突识别与化解

识别与现有规则、进行中事项、上下游协作、数据口径或资源节奏相关的冲突；对每项给出化解思路及对业务节奏、成本或风险的影响。`--skip-conflict` 时跳过（仅适用于全新场景）。

### 步骤 4：方案制定与评估

明确可度量的业务目标（G-n）；阐述整体思路、关键决策与备选对比；评估落地条件（时间、人力、协作依赖）与风险（R-n）；界定范围边界与 MVP 拆分建议。

### 步骤 5：文档输出与评审

将步骤 1–4 产出整合为解决方案文档，严格采用 [assets/solution-template.md](assets/solution-template.md) 的九章结构；通读全文去除技术术语；执行质量门禁自查。

质量门禁清单见 [assets/quality-gate-checklist.md](assets/quality-gate-checklist.md)。

可使用辅助脚本验证文档结构（于**仓库根目录**执行）：

```bash
.ai/skills/sdx-solution/scripts/validate-solution.sh --doc-root docs
```

## 核心约束

| 约束 | 说明 |
|------|------|
| 模板驱动 | 输出严格遵循 `assets/solution-template.md` 九章结构，无内容章节保留标题并标注「不适用」 |
| 业务可读 | 正文不出现具体技术术语；受众与语言规范见 [reference/audience-language-spec.md](reference/audience-language-spec.md) |
| 证据优先 | 影响面与冲突分析可依据 `knowledge/` 或工程事实校准，禁止臆测；写入文档时转为业务表述 |
| 按需加载 | 仅在本轮需要时打开文件，禁止为完整性通读全仓 |
| 歧义标注 | 不确定项标为 Q-n，**逐一向用户提问确认**（每题 3–4 个选项 + 「其他」兜底），禁止自行假设 |
| 范围清晰 | 仅产出解决方案文档，不涉及 PRD、技术设计、代码 |
| 可追溯 | 每个 G-n 可追溯到原始需求；每个影响点可追溯到具体业务能力或协作环节 |

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
| 受众与文档语言规范 | [reference/audience-language-spec.md](reference/audience-language-spec.md) |
| 设计原则与反模式 | [reference/design-principles.md](reference/design-principles.md) |
| 五步工作流详细规范 | [reference/workflow-spec.md](reference/workflow-spec.md) |
| 质量门禁验收清单 | [assets/quality-gate-checklist.md](assets/quality-gate-checklist.md) |
| 解决方案文档模板 | [assets/solution-template.md](assets/solution-template.md) |
| 文档结构校验脚本 | [scripts/validate-solution.sh](scripts/validate-solution.sh) |
| 下游：需求分析 | `.ai/skills/sdx-analysis/SKILL.md` |
| 下游：产品需求 | `.ai/skills/sdx-prd/SKILL.md` |
| 下游：技术设计 | `.ai/skills/sdx-design/SKILL.md` |
