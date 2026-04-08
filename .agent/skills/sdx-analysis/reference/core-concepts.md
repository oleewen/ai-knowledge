# 核心概念（sdx-analysis）

面向产品/需求分析语境的术语与目标，供步骤 1–5 对齐口径。算法与决策点见 [workflow-spec.md](workflow-spec.md)。

## IDEA-ID

**IDEA-ID** 的定义（统一格式 `*-{YYMMDD}-{主题slug}` 中的 `{YYMMDD}-{主题slug}` 段）见 [sdx-solution：core-concepts §IDEA-ID](../../sdx-solution/reference/core-concepts.md#idea-id)。

本阶段路径示例：输出 `application/analysis/ANALYSIS-{IDEA-ID}.md`；上游 `application/solutions/SOLUTION-{IDEA-ID}.md`；下游需求包目录 `application/requirements/REQUIREMENT-{IDEA-ID}/`（与 **sdx-prd** 等一致）。

## 深度研究

从业务边界、核心规则、跨部门/跨系统协作、行业惯例等维度澄清「做什么、不做什么」。内部分析可对照知识库识别**现有能力缺口与历史约束**；写入文档时改为**对业务与协作的影响**表述，不罗列模块或栈名。

## 需求细化

把方案目标拆成带优先级（P0–P3）的功能诉求与非功能诉求。功能用**输入信息—处理规则—产出与验收**描述；非功能用**用户可感知的体验与承诺**（时效、可用场景、合规要求等）描述，避免接口与存储细节。

## MVP 拆分

按独立业务价值、可独立交付、依赖尽量单向等原则划分阶段；每个 MVP 写清范围、清单与**可验证的验收要点**。

## 需求分析文档

遵循 [../assets/analysis-template.md](../assets/analysis-template.md) 的**六章**结构：功能需求以 **FR-n** 分节，**BR-n** 与业务对象表写在对应 FR 节内；非功能、交付计划、依赖与风险、附录（含 **§6.3 变更历史**、**§6.4 质量自查**）。语言规范见 [audience-and-language.md](audience-and-language.md) 与 [design-principles.md](design-principles.md)。
