---
name: sdx-prd
description: >
  产品需求说明：将需求分析中当前 MVP 的需求转化为详细产品方案与功能设计（业务流程、用户故事、用例、功能模块、交互与业务规则）。
  在用户执行 /sdx-prd、编写 PRD 文档时使用。产出 docs/requirements/REQUIREMENT-{ID}/MVP-{N}/PRD-{ID}-{N}.md，模板见 .cursor/rules/requirement/prd-template.md。
---

# 产品需求阶段（sdx-prd）

将需求分析中当前 MVP 阶段的需求转化为详细的产品方案和功能设计，涵盖完整的业务流程、用户故事、用例建模、功能模块划分、交互设计和业务规则定义。

## 输入与输出

**输入**：需求分析文档中当前 MVP 章节（`docs/analysis/ANALYSIS-{ID}.md`）、产品文档（`knowledge/product/`）
**输出**：`docs/requirements/REQUIREMENT-{ID}/MVP-{N}/PRD-{ID}-{N}.md`（结构遵循 [prd-template.md](../../rules/requirement/prd-template.md)）

| 类型 | 内容 |
|------|------|
| 硬输入 | 需求分析文档（`docs/analysis/ANALYSIS-{ID}.md`）中当前 MVP 章节 |
| 可选输入 | `knowledge/product/`、`knowledge/business/`、`requirements/.../specs/`、AGENTS.md |
| 固定输出 | `docs/requirements/REQUIREMENT-{ID}/MVP-{N}/PRD-{ID}-{N}.md` |
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

## 核心概念

- **业务流程设计**：绘制主流程与分支/异常流程，标注参与角色、输入输出、业务规则与跨系统交互
- **用户故事建模**：按 INVEST 原则编写用户故事，含 Given-When-Then 验收标准，覆盖正常/备选/异常/边界场景
- **用例建模**：绘制用例图，编写用例描述（参与者、前后置条件、主成功场景、扩展场景、业务规则引用）
- **功能模块设计**：划分功能模块与模块间关系，定义信息架构、操作流程、校验与反馈
- **PRD 文档**：遵循 [prd-template.md](../../rules/requirement/prd-template.md) 的十章结构

## 工作流（五步）

按顺序执行，每步产出作为下一步输入；最终文档需通过质量门禁。详细算法与决策点见 [reference/workflow-spec.md](reference/workflow-spec.md)。

### 步骤 1：业务流程设计

从需求分析的功能需求（FR-n）出发，绘制主流程与分支/异常流程；标注参与角色、输入输出、业务规则；识别跨系统交互与异步回调；使用 Mermaid 可视化。

### 步骤 2：用户故事与场景

按 INVEST 原则编写用户故事（作为…我希望…以便…），含 Given-When-Then 验收标准；详述正常/备选/异常/边界场景；标注优先级与故事点；关联功能需求 FR-n 与业务规则 BR-n。

### 步骤 3：用例建模

用 Mermaid 绘制用例图；编写用例描述（参与者、前后置条件、主成功场景、扩展场景、业务规则引用）；确保用户故事与用例双向映射。

### 步骤 4：功能模块与交互设计

功能模块划分与模块间关系；交互设计（信息架构、操作流程、校验与反馈）；业务规则汇总（触发条件、执行逻辑、异常与优先级）；数据字典与状态定义。

### 步骤 5：文档输出与评审

将步骤 1–4 的产出整合为 PRD 文档，严格采用 [prd-template.md](../../rules/requirement/prd-template.md) 的章节与格式；执行质量门禁自查。

质量门禁清单见 [assets/quality-gate-checklist.md](assets/quality-gate-checklist.md)。

可使用辅助脚本验证文档结构：

```bash
scripts/validate-prd.sh --doc-root docs
```

## 核心约束

| 约束 | 说明 |
|------|------|
| 模板驱动 | 输出严格遵循 prd-template.md 十章结构 |
| 证据优先 | 用户故事与业务规则须引用需求分析文档与 `knowledge/` 事实，禁止臆测 |
| 按需加载 | 仅在本轮需要时打开文件，禁止为完整性通读全仓 |
| 歧义标注 | 不确定项标为待澄清，禁止自行假设 |
| 范围清晰 | 仅产出 PRD 文档，不涉及 ADD / 测试设计 / 代码 |
| 可追溯 | 每个用户故事可追溯到需求分析 FR-n，每个业务规则可追溯到需求分析 BR-n |
| MVP 聚焦 | 仅覆盖目标 MVP 范围内的功能需求，不超越 MVP 边界 |

设计原则完整版与反模式清单见 [reference/design-principles.md](reference/design-principles.md)。

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
| 设计原则与反模式 | [reference/design-principles.md](reference/design-principles.md) |
| 五步工作流详细规范 | [reference/workflow-spec.md](reference/workflow-spec.md) |
| 质量门禁验收清单 | [assets/quality-gate-checklist.md](assets/quality-gate-checklist.md) |
| 文档结构校验脚本 | [scripts/validate-prd.sh](scripts/validate-prd.sh) |
| PRD 文档模板 | [.cursor/rules/requirement/prd-template.md](../../rules/requirement/prd-template.md) |
| 上游：需求分析 | `.cursor/skills/sdx-analysis/SKILL.md` |
| 下游：技术设计 | `.cursor/skills/sdx-design/SKILL.md` |
| 下游：测试设计 | `.cursor/skills/sdx-test/SKILL.md` |
| 知识库 | `knowledge/product/`、`knowledge/business/`、`requirements/.../specs/` |
