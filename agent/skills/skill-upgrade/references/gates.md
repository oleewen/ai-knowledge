# skill-upgrade 风险控制与确认点

按 [agent/rules/CONVENTIONS.md](../../../rules/CONVENTIONS.md#artifact-gates)，本技能为低风险工程同步族中的**生态 skills 追新**编排：副作用在 `$HOME/.agents/skills`，闸门从严。

非 dry-run 写盘前须取得用户明确同意（轻流程 `C`）。

## 参数确认

至少收口：

- 生态 global 与 lock 范围
- 无源：是否 find；建议桶确认；待决策已决或明确跳过
- dry-run 默认开启直至 `C`

宣称完成前须写后 **A/B**。

## 风险与动作

须先给结论、推荐与选项：

- 写 `$HOME` / 覆盖 `~/.agents/skills`
- 生态 `npx skills update` / 补源 `npx skills add`
- 全量无源 find（耗时与误匹配风险）——搜前须确认

用户要更新本仓 `agent/` 树 → **停止**，分流 `/agent-install`。

```text
即将执行 /skill-upgrade，当前参数如下：
- ecosystem: <lock 更新 N；失败转无源摘要>
- find-source: <skip | pending-confirm | suggested K + decide M>
- dry-run: <yes|no>

C 确认当前追新计划 / M 修改参数 / S 跳过 / F 在已确认前提下补齐同类计划
```
