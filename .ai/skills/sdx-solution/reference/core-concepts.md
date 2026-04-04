# 核心概念（sdx-solution）

面向业务与产品评审语境的术语与产出边界，供步骤 1–5 对齐口径。算法、`--depth` / `--skip-conflict` 与数据流见 [workflow-spec.md](workflow-spec.md)。

## IDEA-ID

**IDEA-ID** 为需求链统一标识，对应统一命名格式 **`*-{YYMMDD}-{主题slug}`** 中的 **`{YYMMDD}-{主题slug}`** 段：

- **`{YYMMDD}`**：六位日期（年两位 + 月两位 + 日两位）。
- **`{主题slug}`**：ASCII `kebab-case` 短标识。

与下游 `ANALYSIS-*`、`REQUIREMENT-*` 等同链一致。本技能与其它文档中凡写 **`{IDEA-ID}`**，均指该段（不含类型前缀）。示例文件名：`SOLUTION-{IDEA-ID}.md`。

## 解决方案文档

本阶段唯一固定产出：`system/solutions/SOLUTION-{IDEA-ID}.md`（**IDEA-ID** 见上节）。九章结构见 [../assets/solution-template.md](../assets/solution-template.md)；用于**共识级**范围、目标、影响、冲突化解与 MVP 建议，**不**替代 PRD、ADD 或测试设计。

## 诉求结构化

从原始业务材料萃取背景、目标、场景、角色、约束、排期；每条需求标注性质（功能/非功能）、变更类型（新增/变更/修复）、优先级（P0–P3）。歧义与缺失一律标为 **Q-n**，按 workflow-spec 中的交互协议逐题确认，禁止默认补全。

## 影响面

描述「谁、在什么业务环节、如何被影响」，区分直接/间接与程度（高/中/低）。内部分析可对照 `knowledge/` 与规约；**写入正文**时避免罗列系统/模块/接口名，见 [audience-and-language.md](audience-and-language.md)。

## 冲突与化解

**C-n** 偏业务规则与协作；**C-Tn** 偏契约与实现侧冲突（内部分析用，正文仍转业务表述）。每项需化解思路及成本/残余风险；`--skip-conflict` 仅用于确认无存量交叉的全新场景。

## 业务目标与风险

**G-n**：可度量的业务目标，须能追溯到原始描述。**R-n**：可行性、资源或化解残余风险；须有应对策略。

## MVP 拆分建议

按**独立业务价值**与可演示性拆分阶段，依赖尽量单向；不写用户故事级验收细则（留给 **sdx-analysis** / **sdx-prd**）。

## 与下游分工

| 下游技能 | 输入本阶段产出后负责 |
|----------|---------------------|
| **sdx-analysis** | 需求深化、MVP 清单与验收要点 |
| **sdx-prd** | PRD、用户故事与功能需求 |
| **sdx-design** | ADD、规约与实现设计（在 PRD 之后） |
