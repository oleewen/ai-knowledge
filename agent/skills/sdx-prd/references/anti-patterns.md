# sdx-prd 概念反模式

操作细节：[../gotchas.md](../gotchas.md)。原则：[design-principles.md](design-principles.md)。

| # | 反模式 | 纠正 |
| --- | --- | --- |
| 1 | 未确认当前段就自动推进下一段 | [gates.md](gates.md)：自动 grill 收敛后必须停在 `C/M/G/F` |
| 2 | 无 ANALYSIS 硬写 PRD | 停并指 `sdx-analysis`，或收窄并标注产品基线盲区 |
| 3 | 退回会话 spec / `Qclose-1` / `CONFIRMED` 主线 | 主线是参数向导 + 分段直写 `PRD-*.md` |
| 4 | 把 `11G/6G` 当流程门禁继续使用 | 仅保留模板章节，不再以旧门禁驱动推进 |
| 5 | 当前段未收口就一口气补齐多段 | 一次只处理一个当前段；批量补齐仅能走 `F` |
| 6 | `G` 被当成每轮继续 grill 的必选按钮 | 自动 grill 应连续收敛；`G` 仅表示额外深挖当前段 |
| 7 | 语义性变更直接改文，不先确认 | 先给结论、推荐修订和数字选项 |
| 8 | `F` 被当成覆盖前文的整篇重写 | `F` 只补齐剩余未完成章节，保留已确认前文 |
| 9 | 仅 `§2/§5/§10` 才做多方案 | 任一当前段 `>=2` 条真实路径都应段内比选 |
| 10 | 正文堆接口、DDL、技术选型 | 留给 ASD/DSD；PRD 保持产品/业务表述 |
| 11 | §11.3 假勾选 | [quality-checklist.md](quality-checklist.md) 逐项自检 |
| 12 | `IDEA-ID` / `N` 与 ANALYSIS 或路径脱节 | 参数向导阶段锁同链 [core-concepts.md](core-concepts.md) |
| 13 | 文首元数据缺失或 `id` 与路径不一致 | 要求文首 frontmatter；字段齐；`id = PRD-{IDEA-ID}-{N}` |
| 14 | 未跑 validate | [SKILL.md](../SKILL.md) 校验 |
