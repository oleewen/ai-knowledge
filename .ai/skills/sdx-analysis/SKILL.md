---
name: sdx-analysis
description: >
  需求分析：基于解决方案文档与知识库进行深度研究、需求细化、MVP 拆分与依赖/风险评估，输出需求分析文档。
  在用户执行 /sdx-analysis、编写需求分析文档、或进行方案→需求分析时使用。
  产出 system/analysis/ANALYSIS-{ID}.md；模板见 assets/analysis-template.md；工作流与门禁见 reference/。
  主要面向产品经理与需求分析师；技术实现细节留给 sdx-design。
---

# 需求分析阶段（sdx-analysis）

在解决方案与事实材料基础上，将共识级方案细化为**可评审、可排期、可验收**的需求分析：划清范围、拆 MVP、标优先级与依赖，并识别风险。**主要读者为产品经理与需求分析师**（业务方参与范围与验收对齐）；研发以本阶段产出为输入编写 PRD/技术方案。

**执行顺序建议**：先读本文件与 `gotchas.md` → 步骤 1–4 按需打开 `workflow-spec.md` → 输出前打开 `analysis-template.md` 与 `quality-checklist.md`。

## 输入与输出

**输入**：解决方案文档（`system/solutions/`）；为校准范围与事实可**按需**查阅 `knowledge/`、各 `requirements/.../specs/` 或 `knowledge/technical/`（**勿将工程细节原样写入需求分析正文**）。  
**输出**：`system/analysis/ANALYSIS-{ID}.md`（结构遵循 [assets/analysis-template.md](assets/analysis-template.md)）

| 类型 | 内容 |
|------|------|
| 硬输入 | 解决方案文档（`system/solutions/SOLUTION-{ID}.md`） |
| 可选输入 | `knowledge/`、`requirements/.../specs/`、`knowledge/technical/`、AGENTS.md |
| 固定输出 | `system/analysis/ANALYSIS-{ID}.md` |
| 不产出 | PRD、ADD、测试设计、代码（使用下游 sdx-prd / sdx-design / sdx-test） |

## 参数

| 参数 | 必需 | 默认值 | 说明 |
|------|------|--------|------|
| `--id` | 否 | `YYYYMMDD-SEQ` | 需求分析文档编号 |
| `--doc-root` | 否 | `docs` | 文档根目录 |
| `--depth` | 否 | `standard` | 分析深度（quick / standard / deep），影响步骤 1–2 粒度 |
| `--solution` | 否 | — | 上游解决方案编号，自动定位对应文件 |

## 适用场景

| 场景 | 使用本技能 |
|------|-----------|
| 已有解决方案，需要进行需求分析与 MVP 拆分 | 是 |
| 需将高层方案细化为可度量的功能与非功能诉求（仍以业务/产品可读的表述呈现） | 是 |
| 收到业务需求/工单，需先输出解决方案文档 | 否 → **sdx-solution** |
| 已有需求分析，需要编写 PRD | 否 → **sdx-prd** |
| 已有 PRD，需技术方案设计 | 否 → **sdx-design** |

## 工作流（五步）

按顺序执行；每步算法、depth 差异与 Q-n 处理见 [reference/workflow-spec.md](reference/workflow-spec.md)。

1. **深度研究与探索** — 边界、规则、协作与风险；按影响面按需读库，禁止通读全仓。
2. **需求细化与建模** — FR/BR/非功能/数据对象（业务语义）；歧义标 Q-n，按 sdx-solution 协议交互确认后再进步骤 3。
3. **MVP 拆分与规划** — 独立价值、单向依赖、P0 进首包。
4. **依赖分析与风险评估** — R-n、协作与外部依赖，业务影响表述。
5. **文档输出与评审** — 严格套 [assets/analysis-template.md](assets/analysis-template.md)；按 [reference/quality-checklist.md](reference/quality-checklist.md) 自查。

辅助校验（于**文档根**执行，路径以仓库为准）：

```bash
.ai/skills/sdx-analysis/scripts/validate-analysis.sh --doc-root docs
```

## 核心约束

| 约束 | 说明 |
|------|------|
| 模板驱动 | 输出严格遵循 `analysis-template.md` 八章结构 |
| 受众可读 | 正文以产品/需求语言为主；细则见 [reference/audience-and-language.md](reference/audience-and-language.md) 与 [../sdx-solution/reference/audience-and-language.md](../sdx-solution/reference/audience-and-language.md) |
| 证据优先 | 须引用解决方案与 `knowledge/` 等校准，禁止臆测；写入时转为需求/业务表述 |
| 按需加载 | 仅在本轮需要时打开文件，禁止为完整性通读全仓 |
| 歧义标注 | 不确定项标 Q-n，**逐一向用户提问确认**（每题 3–4 个选项 + 「其他」）；交互格式见 [../sdx-solution/reference/workflow-spec.md](../sdx-solution/reference/workflow-spec.md) |
| 范围清晰 | 仅产出需求分析文档，不涉及 PRD / ADD / 代码 |
| 可追溯 | FR→G、BR→FR、MVP→FR、R→依赖或影响面 |

完整原则、反模式、编号体系与错误处理见 [reference/design-principles.md](reference/design-principles.md)。

## 依赖关系

| 类型 | 技能/组件 | 说明 |
|------|-----------|------|
| 上游（必需） | `sdx-solution` | 提供解决方案文档作为核心输入 |
| 上游（可选） | `knowledge-extract` | 提供 `knowledge/*/*_knowledge.json` 与 `knowledge/KNOWLEDGE_INDEX.md` 基线 |
| 下游 | `sdx-prd` | 基于需求分析转化为产品需求文档 |
| 下游 | `sdx-design` | 基于 PRD 进行技术方案设计 |
| 下游 | `sdx-test` | 基于 PRD 与 ADD 进行测试设计 |

## 参考

| 资源 | 路径 |
|------|------|
| 五步工作流（算法、depth、Q-n、数据流） | [reference/workflow-spec.md](reference/workflow-spec.md) |
| 受众与文档语言 | [reference/audience-and-language.md](reference/audience-and-language.md) |
| 核心概念口径 | [reference/core-concepts.md](reference/core-concepts.md) |
| 设计原则、反模式、错误处理 | [reference/design-principles.md](reference/design-principles.md) |
| 质量验收清单 | [reference/quality-checklist.md](reference/quality-checklist.md) |
| 需求分析文档模板 | [assets/analysis-template.md](assets/analysis-template.md) |
| 常见陷阱与防错 | [gotchas.md](gotchas.md) |
| 文档结构校验脚本 | [scripts/validate-analysis.sh](scripts/validate-analysis.sh) |
| 上游：解决方案 | `.ai/skills/sdx-solution/SKILL.md` |
| 受众语言规范（与解决方案阶段同原则） | `.ai/skills/sdx-solution/reference/audience-and-language.md` |
| 下游：产品需求 | `.ai/skills/sdx-prd/SKILL.md` |
| 下游：技术设计 | `.ai/skills/sdx-design/SKILL.md` |
| 知识库 | `knowledge/`、`requirements/.../specs/`、`knowledge/technical/` |
