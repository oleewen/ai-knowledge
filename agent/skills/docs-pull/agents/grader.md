# docs-pull Grader

据 **evals/evals.json** 输出 JSON：`text`、`passed`、`evidence`。

## 判定

1. 读 `category`：`should-trigger` / `should-not-trigger`
2. **硬门**：以本 eval 的 `assertions`（按 `priority`）为准；`evidence` 映射 `assertions[].id`
3. **协议释义**（仅当 assertions / prompt 覆盖时强制）：轻流程参数向导 → 风险校核 → `C/M/S/F`（无 `G`、不绑意图澄清）。见 [light-flow-actions.md](../../../references/light-flow-actions.md)
4. **P0** 任一失败 → `passed: false`

### should-not-trigger P0 摘要

- `correct-downstream`：点名 docs-push 等下游
- `boundary-push`：不以槽位回拉框中央规约下发

**例**（对齐 docs-pull-trigger-001）

```json
{
  "text": "通过。单槽位停顿与同步后 CHANGE-LOG 追溯正确。",
  "passed": true,
  "evidence": ["single-slot-stop", "changelog-must-follow-sync"]
}
```
