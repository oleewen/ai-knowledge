---
name: sdx-solution
description: >
  逐步确认参数，按模板分段生成并直写 SOLUTION-{IDEA-ID}.md；
  每段生成后进入 grilling 补强，用户确认后再推进下一段。
  触发：/sdx-solution、「写方案」「整理业务目标」、需求模糊需结构化并形成共识级解决方案。
  分流：只要 ANALYSIS/PRD/ASD/DSD/TDD 或 docs-* 主路径 → 对应技能。
  推进协议：段落推进、回改与用户动作见 gates.md。
compatibility: Bash 5+；校验脚本 agent/skills/sdx-solution/scripts/validate-solution.sh。
---

# sdx-solution

读 references/ → 参数向导 → 分段直写终稿 → 每段 grilling 补强 → 用户确认推进。

## 边界

| 负责 | 不负责 |
| --- | --- |
| `SOLUTION-{IDEA-ID}.md` 共识级解决方案、参数向导、分段生成、段内补强、段落推进 | `ANALYSIS/PRD/ASD/DSD/TDD`；docs-* 主路径；实现级接口/表结构/中间件设计 |

## 路由

| 目的 | 文件 |
| --- | --- |
| 流程 | [workflow.md](references/workflow.md) |
| 推进协议 | [gates.md](references/gates.md) |
| grilling 能力 | [grilling-skill.md](../../references/grilling-skill.md) |
| brainstorming | [brainstorming-integration.md](references/brainstorming-integration.md) |
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

段落推进、前文回改、用户动作 `C/M/G/S/F` 见 [gates.md](references/gates.md)。

## 产出与校验

- 正式：`{DOC_DIR}/solutions/SOLUTION-{IDEA-ID}.md`

```bash
agent/skills/sdx-solution/scripts/validate-solution.sh
agent/skills/sdx-solution/scripts/validate-solution.sh --file path/to/SOLUTION-xxx.md
```

## 评测 / 钩子

评测：`evals/evals.json`、[grader.md](agents/grader.md)。
