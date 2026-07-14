---
name: sdx-test
description: >
  基于已共识 PRD 与 DSD（及 ASD）按六章分段细化测试策略、用例、数据、环境、进出标准与回归范围，并直写 TDD-{IDEA-ID}-{N}.md；
  每段生成后自动 grilling 补强至收敛，用户确认后再推进下一段。
  触发：/sdx-test、「测试方案」「用例」「TDD」「PRD/DSD 转测试」。
  分流：只要上游 SDX 正文或 docs-* 主路径 → 对应技能。不产出自动化代码与执行报告。
  推进协议：参数向导、当前段、自动 grilling、前文回改与用户动作见 references/gates.md。
compatibility: Bash 5+；校验脚本 agent/skills/sdx-test/scripts/validate-test.sh（仅结构/内容校验）。
---

# sdx-test

读 references/ → 参数向导 → 分段直写终稿 → 每段自动 grilling 补强至收敛 → 用户确认推进。无 PRD → 引导 `sdx-prd`；缺 DSD 时按范围收窄并标基线盲区。**不产自动化代码与执行报告。**

## 输出硬门禁（P0）

- 一次只处理一个“当前段”（章节、子章节、单个用例组、单个接口异常组、单个回归范围块、单个进出标准块或单个数据/环境块）；禁止一口气补齐多段。
- 当前段写入终稿后，必须进入自动 `grilling` 循环；仅当当前段已收敛，或打出必须等待用户确认的语义性问题时，才把控制权交还用户。
- 自动 `grilling` 收敛后，输出 `C/M/G/F` 选项并停止等待用户选择；不得自动推进下一段。
- `F` 仅表示在当前段已收敛后，一次性补齐当前文档剩余未完成章节；不得覆盖已确认前文。
- 若用户一开始就要求“一次性生成整篇”，仍先完成当前段并自动 `grilling` 至收敛，再由用户明确选择 `F` 进入批量补齐。
- `grilling` 过程中如发现**语义性问题**（改变测试范围、优先级、回归边界、用例口径、环境约束、退出标准、术语等），必须先给出结论、推荐修订与数字选项并等待用户确认；未获确认不得修订当前段。
- 仅**非语义性修订**（不改变含义的错别字、编号、排版等）可在当前段默认授权下直接修订；不确定时按语义性处理。

## 边界

| 负责 | 不负责 |
| --- | --- |
| `TDD-{IDEA-ID}-{N}.md` 生成与推进、六章测试设计、用例/回归/进出标准/数据/环境设计 | 自动化测试代码、执行报告；以其他 SDX 替代 TDD；docs-* 主路径 |

## 不这样用

- 不走前置草稿 + 集中收口主线；主线是参数向导后直接分段直写终稿
- 不把整篇集中回炉或整份重生成当默认路径
- 不把 `TDD` 阶段偷换成 `PRD/DSD/ASD` 或 docs-* 主路径
- 不在 TDD 中塞入自动化代码、执行报告或实现脚本

## 路由

| 目的 | 文件 |
| --- | --- |
| 流程 | [workflow.md](references/workflow.md) |
| 推进协议 | [gates.md](references/gates.md) |
| grilling 能力 | [grilling-skill.md](../../references/grilling-skill.md) |
| IDEA-ID / depth / 编号 | [core-concepts.md](references/core-concepts.md) |
| 原则 / 反模式 | [design-principles.md](references/design-principles.md)、[anti-patterns.md](references/anti-patterns.md) |
| 易错 / 受众 / 终检 | [gotchas.md](gotchas.md)、[audience-and-language.md](references/audience-and-language.md)、[quality-checklist.md](references/quality-checklist.md) |
| 模板 | [tdd-template.md](assets/tdd-template.md) |

## 最少输入

- 可对齐的 **`PRD-{IDEA-ID}-{N}.md`**
- 可选但强推荐的 **`DSD-{IDEA-ID}-{N}.md`**；可补充 `ASD-{IDEA-ID}-{N}.md`
- `{DOC_DIR}/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/` 可写
- 若已给 `IDEA-ID`、`N`、章节范围、深度，则直接进入参数向导确认

## 推进协议

段落推进、前文回改、自动 `grilling` 与用户动作 `C/M/G/F` 见 [gates.md](references/gates.md)。

## 产出与校验

- 正式：`{DOC_DIR}/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/TDD-{IDEA-ID}-{N}.md`

```bash
agent/skills/sdx-test/scripts/validate-test.sh
agent/skills/sdx-test/scripts/validate-test.sh --file path/to/TDD-xxx.md
```

## 评测 / 钩子

评测：`evals/evals.json`、[grader.md](agents/grader.md)。
`sdx-test` 评测聚焦当前段推进协议与结构校验。
