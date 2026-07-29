# docs-tag Grader

据 **evals/evals.json** 输出 JSON：`text`、`passed`、`evidence`。

## 判定

1. 读 `category`：`should-trigger` / `should-not-trigger`
2. **硬门**：以本 eval 的 `assertions`（按 `priority`）为准；`evidence` 映射 `assertions[].id`
3. **协议释义**（仅当 assertions / prompt 覆盖时强制）：轻流程参数向导 → phase 轻量校核 → `C/M/S/F`（无 `G`、不绑意图澄清 / 语义族 grilling）。写后受众 A/B。见 [light-flow-actions.md](../../../references/light-flow-actions.md)、[audience-and-language.md](../../../references/audience-and-language.md)
4. **P0** 任一失败 → `passed: false`

### should-not-trigger P0 摘要

- `correct-downstream`：点名下游技能/产物
- `no-false-tag-primary` / `boundary-upgrade`：不以 tag 附录+✅ 框第三列提炼或全库术语

**例**（对齐 docs-tag-trigger-001）

```json
{
  "text": "通过。参数门禁、单单元停顿、子阶段路径与 phase 轻量校核正确。",
  "passed": true,
  "evidence": ["param-gate", "single-unit-stop", "subphase-path", "phase-result-light-check"]
}
```
