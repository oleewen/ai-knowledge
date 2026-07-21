---
name: sdx-solution
description: >
  逐步确认参数，按模板分段「澄清 → 生成 → 烤干」直写 SOLUTION-{IDEA-ID}.md；
  每段写前意图澄清，写入后自动 grilling 至收敛，再由用户确认推进。
  用户提到 /sdx-solution、写方案、整理业务目标、需求模糊要结构化成共识级解决方案、
  写 SOLUTION-*.md / 七章方案、一口气写完整版、选 F 补齐剩余章节时，务必使用本技能（分段协议与 F 门禁；非法整篇覆盖也须加载本技能以拒绝）。
  分流：ANALYSIS/PRD/ASD/DSD/TDD 或 docs-* 主路径 → 对应技能，不以本技能代跑。
  推进见 references/gates.md。
compatibility: Bash 5+；校验脚本 agent/skills/sdx-solution/scripts/validate-solution.sh（仅结构/内容校验）。
---

# sdx-solution

## 输出硬门禁（P0）

- 对象=当前段；一次一段（除非 `F` 且已批确认意图）。
- 写前澄清 / 推进环 `C/M/G/F`（无 `S`）/ 烤干 → [intent-clarify.md](../../references/intent-clarify.md)、[unit-cycle-protocol.md](../../references/unit-cycle-protocol.md)、[grilling-skill.md](../../references/grilling-skill.md)、[docs-simplify.md](../../references/docs-simplify.md)；细节 [gates.md](references/gates.md)。

## 边界

| 负责 | 不负责 |
| --- | --- |
| `SOLUTION-{IDEA-ID}.md` 共识级方案、参数向导、意图澄清、分段生成、段内烤干、段落推进 | `ANALYSIS/PRD/ASD/DSD/TDD`；docs-* 主路径；实现级接口/表结构/中间件设计 |

## 不这样用

- 不走前置草稿 + 集中收口；默认参数向导后分段推进
- 不把整篇集中回炉或整份重生成当默认路径
- 不把写前意图澄清当成完整 grilling Skill 深挖
- 不把 `SOLUTION` 偷换成 `ANALYSIS/PRD/ASD/DSD/TDD` 或 docs-* 主路径

## 路由

| 目的 | 文件 |
| --- | --- |
| 流程 / 推进 binding | [workflow.md](references/workflow.md)、[gates.md](references/gates.md) |
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

## 产出与校验

- 正式：`{DOC_DIR}/solutions/SOLUTION-{IDEA-ID}.md`

```bash
agent/skills/sdx-solution/scripts/validate-solution.sh
agent/skills/sdx-solution/scripts/validate-solution.sh --file path/to/SOLUTION-xxx.md
```

## 评测

`evals/evals.json`、[grader.md](agents/grader.md)。聚焦：意图澄清、当前段推进、边界分流。
