---
name: sdx-solution
description: >
  解决方案制定：从业务想法或需求描述提取结构化诉求，评估影响面，识别并化解冲突，形成共识级解决方案文档。
  当用户执行 /sdx-solution、需要编写解决方案文档、收到业务需求需要结构化分析、
  需求模糊或矛盾需要冲突识别、或需要制定 MVP 拆分建议时，务必使用本技能。
  即使用户只说"帮我写个方案"、"分析一下这个需求"、"整理一下业务目标"，也应触发本技能。
  输出至 system/solutions/SOLUTION-{IDEA-ID}.md。
---

# 解决方案阶段（sdx-solution）

从海量、模糊甚至矛盾的业务描述中提取结构化诉求，评估业务影响面，识别潜在冲突，确立业务目标与解决思路，输出**可供业务与产品评审、对齐共识**的解决方案文档。

主要读者为**业务方与产品**；技术实现留给下游 sdx-analysis / sdx-prd / sdx-design。

## 输入与输出

| 类型 | 内容 |
|------|------|
| 硬输入 | 业务需求描述（至少一种原始来源：邮件/会议纪要/工单等） |
| 可选输入 | `knowledge/`、`requirements/.../specs/`、AGENTS.md（内部分析用，写入文档时转为业务表述） |
| 固定输出 | `system/solutions/SOLUTION-{IDEA-ID}.md` |
| 不产出 | PRD、ADD、测试设计、代码（使用下游 sdx-analysis / sdx-prd / sdx-design） |

## 参数

| 参数 | 必需 | 默认值 | 说明 |
|------|------|--------|------|
| `--id` | 否 | `IDEA-ID` | 与文件名中段一致；定义见 [reference/core-concepts.md](reference/core-concepts.md) |
| `--doc-root` | 否 | `system` | 文档根目录 |
| `--depth` | 否 | `standard` | 分析深度（quick / standard / deep），影响步骤 2–3 粒度 |
| `--skip-conflict` | 否 | `false` | 跳过冲突分析（仅全新场景且确认无已有逻辑时合法） |

## 适用场景

| 场景 | 使用本技能 |
|------|-----------|
| 收到业务需求/工单，需输出解决方案文档 | 是 |
| 需求模糊或矛盾，需结构化提取与冲突分析 | 是 |
| 已有解决方案，需做需求分析或 PRD | 否 → sdx-analysis / sdx-prd |
| 已有 PRD，需技术方案设计 | 否 → sdx-design |

## 工作流（五步）

按顺序执行，每步产出作为下一步输入；最终文档需通过质量门禁。

1. **诉求提取与结构化** — 背景、目标（G-n）、场景、角色、约束、排期；歧义标注为 Q-n 逐一向用户确认（每题 3–4 个选项）；**不在此步骤展开实现手段**
2. **影响面评估与分析** — 覆盖功能/数据/接口承诺/下游四维度；`--depth=quick` 时合并入步骤 4
3. **冲突识别与化解** — 业务冲突（C-n）与系统冲突（C-Tn）；每项含化解成本与残余风险；`--skip-conflict` 慎用（见 gotchas）
4. **方案制定与评估** — G-n 可度量化、解决思路、关键决策（含备选）、R-n、范围界定、MVP 拆分建议
5. **文档输出与评审** — 按 [assets/solution-template.md](assets/solution-template.md) 九章整合；语言审查（技术词转业务表述）；按 [reference/quality-checklist.md](reference/quality-checklist.md) 自查

详细算法、Q-n 交互协议、`--depth` / `--skip-conflict` 规则、步间数据流见 [reference/workflow-spec.md](reference/workflow-spec.md)。

辅助校验：

```bash
.ai/skills/sdx-solution/scripts/validate-solution.sh --doc-root system
```

## 核心约束

| 约束 | 说明 |
|------|------|
| 模板驱动 | 输出严格遵循 solution-template.md 九章结构；无内容章节保留标题并标注「不适用」 |
| 业务可读 | 正文不出现具体技术术语；见 [reference/audience-and-language.md](reference/audience-and-language.md) |
| 证据优先 | 影响面与冲突分析可依据 `knowledge/` 校准，禁止臆测；写入文档时转为业务表述 |
| 按需加载 | 仅在本轮需要时打开文件，禁止为完整性通读全仓 |
| 歧义标注 | 不确定项标为 Q-n，逐一向用户提问确认（每题 3–4 个选项 + 「其他」兜底），禁止自行假设 |
| 范围清晰 | 仅产出解决方案文档，不涉及 PRD、技术设计、代码 |
| 可追溯 | 每个 G-n 可追溯到原始需求；每个影响点可追溯到具体业务能力或协作环节 |

完整原则、反模式与错误处理见 [reference/design-principles.md](reference/design-principles.md)。

## 依赖关系

| 类型 | 技能/组件 | 说明 |
|------|-----------|------|
| 上游（可选） | `docs-build` | 提供 `knowledge/` 基线 |
| 下游 | `sdx-analysis` | 基于解决方案进行需求分析与 MVP 拆分 |
| 下游 | `sdx-prd` | 将需求分析转化为 PRD |
| 下游 | `sdx-design` | 基于 PRD 进行技术方案设计 |

## 参考

| 资源 | 路径 | 何时读 |
|------|------|--------|
| 五步工作流（算法、Q-n 协议、depth、数据流） | [reference/workflow-spec.md](reference/workflow-spec.md) | 步骤执行时，规则不确定时 |
| 核心概念与 IDEA-ID 定义 | [reference/core-concepts.md](reference/core-concepts.md) | 口径对齐、编号规则不确定时 |
| 受众与文档语言 | [reference/audience-and-language.md](reference/audience-and-language.md) | 步骤 5 语言审查时 |
| 设计原则、反模式、错误处理 | [reference/design-principles.md](reference/design-principles.md) | 遇到边界判断、错误场景时 |
| 质量验收清单 | [reference/quality-checklist.md](reference/quality-checklist.md) | 步骤 5 自查时 |
| 解决方案文档模板 | [assets/solution-template.md](assets/solution-template.md) | 步骤 5 生成文档时 |
| 常见陷阱与防错 | [gotchas.md](gotchas.md) | 遇到歧义处理、冲突分析、语言审查相关问题时 |
| 文档结构校验脚本 | [scripts/validate-solution.sh](scripts/validate-solution.sh) | 步骤 5 自动验证时 |
