---
name: sdx-prd
description: >
  产品需求说明：将需求分析中当前 MVP 的需求转化为详细产品方案与功能设计（业务流程、用户故事、用例、功能模块、交互与业务规则）。
  在用户执行 /sdx-prd、编写 PRD 文档时使用。
  产出 system/requirements/REQUIREMENT-{ID}/MVP-{N}/PRD-{ID}-{N}.md；模板见 assets/prd-template.md；工作流、概念与门禁见 reference/。
  主要读者为产品；研发参与评审。技术实现细节留给下游 sdx-design。
---

# 产品需求阶段（sdx-prd）

将需求分析中**当前 MVP** 细化为可评审、可验收的 PRD：业务流程、用户故事与用例、功能模块与交互、业务规则与数据字典。**分工与语言**见 [reference/audience-and-language.md](reference/audience-and-language.md)（与 [../sdx-solution/SKILL.md](../sdx-solution/SKILL.md) 的阶段分工一致）。

**执行顺序建议**：先读本文件与 [gotchas.md](gotchas.md) → 步骤 1–5 按需打开 [reference/workflow-spec.md](reference/workflow-spec.md) → 定稿前打开 [assets/prd-template.md](assets/prd-template.md) 与 [reference/quality-checklist.md](reference/quality-checklist.md)。

## 输入与输出

**输入**：需求分析文档中当前 MVP 章节（`system/analysis/ANALYSIS-{ID}.md`）、产品文档（`knowledge/product/`）；内部分析可按需查阅 `knowledge/`、`requirements/.../specs/`（**勿将实现向技术细节原样写入 PRD 正文**）。  
**输出**：`system/requirements/REQUIREMENT-{ID}/MVP-{N}/PRD-{ID}-{N}.md`（结构遵循 [assets/prd-template.md](assets/prd-template.md)）

| 类型 | 内容 |
|------|------|
| 硬输入 | 需求分析文档（`system/analysis/ANALYSIS-{ID}.md`）中当前 MVP 章节 |
| 可选输入 | `knowledge/product/`、`knowledge/business/`、`requirements/.../specs/`、AGENTS.md |
| 固定输出 | `system/requirements/REQUIREMENT-{ID}/MVP-{N}/PRD-{ID}-{N}.md` |
| 不产出 | ADD、TDD、代码（使用下游 sdx-design / sdx-test） |

## 参数

| 参数 | 必需 | 默认值 | 说明 |
|------|------|--------|------|
| `--id` | 否 | `{ID}-{N}` | PRD 文档编号（{ID} 为需求分析编号中的 ID 部分，{N} 为 MVP 序号） |
| `--doc-root` | 否 | `docs` | 文档根目录 |
| `--requirement` | 否 | — | 上游需求分析编号，自动定位对应文件 |
| `--mvp` | 否 | `1` | 目标 MVP 阶段编号 |

## 适用场景

| 场景 | 使用本技能 |
|------|-----------|
| 已有需求分析，需将 MVP 转化为详细产品需求 | 是 |
| 需编写完整业务流程、用户故事与用例 | 是 |
| 收到业务需求/工单，需先输出解决方案文档 | 否 → **sdx-solution** |
| 已有解决方案，需进行需求分析与 MVP 拆分 | 否 → **sdx-analysis** |
| 已有 PRD，需技术方案设计 | 否 → **sdx-design** |
| 已有 PRD 与 ADD，需测试设计 | 否 → **sdx-test** |

## 工作流（五步）

按顺序执行；每步算法、决策点与步间数据流见 [reference/workflow-spec.md](reference/workflow-spec.md)。术语口径见 [reference/core-concepts.md](reference/core-concepts.md)。

1. **业务流程设计** — 主/分支/异常流程，角色与 BR-n 引用，跨系统交互（Mermaid）。
2. **用户故事与场景** — INVEST、Given-When-Then，关联 FR-n / BR-n，覆盖正常与异常/边界。
3. **用例建模** — 用例图与 UC-n 描述；US-n ↔ UC-n 双向映射。
4. **功能模块与交互设计** — 按业务能力域划分模块；IA、操作流程、规则汇总、数据字典与状态。
5. **文档输出与评审** — 套 [assets/prd-template.md](assets/prd-template.md)；按 [reference/quality-checklist.md](reference/quality-checklist.md) 自查。

辅助校验（于**文档根**执行，路径以仓库为准）：

```bash
.ai/skills/sdx-prd/scripts/validate-prd.sh --doc-root docs
```

## 核心约束

| 约束 | 说明 |
|------|------|
| 模板驱动 | 输出严格遵循 `prd-template.md` 十章结构 |
| 受众与语言 | 产品主导、研发评审；业务/产品语言为主；细则见 [reference/audience-and-language.md](reference/audience-and-language.md) 与 [../sdx-solution/reference/audience-and-language.md](../sdx-solution/reference/audience-and-language.md) |
| 证据优先 | 用户故事与业务规则须引用需求分析与 `knowledge/` 事实，禁止臆测 |
| 按需加载 | 仅在本轮需要时打开文件，禁止为完整性通读全仓 |
| 歧义标注 | 不确定项标为待澄清，禁止自行假设 |
| 范围清晰 | 仅产出 PRD，不涉及 ADD / 测试设计 / 代码 |
| 可追溯 | US-n→FR-n，BR-n 与需求分析一致，UC-n 与 US-n 映射完整 |
| MVP 聚焦 | 仅覆盖 `--mvp` 对应范围，不混入后续 MVP |

完整原则、反模式、编号体系与错误处理见 [reference/design-principles.md](reference/design-principles.md)。

## 依赖关系

| 类型 | 技能/组件 | 说明 |
|------|-----------|------|
| 上游（必需） | `sdx-analysis` | 提供需求分析文档与 MVP 拆分作为核心输入 |
| 上游（可选） | `knowledge-extract` | 提供 `knowledge/*/*_knowledge.json` 与 `knowledge/KNOWLEDGE_INDEX.md` 基线 |
| 下游 | `sdx-design` | 基于 PRD 进行技术方案设计 |
| 下游 | `sdx-test` | 基于 PRD 与 ADD 进行测试设计 |

## 参考

| 资源 | 路径 |
|------|------|
| 五步工作流（算法、决策点、数据流） | [reference/workflow-spec.md](reference/workflow-spec.md) |
| 受众与文档语言 | [reference/audience-and-language.md](reference/audience-and-language.md) |
| 核心概念口径 | [reference/core-concepts.md](reference/core-concepts.md) |
| 设计原则、反模式、错误处理 | [reference/design-principles.md](reference/design-principles.md) |
| 质量门禁验收清单 | [reference/quality-checklist.md](reference/quality-checklist.md) |
| PRD 文档模板 | [assets/prd-template.md](assets/prd-template.md) |
| 常见陷阱与防错 | [gotchas.md](gotchas.md) |
| 文档结构校验脚本 | [scripts/validate-prd.sh](scripts/validate-prd.sh) |
| 受众语言规范（与解决方案阶段同原则） | `.ai/skills/sdx-solution/reference/audience-and-language.md` |
| 上游：需求分析 | `.ai/skills/sdx-analysis/SKILL.md` |
| 下游：技术设计 | `.ai/skills/sdx-design/SKILL.md` |
| 下游：测试设计 | `.ai/skills/sdx-test/SKILL.md` |
| 知识库 | `knowledge/product/`、`knowledge/business/`、`requirements/.../specs/` |
