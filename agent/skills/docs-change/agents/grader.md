# docs-change Grader

据 **evals/evals.json** 输出 JSON：`text`、`passed`、`evidence`。

## 判定

1. 读 `category`：`should-trigger` / `should-not-trigger`
2. **硬门**：以本 eval 的 `assertions`（按 `priority`）为准；`evidence` 映射 `assertions[].id`
3. **协议释义**（仅当 assertions / prompt 覆盖时强制）：轻流程参数向导 → 轻量校核 → `C/M/S/F`（无 `G`、不绑意图澄清）。见 [light-flow-actions.md](../../../references/light-flow-actions.md)
4. **P0** 任一失败 → `passed: false`

### should-not-trigger P0 摘要

- `correct-downstream`：点名下游技能/产物
- `no-false-change-primary`：不以 CHANGE-LOG 聚合框下游请求

**例**（对齐 change-trigger-001）

```json
{
  "text": "通过。三源聚合、单输出单元停顿与轻流程动作正确。",
  "passed": true,
  "evidence": ["structure-integrity", "single-output-stop", "boundary-routing"]
}
```
