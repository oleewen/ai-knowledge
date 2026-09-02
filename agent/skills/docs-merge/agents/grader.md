# docs-merge Grader

据 **evals/evals.json** 输出 JSON：`text`、`passed`、`evidence`。

1. 读 `category`：`should-trigger` / `should-not-trigger`
2. 硬门 = 本 eval `assertions`（按 `priority`）；`evidence` 映 `assertions[].id`
3. 协议释义（仅 assertions/prompt 覆盖时强制）：…识别落位、**先出变更清单（待新增/更新项数）**、**逐项提问（确认完一条再流转）**、冲突 grilling、一次落盘。
4. 任一 P0 失败 → `passed: false`

**should-not-trigger P0**：`correct-downstream`；`no-false-merge-primary`（不以章节 merge 框下游）。

```json
{
  "text": "通过。写前澄清、单单元、dry-run 与逐项提问确认约束正确。",
  "passed": true,
  "evidence": ["intent-clarify-before-write", "single-unit-stop", "dry-run-no-write"]
}
```
