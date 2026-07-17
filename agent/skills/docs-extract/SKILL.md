---
name: docs-extract
description: >
  按段落关键词相关度从 `--sources` 提炼业务知识，写入 `--overview` 第三列（A/U/D）；
  按「澄清 → 生成 → 烤干」处理单个 overview 当前单元；支持 `--dry-run`，不写 `DISTILL-LOG`。
  触发：/docs-extract、「提炼进 overview」「从设计文档整理进知识库」等。
  分流：用户只要 docs-distill/archive/indexing 或 SDD 为主路径 → 对应技能。
  推进协议：参数向导、写前意图澄清、当前单元、烤干、C/M/G/S/F 见 references/gates.md 与 references/workflow.md。
---

# docs-extract

读 references/ → 参数向导 → 分段「澄清 → 生成 → 烤干」→ 用户动作推进。
主路径是“任意来源 -> overview 第三列 A/U/D”，不负责 `DISTILL-LOG`。

## 输出硬门禁（P0）

- 一次只处理一个“当前单元”：单个 `--overview` 目标 + 单批命中段落；禁止一口气补齐多个 overview（除非用户显式 `F` 且已完成剩余单元意图批确认）。
- 当前单元**写入/预览前**必须完成**意图澄清**（公共六项 + 阶段横幅「当前阶段：意图澄清」）；未获写前 `C` 不得写入第三列或输出正式预览结论。契约见 [intent-clarify.md](../../references/intent-clarify.md)。
- 当前单元执行或预览后，必须进入自动 `grilling`（烤干）循环；仅当当前单元已收敛，或打出必须等待用户确认的语义性问题时，才把控制权交还用户。
- 自动 `grilling` 收敛后，输出 `C/M/G/S/F` 选项并停止等待用户选择；须标明「当前阶段：烤干」；不得自动推进下一个 overview 或下一批来源。
- `C` 同符异义：意图澄清阶段 = 授权写入/预览；烤干阶段 = 确认本单元并推进。禁止无阶段横幅裸发动作字母。
- `F` 仅表示在当前单元已收敛后，先批确认剩余未完成 overview/来源批次意图，再一次性补齐；不得跳过意图批确认。
- 语义性变更（来源范围、目标 overview、关键词口径、是否直接写入、更新策略）必须先给出结论、推荐方案与数字选项；未获确认不得写入。
- `--dry-run` 仍须写前意图澄清；只预览命中摘要与 `A/U/D` 影响面，不写第三列；烤干可针对预览结果。
- 4.1 无命中时，当前单元直接结束，禁止空写入。

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
| 推进协议 | [gates.md](references/gates.md) |
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

## 推进协议

意图澄清、单元推进、烤干与用户动作 `C/M/G/S/F` 见 [gates.md](references/gates.md)。

## 产出

- 正式：`--overview` 第三列 `A/U/D`
- 预览：命中摘要与 `A/U/D` 影响面

## 评测 / 脚本

评测：`evals/evals.json`、[grader.md](agents/grader.md)。
评测重点：写前意图澄清、单单元停顿、语义变更先确认、无命中不空写、`--dry-run` 不落盘。
