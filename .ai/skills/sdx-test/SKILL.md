---
name: sdx-test
description: >
  测试方案设计：基于 PRD 与 ADD 制定测试策略与计划，输出测试设计文档（TDD）。
  在用户执行 /sdx-test、编写测试设计/测试计划时使用。
  产出 system/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/TDD-{IDEA-ID}-{N}.md（**IDEA-ID** 见 reference/core-concepts.md 与 ../sdx-solution/reference/core-concepts.md#idea-id）；模板见 assets/tdd-template.md；
  工作流与门禁见 reference/；陷阱见 gotchas.md。交付文档元数据仅在文末，勿用文件头 frontmatter。
---

# 测试设计阶段（sdx-test）

基于产品需求文档与技术设计文档，制定当前 MVP 的测试策略与测试计划，设计测试用例、测试数据与回归范围，输出测试设计文档（TDD），为后续开发与测试验证提供依据。

**执行顺序建议**：先读本文件与 [gotchas.md](gotchas.md) → 步骤 1–5 的算法与 depth 见 [reference/workflow-spec.md](reference/workflow-spec.md) → 输出前打开 [assets/tdd-template.md](assets/tdd-template.md) 与 [reference/quality-checklist.md](reference/quality-checklist.md)。

## 命名与落盘约定

