# agent-install Grader

据 **evals/evals.json** 输出 JSON：`text`、`passed`、`evidence`。

## 判定

1. 读 `category`：`should-trigger` / `should-not-trigger`
2. **硬门**：以本 eval 的 `assertions`（按 `priority`）为准
3. **协议释义**：轻流程 → dry-run → `C/M/S/F`；写后 A/B。见 [light-flow-actions.md](../../../references/light-flow-actions.md)
4. **P0** 任一失败 → `passed: false`
