---
name: sdx-test
description: >
  测试方案设计：基于 PRD 与 ADD 制定测试策略与计划，设计测试用例、测试数据与回归范围，输出测试设计文档（TDD）。
  当用户执行 /sdx-test、需要编写测试设计文档、制定测试策略与用例、设计回归测试范围、
  需要测试进出标准、需要将 PRD/ADD 转化为可执行的测试方案、或需要覆盖功能/接口/业务规则/异常/性能测试时，务必使用本技能。
  即使用户只说"帮我写个测试方案"、"设计一下测试用例"、"出一份 TDD"、"把 PRD 转成测试用例"、
  "设计一下回归范围"、"制定一下进出标准"，也应触发本技能。
  输出至系统知识库根目录 application/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/TDD-{IDEA-ID}-{N}.md。
---

# 测试设计阶段（sdx-test）

**术语**：**系统知识库根目录**指路径前缀 `application/`（与 `--doc-root` 默认一致时）。

基于产品需求文档与技术设计文档，制定当前 MVP 的测试策略与测试计划，设计测试用例、测试数据与回归范围，输出测试设计文档（TDD），为后续开发与测试验证提供依据。

主要读者：**测试/质量角色**（制定策略与用例）；**研发参与评审**（可执行性、数据与环境、与 ADD 一致性）。

---

## 输入与输出

| 类型 | 内容 |
|------|------|
| 硬输入 | 产品需求文档（系统知识库根目录 `application/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/PRD-{IDEA-ID}-{N}.md`） |
| 可选输入 | 架构设计（`ADD-{IDEA-ID}-{N}.md`）、规约（`specs/`）、`knowledge/`（按需加载，禁止通读全仓） |
| 固定输出 | 系统知识库根目录下 `application/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/TDD-{IDEA-ID}-{N}.md` |
| 不产出 | 代码、自动化测试脚本、测试执行报告（实现与执行阶段产出） |

## 参数

| 参数 | 必需 | 默认值 | 说明 |
|------|------|--------|------|
| `--id` | 否 | `IDEA-ID` | 与 PRD/ADD 一致 |
| `--doc-root` | 否 | `system` | 文档根目录 |
| `--prd` | 否 | — | 上游 PRD stem，自动定位对应文件 |
| `--mvp` | 否 | `1` | 目标 MVP 阶段编号（`MVP-Phase-{N}`） |
| `--depth` | 否 | `standard` | 设计深度：`quick`（仅 P0 功能+核心接口）/ `standard`（完整六类用例）/ `deep`（增加性能与安全用例） |

## 适用场景

| 场景 | 使用本技能 |
|------|-----------|
| 已有 PRD 与 ADD，需制定测试方案 | ✅ |
| 需设计测试用例、测试数据与回归策略 | ✅ |
| 需制定可度量的测试进出标准 | ✅ |
| 已有解决方案，需进行需求分析 | ❌ → sdx-analysis |
| 已有需求分析，需编写 PRD | ❌ → sdx-prd |
| 已有 PRD，需技术方案设计 | ❌ → sdx-design |

---

## 工作流（五步）

执行前先加载 PRD，提取 US-n、验收标准、BR-n、NFR；ADD 存在时额外提取 API 规约、影响面分析；PRD 不存在时终止并提示先执行 `sdx-prd`。详细算法、ADD 缺失分支、`--depth` 差异与步间数据流见 [reference/workflow-spec.md](reference/workflow-spec.md)。

### 步骤 1：测试策略与范围分析

确定测试层次（单元/集成/端到端）与覆盖率目标；划定新增/变更/回归范围；识别复杂度、数据一致性、并发安全、外部依赖等测试风险与重点区域。产出对应文档 §1。

### 步骤 2：测试用例设计

六类用例（按 `--depth` 取舍）：功能用例（US-n 验收标准 Given-When-Then）、接口用例（API 正常/参数/权限/幂等/并发）、业务规则用例（BR-n 等价类与边界值）、异常场景用例（系统/数据/并发/依赖异常）、性能用例（`deep` 或 NFR 要求时）、回归用例（基于 ADD 影响面）。每个用例含编号、场景、前置条件、步骤、预期结果、优先级、追溯锚点。产出对应文档 §2。

