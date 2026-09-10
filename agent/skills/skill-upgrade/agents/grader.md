# skill-upgrade Grader

据 **evals/evals.json** 输出 JSON：`text`、`passed`、`evidence`。

## 判定

1. 读 `category`：`should-trigger` / `should-not-trigger`
2. **硬门**：以本 eval 的 `assertions`（按 `priority`）为准；`evidence` 映射 `assertions[].id`
3. **协议释义**：轻流程参数向导 → dry-run 清单（含无源 find 闸门）→ `C/M/S/F`；写后受众维 A/B；执行序；overlap 本仓优先；多候选不擅自选；建议桶须确认。见 [light-flow-actions.md](../../../references/light-flow-actions.md)、[gates.md](../references/gates.md)、[find-source.md](../references/find-source.md)
4. **P0** 任一失败 → `passed: false`