- **IDEA-ID**：定义见 [../sdx-solution/reference/core-concepts.md#idea-id](../sdx-solution/reference/core-concepts.md#idea-id)；本阶段 TDD 路径见 [reference/core-concepts.md#idea-id](reference/core-concepts.md#idea-id)。
- **主交付文件名**：`TDD-{IDEA-ID}-{N}.md`，与同一阶段 `PRD-{IDEA-ID}-{N}.md`、`ADD-{IDEA-ID}-{N}.md` 的 **IDEA-ID** **完全一致**（类型前缀 `TDD`）。
- **路径**：`system/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/`，需求包目录前缀 `REQUIREMENT-`，与上游 `ANALYSIS-{IDEA-ID}.md` 及同目录下 PRD/ADD 一致；阶段目录为 `MVP-Phase-{N}/`（**不是** `MVP-{N}/`），见 [system/requirements/README.md](../../../system/requirements/README.md)。
- **元数据位置**：TDD 正文从标题起；`id`、`title`、`parent` 等 **仅** 放在全文末尾「## 文档元数据」下的 fenced YAML（与 [assets/tdd-template.md](assets/tdd-template.md)），**禁止**文件头 `---` YAML。

## 输入与输出

**输入**：产品需求（`system/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/PRD-{IDEA-ID}-{N}.md`）、架构设计（`system/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/ADD-{IDEA-ID}-{N}.md`）、规约（`.../specs/`）  
**输出**：`system/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/TDD-{IDEA-ID}-{N}.md`（结构遵循 [assets/tdd-template.md](assets/tdd-template.md)）

| 类型 | 内容 |
|------|------|
| 硬输入 | 产品需求文档（`system/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/PRD-{IDEA-ID}-{N}.md`） |
| 可选输入 | 架构设计（`.../ADD-{IDEA-ID}.md`）、规约（`specs/`）、`knowledge/`、AGENTS.md |
| 固定输出 | `system/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/TDD-{IDEA-ID}-{N}.md` |
| 不产出 | 代码、自动化测试脚本、测试执行报告（实现与执行阶段产出） |

## 参数

| 参数 | 必需 | 默认值 | 说明 |
|------|------|--------|------|
| `--id` | 否 | `IDEA-ID` | 与 PRD/ADD 一致，用于 `REQUIREMENT-{IDEA-ID}/` 与 `TDD-{IDEA-ID}-{N}.md`；定义见 [../sdx-solution/reference/core-concepts.md#idea-id](../sdx-solution/reference/core-concepts.md#idea-id) |
| `--doc-root` | 否 | `system` | 文档根目录；校验脚本在 `${DOC_ROOT}` 下递归查找 `TDD-*.md`；旧布局可用 `docs` |
| `--prd` | 否 | — | 上游 PRD 或 `PRD-*.md` stem，自动定位对应文件 |
| `--mvp` | 否 | `1` | 目标 MVP 阶段编号（`MVP-Phase-{N}`） |
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

## 工作流（五步）

按顺序执行；每步角色、算法、ADD 缺失分支、depth 差异与步间数据流见 [reference/workflow-spec.md](reference/workflow-spec.md)。

1. **测试策略与范围分析** — 层次与覆盖目标；新增/变更/回归；风险与重点区域。
2. **测试用例设计** — 功能 / 接口 / 规则 / 异常 /（deep 时）性能与安全；回归用例与影响面对齐。
3. **测试数据与环境规划** — 数据需求、准备方式、环境依赖与 Mock 策略。
4. **进出标准与回归策略** — 进入/退出可度量条件；回归执行顺序。
5. **文档输出与评审** — 套 [assets/tdd-template.md](assets/tdd-template.md)；按 [reference/quality-checklist.md](reference/quality-checklist.md) 自查。

辅助校验（于**仓库根**执行）：

```bash
.ai/skills/sdx-test/scripts/validate-test.sh --doc-root system
```

## 核心约束

| 约束 | 说明 |
|------|------|
| 模板驱动 | 输出严格遵循 tdd-template.md 六章结构 |
| 证据优先 | 用例须引用 PRD 用户故事、ADD 接口规约与业务规则，禁止臆测 |
| 按需加载 | 仅在本轮需要时打开文件，禁止为完整性通读全仓 |
| 歧义标注 | 不确定项标为待澄清，禁止自行假设 |
| 范围清晰 | 仅产出测试设计文档，不涉及自动化测试代码 |
| 可追溯 | 每个用例可追溯到用户故事、API 规约或业务规则 |
| MVP 聚焦 | 仅覆盖目标 MVP 范围，不超越 MVP 边界 |

术语口径见 [reference/core-concepts.md](reference/core-concepts.md)；著文语气见 [reference/audience-and-language.md](reference/audience-and-language.md)。完整原则、反模式、编号体系与错误处理见 [reference/design-principles.md](reference/design-principles.md)。

## 依赖关系

| 类型 | 技能/组件 | 说明 |
|------|-----------|------|
| 上游（必需） | `sdx-prd` | 提供产品需求文档（用户故事、业务规则） |
| 上游（推荐） | `sdx-design` | 提供架构设计文档（接口规约、组件设计） |
| 上游（可选） | `docs-build` | 提供 `knowledge/*/*_knowledge.json` 与 `knowledge/KNOWLEDGE_INDEX.md` 基线 |

## 参考

| 资源 | 路径 |
|------|------|
| 五步工作流（算法、depth、数据流） | [reference/workflow-spec.md](reference/workflow-spec.md) |
| 受众与文档语言 | [reference/audience-and-language.md](reference/audience-and-language.md) |
| 核心概念口径（含本阶段 **IDEA-ID** 落盘示例） | [reference/core-concepts.md#idea-id](reference/core-concepts.md#idea-id) |
| **IDEA-ID**（权威定义） | [../sdx-solution/reference/core-concepts.md#idea-id](../sdx-solution/reference/core-concepts.md#idea-id) |
| 设计原则、反模式、错误处理 | [reference/design-principles.md](reference/design-principles.md) |
| 质量验收清单 | [reference/quality-checklist.md](reference/quality-checklist.md) |
| 常见陷阱与防错 | [gotchas.md](gotchas.md) |
| TDD 文档模板 | [assets/tdd-template.md](assets/tdd-template.md) |
| 文档结构校验脚本 | [scripts/validate-test.sh](scripts/validate-test.sh) |
| 上游：产品需求 | `.ai/skills/sdx-prd/SKILL.md` |
| 上游：技术设计 | `.ai/skills/sdx-design/SKILL.md` |
| 知识库 | `knowledge/`、`requirements/.../specs/` |
