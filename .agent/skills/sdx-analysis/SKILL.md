---
name: sdx-analysis
description: >
  需求分析：基于解决方案文档与知识库进行深度研究、需求细化、MVP 拆分与依赖/风险评估，输出需求分析文档。
  当用户执行 /sdx-analysis、需要编写需求分析文档、将解决方案细化为可排期的功能需求、
  做 MVP 拆分规划、或需要识别需求依赖与风险时，务必使用本技能。
  即使用户只说"帮我分析一下需求"、"拆一下 MVP"、"细化一下方案"，也应触发本技能。
  输出至系统知识库根目录 application/analysis/ANALYSIS-{IDEA-ID}.md。
---

# 需求分析阶段（sdx-analysis）

**术语**：**系统知识库根目录**指路径前缀 `application/`（与 `--doc-root` 默认一致时）。

在解决方案与事实材料基础上，将共识级方案细化为**可评审、可排期、可验收**的需求分析：划清范围、拆 MVP、标优先级与依赖，并识别风险。产出结构以 [assets/analysis-template.md](assets/analysis-template.md) 为准：**六章**（**§1 背景目标** → 功能需求「含 FR 节内规则与业务对象」→ 非功能需求 → 交付计划 → 依赖与风险 → 附录含 **§6.4 质量自查**）。

主要读者为**产品经理与需求分析师**（业务方参与范围与验收对齐）；研发以本阶段产出为输入编写 PRD/技术方案。

## 输入与输出

| 类型 | 内容 |
|------|------|
| 硬输入 | 解决方案文档（系统知识库根目录 `application/solutions/SOLUTION-{IDEA-ID}.md`） |
| 可选输入 | `knowledge/`、`requirements/.../specs/`、AGENTS.md（内部分析用，写入时转为需求/业务表述） |
| 固定输出 | 系统知识库根目录下 `application/analysis/ANALYSIS-{IDEA-ID}.md` |
| 不产出 | PRD、ADD、测试设计、代码（使用下游 sdx-prd / sdx-design / sdx-test） |

## 参数

| 参数 | 必需 | 默认值 | 说明 |
|------|------|--------|------|
| `--id` | 否 | `IDEA-ID` | 与上游 `SOLUTION-{IDEA-ID}.md`、下游 `REQUIREMENT-{IDEA-ID}/` 同链对齐 |
| `--doc-root` | 否 | `system` | 文档根目录 |
| `--depth` | 否 | `standard` | 分析深度（quick / standard / deep），影响步骤 1–2 粒度 |
| `--solution` | 否 | — | 上游解决方案编号，自动定位对应文件 |

## 适用场景

| 场景 | 使用本技能 |
|------|-----------|
| 已有解决方案，需要进行需求分析与 MVP 拆分 | 是 |
| 需将高层方案细化为可度量的功能与非功能诉求 | 是 |
| 收到业务需求/工单，需先输出解决方案文档 | 否 → sdx-solution |
| 已有需求分析，需要编写 PRD | 否 → sdx-prd |
| 已有 PRD，需技术方案设计 | 否 → sdx-design |

## 工作流（五步）

按顺序执行；每步算法、depth 差异与 Q-n 处理见 [reference/workflow-spec.md](reference/workflow-spec.md)。

1. **深度研究与探索** — §1.3「研究与分析」及范围/假设；领域边界、核心规则、跨域协作；按影响面按需读库，禁止通读全仓
2. **需求细化与建模** — §2 按 **FR-n** 分节（描述、规则 BR、业务对象、验收）；§3 非功能；歧义标 Q-n 并交互确认，结果融入 §1.3 / 各 FR，**不再单独设「业务规则」「数据需求」章**
3. **MVP 拆分与规划** — §4.1–§4.3（总览、分 MVP 详述、依赖图）
4. **依赖分析与风险评估** — §5.1 依赖表、§5.2 风险 R-n
5. **文档输出与评审** — 严格套 [assets/analysis-template.md](assets/analysis-template.md)；§6 附录（含 §6.4 质量自查）；语言审查；按 [reference/quality-checklist.md](reference/quality-checklist.md) **逐项**自查；**凡已满足通过标准的条目**，在写入 `ANALYSIS-*.md` 时须将该项由 `- [ ]` 改为 `- [x]`，未满足的保持 `- [ ]` 并先修复或说明，不得虚假勾选

辅助校验：

```bash
.agent/skills/sdx-analysis/scripts/validate-analysis.sh --doc-root system
```

## 核心约束

| 约束 | 说明 |
|------|------|
| 模板驱动 | 输出严格遵循 `analysis-template.md` **六章**及模板内小节标题；无内容章节保留标题并标注「不适用」 |
| 受众可读 | 正文以产品/需求语言为主；工程线索集中 **§6.3 变更历史**（须标注「待研发确认」）；细则见 [reference/audience-and-language.md](reference/audience-and-language.md) |
| 证据优先 | 须引用解决方案与 `knowledge/` 等校准，禁止臆测；写入时转为需求/业务表述 |
| 按需加载 | 仅在本轮需要时打开文件，禁止为完整性通读全仓 |
| 歧义标注 | 不确定项标 Q-n，逐一向用户提问确认（每题 3–4 个选项 + 「其他」）；澄清结果写入 §1.3 或对应 **FR-n**，模板无单独 Q 表 |
| 范围清晰 | 仅产出需求分析文档，不涉及 PRD / ADD / 代码 |
| 可追溯 | FR→G、BR→FR（规则表置于 FR 节内）、MVP→FR、R→依赖或影响面 |
| 自查勾选 | 质量门禁通过后，交付物 **§6.4** 中已通过项须为 `- [x]`；未通过项保持 `- [ ]` 直至修复（禁止未达标而全选） |

完整原则、反模式、编号体系与错误处理见 [reference/design-principles.md](reference/design-principles.md)。

## 依赖关系

| 类型 | 技能/组件 | 说明 |
|------|-----------|------|
| 上游（必需） | `sdx-solution` | 提供解决方案文档作为核心输入 |
| 上游（可选） | `docs-build` | 提供 `knowledge/` 基线 |
| 下游 | `sdx-prd` | 基于需求分析转化为产品需求文档 |
| 下游 | `sdx-design` | 基于 PRD 进行技术方案设计 |
| 下游 | `sdx-test` | 基于 PRD 与 ADD 进行测试设计 |

## 参考

| 资源 | 路径 | 何时读 |
|------|------|--------|
| 五步工作流（算法、depth、Q-n、数据流） | [reference/workflow-spec.md](reference/workflow-spec.md) | 步骤执行时，规则不确定时 |
| 受众与文档语言 | [reference/audience-and-language.md](reference/audience-and-language.md) | 步骤 5 语言审查时 |
| 核心概念与 IDEA-ID 落盘示例 | [reference/core-concepts.md](reference/core-concepts.md) | 口径对齐、编号规则不确定时 |
| 设计原则、反模式、错误处理 | [reference/design-principles.md](reference/design-principles.md) | 遇到边界判断、错误场景时 |
| 质量验收清单 | [reference/quality-checklist.md](reference/quality-checklist.md) | 步骤 5 自查时 |
| 需求分析文档模板 | [assets/analysis-template.md](assets/analysis-template.md) | 步骤 5 生成文档时 |
| 常见陷阱与防错 | [gotchas.md](gotchas.md) | 遇到输入缺失、需求细化、MVP 拆分相关问题时 |
| 文档结构校验脚本 | [scripts/validate-analysis.sh](scripts/validate-analysis.sh) | 步骤 5 自动验证时 |
