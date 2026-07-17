---
name: sdx-architect
description: >
  基于已共识 PRD 按 §1-§3 分段「澄清 → 生成 → 烤干」细化边界、变更与规约摘要，
  并直写 ASD-{IDEA-ID}-{N}.md；每段写前意图澄清，写入后自动 grilling 至收敛，用户确认后再推进下一段。
  触发：/sdx-architect、ASD、边界、变更、§3 规约摘要或 spec-asd-*，且可对齐上游 PRD。
  分流：API/DDL/DSD → sdx-design；docs-* 或仅其他 SDX 阶段 → 对应技能。
  推进协议：参数向导、意图澄清、当前段、烤干、前文回改与用户动作见 references/gates.md。
compatibility: Bash 5+；校验脚本 agent/skills/sdx-architect/scripts/validate-asd.sh（仅结构/内容校验）。
---

# sdx-architect

读 references/ → 参数向导 → 分段「澄清 → 生成 → 烤干」→ 用户确认推进。无 PRD → 引导 sdx-prd。**DSD 正文 → sdx-design**。

## 输出硬门禁（P0）

- 一次只处理一个“当前段”（章节、子章节、单个 `DD`、单个服务变更项或单个规约摘要行）；禁止一口气补齐多段（除非用户显式 `F` 且已完成剩余意图批确认）。
- 当前段**写入前**必须完成**意图澄清**（公共六项 + 阶段横幅「当前阶段：意图澄清」）；未获写前 `C` 不得写入正文。契约见 [intent-clarify.md](../../references/intent-clarify.md)。
- 当前段写入终稿后，必须进入自动 `grilling`（烤干）循环；仅当当前段已收敛，或打出必须等待用户确认的语义性问题时，才把控制权交还用户。
- 自动 `grilling` 收敛后，输出 `C/M/G/F` 选项并停止等待用户选择；须标明「当前阶段：烤干」；不得自动推进下一段。
- `C` 同符异义：意图澄清阶段 = 授权写入；烤干阶段 = 确认本段并推进。禁止无阶段横幅裸发动作字母。
- `F` 仅表示在当前段已收敛后，先批确认剩余未完成章节意图，再一次性补齐；不得覆盖已确认前文，不得跳过意图批确认。
- 若用户一开始就要求“一次性生成整篇”，仍先完成当前段「澄清 → 生成 → 烤干」，再由用户明确选择 `F` 进入批量补齐。
- `grilling` 过程中如发现**语义性问题**（改变目标/范围/边界/能力归属/服务拆分/规约口径/风险/优先级/术语/联邦模式等），必须先给出结论、推荐修订与数字选项并等待用户确认；未获确认不得修订当前段。
- 仅**非语义性修订**（不改变含义的错别字/编号/排版等）可在当前段默认授权下直接修订；不确定时按语义性处理。

## 边界

| 负责 | 不负责 |
| --- | --- |
| `ASD-{IDEA-ID}-{N}.md` 生成与推进、意图澄清、烤干、§1-§3 边界/变更/规约摘要、可选 `spec-asd-*` 指针 | `PRD/ANALYSIS/SOLUTION` 初稿；DSD 实现级 API/DDL；docs-* 主路径 |

## 不这样用

- 不走前置草稿 + 集中收口主线；主线是参数向导后分段「澄清 → 生成 → 烤干」
- 不把整篇集中回炉或整份重生成当默认路径
- 不把写前意图澄清当成完整 grilling Skill 深挖
- 不把 `ASD` 阶段偷换成 `DSD` 实现级设计或 docs-* 主路径

## 路由

| 目的 | 文件 |
| --- | --- |
| 流程 | [workflow.md](references/workflow.md) |
| 推进协议 | [gates.md](references/gates.md) |
| 意图澄清 | [intent-clarify.md](../../references/intent-clarify.md) |
| grilling / 烤干 | [grilling-skill.md](../../references/grilling-skill.md) |
| KNOWLEDGE_TYPE / 联邦模式 | [knowledge-type-modes.md](references/knowledge-type-modes.md) |
| 原则 / 反模式 | [anti-patterns.md](references/anti-patterns.md)、[quality-checklist.md](references/quality-checklist.md) |
| 易错 | [gotchas.md](gotchas.md) |
| 模板 | [asd-template.md](assets/asd-template.md)、[asd-spec-template.md](assets/asd-spec-template.md) |

## 最少输入

- 可对齐的 **`PRD-{IDEA-ID}-{N}.md`**
- 可选但推荐的 `ANALYSIS-{IDEA-ID}.md`
- `{DOC_DIR}/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/` 可写
- 若已给 `IDEA-ID`、`N`、章节范围、深度、`KNOWLEDGE_TYPE`，则直接进入参数向导确认

## 推进协议

意图澄清、段落推进、前文回改、烤干与用户动作 `C/M/G/F` 见 [gates.md](references/gates.md)。

## 产出与校验

- 正式：`{DOC_DIR}/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/ASD-{IDEA-ID}-{N}.md`
- 可选：`{DOC_DIR}/specs/spec-asd-{IDEA-ID}-{N}-{app-name}.md`

```bash
agent/skills/sdx-architect/scripts/validate-asd.sh
agent/skills/sdx-architect/scripts/validate-asd.sh --file path/to/ASD-xxx.md
```

## 评测 / 钩子

评测：`evals/evals.json`、[grader.md](agents/grader.md)。
`sdx-architect` 评测聚焦意图澄清、当前段推进协议与结构校验。
