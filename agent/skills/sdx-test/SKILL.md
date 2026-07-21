---
name: sdx-test
description: >
  基于已共识 PRD 与 DSD（及 ASD）按六章分段「澄清 → 生成 → 烤干」直写 TDD-{IDEA-ID}-{N}.md；
  每段写前意图澄清，写入后自动 grilling 至收敛，再由用户确认推进。
  用户提到 /sdx-test、测试方案、用例、TDD、PRD/DSD 转测试时，使用本技能。
  分流：只要上游 SDX 正文或 docs-* 主路径 → 对应技能，不以本技能代跑。不产出自动化代码与执行报告。
  推进见 references/gates.md。
compatibility: Bash 5+；校验脚本 agent/skills/sdx-test/scripts/validate-test.sh（仅结构/内容校验）。
---

# sdx-test

## 输出硬门禁（P0）

- 对象=当前段（章节 / 用例组 / 回归块 / 进出标准 / 数据·环境块）；一次一段（除非 `F` 且已批确认意图）。
- 写前澄清 / 推进环 `C/M/G/F`（无 `S`）/ 烤干 → [intent-clarify.md](../../references/intent-clarify.md)、[unit-cycle-protocol.md](../../references/unit-cycle-protocol.md)、[grilling-skill.md](../../references/grilling-skill.md)、[docs-simplify.md](../../references/docs-simplify.md)；细节 [gates.md](references/gates.md)。
- 上游须可对齐 `PRD`；缺 PRD → `sdx-prd`；缺 DSD 时按范围收窄并标基线盲区。**不产自动化代码与执行报告。**

## 边界

| 负责 | 不负责 |
| --- | --- |
| `TDD-{IDEA-ID}-{N}.md` 测试设计、参数向导、意图澄清、分段生成、段内烤干、六章策略/用例/数据/环境/进出标准/回归 | 自动化测试代码、执行报告；以其他 SDX 替代 TDD；docs-* 主路径 |

## 不这样用

- 不走前置草稿 + 集中收口；默认参数向导后分段推进
- 不把整篇集中回炉或整份重生成当默认路径
- 不把写前意图澄清当成完整 grilling Skill 深挖
- 不把 `TDD` 偷换成 `PRD/DSD/ASD` 或 docs-* 主路径
- 不在 TDD 中塞入自动化代码、执行报告或实现脚本

## 路由

| 目的 | 文件 |
| --- | --- |
| 流程 / 推进 binding | [workflow.md](references/workflow.md)、[gates.md](references/gates.md) |
| IDEA-ID / depth / 编号 | [core-concepts.md](references/core-concepts.md) |
| 原则 / 反模式 | [design-principles.md](references/design-principles.md)、[anti-patterns.md](references/anti-patterns.md) |
| 易错 / 受众 / 终检 | [gotchas.md](gotchas.md)、[audience-and-language.md](references/audience-and-language.md)、[quality-checklist.md](references/quality-checklist.md) |
| 模板 | [tdd-template.md](assets/tdd-template.md) |

## 最少输入

- 可对齐的 **`PRD-{IDEA-ID}-{N}.md`**
- 可选但强推荐的 **`DSD-{IDEA-ID}-{N}.md`**；可补充 `ASD-{IDEA-ID}-{N}.md`
- `{DOC_DIR}/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/` 可写
- 若已给 `IDEA-ID`、`N`、章节范围、深度，则直接进入参数向导确认

## 产出与校验

- 正式：`{DOC_DIR}/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/TDD-{IDEA-ID}-{N}.md`

```bash
agent/skills/sdx-test/scripts/validate-test.sh
agent/skills/sdx-test/scripts/validate-test.sh --file path/to/TDD-xxx.md
```

## 评测

`evals/evals.json`、[grader.md](agents/grader.md)。聚焦：意图澄清、当前段推进、上游 PRD/DSD、边界分流。
