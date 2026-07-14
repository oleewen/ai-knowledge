---
name: docs-build
description: >
  从五视角提取实体 ID，产出 per-entity {ID}.md、各视角 README、扫描生成 KNOWLEDGE_INDEX.md。依赖主 Index Guide。
  触发：初始化/同步知识实体、对齐 ID、docs-indexing 下游要实体等。
  分流：用户只要 INDEX、overview、归档或 SDD 为主路径 → 对应技能。
  推进协议：参数向导、当前单元、自动 grilling、C/M/G/S/F 见 references/workflow.md 与 references/gates.md。
---

# docs-build

读 references/ → 参数向导 → 处理单个构建单元 → 自动 grilling → 用户动作推进。
主路径是“依赖主 Index Guide，按视角批次或实体批次生成 `{DOC_DIR}/knowledge/`”。

## 输出硬约束（P0）

- 一次只处理一个“当前单元”：单个视角批次、单个路径组，或单批实体集合。
- 参数未收口前，不得写 `{DOC_DIR}/knowledge/`。
- 语义性变更（视角范围、输出路径、跳过策略、置信度策略、是否补 README/KNOWLEDGE_INDEX）必须先给出结论、推荐方案与数字选项；未获确认不得执行。
- 当前单元写入后，必须进入自动 `grilling`；未收敛前，不得自动推进下一批。
- 校验失败、路径不明、规则未覆盖时，必须停下澄清，不得静默继续。

## 边界

- 负责：五视角 per-entity、README、`KNOWLEDGE_INDEX.md`、`validate-extraction.sh`
- 不负责：index；docs-okf 迁移；distill/extract；docs-archive；SDD

## 不这样用

- 参数收口后直接处理当前单元
- 不把 `docs-build` 偷换成 `docs-indexing`、overview、归档或 SDD 主路径

## 路由

| 目的 | 文件 |
| --- | --- |
| 流程 | [workflow.md](references/workflow.md) |
| 风险控制 / 推进协议 | [gates.md](references/gates.md) |
| grilling 能力 | [grilling-skill.md](../../references/grilling-skill.md) |
| 配置 / 规则 | [builtin-config.md](references/builtin-config.md)、[extraction-rules.md](references/extraction-rules.md) |
| README / 归并 | [readme-fill-spec.md](references/readme-fill-spec.md)、[consolidation-spec.md](references/consolidation-spec.md) |
| 核心概念 | [core-concepts.md](references/core-concepts.md) |
| 终检 / 易错 | [quality-checklist.md](references/quality-checklist.md)、[gotchas.md](gotchas.md) |

## 最少输入

- 主 Index Guide 可用
- `{DOC_DIR}` 可解析
- 可确定的视角范围
- `--skip-existing`、`--confidence-threshold`、`--emit-report` 等策略已收口

## 当前单元

- 单个视角批次
- 或单个路径组
- 或单批实体集合

当前单元收敛后，由用户用 `C/M/G/S/F` 推进：

- `C`：确认当前单元并进入下一批或结束
- `M`：修改参数或范围，再重新 grill
- `G`：继续深挖当前单元
- `S`：暂存当前单元，跳过写入
- `F`：在当前单元已收敛后，按既定参数补齐剩余批次

## 产出

- 产物：各视角 `{ID}.md`、README、KNOWLEDGE_INDEX.md

```bash
agent/skills/docs-build/scripts/validate-extraction.sh
```

## 评测 / 脚本

评测：`evals/evals.json`、[grader.md](agents/grader.md)。
评测重点：参数收口、单单元停顿、校验后再继续。
