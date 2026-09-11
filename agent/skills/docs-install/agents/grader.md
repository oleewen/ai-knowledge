# docs-install Grader

据 **evals/evals.json** 输出 JSON：`text`、`passed`、`evidence`。

## 判定

1. 读 `category`：`should-trigger` / `should-not-trigger`
2. **硬门**：以本 eval 的 `assertions`（按 `priority`）为准；`evidence` 映射 `assertions[].id`
3. **协议释义**（assertions 覆盖时强制）：轻流程参数向导 → dry-run → `C/M/S/F`；写后受众维 A/B。见 [light-flow-actions.md](../../../references/light-flow-actions.md)、[gates.md](../references/gates.md)
4. **P0** 任一失败 → `passed: false`
