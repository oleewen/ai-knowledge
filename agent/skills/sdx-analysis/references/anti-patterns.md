# sdx-analysis 概念反模式

操作细节：[../gotchas.md](../gotchas.md)。原则：[design-principles.md](design-principles.md)。

| # | 反模式 | 纠正 |
|---|--------|------|
| 1 | 未确认写终稿 | [gates.md](gates.md)：总确认与标记 |
| 2 | 无 SOLUTION 硬写 ANALYSIS | 停并指 `sdx-solution`，或收窄并标注不完整 |
| 3 | brainstorming 替代会话 spec / Qclose-1 | 仍用 `…-sdx-analysis.md`；[brainstorming-integration.md](brainstorming-integration.md) |
| 4 | G{n} / G-n 混用 | **G{n}** 门禁；**G-n** §1.2 |
| 5 | Gn 未收口就写下一门禁 | [workflow.md](workflow.md) |
| 6 | 回跳后全州重填 | 强/弱/无依赖 + 用户选范围 |
| 7 | 确认人占位、缺 gate 标记 | `$HOME` 末级；补齐 HTML 与 `ANALYSIS-{IDEA-ID}.md` 引用 |
| 8 | 仅 G2/G4 才做多方案 | 任一门禁 ≥2 路径须**门内**对比 |
| 9 | §1–§5、§6.1–§6.2 堆工程名 | 业务语；线索 §6.3 |
|10 | §6.4 假勾 | [quality-checklist.md](quality-checklist.md) |
|11 | MVP 无价值或依赖成环 | 业务价值问句 + §4.3 验环 |
|12 | P0 落在后序 MVP | P0 进首个合理 MVP |
|13 | IDEA-ID 与 SOLUTION 脱节 | 阶段一锁同链 [core-concepts.md](core-concepts.md) |
|14 | 未跑 validate | [SKILL.md](../SKILL.md) 校验 |
