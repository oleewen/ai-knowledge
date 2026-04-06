---
name: sdx-solution
description: >
  解决方案制定：从业务想法或需求描述提取结构化诉求，评估影响面，识别并化解冲突，形成共识级解决方案文档。
  当用户执行 /sdx-solution、需要编写解决方案文档、收到业务需求需要结构化分析、
  需求模糊或矛盾需要冲突识别、或需要制定 MVP 与里程碑时，务必使用本技能。
  即使用户只说"帮我写个方案"、"分析一下这个需求"、"整理一下业务目标"，也应触发本技能。
  输出至系统知识库根目录 system/solutions/SOLUTION-{IDEA-ID}.md。
---

# 解决方案阶段（sdx-solution）

**术语**：**系统知识库根目录**指路径前缀 `system/`（与 `--doc-root` 默认一致时）。

从海量、模糊甚至矛盾的业务描述中提取结构化诉求，评估业务影响面，识别冲突，确立目标与解决思路，输出**可供业务与产品评审、对齐共识**的解决方案文档。文档骨架以 [assets/solution-template.md](assets/solution-template.md) 为准：**七章**（背景与目标 → 范围与约束 → 影响与冲突 → 思路与方案 → 风险与待定 → 交付计划 → 附录）；**§3.4** 统一承载业务冲突（C-n，含以业务后果表述的协作/契约影响）；**§5.2** 为待澄清问题（Q-n）；文末 **文档元数据** 为 fenced `yaml`（含 `author`、`parent`、`dependencies`、`tags` 等）。

主要读者为**业务方与产品**；技术实现留给下游 sdx-analysis / sdx-prd / sdx-design。

## 输入与输出

| 类型 | 内容 |
|------|------|
| 硬输入 | 业务需求描述（至少一种原始来源：邮件/会议纪要/工单等） |
| 可选输入 | `knowledge/`、`requirements/.../specs/`、AGENTS.md（内部分析用，写入文档时转为业务表述） |
| 固定输出 | 系统知识库根目录下 `system/solutions/SOLUTION-{IDEA-ID}.md` |
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

1. **诉求提取与结构化** — §1（1.1 现状 → 1.2 问题 → 1.3 业务目标 **G-n** → 1.4 业务价值）、§2（场景、角色、范围边界、成功标准、关键约束）；交互澄清 **Q-n**，确认摘要最终落入 **§5.2**；**不在此步骤展开实现手段**
2. **影响面评估与分析** — §3.1 叙述性影响面、§3.2 影响业务能力表、§3.3 传播路径；覆盖功能/数据/对外承诺/下游四维度；`--depth=quick` 时合并入步骤 4
3. **冲突识别与化解** — §3.4 业务冲突表（C-n）；模型/接口/资源类冲突以**业务后果**写入同一表，避免纯技术栈表述；`--skip-conflict` 慎用（见 gotchas）
4. **方案制定与评估** — §4.1–§4.3（思路、方案对比、关键决策）、§5.1 风险（R-n）、§6.1 MVP、§6.2 里程碑
5. **文档输出与评审** — 按模板七章整合 **§7** 附录（含 **§7.4 质量自查表**）；语言审查（技术词转业务表述或落入 §7.3）；对照模板 §7.4 与 [reference/quality-checklist.md](reference/quality-checklist.md) **逐项**自查；**凡已满足通过标准的条目**，在写入 `SOLUTION-*.md` 时须将该项由 `- [ ]` 改为 `- [x]`，未满足的保持 `- [ ]` 并先修复或说明，不得虚假勾选

详细算法、Q-n 交互协议、`--depth` / `--skip-conflict` 规则、步间数据流见 [reference/workflow-spec.md](reference/workflow-spec.md)。

辅助校验：

```bash
.ai/skills/sdx-solution/scripts/validate-solution.sh --doc-root system
```

## 核心约束

| 约束 | 说明 |
|------|------|
| 模板驱动 | 输出严格遵循 solution-template.md **七章**及模板内 `###`/`####` 小节标题；无内容小节保留标题并标注「不适用」或「待补充」 |
| 业务可读 | 正文不出现具体技术术语；见 [reference/audience-and-language.md](reference/audience-and-language.md) |
| 证据优先 | 影响面与冲突分析可依据 `knowledge/` 校准，禁止臆测；写入文档时转为业务表述 |
| 按需加载 | 仅在本轮需要时打开文件，禁止为完整性通读全仓 |
| 歧义标注 | 不确定项标为 Q-n，逐一向用户提问确认（每题 3–4 个选项 + 「其他」兜底），禁止自行假设；定稿写入 **§5.2** |
| 范围清晰 | 仅产出解决方案文档，不涉及 PRD、技术设计、代码 |
| 可追溯 | 每个 G-n 可追溯到原始需求；每个影响点与 C-n 可追溯到业务能力或协作环节 |
| 自查勾选 | 质量门禁通过后，交付物 **§7.4** 中已通过项须为 `- [x]`；未通过项保持 `- [ ]` 直至修复（禁止未达标而全选） |

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
