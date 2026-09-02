---
name: docs-merge
description: >
  将源文件或内联文本按目标 md 的 H2/H3 章节落位合入；不存在则确认后新增，类似则合并，冲突用 grilling 逐条决策。
  调用：/docs-merge <source> <target>〔--dry-run〕。source 为已存在路径则读文件，否则当内联文本；歧义或 target 不清则停问。
  用户提到 /docs-merge、合并进文档、合入章节、把这段写进某 md、章节合并冲突时，使用本技能。
  分流：overview 第三列关键词提炼 A/U/D → docs-extract；结构精简/SSOT → docs-simplify；术语替换 → docs-upgrade。
  推进见 references/gates.md。
---

# docs-merge

## 输出硬约束（P0）

- 当前单元：单个已存在 `<target>` + 本批 `<source>` 的一次合入计划。算法与落盘：[merge-spec.md](references/merge-spec.md)。
- 写前澄清 / `C/M/G/S/F` / 烤干 → [intent-clarify.md](../../references/intent-clarify.md)、[unit-cycle-protocol.md](../../references/unit-cycle-protocol.md)、[grilling-skill.md](../../references/grilling-skill.md)、[docs-simplify.md](../../references/docs-simplify.md)；binding：[gates.md](references/gates.md)。未落位须在澄清收口；未获写前 `C` 不得写 target；`--dry-run` 只出计划仍须澄清。**dry-run 结束后若要正式写入，须重新写前 `C`，且证明未落位已空**（不得沿用 dry-run 那次 C）。执行/预览后须烤干，收敛后停等。
- **落位**：仅 H2/H3；不明则停（候选节 + 新建）。**冲突**：grilling 一问一答 → 全部决完一次落盘。
- **源只读**；**target 必须已存在**（不新建）。
- **knowledge**：写 `application|system|company` 下 `*/knowledge/**` 须守 [knowledge-governance.md](../../knowledge/knowledge-governance.md)「业务 knowledge 引用边界」；违规能修则修，不明则停。

## 边界

| 负责 | 不负责 |
| --- | --- |
| 已存在 md 章节合入；新增确认；类似合并；冲突 grilling；dry-run 计划 | overview 第三列 A/U/D（docs-extract）；精简/SSOT（docs-simplify）；术语链（docs-upgrade）；新建 target |

## 不这样用

- 不把第三列提炼收成本技能
- 不猜 source/target；不改源；不边决冲突边写
- 不把写前澄清称作 grilling（写前走 intent-clarify；冲突决策与写后烤干用 grilling）

## 路由

| 目的 | 文件 |
| --- | --- |
| 流程 / binding | [workflow.md](references/workflow.md)、[gates.md](references/gates.md) |
| 合入规范 | [merge-spec.md](references/merge-spec.md) |
| 概念 | [core-concepts.md](references/core-concepts.md) |
| 受众 | [audience-and-language.md](references/audience-and-language.md) |
| 原则 / 反模式 | [design-principles.md](references/design-principles.md)、[anti-patterns.md](references/anti-patterns.md) |
| 终检 / 易错 | [quality-checklist.md](references/quality-checklist.md)、[gotchas.md](gotchas.md) |

## 最少输入

- `<source>`（已存在路径或内联文本）
- 已存在单个 `<target>` md
- 是否 `--dry-run`（唯一可选旗标）

## 产出

- 正式：一次落盘后的 `<target>`；预览：合入计划三分区（dry-run 不改文件）
- 动作：[unit-cycle-protocol.md](../../references/unit-cycle-protocol.md)（有 `S`）

## 评测

`evals/evals.json`、[grader.md](agents/grader.md)（P0 为准）。
