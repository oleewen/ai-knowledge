---
name: sdx-architect
description: >
  基于已共识 PRD 按 §1-§3 分段「澄清 → 生成 → 烤干」直写 ASD-{IDEA-ID}-{N}.md；
  每段写前意图澄清，写入后自动 grilling 至收敛，再由用户确认推进。
  用户提到 /sdx-architect、ASD、边界、变更、§3 规约摘要或 spec-asd-* 且可对齐上游 PRD 时，使用本技能。
  分流：API/DDL/DSD → sdx-design；docs-* 或仅其他 SDX 阶段 → 对应技能，不以本技能代跑。
  推进见 references/gates.md。
compatibility: Bash 5+；校验脚本 agent/skills/sdx-architect/scripts/validate-asd.sh（仅结构/内容校验）。
---

# sdx-architect

## 输出硬门禁（P0）

- 对象=当前段（章节 / `DD` / 服务变更项 / 规约摘要行）；一次一段（除非 `F` 且已批确认意图）。
- 写前澄清 / 推进环 `C/M/G/F`（无 `S`）/ 烤干 → [intent-clarify.md](../../references/intent-clarify.md)、[unit-cycle-protocol.md](../../references/unit-cycle-protocol.md)、[grilling-skill.md](../../references/grilling-skill.md)、[docs-simplify.md](../../references/docs-simplify.md)；细节 [gates.md](references/gates.md)。
- 上游须可对齐 `PRD-{IDEA-ID}-{N}.md`；否则引导 `sdx-prd`。**DSD 正文 → sdx-design**。
- `KNOWLEDGE_TYPE` / 联邦模式约束见 [knowledge-type-modes.md](references/knowledge-type-modes.md)。

## 边界

| 负责 | 不负责 |
| --- | --- |
| `ASD-{IDEA-ID}-{N}.md` 架构边界与变更、参数向导、意图澄清、分段生成、段内烤干、§1-§3 规约摘要、可选 `spec-asd-*` 指针 | `PRD/ANALYSIS/SOLUTION` 初稿；DSD 实现级 API/DDL；docs-* 主路径 |

## 不这样用

- 不走前置草稿 + 集中收口；默认参数向导后分段推进
- 不把整篇集中回炉或整份重生成当默认路径
- 不把写前意图澄清当成完整 grilling Skill 深挖
- 不把 `ASD` 偷换成 `DSD` 实现级设计或 docs-* 主路径

## 路由

| 目的 | 文件 |
| --- | --- |
| 流程 / 推进 binding | [workflow.md](references/workflow.md)、[gates.md](references/gates.md) |
| KNOWLEDGE_TYPE / 联邦模式 | [knowledge-type-modes.md](references/knowledge-type-modes.md) |
| 原则 / 反模式 / 终检 | [anti-patterns.md](references/anti-patterns.md)、[quality-checklist.md](references/quality-checklist.md) |
| 受众与语言 | [audience-and-language.md](references/audience-and-language.md) |
| 易错 | [gotchas.md](gotchas.md) |
| 模板 | [asd-template.md](assets/asd-template.md)、[asd-spec-template.md](assets/asd-spec-template.md) |

## 最少输入

- 可对齐的 **`PRD-{IDEA-ID}-{N}.md`**
- 可选但推荐的 `ANALYSIS-{IDEA-ID}.md`
- `{DOC_DIR}/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/` 可写
- 若已给 `IDEA-ID`、`N`、章节范围、深度、`KNOWLEDGE_TYPE`，则直接进入参数向导确认

## 产出与校验

- 正式：`{DOC_DIR}/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/ASD-{IDEA-ID}-{N}.md`
- 可选：`{DOC_DIR}/specs/spec-asd-{IDEA-ID}-{N}-{app-name}.md`

```bash
agent/skills/sdx-architect/scripts/validate-asd.sh
agent/skills/sdx-architect/scripts/validate-asd.sh --file path/to/ASD-xxx.md
```

## 评测

`evals/evals.json`、[grader.md](agents/grader.md)。聚焦：意图澄清、当前段推进、上游 PRD/边界、联邦模式分流。
