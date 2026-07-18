---
name: docs-change
description: >
  从 Git、CHANGELOG*、本地 mtime 三源采集变更，写入 {output_dir}/CHANGE-LOG.md，文末保留增量基线注释。
  触发：/docs-change、变更聚合、口述「记录改动」「最近改了什么」。
  分流：用户只要 docs-indexing/docs-build/docs-archive/docs-upgrade 为主路径 → 对应技能。
  推进协议：轻流程；参数向导、当前输出单元、轻量校核、C/M/S/F 见 references 与 [light-flow-actions.md](../../references/light-flow-actions.md)。
---

# docs-change：变更聚合

参数向导 → 处理单个 CHANGE-LOG 当前输出单元 → 轻量校核 → 用户动作推进。

## 输出硬约束（P0）

- 一次只处理一个“当前输出单元”：单个 `CHANGE-LOG.md` 输出。
- 参数未收口前，不得写 `CHANGE-LOG.md` 或更新文末基线注释。
- `.docsconfig` 无效时必须中止；不得启发式猜路径继续执行。
- 时间基准、`--output`、单源采集等语义性参数有歧义时，必须先给出结论、推荐方案与数字选项；未获确认不得执行。
- 当前输出单元校核完成前，不得自动推进下一输出目录或下一轮聚合。

## 边界

| 负责 | 不负责 |
| ---- | ------ |
| CHANGE-LOG.md 多源聚合、倒序插入、文末基线 | index、KNOWLEDGE_INDEX、overview 归档、全库术语替换；docs-indexing、docs-build、docs-archive、docs-upgrade |

## 不这样用

- 不把旧“环境准备五步”当唯一主线；主线是参数收口后处理当前输出单元
- 不在无 `.docsconfig` 时猜测 `**/changelogs/` 路径继续写入
- 不把全量/增量 INDEX、实体刷新、overview 归档收成 `docs-change`

## 最短路径

1. [gates.md](references/gates.md)
2. [workflow.md](references/workflow.md)
3. [light-flow-actions.md](../../references/light-flow-actions.md) — `C/M/S/F`
4. [collection-rules.md](references/collection-rules.md)
5. [gotchas.md](gotchas.md)

## 最少输入

- 有效 `.docsconfig`
- `--since` 或可确定的基线策略
- `--output` 已收口或接受默认值
- 若仅采单源，来源范围已确认

## 当前输出单元

- 单个 `CHANGE-LOG.md` 输出

当前输出单元收敛后，动作字母见 [light-flow-actions.md](../../references/light-flow-actions.md)（`C/M/S/F`，无 `G`）。

## 产出

- 输出：`{output_dir}/CHANGE-LOG.md`（默认 `${DOC_ROOT}/changelogs/`；参数见 [workflow.md](references/workflow.md)）
- 原始数据：`{output_dir}/.raw/`（[change-indexing.sh](scripts/change-indexing.sh)）

```bash
agent/skills/docs-change/scripts/change-indexing.sh --since "yyyy-MM-dd HH:mm:ss.SSS"
```

## 评测 / 脚本

评测：`evals/evals.json`、[grader.md](agents/grader.md)、[analyzer.md](agents/analyzer.md)。无 preToolUse 钩子。
评测重点：`.docsconfig` 硬门禁、基线歧义确认、单输出单元停顿、不得静默降级。

## 下游

docs-indexing / docs-build 可消费 CHANGE-LOG.md（一行指针，详 workflow）。
