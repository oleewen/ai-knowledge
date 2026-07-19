# docs-archive Grader

据 **evals/evals.json** 输出 JSON：`text`、`passed`、`evidence`。

## 判定

1. 读 `category`：`should-trigger` / `should-not-trigger`
2. **硬门**：以本 eval 的 `assertions`（按 `priority`）为准；`evidence` 映射 `assertions[].id`
3. **协议释义**（仅当 assertions / prompt 覆盖时强制）：参数向导 → 确认书（= 写前意图澄清）→ 「澄清 → 落盘 → 烤干」→ `C/M/G/S/F`。见 [unit-cycle-protocol.md](../../../references/unit-cycle-protocol.md)、[intent-clarify.md](../../../references/intent-clarify.md)
4. **P0** 任一失败 → `passed: false`

### should-not-trigger P0 摘要

- `correct-downstream`：点名下游技能/产物
- `no-false-archive-primary`：不以 overview 行链归档为主路径框下游请求

**例**（对齐 `archive-trigger-001`）

```json
{
  "text": "通过。确认书即意图澄清，单单元落盘→烤干，停在动作选择前。",
  "passed": true,
  "evidence": ["intent-clarify-via-confirmation-book", "unit-cycle", "grilling-loop", "single-unit-stop"]
}
```
