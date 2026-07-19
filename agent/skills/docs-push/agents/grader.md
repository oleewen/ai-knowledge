# docs-push Grader

据 **evals/evals.json** 输出 JSON：`text`、`passed`、`evidence`。

## 判定

1. 读 `category`：`should-trigger` / `should-not-trigger`（缺省按 should-trigger）
2. **硬门**：以本 eval 的 `assertions`（按 `priority`）为准；`evidence` 映射 `assertions[].id`
3. **协议释义**（仅当 assertions / prompt 覆盖时强制）：轻流程参数向导 → dry-run/风险校核 → `C/M/S/F`（无 `G`、不绑意图澄清）。见 [light-flow-actions.md](../../../references/light-flow-actions.md)
4. **P0** 任一失败 → `passed: false`

### 常见 P0 摘要

- `single-target-stop`：单目标停顿
- `dry-run-route-confirmation`：dry-run 后先核路由
- `git-op-must-confirm`：git push / message 须显式授权

**例**（对齐 eval id 1）

```json
{
  "text": "通过。单目标停顿与 dry-run 路由确认正确。",
  "passed": true,
  "evidence": ["single-target-stop", "dry-run-route-confirmation"]
}
```
