---
name: sdx-prd
description: >
  在已共识 ANALYSIS 当前 MVP 上按十一章分段「澄清 → 生成 → 烤干」细化用户故事/用例/流程/验收，
  并直写 PRD-{IDEA-ID}-{N}.md；每段写前意图澄清，写入后自动 grilling 至收敛，用户确认后再推进下一段。
  触发：/sdx-prd、「写 PRD」「细化用户故事/业务流程」且可对齐上游 ANALYSIS。
  分流：无 ANALYSIS、只要其他 SDX 阶段或 docs-* 主路径 → 对应技能。
  推进协议：参数向导、意图澄清、当前段、烤干、前文回改与用户动作见 references/gates.md。
compatibility: Bash 5+；校验脚本 agent/skills/sdx-prd/scripts/validate-prd.sh（仅结构/内容校验）。
---

# sdx-prd

读 references/ → 参数向导 → 分段「澄清 → 生成 → 烤干」→ 用户确认推进。无 ANALYSIS → 引导 sdx-analysis。

## 输出硬门禁（P0）

- 一次只处理一个“当前段”（章节、子章节、单个 `UC` 或单个 `US`）；禁止一口气补齐多段（除非用户显式 `F` 且已完成剩余意图批确认）。
- 当前段**写入前**必须完成**意图澄清**（公共六项 + 阶段横幅「当前阶段：意图澄清」）；未获写前 `C` 不得写入正文。契约见 [intent-clarify.md](../../references/intent-clarify.md)。
- 当前段写入终稿后，必须进入自动 `grilling`（烤干）循环；仅当当前段已收敛，或打出必须等待用户确认的语义性问题时，才把控制权交还用户。
- 自动 `grilling` 收敛后，输出 `C/M/G/F` 选项并停止等待用户选择；须标明「当前阶段：烤干」；不得自动推进下一段。
- `C` 同符异义：意图澄清阶段 = 授权写入；烤干阶段 = 确认本段并推进。禁止无阶段横幅裸发动作字母。
- `F` 仅表示在当前段已收敛后，先批确认剩余未完成章节意图，再一次性补齐；不得覆盖已确认前文，不得跳过意图批确认。
- 若用户一开始就要求“一次性生成整篇”，仍先完成当前段「澄清 → 生成 → 烤干」，再由用户明确选择 `F` 进入批量补齐。
- `grilling` 过程中如发现**语义性问题**（改变目标/范围/承诺/口径/取舍/风险/MVP/优先级/角色/流程/术语/验收标准等），必须先给出结论、推荐修订与数字选项并等待用户确认；未获确认不得修订当前段。
- 仅**非语义性修订**（不改变含义的错别字/编号/排版等）可在当前段默认授权下直接修订；不确定时按语义性处理。

## 边界

| 负责 | 不负责 |
| --- | --- |
| `PRD-{IDEA-ID}-{N}.md` 生成与推进、意图澄清、烤干、十一章用户故事/用例/流程/验收细化 | `SOLUTION/ANALYSIS` 初稿；`ASD/DSD/TDD`；docs-*；实现级接口/DDL/中间件设计 |

## 不这样用

- 不走前置草稿 + 集中收口主线；主线是参数向导后分段「澄清 → 生成 → 烤干」
- 不把整篇集中回炉或整份重生成当默认路径
- 不把写前意图澄清当成完整 grilling Skill 深挖
- 不把 `PRD` 阶段偷换成 `ANALYSIS/ASD/DSD/TDD` 或 docs-* 主路径

## 路由

| 目的 | 文件 |
| --- | --- |
| 流程 | [workflow.md](references/workflow.md) |
| 推进协议 | [gates.md](references/gates.md) |
| 意图澄清 | [intent-clarify.md](../../references/intent-clarify.md) |
| grilling / 烤干 | [grilling-skill.md](../../references/grilling-skill.md) |
| IDEA-ID / MVP-Phase | [core-concepts.md](references/core-concepts.md) |
| 原则 / 反模式 | [design-principles.md](references/design-principles.md)、[anti-patterns.md](references/anti-patterns.md) |
| 易错 / 受众 / 终检 | [gotchas.md](gotchas.md)、[audience-and-language.md](references/audience-and-language.md)、[quality-checklist.md](references/quality-checklist.md) |
| 模板 | [prd-template.md](assets/prd-template.md) |

## 最少输入

- 可对齐的 **`ANALYSIS-{IDEA-ID}.md`** 与目标 **`MVP-Phase-{N}`**
- 可确定的主题或标题线索
- `{DOC_DIR}/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/` 可写
- 若已给 `IDEA-ID`、`N`、章节范围、深度，则直接进入参数向导确认

## 推进协议

意图澄清、段落推进、前文回改、烤干与用户动作 `C/M/G/F` 见 [gates.md](references/gates.md)。

## 产出与校验

- 正式：`{DOC_DIR}/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/PRD-{IDEA-ID}-{N}.md`

```bash
agent/skills/sdx-prd/scripts/validate-prd.sh
agent/skills/sdx-prd/scripts/validate-prd.sh --file path/to/PRD-xxx.md
```

## 评测 / 钩子

评测：`evals/evals.json`、[grader.md](agents/grader.md)。
`sdx-prd` 评测聚焦意图澄清、当前段推进协议与结构校验。
