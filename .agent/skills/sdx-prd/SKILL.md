---
name: sdx-prd
description: >
  产品需求说明（PRD）：将需求分析中当前 MVP 的功能需求细化为可评审、可验收的产品方案——
  业务流程、用例模型、用户故事、功能模块、交互设计与业务规则。
  当用户执行 /sdx-prd、需要编写 PRD 文档、将需求分析细化为用户故事和用例、
  设计业务流程和功能模块、或需要产出可评审可验收的产品需求时，务必使用本技能。
  即使用户只说"帮我写个 PRD"、"细化一下用户故事"、"设计一下业务流程"、
  "把需求分析转成 PRD"，也应触发本技能。
  输出至应用知识库 {DOC_DIR}/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/PRD-{IDEA-ID}-{N}.md。
---

# 产品需求阶段（sdx-prd）

**术语**：**应用知识库**指应用知识库目录 `DOC_DIR`（见 `.docsconfig`），对应路径前缀 `{DOC_DIR}/`。

将需求分析中**当前 MVP** 细化为可评审、可验收的 PRD：业务流程、用户故事与用例、功能模块与交互、业务规则与数据字典。

主要读者：**产品经理**（撰写与验收对齐）；**研发团队参与评审**（可行性、范围边界）。技术实现细节留给下游 sdx-design。

---

## 输入与输出

| 类型 | 内容 |
|------|------|
| 硬输入 | 需求分析文档（应用知识库 `{DOC_DIR}/analysis/ANALYSIS-{IDEA-ID}.md`）中当前 MVP 章节 |
| 可选输入 | `knowledge/product/`、`knowledge/business/`（按需加载，禁止通读全仓） |
| 固定输出 | 应用知识库下 `{DOC_DIR}/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/PRD-{IDEA-ID}-{N}.md` |
| 不产出 | ADD、TDD、代码（使用下游 sdx-design / sdx-test） |

## 参数

| 参数 | 必需 | 默认值 | 说明 |
|------|------|--------|------|
| `--id` | 否 | `IDEA-ID` | 与上游 `ANALYSIS-{IDEA-ID}.md` 共用 IDEA-ID |
| `--requirement` | 否 | — | 上游需求分析编号，自动定位对应文件 |
| `--mvp` | 否 | `1` | 目标 MVP 阶段编号（对应 `MVP-Phase-{N}`） |

## 适用场景

| 场景 | 使用本技能 |
|------|-----------|
| 已有需求分析，需将 MVP 转化为详细产品需求 | ✅ |
| 需编写完整业务流程、用户故事与用例 | ✅ |
| 收到业务需求/工单，需先输出解决方案文档 | ❌ → sdx-solution |
| 已有解决方案，需进行需求分析与 MVP 拆分 | ❌ → sdx-analysis |
| 已有 PRD，需技术方案设计 | ❌ → sdx-design |
| 已有 PRD 与 ADD，需测试设计 | ❌ → sdx-test |

---

## 工作流（五步）

执行前先加载需求分析文档，提取目标 MVP 的 FR-n / BR-n / NFR / 角色列表；目标 MVP 章节不存在时终止并提示。详细算法与步间数据流见 [reference/workflow-spec.md](reference/workflow-spec.md)。

### 步骤 1：业务流程设计

绘制主流程（Mermaid flowchart）与分支/异常流程；步骤表六要素（序号、角色、输入、处理逻辑、输出、BR-n 引用）；跨系统交互用 sequenceDiagram 标注同步/异步与回调。产出对应文档 §2。

### 步骤 2：用例建模

绘制用例图（Mermaid graph），覆盖 §1.4 全部角色；每个 UC-n 含参与者、前后置条件、主成功场景（≤9 步）、扩展场景；与 FR-n 对齐。产出对应文档 §4。

### 步骤 3：用户故事与场景

为当前 MVP 每个 FR-n 编写至少一个 US-n；INVEST 校验；Given-When-Then 覆盖正常与异常/边界场景；US-n ↔ UC-n 双向映射；关联 FR-n / BR-n。产出对应文档 §5。

### 步骤 4：功能模块与交互设计

