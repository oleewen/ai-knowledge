---
name: sdx-design
description: >
  基于已共识 PRD 与 ASD/spec-asd 按 §1-§3 分段「澄清 → 生成 → 烤干」直写 DSD-{IDEA-ID}-{N}.md；
  每段写前意图澄清，写入后自动 grilling 至收敛，再由用户确认推进。
  用户提到 /sdx-design、编写/修改 DSD、API、DDL、错误码、幂等、时序、validate-dsd 且可对齐上游 ASD 或 spec-asd 时，使用本技能。
  分流：只要 PRD/ASD/TDD/docs-* 主路径 → 对应技能，不以本技能代跑。
  推进见 references/gates.md。
compatibility: Bash 5+；校验脚本 agent/skills/sdx-design/scripts/validate-dsd.sh（仅结构/内容校验）。
---

# sdx-design

## 输出硬门禁（P0）

- 对象=当前段（章节 / `API` / `DDL`/`TBL` / `LOGIC` / 错误码组 / 幂等·时序·安全块）；一次一段（除非 `F` 且已批确认意图）。
- 写前澄清 / 推进环 `C/M/G/F`（无 `S`）/ 烤干 → [intent-clarify.md](../../references/intent-clarify.md)、[unit-cycle-protocol.md](../../references/unit-cycle-protocol.md)、[grilling-skill.md](../../references/grilling-skill.md)；细节 [gates.md](references/gates.md)。
- 上游须可对齐 `PRD` 与 `ASD/spec-asd`；缺 PRD → `sdx-prd`；缺 ASD/spec-asd → `sdx-architect` 或按缺口标注受限继续。**不写 ASD，不产 TDD。**
- 结构校验：`scripts/validate-dsd.sh`（见「产出与校验」）。

## 边界

| 负责 | 不负责 |
| --- | --- |
| `DSD-{IDEA-ID}-{N}.md` 实现级详设、参数向导、意图澄清、分段生成、段内烤干、§1-§3 与 §2 API/DDL/LOGIC/错误码/幂等/时序 | `PRD/ASD/TDD/SOLUTION/ANALYSIS` 初稿；docs-* 主路径；实现代码与自动化测试 |

## 不这样用

- 不走前置草稿 + 集中收口；默认参数向导后分段推进
- 不把整篇集中回炉或整份重生成当默认路径
- 不把写前意图澄清当成完整 grilling Skill 深挖
- 不把 `DSD` 偷换成 `ASD/PRD/TDD` 或 docs-* 主路径
- 不把实现级契约拆到 DSD 外的第二份 Markdown 作为并行正文

## 路由

| 目的 | 文件 |
| --- | --- |
| 流程 / 推进 binding | [workflow.md](references/workflow.md)、[gates.md](references/gates.md) |
| 原则 / 反模式 | [design-principles.md](references/design-principles.md)、[anti-patterns.md](references/anti-patterns.md) |
| 易错 / 受众 / 终检 | [gotchas.md](gotchas.md)、[audience-and-language.md](references/audience-and-language.md)、[quality-checklist.md](references/quality-checklist.md) |
| KNOWLEDGE_TYPE | [knowledge-type-modes.md](references/knowledge-type-modes.md) |
| 模板 | [dsd-template.md](assets/dsd-template.md)、上游 [asd-spec-template.md](../sdx-architect/assets/asd-spec-template.md) |

## 最少输入

- 可对齐的 **`PRD-{IDEA-ID}-{N}.md`**
- 可对齐的 **`ASD-{IDEA-ID}-{N}.md`** 和/或 `spec-asd-{IDEA-ID}-{N}-{app-name}.md`
- `{DOC_DIR}/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/` 可写
- 若已给 `IDEA-ID`、`N`、章节范围、深度、上游文档范围，则直接进入参数向导确认

## 产出与校验

- 正式：`{DOC_DIR}/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/DSD-{IDEA-ID}-{N}.md`

```bash
agent/skills/sdx-design/scripts/validate-dsd.sh
agent/skills/sdx-design/scripts/validate-dsd.sh --file path/to/DSD-xxx.md
```

## 评测

`evals/evals.json`、[grader.md](agents/grader.md)。聚焦：意图澄清、当前段推进、上游 PRD/ASD、边界分流。
