# sdx-analysis 概念反模式

操作细节：[../gotchas.md](../gotchas.md)。原则：[design-principles.md](design-principles.md)。

| # | 反模式 | 纠正 |
| --- | --- | --- |
| 1 | 未确认当前段就自动推进下一段 | [gates.md](gates.md)：烤干收敛后必须停在 `C/M/G/F` |
| 1b | 跳过写前意图澄清直接写正文 | 先六项清单 + 写前 `C`，再生成 |
| 2 | 无 SOLUTION 硬写 ANALYSIS | 停并指 `sdx-solution`，或收窄并标注分析盲区 |
| 3 | 退回已删除的 HTML gate / CONFIRMED / 会话 spec 主线 | 主线是参数向导 + 「澄清 → 生成 → 烤干」；见 [unit-cycle-protocol.md](../../../references/unit-cycle-protocol.md) |
| 4 | 把 `G{n}` 当流程门禁继续使用 | 仅保留 `G-n` 作为 §1.2 目标条目编号 |
| 5 | 当前段未收口就一口气补齐多段 | 一次只处理一个当前段；批量补齐仅能走 `F`（含意图批确认） |
| 6 | `G` 被当成每轮继续 grill 的必选按钮或意图澄清 | 自动 grill 应连续收敛；`G` 仅表示额外深挖当前段 |
| 7 | 语义性变更直接改文，不先确认 | 先给结论、推荐修订和数字选项 |
| 8 | `F` 被当成覆盖前文的整篇重写或跳过意图批确认 | `F` 先批确认意图，再补齐剩余章节，保留已确认前文 |
| 9 | 仅 `§2/§4` 才做多方案 | 任一当前段 `>=2` 条真实路径都应段内比选 |
| 10 | §1–§5、§6.1–§6.2 堆工程名 | 需求分析阶段保持业务语；线索收 `§6.3` |
| 11 | §6.4 假勾 | [quality-checklist.md](quality-checklist.md) 逐项自检 |
| 12 | MVP 无价值或依赖成环 | 业务价值问句 + `§4.3` 验环 |
| 13 | `IDEA-ID` 与 `SOLUTION` 脱节 | 参数向导阶段锁同链 [core-concepts.md](core-concepts.md) |
| 14 | 未跑 validate | [SKILL.md](../SKILL.md) 校验 |
