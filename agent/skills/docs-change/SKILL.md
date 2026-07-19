---
name: docs-change
description: >
  从 Git、CHANGELOG*、本地 mtime 三源采集变更，写入 {output_dir}/CHANGE-LOG.md，文末保留增量基线注释。
  用户提到 /docs-change、变更聚合、「记录改动」「最近改了什么」时，使用本技能。
  分流：INDEX / 实体 / 归档 / 术语为主路径 → docs-indexing、docs-build、docs-archive、docs-upgrade。
  推进见 light-flow-actions（C/M/S/F，无 G）与 references/gates.md。
---

# docs-change

## 输出硬约束（P0）

- 当前单元：单个 `CHANGE-LOG.md` 输出。
- 轻流程：参数向导 → 轻量校核 → `C/M/S/F`（无 `G`、不绑意图澄清）→ [light-flow-actions.md](../../references/light-flow-actions.md)；细节 [gates.md](references/gates.md)。参数未收口前不得写 `CHANGE-LOG.md` 或更新文末基线。
- `.docsconfig` 无效时必须中止；不得启发式猜路径继续。
- 时间基准、`--output`、单源采集等语义歧义须先给结论、推荐与数字选项；未确认不得执行。
- 当前输出单元校核完成前，不得自动推进下一输出目录。

## 边界

| 负责 | 不负责 |
| --- | --- |
| 三源聚合、倒序插入、文末基线 | index、KNOWLEDGE_INDEX、overview 归档、全库术语；docs-indexing / docs-build / docs-archive / docs-upgrade |

## 不这样用

- 不把旧「环境准备五步」当唯一主线；主线是参数收口后处理当前输出单元
- 不在无 `.docsconfig` 时猜测 `**/changelogs/` 继续写入
- 不把全量/增量 INDEX、实体刷新、overview 归档收成 `docs-change`

## 路由

| 目的 | 文件 |
| --- | --- |
| 流程 / 风险 | [workflow.md](references/workflow.md)、[gates.md](references/gates.md) |
| 轻流程动作 | [light-flow-actions.md](../../references/light-flow-actions.md) |
| 采集 / 概念 | [collection-rules.md](references/collection-rules.md)、[core-concepts.md](references/core-concepts.md) |
| 原则 / 反模式 | [design-principles.md](references/design-principles.md)、[anti-patterns.md](references/anti-patterns.md) |
| 终检 / 易错 | [quality-checklist.md](references/quality-checklist.md)、[gotchas.md](gotchas.md) |

## 最少输入

- 有效 `.docsconfig`
- `--since` 或可确定的基线策略
- `--output` 已收口或接受默认
- 若仅采单源，来源范围已确认

## 产出与脚本

- 正式：`{output_dir}/CHANGE-LOG.md`（默认 `${DOC_ROOT}/changelogs/`）
- 原始：`{output_dir}/.raw/`（[change-indexing.sh](scripts/change-indexing.sh)）
- 收敛后动作见 [light-flow-actions.md](../../references/light-flow-actions.md)（本技能有 `S`，无 `G`）
- 下游：docs-indexing / docs-build 可消费 CHANGE-LOG（详 workflow）

```bash
agent/skills/docs-change/scripts/change-indexing.sh --since "yyyy-MM-dd HH:mm:ss.SSS"
```

## 评测

`evals/evals.json`、[grader.md](agents/grader.md)（P0 断言为准）。重点：`.docsconfig` 硬门禁、基线歧义确认、单输出单元停顿、不得静默降级。
