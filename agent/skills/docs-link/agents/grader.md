# docs-link Grader

据 **evals/evals.json** 输出 JSON：`text`、`passed`、`evidence`。

## 判定

1. 读 `category`：`should-trigger` / `should-not-trigger`
2. **硬门**：以本 eval 的 `assertions`（按 `priority`）为准；`evidence` 映射 `assertions[].id`
3. **协议释义**（仅当 assertions / prompt 覆盖时强制）：轻流程参数向导 → 风险校核 → `C/M/S/F`（无 `G`、不绑意图澄清）。写后受众 A/B。见 [light-flow-actions.md](../../../references/light-flow-actions.md)、[audience-and-language.md](../../../references/audience-and-language.md)
4. **P0** 任一失败 → `passed: false`

### should-not-trigger P0 摘要

- `correct-downstream` / `correct-downstream-push`：点名 docs-pull / docs-push 等下游
- `boundary-pull`：不以建联框槽位回拉

**例**（对齐 docs-link-trigger-001）

```json
{
  "text": "通过。默认 dry-run 与单目标单元停顿正确。",
  "passed": true,
  "evidence": ["dry-run-first", "single-target-unit", "app-name-confirm"]
}
```
