---
name: sdx-analysis
description: >
  在已共识 SOLUTION 上按六章分段「澄清 → 生成 → 烤干」细化 FR/MVP/依赖/风险，
  并直写 ANALYSIS-{IDEA-ID}.md；每段写前意图澄清，写入后自动 grilling 至收敛，用户确认后再推进下一段。
  用户提到 /sdx-analysis、拆 MVP、需求分析、细化方案且可对齐上游 SOLUTION 时，使用本技能。
  分流：无 SOLUTION、只要其他 SDX 阶段或 docs-* 主路径 → 对应技能，不以本技能代跑。
  推进见 references/gates.md。
compatibility: Bash 5+；校验脚本 agent/skills/sdx-analysis/scripts/validate-analysis.sh（仅结构/内容校验）。
---

# sdx-analysis

## 输出硬门禁（P0）

- 对象=当前段（`§2` 先独立确认 `### 概览`，再可细到单个 `FR`）；一次一段（除非 `F` 且已批确认意图；概览段 `F` 不得跳过写后确认）。
- 写前澄清 / 推进环 `C/M/G/F`（无 `S`）/ 烤干 → [intent-clarify.md](../../references/intent-clarify.md)、[unit-cycle-protocol.md](../../references/unit-cycle-protocol.md)、[grilling-skill.md](../../references/grilling-skill.md)、[docs-simplify.md](../../references/docs-simplify.md)、[sdx-adr-protocol.md](../../references/sdx-adr-protocol.md)；细节 [gates.md](references/gates.md)。
- 无已共识 SOLUTION → 引导 [sdx-solution](../sdx-solution/SKILL.md)，不以本技能代写。
- 上游 §6.1 里程碑不可用 → 硬停回补；概览按里程碑范围拆 FR；§4 再划 `MVP{n}`（与里程碑不硬对齐）。

## 边界

| 负责 | 不负责 |
| --- | --- |
| `ANALYSIS-{IDEA-ID}.md` 分析生成与推进、参数向导、意图澄清、分段生成、段内烤干、段落推进 | `SOLUTION`；`PRD/ASD/DSD/TDD`；docs-*；实现级设计 |

## 不这样用

- 不走前置草稿 + 集中收口；默认参数向导后分段推进
- 不把整篇集中回炉或整份重生成当默认路径
- 不把写前意图澄清当成完整 grilling Skill 深挖
- 不把 `ANALYSIS` 阶段偷换成 `PRD/ASD/DSD/TDD` 或 docs-* 主路径

## 路由

| 目的 | 文件 |
| --- | --- |
| 流程 / 推进 binding | [workflow.md](references/workflow.md)、[gates.md](references/gates.md) |
| IDEA-ID / depth | [core-concepts.md](references/core-concepts.md) |
| 原则 / 反模式 | [design-principles.md](references/design-principles.md)、[anti-patterns.md](references/anti-patterns.md) |
| 易错 / 受众 / 终检 | [gotchas.md](gotchas.md)、[audience-and-language.md](references/audience-and-language.md)、[quality-checklist.md](references/quality-checklist.md) |
| 技术决策 ADR | [sdx-adr-protocol.md](../../references/sdx-adr-protocol.md) |
| 模板 | [analysis-template.md](assets/analysis-template.md) |

## 最少输入

- 可对齐的 **`SOLUTION-{IDEA-ID}.md`** 或等价已共识方案材料
- 可确定的主题或标题线索
- `{DOC_DIR}/analysis/` 可写
- 若已给 `IDEA-ID`、章节范围、深度，则直接进入参数向导确认

## 产出与校验

- 正式：`{DOC_DIR}/analysis/ANALYSIS-{IDEA-ID}.md`

```bash
agent/skills/sdx-analysis/scripts/validate-analysis.sh
agent/skills/sdx-analysis/scripts/validate-analysis.sh --file path/to/ANALYSIS-xxx.md
```

## 评测

`evals/evals.json`、[grader.md](agents/grader.md)。聚焦：意图澄清、当前段推进、边界分流。
