# docs-merge Grader

据 **evals/evals.json** 输出 JSON：`text`、`passed`、`evidence`。

1. 读 `category`：`should-trigger` / `should-not-trigger`
2. 硬门 = 本 eval `assertions`（按 `priority`）；`evidence` 映 `assertions[].id`
3. 协议释义（仅 assertions/prompt 覆盖时强制）：参数向导 → 写前澄清 → 「澄清 → 生成 → 烤干」→ `C/M/G/S/F`；烤干含受众 A/B/C/E；识别 `<source>`/`<target>`/`--dry-run`、落位、冲突 grilling、一次落盘。见 [unit-cycle-protocol.md](../../../references/unit-cycle-protocol.md)、[intent-clarify.md](../../../references/intent-clarify.md)、[audience-and-language.md](../../../references/audience-and-language.md)
4. 任一 P0 失败 → `passed: false`

**should-not-trigger P0**：`correct-downstream`；`no-false-merge-primary`（不以章节 merge 框下游）。

```json
{
  "text": "通过。写前澄清、单单元、dry-run 与冲突逐条约束正确。",
  "passed": true,
  "evidence": ["intent-clarify-before-write", "single-unit-stop", "dry-run-no-write"]
}
```
