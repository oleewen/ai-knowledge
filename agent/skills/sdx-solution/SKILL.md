---
name: sdx-solution
description: >
  逐步确认参数，按模板分段「澄清 → 生成 → 烤干」直写 SOLUTION-{IDEA-ID}.md；
  每段写前意图澄清，写入后自动 grilling 至收敛，用户确认后再推进下一段。
  触发：/sdx-solution、「写方案」「整理业务目标」、需求模糊需结构化并形成共识级解决方案。
  分流：只要 ANALYSIS/PRD/ASD/DSD/TDD 或 docs-* 主路径 → 对应技能。
  推进协议：参数向导、当前段；见 references/gates.md 与 intent-clarify / unit-cycle-protocol / grilling-skill。
compatibility: Bash 5+；校验脚本 agent/skills/sdx-solution/scripts/validate-solution.sh（仅结构/内容校验）。
---

# sdx-solution

读 references/ → 参数向导 → 分段「澄清 → 生成 → 烤干」→ 用户确认推进。

## 输出硬门禁（P0）

- 对象=当前段；一次一段（除非 `F` 且已批确认意图）。
- 写前意图澄清 → [intent-clarify.md](../../references/intent-clarify.md)
- 推进环/动作/重开 → [unit-cycle-protocol.md](../../references/unit-cycle-protocol.md)（sdx 无 `S`）
- 烤干能力 → [grilling-skill.md](../../references/grilling-skill.md)

## 边界

| 负责 | 不负责 |
| --- | --- |
| `SOLUTION-{IDEA-ID}.md` 共识级解决方案、参数向导、意图澄清、分段生成、段内烤干、段落推进 | `ANALYSIS/PRD/ASD/DSD/TDD`；docs-* 主路径；实现级接口/表结构/中间件设计 |

## 不这样用

- 不走前置草稿 + 集中收口主线；主线是参数向导后分段「澄清 → 生成 → 烤干」
- 不把整篇集中回炉或整份重生成当默认路径
- 不把写前意图澄清当成完整 grilling Skill 深挖
- 不把 `SOLUTION` 阶段偷换成 `ANALYSIS/PRD/ASD/DSD/TDD` 或 docs-* 主路径

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
| 模板 | [solution-template.md](assets/solution-template.md) |
| sdx 族结构 | [sdx-skill-skeleton.md](references/sdx-skill-skeleton.md) |

## 最少输入

- 原始业务描述或待整理材料
- 可确定的主题或标题线索
- `{DOC_DIR}/solutions/` 可写
- 若已给 `IDEA-ID`、章节范围、深度，则直接进入参数向导确认

## 推进协议

见 [gates.md](references/gates.md)；SSOTs：[intent-clarify.md](../../references/intent-clarify.md)、[unit-cycle-protocol.md](../../references/unit-cycle-protocol.md)（sdx 无 `S`）、[grilling-skill.md](../../references/grilling-skill.md)。

## 产出与校验

- 正式：`{DOC_DIR}/solutions/SOLUTION-{IDEA-ID}.md`

```bash
agent/skills/sdx-solution/scripts/validate-solution.sh
agent/skills/sdx-solution/scripts/validate-solution.sh --file path/to/SOLUTION-xxx.md
```

## 评测 / 钩子

评测：`evals/evals.json`、[grader.md](agents/grader.md)。
`sdx-solution` 评测聚焦意图澄清、当前段推进协议与结构校验。
