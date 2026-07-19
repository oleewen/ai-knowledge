---
name: sdx-prd
description: >
  在已共识 ANALYSIS 当前 MVP 上按十一章分段「澄清 → 生成 → 烤干」直写 PRD-{IDEA-ID}-{N}.md；
  每段写前意图澄清，写入后自动 grilling 至收敛，再由用户确认推进。
  用户提到 /sdx-prd、写 PRD、细化用户故事/业务流程且可对齐上游 ANALYSIS 时，使用本技能。
  分流：无 ANALYSIS、只要其他 SDX 阶段或 docs-* 主路径 → 对应技能，不以本技能代跑。
  推进见 references/gates.md。
compatibility: Bash 5+；校验脚本 agent/skills/sdx-prd/scripts/validate-prd.sh（仅结构/内容校验）。
---

# sdx-prd

## 输出硬门禁（P0）

- 对象=当前段（章节 / `UC` / `US`）；一次一段（除非 `F` 且已批确认意图）。
- 写前澄清 / 推进环 `C/M/G/F`（无 `S`）/ 烤干 → [intent-clarify.md](../../references/intent-clarify.md)、[unit-cycle-protocol.md](../../references/unit-cycle-protocol.md)、[grilling-skill.md](../../references/grilling-skill.md)；细节 [gates.md](references/gates.md)。
- 上游须可对齐 `ANALYSIS-{IDEA-ID}.md` 与目标 `MVP-Phase-{N}`；否则引导 `sdx-analysis`。

## 边界

| 负责 | 不负责 |
| --- | --- |
| `PRD-{IDEA-ID}-{N}.md` 共识级产品需求、参数向导、意图澄清、分段生成、段内烤干、十一章用户故事/用例/流程/验收 | `SOLUTION/ANALYSIS` 初稿；`ASD/DSD/TDD`；docs-* 主路径；实现级接口/DDL/中间件设计 |

## 不这样用

- 不走前置草稿 + 集中收口；默认参数向导后分段推进
- 不把整篇集中回炉或整份重生成当默认路径
- 不把写前意图澄清当成完整 grilling Skill 深挖
- 不把 `PRD` 偷换成 `ANALYSIS/ASD/DSD/TDD` 或 docs-* 主路径

## 路由

| 目的 | 文件 |
| --- | --- |
| 流程 / 推进 binding | [workflow.md](references/workflow.md)、[gates.md](references/gates.md) |
| IDEA-ID / MVP-Phase | [core-concepts.md](references/core-concepts.md) |
| 原则 / 反模式 | [design-principles.md](references/design-principles.md)、[anti-patterns.md](references/anti-patterns.md) |
| 易错 / 受众 / 终检 | [gotchas.md](gotchas.md)、[audience-and-language.md](references/audience-and-language.md)、[quality-checklist.md](references/quality-checklist.md) |
| 模板 | [prd-template.md](assets/prd-template.md) |

## 最少输入

- 可对齐的 **`ANALYSIS-{IDEA-ID}.md`** 与目标 **`MVP-Phase-{N}`**
- 可确定的主题或标题线索
- `{DOC_DIR}/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/` 可写
- 若已给 `IDEA-ID`、`N`、章节范围、深度，则直接进入参数向导确认

## 产出与校验

- 正式：`{DOC_DIR}/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/PRD-{IDEA-ID}-{N}.md`

```bash
agent/skills/sdx-prd/scripts/validate-prd.sh
agent/skills/sdx-prd/scripts/validate-prd.sh --file path/to/PRD-xxx.md
```

## 评测

`evals/evals.json`、[grader.md](agents/grader.md)。聚焦：意图澄清、当前段推进、上游 ANALYSIS/MVP、边界分流。
