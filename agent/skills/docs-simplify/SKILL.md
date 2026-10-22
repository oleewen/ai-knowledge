---
name: docs-simplify
description: >
  用于就地精简 Markdown、按金字塔重组正文或将重复定义改为 SSOT 引用。
  适用 /docs-simplify、删冗余、压缩正文，以及 docs-revise 后的整篇或指定 hunk 改善。
  术语统一与定向纠错用 docs-revise；重建索引用 docs-indexing。
---

# docs-simplify

## 输出硬约束（P0）

在确认范围内改善可读性，保留约束、例外和验收条件。写作原则唯一真源为 [simplify-principles.md](../../references/simplify-principles.md)。

- 当前单元为一个文件、指定 hunk 或已确认的多文件批次；不得静默扩围。
- 写前输出六项澄清并获 `C`；写后必须烤干，收敛后停等用户。绑定见 [gates.md](references/gates.md)。
- 疑似跨文件重复须确认具体真源和处置后才能删段或改引用；默认不改真源正文。
- 保留模板章号、编号实体及必要表行；不以行数降幅判断成功。
- 默认保护 ID、frontmatter 契约字段、稳定锚点、代码/命令字面量和扫描列；日期可刷新。其他契约变更须用户明示。

## 边界

本技能处理正文结构、冗余和去重引用。术语链式替换交 `docs-revise`，索引重建、归档、实体索引交对应技能；变更溯源用 git。双目标未定顺序时才询问，已有明确顺序则沿用。

协议内 simplify 遍只改善烤干修订的 hunk，不另开本技能完整环；revise 已 `grilled` 后，可独立启动本技能并限定 hunk。

## 不这样用

不把精简变成业务承诺调整、默认全仓改写或无条件全仓扫描。发现范围外重复不构成扩围授权。

## 路由

| 时机 | 读取 |
| --- | --- |
| 执行改写 | [workflow.md](references/workflow.md)：范围、澄清、改写与交付 |
| 确认权限、停顿或重开 | [gates.md](references/gates.md)：共享协议绑定与本地边界 |
| 改写四层业务 knowledge | [knowledge-governance.md](../../knowledge/knowledge-governance.md) 的「业务 knowledge 引用边界」；不得因去重越出允许边界，跨层 HTTP 用生成函数，无 parent 用纯 ID |
| 写后检查 | [quality-checklist.md](references/quality-checklist.md)、[audience-and-language.md](references/audience-and-language.md) |
| 需要确认书 | [范围模板](assets/docs-simplify-scope-ack-template.md) |
| 排查常见失误 | [gotchas.md](gotchas.md)、[anti-patterns.md](references/anti-patterns.md) |

## 最少输入

目标路径或候选范围；缺失时先查找再列选项。默认激进精简、排除未点名索引/日志/生成物、不扩批；已有明确参数和授权不重复询问。

## 产出

已确认范围内的文件修改，以及变更摘要、验证结果和未决问题。hunk 模式须核对范围外内容未变；收敛后按 [单元推进协议](../../references/unit-cycle-protocol.md) 等待写后动作。

## 评测

套件：[evals.json](evals/evals.json)。运行方式与证据要求见 [evaluation.md](references/evaluation.md)，判分见 [grader.md](agents/grader.md)。结构校验不能替代行为实测。
