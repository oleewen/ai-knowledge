# sdx-architect 概念反模式

操作细节：[../gotchas.md](../gotchas.md)。

| # | 反模式 | 纠正 |
| --- | --- | --- |
| 1 | 未确认当前段就自动推进下一段 | [gates.md](gates.md)：烤干收敛后必须停在 `C/M/G/F` |
| 1b | 跳过写前意图澄清直接写正文 | 先六项清单 + 写前 `C`，再生成 |
| 2 | 无 PRD 硬写 ASD | 停并指 `sdx-prd`，或收窄并标注架构基线盲区 |
| 3 | 退回已删除 gate 主线（HTML gate / CONFIRMED / 会话 spec / 写前 hook） | 见 [unit-cycle-protocol.md](../../../references/unit-cycle-protocol.md) |
| 4 | 把 `G1-G3` 当流程门禁继续使用 | 仅保留 `§1-§3` 章节语义，不再以旧门禁驱动推进 |
| 5 | 当前段未收口就一口气补齐多段 | 一次只处理一个当前段；批量补齐仅能走 `F`（含意图批确认） |
| 6 | `G` 被当成每轮继续 grill 的必选按钮或意图澄清 | 自动 grill 应连续收敛；`G` 仅表示额外深挖当前段 |
| 7 | 语义性变更直接改文，不先确认 | 先给结论、推荐修订和数字选项 |
| 8 | `F` 被当成覆盖前文的整篇重写或跳过意图批确认 | `F` 先批确认意图，再补齐剩余章节，保留已确认前文 |
| 9 | ASD 塞进 API/DDL/规约全文 | ASD 保持边界、变更与规约摘要；实现级正文 → `/sdx-design` |
| 10 | system/company 仍写应用级详设 | 联邦模式只写概要边界与承接指针 |
| 11 | §3 无规约摘要或无下游承接 | 至少保留摘要表与 DSD/spec-asd 指针 |
| 12 | 文首元数据缺失或 `id` 与路径不一致 | 要求文首 frontmatter；`id = ASD-{IDEA-ID}-{N}` |
| 13 | `IDEA-ID` / `N` 与 PRD 脱节 | 参数向导阶段锁同链 |
| 14 | 未跑 validate | [SKILL.md](../SKILL.md) 校验 |
