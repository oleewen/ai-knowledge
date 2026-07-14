---
name: docs-archive
description: >
  将 overview 知识按表格行内副标题链接归档到 system/company 视角章节；
  先收口方案确认书，再按当前单元落目标章并按策略回写 overview。
  触发：/docs-archive、「知识归档」「overview 落盘」「冲突检查」等。
  分流：用户只要 extract/distill/build/upgrade 或仅 SDD/KNOWLEDGE_INDEX → 对应技能。
  推进协议：参数向导、当前单元、自动 grilling、C/M/G/S/F 见 references/workflow.md 与 references/gates.md。
---

# docs-archive

读 references/ → 参数向导 → 形成当前确认书 → 处理单个归档单元 → 自动 grilling → 用户动作推进。
主路径是“overview 行块 -> 目标章节”，并按策略回写 overview。

## 输出硬约束（P0）

- 一次只处理一个“当前单元”：单个目标章节，或单个 overview 行块。
- 当前单元落盘前，必须先形成并收口当前确认书；确认书未收口前，不得写目标章节或回写 overview。
- 语义性变更（来源范围、目标章节、冲突策略、来源清理策略、索引壳与否）必须先给结论、推荐方案与数字选项；未获确认不得落盘。
- 当前单元落盘后，必须进入自动 `grilling`；未收敛前，不得自动推进下一章节或下一 overview 行块。
- overview 回写必须保留行内副标题链接；若改为索引壳，也不得承载新的业务事实。

## 边界

- 负责：overview -> 链接指向的视角章节；确认书；冲突检查；overview 按策略回写
- 不负责：extract；distill；docs-build；docs-upgrade；SDD 终稿

## 不这样用

- 确认书收口后直接处理当前单元
- 不把 `docs-archive` 偷换成 `docs-build`、`docs-upgrade` 或 `docs-extract`

## 路由

| 目的 | 文件 |
| --- | --- |
| 流程 | [workflow.md](references/workflow.md) |
| 风险控制 / 推进协议 | [gates.md](references/gates.md) |
| grilling 能力 | [grilling-skill.md](../../references/grilling-skill.md) |
| 链接与索引 | [links-and-index.md](references/links-and-index.md) |
| 核心概念 | [core-concepts.md](references/core-concepts.md) |
| 原则 / 反模式 | [design-principles.md](references/design-principles.md)、[anti-patterns.md](references/anti-patterns.md) |
| 终检 / 易错 | [quality-checklist.md](references/quality-checklist.md)、[gotchas.md](gotchas.md) |
| 确认书模板 | [archive-template.md](assets/archive-template.md) |

## 最少输入

- overview 来源路径或锚点
- 可解析的目标章节或 overview 行内链接
- 来源清理策略
- 初始冲突策略

## 当前单元

- 单个目标章节
- 或单个 overview 行块

当前单元收敛后，由用户用 `C/M/G/S/F` 推进：

- `C`：确认当前单元并进入下一个章节/行块或结束
- `M`：修改确认书、冲突策略或回写策略，再重新 grill
- `G`：继续深挖当前单元
- `S`：暂存当前单元，跳过落盘
- `F`：在当前单元已收敛后，沿用已确认策略补齐剩余同批范围

## 产出

- 工作产物：当前确认书
- 正式：目标章节增补
- 正式：overview 按策略回写

## 评测 / 脚本

评测：`evals/evals.json`、[grader.md](agents/grader.md)。
评测重点：确认书先收口、目标章节先落盘、overview 后回写。
