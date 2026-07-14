---
name: docs-agent
description: >
  维护或初始化仓库根目录 README.md 与 AGENTS.md。
  触发：/docs-agent、入口与 INDEX 不同步、口述「写 README」「更新 AGENTS」。
  分流：用户只要 docs-indexing/docs-build/docs-upgrade 或 SDD/distill/extract → 对应技能。
  推进协议：参数向导、当前单元、自动 grilling、C/M/G/S/F 见 references/workflow.md 与 references/gates.md。
---

# 仓库入口文档（docs-agent）

读 references/ → 参数向导 → 处理单个入口文档当前单元 → 自动 grilling → 用户动作推进。
主路径是“依落盘 INDEX 生成并维护单个根入口文档”。

## 输出硬约束（P0）

- 一次只处理一个“当前单元”：`README.md` 或 `AGENTS.md`。
- 参数未收口前，不得写根 `README.md` / `AGENTS.md`。
- 当前单元写入后，必须进入自动 `grilling`；未收敛前，不得自动推进另一入口文件。
- 语义性变更（`output` / `mode`、覆盖还是合并、README/AGENTS 职责边界、是否保留现有内容）必须先给出结论、推荐方案与数字选项；未获确认不得执行。
- `both` 模式下默认顺序为先 `README.md`，后 `AGENTS.md`；前一单元未收敛前，不得静默写入后一单元。

## 边界

| 负责 | 不负责 |
| ---- | ------ |
| 根 README.md、AGENTS.md；`--output` / `--mode`；与 INDEX 对齐 | index（docs-indexing）；实体（docs-build）；术语批量（docs-upgrade）；SDD / distill / extract 主流程 |

## 不这样用

- 不把旧的集中确认流程当唯一主线；主线是参数向导收口后直接处理当前单元
- 不在本技能内重写或替代 `index.md` / `INDEX_GUIDE`；INDEX 主路径仍是 `docs-indexing`
- 不把术语链式替换、overview 维护、实体索引等任务收成 `docs-agent`

## 最短路径

1. [gates.md](references/gates.md)
2. [workflow.md](references/workflow.md)
3. [execution-spec.md](references/execution-spec.md)
4. [three-file-spec.md](references/three-file-spec.md)
5. [quality-standards.md](references/quality-standards.md)
6. [gotchas.md](gotchas.md)
7. [readme-skeleton.md](assets/readme-skeleton.md)、[agents-skeleton.md](assets/agents-skeleton.md)
8. [docs-skill-skeleton.md](references/docs-skill-skeleton.md) — docs 族结构 SSOT
9. [grilling-skill.md](../../references/grilling-skill.md) — 自动 grilling 公共能力

## 最少输入

- 已落盘的 INDEX
- `output`、`mode` 已收口
- 根入口文件目标路径可解析
- 若涉及覆盖/合并边界，已确认风险策略

## 当前单元

- `README.md`
- `AGENTS.md`

当前单元收敛后，由用户用 `C/M/G/S/F` 推进：

- `C`：确认当前单元并进入下一入口文件或结束
- `M`：调整参数、范围或合并策略，再重新 grill
- `G`：继续深挖当前单元的一致性或职责边界
- `S`：暂存当前单元，跳过写入
- `F`：在当前单元已收敛后，按既定参数补齐剩余入口文件

## 产出

默认 `{REPO_ROOT}` 下 README.md、AGENTS.md（`--output` 可只其一）。

```bash
bash agent/skills/docs-agent/scripts/validate-guide.sh --root .
```

## 评测 / 脚本

评测：`evals/evals.json`、[grader.md](agents/grader.md)、[analyzer.md](agents/analyzer.md)。
评测重点：参数收口、单单元停顿、README/AGENTS 去重、语义变更确认。前置：INDEX 须已落盘（例外见 execution-spec.md）。