### 步骤 3：测试数据与环境规划

枚举各用例所需数据类型、数量与关联关系；确定数据准备方式（脚本生成/手工/生产脱敏）；明确环境依赖（服务版本、数据库、中间件）与外部依赖 Mock/Stub 策略。产出对应文档 §3–§4。

### 步骤 4：进出标准与回归策略

制定可度量的进入标准（代码就绪、单测达标、环境就绪、数据就绪）与退出标准（用例通过率、缺陷清零、回归通过、覆盖达标）；基于 ADD 影响面确定回归执行顺序（核心流程 → 直接影响 → 间接影响）。产出对应文档 §5。

### 步骤 5：文档输出与评审

套用 [assets/tdd-template.md](assets/tdd-template.md) 六章结构；填写文末元数据 YAML（**禁止**文件头 frontmatter）；按 [reference/quality-checklist.md](reference/quality-checklist.md) **逐项**自查；已通过项在 §6.2 中将 `- [ ]` 改为 `- [x]`，未通过项保持 `- [ ]` 先修复，**禁止虚假勾选**。

辅助校验：

```bash
.agent/skills/sdx-test/scripts/validate-test.sh --doc-root system
```

---

## 核心约束

| 约束 | 说明 |
|------|------|
| 模板驱动 | 严格遵循 `tdd-template.md` 六章结构；无内容章节保留标题并标注「不适用」 |
| 证据优先 | 用例须引用 PRD US-n/BR-n 与 ADD API 规约，禁止臆测 |
| MVP 聚焦 | 仅覆盖目标 MVP 范围，不超越 MVP 边界 |
| 歧义标注 | 不确定项标为待澄清，暂停确认，禁止自行假设 |
| 可追溯 | TC-n → US-n/API/BR-n/影响面；编号体系见 [reference/design-principles.md](reference/design-principles.md) |
| 自查勾选 | §6.2 已通过项须为 `- [x]`；未通过项保持 `- [ ]` 直至修复 |

完整原则、反模式、编号体系与错误处理见 [reference/design-principles.md](reference/design-principles.md)。

---

## 命名约定

- 落盘路径（系统知识库根目录）：`application/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/TDD-{IDEA-ID}-{N}.md`
- IDEA-ID 与上游 `PRD-{IDEA-ID}-{N}.md`、`ADD-{IDEA-ID}-{N}.md` 完全一致
- 元数据位置：文末「## 文档元数据」下的 fenced YAML；**禁止**在文件开头使用 `---` frontmatter

---

## 依赖关系

| 类型 | 技能/组件 | 说明 |
|------|-----------|------|
| 上游（必需） | `sdx-prd` | 提供产品需求文档（用户故事、业务规则） |
| 上游（推荐） | `sdx-design` | 提供架构设计文档（接口规约、影响面分析） |
| 上游（可选） | `docs-build` | 提供 `knowledge/` 基线 |

---

## 参考资源

| 资源 | 路径 | 何时读 |
|------|------|--------|
| 五步工作流（算法、depth、数据流） | [reference/workflow-spec.md](reference/workflow-spec.md) | 步骤执行时，规则不确定时 |
| 受众与文档语言 | [reference/audience-and-language.md](reference/audience-and-language.md) | 步骤 5 语言审查时 |
| 核心概念与 IDEA-ID 落盘示例 | [reference/core-concepts.md](reference/core-concepts.md) | 口径对齐、编号规则不确定时 |
| 设计原则、反模式、错误处理 | [reference/design-principles.md](reference/design-principles.md) | 遇到边界判断、错误场景时 |
| 质量验收清单 | [reference/quality-checklist.md](reference/quality-checklist.md) | 步骤 5 自查时 |
| TDD 文档模板 | [assets/tdd-template.md](assets/tdd-template.md) | 步骤 5 生成文档时 |
| 常见陷阱与防错 | [gotchas.md](gotchas.md) | 遇到用例设计、范围控制、追溯相关问题时 |
| 文档结构校验脚本 | [scripts/validate-test.sh](scripts/validate-test.sh) | 步骤 5 自动验证时 |
