# sdx-solution 概念层反模式

操作细节见 [../gotchas.md](../gotchas.md)。原则：[design-principles.md](design-principles.md)。

| # | 反模式 | 纠正 |
|---|--------|------|
| 1 | 未确认即写终稿（无例外、`PENDING`） | [gates.md](gates.md)：总确认与标记 |
| 2 | 用独立 brainstorming 终态替代会话 spec / Qclose-1 | 阶段二仍以 `…-sdx-solution.md` 收口；见 [brainstorming-integration.md](brainstorming-integration.md) |
| 3 | G{n} / G-n 混写 | **G{n}** 门禁；**G-n** §1.3 条目 |
| 4 | Gn 未收口就写 G(n+1) | [workflow.md](workflow.md)：逐段收口 |
| 5 | 回跳后无差别重填 | 做强/弱/无依赖评估，由人选重走范围 |
| 6 | 确认人占位或缺门禁标记 | `$HOME` 末级用户名；补齐 HTML 注释与文件名引用 |
| 7 | 仅 G4 才做多方案对比 | 任一门禁若有 ≥2 真实路径须在**该门禁内**对比 |
| 8 | 业务章堆砌接口/表名/中间件 | 转业务语；线索收 §7.3 |
| 9 | §7.4 未核全勾 | [quality-checklist.md](quality-checklist.md) 逐项 |
|10 | 无输入或瞒歧义 | 补足材料；一律 Q-n |
|11 | 影响面只写功能或 quick 整块空 | 四维相关项须覆盖；quick 保留高影响 |
|12 | C-n 无成本与残余风险 | 每项：策略 + 成本档 + 残余风险 |
|13 | 不可测目标或伪 MVP | 能量化或标「待澄清」；MVP 须对应业务问题 |
|14 | 未跑 `validate-solution.sh` 即收口 | [SKILL.md](../SKILL.md) 校验 |
