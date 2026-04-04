---
name: sdx-solution
description: >
  解决方案制定：从业务描述提取结构化诉求，评估影响面，识别并化解冲突，形成共识级解决方案文档。
  在用户执行 /sdx-solution、编写解决方案文档、或进行需求→方案分析时使用。
  输出至 system/solutions/SOLUTION-{IDEA-ID}.md（**IDEA-ID** 见 reference/core-concepts.md）；九章模板见 assets/solution-template.md；
  工作流与门禁见 reference/；常见陷阱见 gotchas.md。
---

# 解决方案阶段（sdx-solution）

从海量、模糊甚至矛盾的业务描述中提取结构化诉求，评估业务影响面，识别潜在冲突，确立业务目标与解决思路，输出**可供业务与产品评审、对齐共识**的解决方案文档。**主要读者为业务方与产品**；技术实现留给下游 **sdx-analysis** / **sdx-prd** / **sdx-design**，见 [reference/audience-and-language.md](reference/audience-and-language.md)。

**执行顺序建议**：先读本文件与 [gotchas.md](gotchas.md) → 步骤 1–5 按需打开 [reference/workflow-spec.md](reference/workflow-spec.md) → 口径对齐可打开 [reference/core-concepts.md](reference/core-concepts.md) → 输出前打开 [assets/solution-template.md](assets/solution-template.md) 与 [reference/quality-checklist.md](reference/quality-checklist.md)。

## 各层职责（按需加载）

| 层 | 路径 | 职责 |
|----|------|------|
| **SKILL** | 本文件 | 边界、参数、五步摘要、约束表、依赖与索引 |
| **gotchas** | [gotchas.md](gotchas.md) | 高频陷阱与正确做法 |
| **assets** | [assets/solution-template.md](assets/solution-template.md) | 交付物骨架（九章），写作时打开 |
| **reference** | [reference/workflow-spec.md](reference/workflow-spec.md) | 算法、Q-n 协议、`--depth` / `--skip-conflict`、步间数据流 |
| | [reference/core-concepts.md](reference/core-concepts.md) | **IDEA-ID** 定义、术语、编号、与下游分工 |
| | [reference/audience-and-language.md](reference/audience-and-language.md) | 受众与业务语言、转写规则 |
| | [reference/design-principles.md](reference/design-principles.md) | 完整原则、反模式、错误处理 |
| | [reference/quality-checklist.md](reference/quality-checklist.md) | 步骤 5 验收勾选 |
| **scripts** | [scripts/validate-solution.sh](scripts/validate-solution.sh) | 结构与前缀校验（可选） |

## 输入与输出

**输入**：业务需求描述（邮件、会议纪要、工单等原始来源）；内部对齐可按需查阅 `knowledge/`、`requirements/.../specs/`（**勿将技术细节原样写入正文**）

