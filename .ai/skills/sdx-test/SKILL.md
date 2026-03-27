---
name: sdx-test
description: >
  测试方案设计：基于产品需求与技术设计制定测试策略与测试计划，输出测试设计文档（TDD）。
  在用户执行 /sdx-test、编写测试设计/测试计划时使用。产出 docs/requirements/REQUIREMENT-{ID}/MVP-{N}/TDD-{ID}-{N}.md，模板见 .cursor/rules/requirement/tdd-template.md。
---

# 测试设计阶段（sdx-test）

基于产品需求文档与技术设计文档，制定当前 MVP 的测试策略与测试计划，设计测试用例、测试数据与回归范围，输出测试设计文档（TDD），为后续开发与测试验证提供依据。

## 输入与输出

**输入**：产品需求（`docs/requirements/REQUIREMENT-{ID}/MVP-{N}/PRD-{ID}.md`）、架构设计（`.../ADD-{ID}.md`）、规约（`.../specs/`）
**输出**：`docs/requirements/REQUIREMENT-{ID}/MVP-{N}/TDD-{ID}-{N}.md`（结构遵循 [tdd-template.md](../../rules/requirement/tdd-template.md)）

| 类型 | 内容 |
|------|------|
| 硬输入 | 产品需求文档（`PRD-{ID}.md`）|
| 可选输入 | 架构设计（`ADD-{ID}.md`）、规约（`specs/`）、`knowledge/`、AGENTS.md |
| 固定输出 | `docs/requirements/REQUIREMENT-{ID}/MVP-{N}/TDD-{ID}-{N}.md` |
| 不产出 | 代码、自动化测试脚本（开发阶段产出）|

## 参数

| 参数 | 必需 | 默认值 | 说明 |
|------|------|--------|------|
| `--id` | 否 | `{REQUIREMENT-ID}-MVP{N}` | TDD 文档编号 |
| `--doc-root` | 否 | `docs` | 文档根目录 |
| `--prd` | 否 | — | 上游 PRD 编号，自动定位对应文件 |
| `--mvp` | 否 | `1` | 目标 MVP 阶段编号 |
| `--depth` | 否 | `standard` | 设计深度（quick / standard / deep），影响步骤 2–3 粒度 |

## 适用场景

| 场景 | 使用本技能 |
|------|-----------|
| 已有 PRD 与 ADD，需制定测试方案 | 是 |
| 需设计测试用例、测试数据与回归策略 | 是 |
| 收到业务需求/工单，需先输出解决方案文档 | 否 → **sdx-solution** |
| 已有解决方案，需进行需求分析 | 否 → **sdx-analysis** |
| 已有需求分析，需编写 PRD | 否 → **sdx-prd** |
| 已有 PRD，需技术方案设计 | 否 → **sdx-design** |

## 核心概念

- **测试策略**：确定测试层次（单元、集成、端到端）与覆盖率目标，按风险优先级分配测试资源
- **用例设计**：从用户故事验收标准、API 规约、业务规则三个维度设计测试用例，覆盖正常/异常/边界场景
- **回归策略**：基于影响面分析确定回归范围，关联变更功能与受影响的已有功能
- **进出标准**：定义测试进入条件（开发完成、环境就绪）与退出条件（用例通过率、缺陷标准）
- **TDD 文档**：遵循 [tdd-template.md](../../rules/requirement/tdd-template.md) 的六章结构

## 工作流（五步）

按顺序执行，每步产出作为下一步输入；最终文档需通过质量门禁。详细算法与决策点见 [reference/workflow-spec.md](reference/workflow-spec.md)。

### 步骤 1：测试策略与范围分析

从 PRD 的用户故事与 ADD 的架构设计出发，确定测试层次（单元/集成/端到端）与覆盖率目标；划定测试范围（新增/变更/回归）；识别测试风险与重点关注区域。

### 步骤 2：测试用例设计

基于用户故事验收标准设计功能测试用例；基于 API 规约设计接口测试用例；基于业务规则设计规则测试用例；补充异常场景、边界条件、性能与回归测试用例。

### 步骤 3：测试数据与环境规划

明确测试数据需求与准备方式（脚本生成/手工/生产脱敏）；定义测试环境要求（服务版本、数据库、中间件、外部依赖）。

### 步骤 4：进出标准与回归策略

定义测试进入标准（代码审查、单测覆盖、环境部署、数据就绪）；定义测试退出标准（用例通过率、缺陷标准、性能达标）；制定回归测试范围与策略。

### 步骤 5：文档输出与评审

将步骤 1–4 的产出整合为测试设计文档，严格采用 [tdd-template.md](../../rules/requirement/tdd-template.md) 的章节与格式；执行质量门禁自查。

质量门禁清单见 [assets/quality-gate-checklist.md](assets/quality-gate-checklist.md)。

可使用辅助脚本验证文档结构：

```bash
scripts/validate-test.sh --doc-root docs
```

## 核心约束

| 约束 | 说明 |
|------|------|
| 模板驱动 | 输出严格遵循 tdd-template.md 六章结构 |
| 证据优先 | 测试用例须引用 PRD 用户故事、ADD 接口规约与业务规则，禁止臆测 |
| 按需加载 | 仅在本轮需要时打开文件，禁止为完整性通读全仓 |
| 歧义标注 | 不确定项标为待澄清，禁止自行假设 |
| 范围清晰 | 仅产出测试设计文档，不涉及自动化测试代码 |
| 可追溯 | 每个测试用例可追溯到用户故事、API 规约或业务规则 |
| MVP 聚焦 | 仅覆盖目标 MVP 范围内的测试需求，不超越 MVP 边界 |

设计原则完整版与反模式清单见 [reference/design-principles.md](reference/design-principles.md)。

## 依赖关系

| 类型 | 技能/组件 | 说明 |
|------|-----------|------|
| 上游（必需） | `sdx-prd` | 提供产品需求文档（用户故事、业务规则）|
| 上游（推荐） | `sdx-design` | 提供架构设计文档（接口规约、组件设计）|
| 上游（可选） | `knowledge-extract` | 提供 `knowledge/*/*_knowledge.json` 与 `knowledge/KNOWLEDGE_INDEX.md` 基线 |

## 参考

| 资源 | 路径 |
|------|------|
| 设计原则与反模式 | [reference/design-principles.md](reference/design-principles.md) |
| 五步工作流详细规范 | [reference/workflow-spec.md](reference/workflow-spec.md) |
| 质量门禁验收清单 | [assets/quality-gate-checklist.md](assets/quality-gate-checklist.md) |
| 文档结构校验脚本 | [scripts/validate-test.sh](scripts/validate-test.sh) |
| TDD 文档模板 | [.cursor/rules/requirement/tdd-template.md](../../rules/requirement/tdd-template.md) |
| 上游：产品需求 | `.cursor/skills/sdx-prd/SKILL.md` |
| 上游：技术设计 | `.cursor/skills/sdx-design/SKILL.md` |
| 知识库 | `knowledge/`、`requirements/.../specs/` |
