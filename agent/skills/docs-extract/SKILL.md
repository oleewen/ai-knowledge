---
name: docs-extract
description: >
  按段落关键词相关度从 `--sources` 提炼业务知识，写入 `--overview` 第三列（A/U/D）；
  支持 `--dry-run`，不写 `DISTILL-LOG`。
  触发：/docs-extract、「提炼进 overview」「从设计文档整理进知识库」等。
  分流：用户只要 docs-distill/archive/indexing 或 SDD 为主路径 → 对应技能。
  推进协议：参数向导、当前单元、自动 grilling、C/M/G/S/F 见 references/gates.md、intent-clarify、unit-cycle-protocol、grilling-skill。
---

# docs-extract

主路径：任意来源 → overview 第三列 A/U/D；不负责 `DISTILL-LOG`。

## 输出硬约束（P0）

- 当前单元：单个 `--overview` 目标 + 单批命中段落。
- 写前意图澄清 → [intent-clarify.md](../../references/intent-clarify.md)；未获写前 `C` 不得写入或输出正式预览结论。
- 推进环 `C/M/G/S/F` → [unit-cycle-protocol.md](../../references/unit-cycle-protocol.md)。
- 烤干 → [grilling-skill.md](../../references/grilling-skill.md)；执行或预览后均须烤干；收敛后停等用户。
- `--dry-run` 仍须写前澄清，只预览命中与 A/U/D 影响面，不写第三列；无命中时当前单元直接结束，禁止空写入。

## 边界

- 负责：任意源 -> overview 第三列；`A/U/D`；当前单元推进
- 不负责：docs-distill 上行；docs-archive；docs-indexing；SDD 终稿

## 不这样用

- 不走前置草稿 + 集中收口主线；主线是参数向导后分段「澄清 → 生成 → 烤干」
- 不把写前意图澄清当成完整 grilling Skill 深挖
- 不把 `docs-extract` 偷换成 `docs-distill`、`docs-archive` 或 `docs-indexing`

## 路由

| 目的 | 文件 |
| --- | --- |
| 流程 | [workflow.md](references/workflow.md) |
| 推进协议 | [gates.md](references/gates.md)、[unit-cycle-protocol.md](../../references/unit-cycle-protocol.md) |
| 意图澄清 | [intent-clarify.md](../../references/intent-clarify.md) |
| grilling / 烤干 | [grilling-skill.md](../../references/grilling-skill.md) |
| 核心概念 | [core-concepts.md](references/core-concepts.md) |
| 提炼规范 | [extract-spec.md](references/extract-spec.md) |
| 原则 / 反模式 | [design-principles.md](references/design-principles.md)、[anti-patterns.md](references/anti-patterns.md) |
| 终检 / 易错 | [quality-checklist.md](references/quality-checklist.md)、[gotchas.md](gotchas.md) |

## 最少输入

- 可解析的 `--sources`（路径或文本）
- 可解析的 `--overview`
- overview 内可读关键词附录
- 是否只做 `--dry-run`

## 当前单元

- 单个 `--overview` + 单批命中段落

收敛后用户动作见 [unit-cycle-protocol.md](../../references/unit-cycle-protocol.md)；本技能有 `S`。

## 产出

- 正式：`--overview` 第三列 `A/U/D`
- 预览：命中摘要与 `A/U/D` 影响面

## 评测 / 脚本

评测：`evals/evals.json`、[grader.md](agents/grader.md)。
评测重点：写前意图澄清、单单元停顿、语义变更先确认、无命中不空写、`--dry-run` 不落盘。
