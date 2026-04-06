---
name: sdx-prd
description: >
  产品需求说明：将需求分析中当前 MVP 的需求转化为详细产品方案与功能设计（业务流程、用户故事、用例、功能模块、交互与业务规则）。
  当用户执行 /sdx-prd、需要编写 PRD 文档、将需求分析细化为用户故事和用例、
  设计业务流程和功能模块、或需要产出可评审可验收的产品需求时，务必使用本技能。
  即使用户只说"帮我写个 PRD"、"细化一下用户故事"、"设计一下业务流程"，也应触发本技能。
  输出至 system/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/PRD-{IDEA-ID}-{N}.md。
---

# 产品需求阶段（sdx-prd）

将需求分析中**当前 MVP** 细化为可评审、可验收的 PRD：业务流程、用户故事与用例、功能模块与交互、业务规则与数据字典。

主要读者为**产品经理**（撰写与验收对齐）；**研发团队参与评审**（可行性、范围边界）。技术实现细节留给下游 sdx-design。

## 命名约定

- 落盘路径：`system/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/PRD-{IDEA-ID}-{N}.md`
- 阶段目录：`MVP-Phase-{N}`（不是 `MVP-{N}/`），`{N}` 为正整数
- IDEA-ID 与上游 `ANALYSIS-{IDEA-ID}.md` 完全一致，不得只写日期而省略 slug
- 元数据位置：文末「## 文档元数据」下的 fenced YAML；**禁止**在文件开头使用 `---` frontmatter

## 输入与输出

| 类型 | 内容 |
|------|------|
| 硬输入 | 需求分析文档（`system/analysis/ANALYSIS-{IDEA-ID}.md`）中当前 MVP 章节 |
| 可选输入 | `knowledge/product/`、`knowledge/business/`、AGENTS.md（内部分析用，写入时转为产品表述） |
| 固定输出 | `system/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/PRD-{IDEA-ID}-{N}.md` |
| 不产出 | ADD、TDD、代码（使用下游 sdx-design / sdx-test） |

## 参数

| 参数 | 必需 | 默认值 | 说明 |
|------|------|--------|------|
| `--id` | 否 | `IDEA-ID` | 与上游 `ANALYSIS-{IDEA-ID}.md` 共用 IDEA-ID |
| `--doc-root` | 否 | `system` | 文档根目录 |
| `--requirement` | 否 | — | 上游需求分析编号，自动定位对应文件 |
| `--mvp` | 否 | `1` | 目标 MVP 阶段编号（对应 `MVP-Phase-{N}`） |

## 适用场景

| 场景 | 使用本技能 |
|------|-----------|
| 已有需求分析，需将 MVP 转化为详细产品需求 | 是 |
| 需编写完整业务流程、用户故事与用例 | 是 |
| 收到业务需求/工单，需先输出解决方案文档 | 否 → sdx-solution |
| 已有解决方案，需进行需求分析与 MVP 拆分 | 否 → sdx-analysis |
| 已有 PRD，需技术方案设计 | 否 → sdx-design |
| 已有 PRD 与 ADD，需测试设计 | 否 → sdx-test |

## 工作流（五步）

按顺序执行；每步算法、决策点与步间数据流见 [reference/workflow-spec.md](reference/workflow-spec.md)。

1. **业务流程设计** — 主/分支/异常流程，角色与 BR-n 引用，跨系统交互（Mermaid）
2. **用例建模** — 用例图与 UC-n 描述；与业务流程、FR-n 对齐；前后置条件
3. **用户故事与场景** — INVEST、Given-When-Then，关联 FR-n / BR-n，覆盖正常与异常/边界；US-n ↔ UC-n 双向映射
4. **功能模块与交互设计** — 按业务能力域划分模块；IA、操作流程、规则汇总、数据字典与状态；**§9 NFR**（选择性类别 + 度量方法，与 ANALYSIS 对齐）及 **§10.1 / §10.2** 验收表（NAC 与 §9 互链）
5. **文档输出与评审** — 套 [assets/prd-template.md](assets/prd-template.md)（§1.2 成功标准、§1.3 后续阶段表、**§9**、**§10**、§11）；语言审查；按 [reference/quality-checklist.md](reference/quality-checklist.md) 自查

辅助校验：

```bash
.ai/skills/sdx-prd/scripts/validate-prd.sh --doc-root system
```

## 核心约束

| 约束 | 说明 |
|------|------|
| 模板驱动 | 输出严格遵循 `prd-template.md` 十一章结构；无内容章节保留标题并标注「不适用」 |
| 受众与语言 | 产品主导、研发评审；业务/产品语言为主；细则见 [reference/audience-and-language.md](reference/audience-and-language.md) |
| 证据优先 | 用户故事与业务规则须引用需求分析 FR-n / BR-n，禁止臆测 |
| 按需加载 | 仅在本轮需要时打开文件，禁止为完整性通读全仓 |
| 歧义标注 | 不确定项标为待澄清，禁止自行假设 |
| 范围清晰 | 仅产出 PRD，不涉及 ADD / 测试设计 / 代码 |
| MVP 聚焦 | 仅覆盖 `--mvp` 对应范围，不混入后续 MVP |
| 可追溯 | US-n→FR-n，BR-n 与需求分析一致，UC-n 与 US-n 映射完整；§1.2 / §9 与 ANALYSIS 愿景/成功标准/NFR 对齐（见 [reference/core-concepts.md](reference/core-concepts.md) 可追溯链） |

完整原则、**FR 句式**、反模式、编号体系与错误处理见 [reference/design-principles.md](reference/design-principles.md)。

## 依赖关系

| 类型 | 技能/组件 | 说明 |
|------|-----------|------|
| 上游（必需） | `sdx-analysis` | 提供需求分析文档与 MVP 拆分作为核心输入 |
| 上游（可选） | `docs-build` | 提供 `knowledge/` 基线 |
| 下游 | `sdx-design` | 基于 PRD 进行技术方案设计 |
| 下游 | `sdx-test` | 基于 PRD 与 ADD 进行测试设计 |

## 参考

| 资源 | 路径 | 何时读 |
|------|------|--------|
| 五步工作流（算法、决策点、数据流） | [reference/workflow-spec.md](reference/workflow-spec.md) | 步骤执行时，规则不确定时 |
| 受众与文档语言 | [reference/audience-and-language.md](reference/audience-and-language.md) | 步骤 5 语言审查时 |
| 核心概念与 IDEA-ID 落盘示例 | [reference/core-concepts.md](reference/core-concepts.md) | 口径对齐、编号规则不确定时 |
| 设计原则、反模式、错误处理 | [reference/design-principles.md](reference/design-principles.md) | 遇到边界判断、错误场景时 |
| 质量门禁验收清单 | [reference/quality-checklist.md](reference/quality-checklist.md) | 步骤 5 自查时 |
| PRD 文档模板 | [assets/prd-template.md](assets/prd-template.md) | 步骤 5 生成文档时 |
| 常见陷阱与防错 | [gotchas.md](gotchas.md) | 遇到流程设计、用户故事、MVP 范围相关问题时 |
| 文档结构校验脚本 | [scripts/validate-prd.sh](scripts/validate-prd.sh) | 步骤 5 自动验证时 |
