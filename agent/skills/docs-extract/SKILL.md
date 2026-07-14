---
name: docs-extract
description: >
  按段落关键词相关度从 `--sources` 提炼业务知识，写入 `--overview` 第三列（A/U/D）；
  支持 `--dry-run`，不写 `DISTILL-LOG`。
  触发：/docs-extract、「提炼进 overview」「从设计文档整理进知识库」等。
  分流：用户只要 docs-distill/archive/indexing 或 SDD 为主路径 → 对应技能。
  推进协议：参数向导、当前单元、自动 grilling、C/M/G/S/F 见 references/workflow.md 与 references/gates.md。
---

# docs-extract

读 references/ → 参数向导 → 处理单个 overview 当前单元 → 自动 grilling → 用户动作推进。
主路径是“任意来源 -> overview 第三列 A/U/D”，不负责 `DISTILL-LOG`。

## 输出硬约束（P0）

- 一次只处理一个“当前单元”：单个 `--overview` 目标 + 单批命中段落。
- 当前单元执行或预览后，必须进入自动 `grilling`；未收敛前，不得自动推进下一个 overview 或下一批来源。
- 语义性变更（来源范围、目标 overview、关键词口径、是否直接写入、更新策略）必须先给出结论、推荐方案与数字选项；未获确认不得写入。
- `--dry-run` 只预览命中摘要与 `A/U/D` 影响面，不写第三列。
- 4.1 无命中时，当前单元直接结束，禁止空写入。

## 边界

- 负责：任意源 -> overview 第三列；`A/U/D`；当前单元推进
- 不负责：docs-distill 上行；docs-archive；docs-indexing；SDD 终稿

## 不这样用

- 参数收口后直接处理当前单元
- 不把 `docs-extract` 偷换成 `docs-distill`、`docs-archive` 或 `docs-indexing`

## 路由

| 目的 | 文件 |
| --- | --- |
| 流程 | [workflow.md](references/workflow.md) |
| 风险控制 / 推进协议 | [gates.md](references/gates.md) |
| grilling 能力 | [grilling-skill.md](../../references/grilling-skill.md) |
| 核心概念 | [core-concepts.md](references/core-concepts.md) |
| 提炼规范 | [extract-spec.md](references/extract-spec.md) |
| 原则 / 反模式 | [design-principles.md](references/design-principles.md)、[anti-patterns.md](references/anti-patterns.md) |
| 终检 / 易错 | [quality-checklist.md](references/quality-checklist.md)、[gotchas.md](gotchas.md) |

## 最少输入

- 可解析的 `--sources`
- 可解析的 `--overview`
- overview 内可读关键词附录
- 是否只做 `--dry-run`

## 当前单元

- 单个 `--overview`
- 单批命中段落与对应的 `A/U/D` 集合

当前单元收敛后，由用户用 `C/M/G/S/F` 推进：

- `C`：确认当前单元并进入下一个来源批次或结束
- `M`：修改来源范围、关键词口径或写入策略，再重新 grill
- `G`：继续深挖当前单元
- `S`：暂存当前单元，跳过写入
- `F`：在当前单元已收敛后，沿用已确认参数处理剩余来源

## 产出

- 正式：`--overview` 第三列 `A/U/D`
- 预览：命中摘要与 `A/U/D` 影响面

## 评测 / 脚本

评测：`evals/evals.json`、[grader.md](agents/grader.md)。
评测重点：单单元停顿、语义变更先确认、无命中不空写。
