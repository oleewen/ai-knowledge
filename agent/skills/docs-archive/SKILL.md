---
name: docs-archive
description: >
  将 overview 知识按表格行内副标题链接归档到 system/company 视角章节；
  先收口方案确认书，再按当前单元落目标章并按策略回写 overview。
  触发：/docs-archive、「知识归档」「overview 落盘」「冲突检查」等。
  分流：用户只要 extract/distill/build/upgrade 或仅 SDD/KNOWLEDGE_INDEX → 对应技能。
  推进协议：参数向导、当前单元、自动 grilling、C/M/G/S/F 见 references/gates.md、intent-clarify、unit-cycle-protocol、grilling-skill。
compatibility: Bash 5+；无专用校验脚本。
---

# docs-archive

主路径：overview 行块 → 目标章节，并按策略回写 overview。

## 输出硬约束（P0）

- 当前单元：单个目标章节，或单个 overview 行块。
- 写前意图澄清 → [intent-clarify.md](../../references/intent-clarify.md)；未获写前 `C` 不得落盘或回写 overview。
- 推进环 `C/M/G/S/F` → [unit-cycle-protocol.md](../../references/unit-cycle-protocol.md)。
- 烤干 → [grilling-skill.md](../../references/grilling-skill.md)；本技能默认必须烤干；收敛后停等用户。
- **确认书 = 意图澄清门禁**：批次级确认书收口即完成写前澄清；单元落盘前不再重复六项全清单，仅摘取本单元目标与路径。
- overview 回写须保留行内副标题链接；若改为索引壳，也不得承载新业务事实。

## 边界

- 负责：overview -> 链接指向的视角章节；确认书（意图澄清）；冲突检查；overview 按策略回写
- 不负责：extract；distill；docs-build；docs-upgrade；SDD 终稿

## 不这样用

- 不把写前意图澄清与确认书拆成两套停顿
- 不把 `docs-archive` 偷换成 `docs-build`、`docs-upgrade` 或 `docs-extract`
- 不把写前步骤称作「写前 grilling」；`G` 仅写后深挖

## 路由

| 目的 | 文件 |
| --- | --- |
| 流程 | [workflow.md](references/workflow.md) |
| 推进协议 | [gates.md](references/gates.md)、[unit-cycle-protocol.md](../../references/unit-cycle-protocol.md) |
| 意图澄清 | [intent-clarify.md](../../references/intent-clarify.md) |
| grilling / 烤干 | [grilling-skill.md](../../references/grilling-skill.md) |
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

- 单个目标章节，或单个 overview 行块

收敛后用户动作见 [unit-cycle-protocol.md](../../references/unit-cycle-protocol.md)；本技能有 `S`。

## 产出

- 工作产物：当前确认书（含意图澄清六项）
- 正式：目标章节增补
- 正式：overview 按策略回写

## 评测 / 脚本

评测：`evals/evals.json`、[grader.md](agents/grader.md)。
评测重点：确认书即意图澄清、单单元「落盘 → 烤干」、overview 后回写。
