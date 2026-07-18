# sdx-design 概念反模式

操作细节：[../gotchas.md](../gotchas.md)。

| # | 反模式 | 纠正 |
| --- | --- | --- |
| 1 | 未确认当前段就自动推进下一段 | [gates.md](gates.md)：烤干收敛后必须停在 `C/M/G/F` |
| 1b | 跳过写前意图澄清直接写正文 | 先六项清单 + 写前 `C`，再生成 |
| 2 | 无 PRD 硬写 DSD | 停并指 `sdx-prd`，或收窄并标注需求基线盲区 |
| 3 | 退回已删除的 HTML gate / CONFIRMED / 会话 spec 主线 | 主线是参数向导 + 「澄清 → 生成 → 烤干」；见 [unit-cycle-protocol.md](../../../references/unit-cycle-protocol.md) |
| 4 | 当前段未收口就一口气补齐多段 | 一次只处理一个当前段；批量补齐仅能走 `F`（含意图批确认） |
| 5 | `G` 被当成每轮继续 grill 的必选按钮或意图澄清 | 自动 grill 应连续收敛；`G` 仅表示额外深挖当前段 |
| 6 | 语义性变更直接改文，不先确认 | 先给结论、推荐修订和数字选项 |
| 7 | `F` 被当成覆盖前文的整篇重写或跳过意图批确认 | `F` 先批确认意图，再补齐剩余章节，保留已确认前文 |
| 8 | 在 DSD 中重写 ASD 边界 | 边界变更回 `sdx-architect`；DSD 只承接实现级展开 |
| 9 | 实现级契约散落在 DSD 外第二份 Markdown | 合并进 `DSD §2`，保持单一真相源 |
| 10 | 无 ASD/spec-asd 仍宣称详设已完备 | 至少具备其一，或显式标注例外和风险 |
| 11 | `§2` 无 API/DDL/LOGIC 追溯 | 在 `§2` 内对齐 `PRD/ASD/spec-asd/FR` |
| 12 | 文首元数据缺失或 `id` 与路径不一致 | 要求文首 frontmatter；`id = DSD-{IDEA-ID}-{N}` |
| 13 | `IDEA-ID` / `N` 与上游 PRD、ASD 脱节 | 参数向导阶段锁同链 |
| 14 | 未跑 validate | [SKILL.md](../SKILL.md) 校验 |
