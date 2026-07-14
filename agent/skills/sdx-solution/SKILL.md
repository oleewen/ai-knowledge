---
name: sdx-solution
description: >
  逐步确认参数，按模板分段生成并直写 SOLUTION-{IDEA-ID}.md；
  每段生成后自动 grilling 补强至收敛，用户确认后再推进下一段。
  触发：/sdx-solution、「写方案」「整理业务目标」、需求模糊需结构化并形成共识级解决方案。
  分流：只要 ANALYSIS/PRD/ASD/DSD/TDD 或 docs-* 主路径 → 对应技能。
  推进协议：参数向导、当前段、自动 grilling、回改与用户动作见 references/gates.md。
compatibility: Bash 5+；校验脚本 agent/skills/sdx-solution/scripts/validate-solution.sh（仅结构/内容校验）。
---

# sdx-solution

读 references/ → 参数向导 → 分段直写终稿 → 每段自动 grilling 补强至收敛 → 用户确认推进。

## 输出硬门禁（P0）

- 一次只处理一个“当前段”（章节或子章节），不得一口气补齐多段。
- 当前段写入终稿后，必须进入自动 `grilling` 循环；仅当当前段已收敛，或打出必须等待用户确认的语义性问题时，才把控制权交还用户。
- 自动 `grilling` 收敛后，输出 `C/M/G/F` 选项并停止等待用户选择；不得自动推进下一段。
- `F` 仅表示在当前段已收敛后，一次性补齐当前文档剩余未完成章节；不得覆盖已确认前文。
- 若用户一开始就要求“一次性生成整篇”，仍先完成当前段并自动 `grilling` 至收敛，再由用户明确选择 `F` 进入批量补齐。
- `grilling` 过程中如发现**语义性问题**（改变目标/范围/承诺/口径/取舍/风险/MVP/里程碑/术语等），必须先给出结论、推荐修订与数字选项并等待用户确认；未获确认不得修订当前段。
- 仅**非语义性修订**（不改变含义的错别字/编号/排版等）可在当前段默认授权下直接修订；不确定时按语义性处理。

## 边界

| 负责 | 不负责 |
| --- | --- |
| `SOLUTION-{IDEA-ID}.md` 共识级解决方案、参数向导、分段生成、段内补强、段落推进 | `ANALYSIS/PRD/ASD/DSD/TDD`；docs-* 主路径；实现级接口/表结构/中间件设计 |

## 不这样用

- 不走前置草稿 + 集中收口主线；主线是参数向导后直接分段直写终稿
- 不把整篇集中回炉或整份重生成当默认路径
- 不把 `SOLUTION` 阶段偷换成 `ANALYSIS/PRD/ASD/DSD/TDD` 或 docs-* 主路径

## 路由

| 目的 | 文件 |
| --- | --- |
| 流程 | [workflow.md](references/workflow.md) |
| 推进协议 | [gates.md](references/gates.md) |
| grilling 能力 | [grilling-skill.md](../../references/grilling-skill.md) |
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

段落推进、前文回改、自动 `grilling` 与用户动作 `C/M/G/F` 见 [gates.md](references/gates.md)。

## 产出与校验

- 正式：`{DOC_DIR}/solutions/SOLUTION-{IDEA-ID}.md`

```bash
agent/skills/sdx-solution/scripts/validate-solution.sh
agent/skills/sdx-solution/scripts/validate-solution.sh --file path/to/SOLUTION-xxx.md
```

## 评测 / 钩子

评测：`evals/evals.json`、[grader.md](agents/grader.md)。
`sdx-solution` 评测聚焦当前段推进协议与结构校验。
