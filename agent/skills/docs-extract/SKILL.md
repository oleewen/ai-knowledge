---
name: docs-extract
description: >
  按段落关键词相关度从 `--sources` 提炼业务知识，写入 `--overview` 第三列（A/U/D）；
  支持 `--dry-run`，不写 `DISTILL-LOG`。
  用户提到 /docs-extract、提炼进 overview、从设计文档整理进知识库、sources 写第三列时，使用本技能。
  分流：应用上行蒸馏 → docs-distill；overview 归档 → docs-archive；INDEX → docs-indexing；SDD → 对应技能。
  推进见 references/gates.md。
---

# docs-extract

## 输出硬约束（P0）

- 当前单元：单个 `--overview` 目标 + 单批命中段落。
- 写前澄清 / 推进环 `C/M/G/S/F` / 烤干 → [intent-clarify.md](../../references/intent-clarify.md)、[unit-cycle-protocol.md](../../references/unit-cycle-protocol.md)、[grilling-skill.md](../../references/grilling-skill.md)、[docs-simplify.md](../../references/docs-simplify.md)；细节 [gates.md](references/gates.md)。未获写前 `C` 不得写入或输出正式预览结论；执行或预览后均须烤干，收敛后停等用户。
- `--dry-run` 仍须写前澄清，只预览命中与 A/U/D 影响面，不写第三列；无命中时当前单元直接结束，禁止空写入。

## 边界

- 负责：任意源 → overview 第三列；`A/U/D`；当前单元推进
- 不负责：docs-distill 上行 / `DISTILL-LOG`；docs-archive；docs-indexing；SDD 终稿

## 不这样用

- 不走前置草稿 + 集中收口；默认参数向导后「澄清 → 生成 → 烤干」
- 不把写前意图澄清当成完整 grilling Skill 深挖
- 不把本技能偷换成 `docs-distill`、`docs-archive` 或 `docs-indexing`

## 路由

| 目的 | 文件 |
| --- | --- |
| 流程 / 推进 binding | [workflow.md](references/workflow.md)、[gates.md](references/gates.md) |
| 核心概念 | [core-concepts.md](references/core-concepts.md) |
| 提炼规范 | [extract-spec.md](references/extract-spec.md) |
| 原则 / 反模式 | [design-principles.md](references/design-principles.md)、[anti-patterns.md](references/anti-patterns.md) |
| 终检 / 易错 | [quality-checklist.md](references/quality-checklist.md)、[gotchas.md](gotchas.md) |

## 最少输入

- 可解析的 `--sources`（路径或文本）
- 可解析的 `--overview`
- overview 内可读关键词附录
- 是否只做 `--dry-run`

## 产出

- 正式：`--overview` 第三列 `A/U/D`
- 预览：命中摘要与 `A/U/D` 影响面
- 收敛后动作见 [unit-cycle-protocol.md](../../references/unit-cycle-protocol.md)（本技能有 `S`）

## 评测

`evals/evals.json`、[grader.md](agents/grader.md)（P0 断言为准）。
