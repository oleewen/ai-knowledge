---
name: sdx-analysis
description: >
  在已共识 SOLUTION 上按六章分段「澄清 → 生成 → 烤干」细化 FR/MVP/依赖/风险，
  并直写 ANALYSIS-{IDEA-ID}.md；每段写前意图澄清，写入后自动 grilling 至收敛，用户确认后再推进下一段。
  触发：/sdx-analysis、「拆 MVP」「需求分析」「细化方案」且可对齐上游 SOLUTION。
  分流：无 SOLUTION、只要其他 SDX 阶段或 docs-* 主路径 → 对应技能。
  推进协议：参数向导、当前段；见 references/gates.md 与 intent-clarify / unit-cycle-protocol / grilling-skill。
compatibility: Bash 5+；校验脚本 agent/skills/sdx-analysis/scripts/validate-analysis.sh（仅结构/内容校验）。
---

# sdx-analysis

读 references/ → 参数向导 → 分段「澄清 → 生成 → 烤干」→ 用户确认推进。无 SOLUTION → 引导 sdx-solution。

## 输出硬门禁（P0）

- 对象=当前段（§2 可细到单个 `FR`）；一次一段（除非 `F` 且已批确认意图）。
- 写前意图澄清 → [intent-clarify.md](../../references/intent-clarify.md)
- 推进环/动作/重开 → [unit-cycle-protocol.md](../../references/unit-cycle-protocol.md)（sdx 无 `S`）
- 烤干能力 → [grilling-skill.md](../../references/grilling-skill.md)

## 边界

| 负责 | 不负责 |
| --- | --- |
| `ANALYSIS-{IDEA-ID}.md` 分析生成与推进、意图澄清、烤干 | `SOLUTION`；`PRD/ASD/DSD/TDD`；docs-*；实现级设计 |

## 不这样用

- 不走前置草稿 + 集中收口主线；主线是参数向导后分段「澄清 → 生成 → 烤干」
- 不把整篇集中回炉或整份重生成当默认路径
- 不把写前意图澄清当成完整 grilling Skill 深挖
- 不把 `ANALYSIS` 阶段偷换成 `PRD/ASD/DSD/TDD` 或 docs-* 主路径

## 路由

| 目的 | 文件 |
| --- | --- |
| 流程 | [workflow.md](references/workflow.md) |
| 推进协议 | [gates.md](references/gates.md) |
| 推进环 / 动作 | [unit-cycle-protocol.md](../../references/unit-cycle-protocol.md) |
| 意图澄清 | [intent-clarify.md](../../references/intent-clarify.md) |
| grilling / 烤干 | [grilling-skill.md](../../references/grilling-skill.md) |
| IDEA-ID / depth | [core-concepts.md](references/core-concepts.md) |
| 原则 / 反模式 | [design-principles.md](references/design-principles.md)、[anti-patterns.md](references/anti-patterns.md) |
| 易错 / 受众 / 终检 | [gotchas.md](gotchas.md)、[audience-and-language.md](references/audience-and-language.md)、[quality-checklist.md](references/quality-checklist.md) |
| 模板 | [analysis-template.md](assets/analysis-template.md) |

## 最少输入

- 可对齐的 **`SOLUTION-{IDEA-ID}.md`** 或等价已共识方案材料
- 可确定的主题或标题线索
- `{DOC_DIR}/analysis/` 可写
- 若已给 `IDEA-ID`、章节范围、深度，则直接进入参数向导确认

## 推进协议

见 [gates.md](references/gates.md)；SSOTs：[intent-clarify.md](../../references/intent-clarify.md)、[unit-cycle-protocol.md](../../references/unit-cycle-protocol.md)（sdx 无 `S`）、[grilling-skill.md](../../references/grilling-skill.md)。

## 产出与校验

- 正式：`{DOC_DIR}/analysis/ANALYSIS-{IDEA-ID}.md`

```bash
agent/skills/sdx-analysis/scripts/validate-analysis.sh
agent/skills/sdx-analysis/scripts/validate-analysis.sh --file path/to/ANALYSIS-xxx.md
```

## 评测 / 钩子

评测：`evals/evals.json`、[grader.md](agents/grader.md)。
`sdx-analysis` 评测聚焦意图澄清、当前段推进协议与结构校验。