按业务能力域划分模块（非技术层次）；信息架构与操作流程；业务规则集中汇总至 §7（BR-n 含优先级与冲突处理）；数据字典（§8）含类型/约束/枚举值；状态机标注终态与非法转换；**§9 NFR**（选择性类别 + 度量方法，与 ANALYSIS 对齐）；**§10.1 AC-n** 关联 US-n，**§10.2 NAC-n** 与 §9 互链。产出对应文档 §3、§6–§10。

### 步骤 5：文档输出与评审

套用 [assets/prd-template.md](assets/prd-template.md) 十一章结构；填写文末元数据 YAML（**禁止**文件头 frontmatter）；语言审查（正文不出现接口名/表名/中间件）；按 [reference/quality-checklist.md](reference/quality-checklist.md) **逐项**自查；已通过项在 §11.3 中将 `- [ ]` 改为 `- [x]`，未通过项保持 `- [ ]` 先修复，**禁止虚假勾选**。

辅助校验：

```bash
.agent/skills/sdx-prd/scripts/validate-prd.sh
```

---

## 核心约束

| 约束 | 说明 |
|------|------|
| 模板驱动 | 严格遵循 `prd-template.md` 十一章；无内容章节保留标题并标注「不适用」 |
| 证据优先 | 用户故事与业务规则须引用 FR-n / BR-n，禁止臆测 |
| MVP 聚焦 | 仅覆盖 `--mvp` 对应范围，不混入后续 MVP |
| 业务可读 | 正文以产品/业务语言为主；细则见 [reference/audience-and-language.md](reference/audience-and-language.md) |
| 歧义标注 | 不确定项标为待澄清，暂停确认，禁止自行假设 |
| 可追溯 | US-n→FR-n，UC-n↔US-n，BR-n 与 ANALYSIS 一致，AC/NAC 可指回 US 或 §9 |
| 自查勾选 | §11.3 已通过项须为 `- [x]`；未通过项保持 `- [ ]` 直至修复 |

完整原则、FR 句式、反模式、编号体系与错误处理见 [reference/design-principles.md](reference/design-principles.md)。

---

## 命名约定

- 落盘路径（应用知识库）：`{DOC_DIR}/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/PRD-{IDEA-ID}-{N}.md`
- 阶段目录：`MVP-Phase-{N}`（不是 `MVP-{N}/`），`{N}` 为正整数
- IDEA-ID 与上游 `ANALYSIS-{IDEA-ID}.md` 完全一致，不得只写日期而省略 slug
- 元数据位置：文末「## 文档元数据」下的 fenced YAML；**禁止**在文件开头使用 `---` frontmatter

---

## 依赖关系

| 类型 | 技能/组件 | 说明 |
|------|-----------|------|
| 上游（必需） | `sdx-analysis` | 提供需求分析文档与 MVP 拆分 |
| 上游（可选） | `docs-build` | 提供 `knowledge/` 基线 |
| 下游 | `sdx-design` | 基于 PRD 进行技术方案设计 |
| 下游 | `sdx-test` | 基于 PRD 与 ADD 进行测试设计 |

---

## 参考资源

| 资源 | 路径 | 何时读 |
|------|------|--------|
| 五步工作流（算法、决策点、数据流） | [reference/workflow-spec.md](reference/workflow-spec.md) | 步骤执行时，规则不确定时 |
| 受众与文档语言 | [reference/audience-and-language.md](reference/audience-and-language.md) | 步骤 5 语言审查时 |
| 核心概念与 IDEA-ID 落盘示例 | [reference/core-concepts.md](reference/core-concepts.md) | 口径对齐、编号规则不确定时 |
| 设计原则、反模式、错误处理 | [reference/design-principles.md](reference/design-principles.md) | 遇到边界判断、错误场景时 |
| 质量验收清单 | [reference/quality-checklist.md](reference/quality-checklist.md) | 步骤 5 自查时 |
| PRD 文档模板 | [assets/prd-template.md](assets/prd-template.md) | 步骤 5 生成文档时 |
| 常见陷阱与防错 | [gotchas.md](gotchas.md) | 遇到流程设计、用户故事、MVP 范围相关问题时 |
| 文档结构校验脚本 | [scripts/validate-prd.sh](scripts/validate-prd.sh) | 步骤 5 自动验证时 |
