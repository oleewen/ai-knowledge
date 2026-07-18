# sdx-solution 概念层反模式

操作细节见 [../gotchas.md](../gotchas.md)。原则：[design-principles.md](design-principles.md)。

| # | 反模式 | 纠正 |
| --- | --- | --- |
| 1 | 把集中式前置收口当默认起点 | [workflow.md](workflow.md)：先参数向导，再直写终稿 |
| 2 | 把参数发散或段内比选搬出主流程 | 参数澄清留在参数向导；多方案比选留在当前段循环 |
| 3 | 退回已删除 gate 主线（HTML gate / CONFIRMED / 会话 spec / 写前 hook） | 见 [unit-cycle-protocol.md](../../../references/unit-cycle-protocol.md) |
| 4 | 跳过写前意图澄清直接写正文 | 先六项清单 + 写前 `C`，再生成 |
| 4b | 当前段初稿一写完就算完成 | 先烤干到收敛，再由用户用 `C/M/G/F` 收口 |
| 5 | 当前段未收口就偷偷推进下一段 | [gates.md](gates.md)：当前段优先，除非用户显式 `F` 批量补齐余段 |
| 6 | 回改前文后沿用当前段旧结论 | 前文一改，当前段必须 `reopened` 并再 grill 一轮 |
| 7 | 用户给 `M` 后不复检 | 修改后至少再执行一轮 grilling |
| 8 | 把 `G` 当成每轮必选动作，或用户给 `G` 却直接进入下一段 | `G` 只表示在当前段已收敛后继续深挖当前段 |
| 9 | 业务章堆砌接口/表名/中间件 | 转业务语；线索收 §7.3 |
| 10 | §7.4 未核全勾 | [quality-checklist.md](quality-checklist.md) 逐项 |
| 11 | 无输入或瞒歧义 | 补足材料；优先在当前段内澄清 |
| 12 | 影响面只写功能或 quick 整块空 | 四维相关项须覆盖；quick 保留高影响 |
| 13 | C-n 无成本与残余风险 | 每项：策略 + 成本档 + 残余风险 |
| 14 | 不可测目标或伪 MVP | 能量化或标「待澄清」；MVP 须对应业务问题 |
| 15 | 未跑 `validate-solution.sh` 即收口 | [SKILL.md](../SKILL.md) 校验 |
| 16 | 未经用户显式选择 `F` 就一口气生成多段 | 一次只处理一个当前段；写完烤干后等待 `C/M/G/F`；`F` 须先批确认剩余意图 |
