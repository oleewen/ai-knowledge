---
name: docs-distill
description: >
  将 system/application-{name}/ 已核实内容蒸馏写入 system/knowledge/overview/{APPNAME}-overview.md 第三列，
  并在 overview 成功写入后追加 DISTILL-LOG。
  触发：/docs-distill、「知识蒸馏」「更新 overview」「同步应用知识」等。
  分流：用户只要 docs-extract/archive/indexing 或仅 SDD → 对应技能。
  推进协议：参数向导、当前单元、自动 grilling、C/M/G/S/F 见 references/workflow.md 与 references/gates.md。
---

# docs-distill

读 references/ → 参数向导 → 处理单个 overview 当前单元 → 自动 grilling → 用户动作推进。
主路径是“应用知识蒸馏到系统 overview 第三列”，并在成功写入后追加 `DISTILL-LOG`。

## 输出硬约束（P0）

- 一次只处理一个“当前单元”：单个 `{APPNAME}-overview.md` 目标 + 单次增量范围或单次全量预览范围。
- 当前单元完成 overview 写入后，必须立刻进入自动 `grilling`；当前单元未收敛前，不得自动推进下一应用或下一批范围。
- 语义性变更（目标 app、时间范围、全量/增量策略、冲突口径、是否首次建 overview 等）必须先给出结论、推荐方案与数字选项；未获确认不得执行写入。
- `DISTILL-LOG` 只能在 overview 第三列成功写入后追加；overview 写入失败时，禁止记录日志。
- `--dry-run` 只做当前单元预览，不写 overview，不写 `DISTILL-LOG`。

## 边界

- 负责：已核实应用 -> overview 第三列；增量/全量；`DISTILL-LOG`；当前单元推进
- 不负责：docs-extract；docs-archive；docs-indexing；SDD 终稿代写

## 不这样用

- 参数收口后直接处理当前单元
- 不把 `docs-distill` 偷换成 `docs-extract`、`docs-archive` 或 `docs-indexing`

## 路由

| 目的 | 文件 |
| --- | --- |
| 流程 | [workflow.md](references/workflow.md) |
| 风险控制 / 推进协议 | [gates.md](references/gates.md) |
| grilling 能力 | [grilling-skill.md](../../references/grilling-skill.md) |
| 核心概念 | [core-concepts.md](references/core-concepts.md) |
| 蒸馏规范 | [distill-spec.md](references/distill-spec.md)、[distill-log-spec.md](references/distill-log-spec.md) |
| 联邦规则 | [federation-spec.md](references/federation-spec.md) |
| 原则 / 反模式 | [design-principles.md](references/design-principles.md)、[anti-patterns.md](references/anti-patterns.md) |
| 终检 / 易错 | [quality-checklist.md](references/quality-checklist.md)、[gotchas.md](gotchas.md) |

## 最少输入

- 可定位的应用目录或 `--app`
- 可确定的增量起点：自动锚点或显式 `--since`
- 是否 `--full`
- 是否只做 `--dry-run`
- `system/knowledge/overview/` 与 `system/changelogs/` 可写

## 当前单元

- 单个 `{APPNAME}-overview.md`
- 单次增量范围，或单次 `--full` 预览/执行范围

当前单元收敛后，由用户用 `C/M/G/S/F` 推进：

- `C`：确认当前单元并进入下一个 app 或结束
- `M`：修改当前单元策略或内容摘要，再重新 grill
- `G`：继续深挖当前单元
- `S`：暂存当前单元，跳过写入
- `F`：在当前单元已收敛后，按既定参数补齐剩余同批范围

## 产出与脚本

- 正式：`system/knowledge/overview/{APPNAME}-overview.md` 第三列
- 正式：`system/changelogs/DISTILL-LOG.md`（overview 成功后）

```bash
agent/skills/docs-distill/scripts/run-docs-distill.sh --help
```

## 评测 / 脚本

评测：`evals/evals.json`、[grader.md](agents/grader.md)。
评测重点：单单元停顿、overview 成功后再写 `DISTILL-LOG`、`--dry-run` 不落盘。