**输出**：
- **IDEA-ID**：需求链统一标识，完整定义见 [reference/core-concepts.md#idea-id](reference/core-concepts.md#idea-id)。
- 落盘：`system/solutions/SOLUTION-{IDEA-ID}.md`（类型前缀 **`SOLUTION`** + **IDEA-ID**）。

| 类型 | 内容 |
|------|------|
| 硬输入 | 业务需求描述（至少一种原始来源） |
| 可选输入 | `knowledge/`、`requirements/.../specs/`、`knowledge/technical/`、AGENTS.md |
| 固定输出 | `system/solutions/SOLUTION-{IDEA-ID}.md` |
| 不产出 | PRD、ADD、测试设计、代码（使用下游 sdx-analysis / sdx-prd / sdx-design） |

## 参数

| 参数 | 必需 | 默认值 | 说明 |
|------|------|--------|------|
| `--id` | 否 | `IDEA-ID` | 与 `SOLUTION-{IDEA-ID}.md` 中段一致；定义见 [reference/core-concepts.md#idea-id](reference/core-concepts.md#idea-id) |
| `--doc-root` | 否 | `system` | 文档根目录；校验脚本在 `${DOC_ROOT}/solutions` 下查找；旧布局可用 `docs` |
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

按顺序执行，每步产出作为下一步输入；最终文档需通过质量门禁。详细算法与决策点见 [reference/workflow-spec.md](reference/workflow-spec.md)。概念口径见 [reference/core-concepts.md](reference/core-concepts.md)。

1. **诉求提取与结构化** — 背景、目标、场景、角色、约束、排期；Q-n 与需求类型/优先级；**不在此步骤展开实现手段**。Q-n 交互格式见 workflow-spec。
2. **影响面评估与分析** — 业务能力与用户旅程、直接/间接、四维度（功能/数据/接口承诺/下游）；`--depth=quick` 时合并入步骤 4。
3. **冲突识别与化解** — 规则、流程、数据、协作与资源节奏；化解思路与成本/残余风险；`--skip-conflict` 时慎用（见 gotchas）。
4. **方案制定与评估** — G-n 可度量、思路与关键决策（含备选）、R-n、范围与 MVP 拆分建议。
5. **文档输出与评审** — 按 [assets/solution-template.md](assets/solution-template.md) 九章整合；语言审查；按 [reference/quality-checklist.md](reference/quality-checklist.md) 自查。

辅助校验（于**仓库根**执行，`--doc-root` 与产出目录一致即可）：

```bash
.ai/skills/sdx-solution/scripts/validate-solution.sh --doc-root system
```

## 核心约束

| 约束 | 说明 |
|------|------|
| 模板驱动 | 输出严格遵循 `assets/solution-template.md` 九章结构，无内容章节保留标题并标注「不适用」 |
| 业务可读 | 正文不出现具体技术术语；见 [reference/audience-and-language.md](reference/audience-and-language.md) |
| 证据优先 | 影响面与冲突分析可依据 `knowledge/` 或工程事实校准，禁止臆测；写入文档时转为业务表述 |
| 按需加载 | 仅在本轮需要时打开文件，禁止为完整性通读全仓 |
| 歧义标注 | 不确定项标为 Q-n，**逐一向用户提问确认**（每题 3–4 个选项 + 「其他」兜底），禁止自行假设 |
| 范围清晰 | 仅产出解决方案文档，不涉及 PRD、技术设计、代码 |
| 可追溯 | 每个 G-n 可追溯到原始需求；每个影响点可追溯到具体业务能力或协作环节 |

完整原则、反模式与错误处理见 [reference/design-principles.md](reference/design-principles.md)。

## 依赖关系

| 类型 | 技能/组件 | 说明 |
|------|-----------|------|
| 上游（可选） | `docs-build` | 提供 `knowledge/*/*_knowledge.json` 与 `knowledge/KNOWLEDGE_INDEX.md` 基线 |
| 下游 | `sdx-analysis` | 基于解决方案进行需求分析与 MVP 拆分 |
| 下游 | `sdx-prd` | 将需求分析转化为 PRD |
| 下游 | `sdx-design` | 基于 PRD 进行技术方案设计 |

## 参考

| 资源 | 路径 |
|------|------|
| 五步工作流（算法、depth、Q-n 协议、数据流） | [reference/workflow-spec.md](reference/workflow-spec.md) |
| 核心概念与下游分工 | [reference/core-concepts.md](reference/core-concepts.md) |
| 受众与文档语言 | [reference/audience-and-language.md](reference/audience-and-language.md) |
| 设计原则、反模式、错误处理 | [reference/design-principles.md](reference/design-principles.md) |
| 质量验收清单 | [reference/quality-checklist.md](reference/quality-checklist.md) |
| 解决方案文档模板 | [assets/solution-template.md](assets/solution-template.md) |
| 常见陷阱与防错 | [gotchas.md](gotchas.md) |
| 文档结构校验脚本 | [scripts/validate-solution.sh](scripts/validate-solution.sh) |
| 下游：需求分析 | `.ai/skills/sdx-analysis/SKILL.md` |
| 下游：产品需求 | `.ai/skills/sdx-prd/SKILL.md` |
| 下游：技术设计 | `.ai/skills/sdx-design/SKILL.md` |
