# docs-simplify Grader

据 **evals/evals.json** 输出 JSON：`text`、`passed`、`evidence`。

## 判定

1. 读 `category`：`should-trigger` / `should-not-trigger`
2. **硬门**：以本 eval 的 `assertions`（按 `priority`）为准；`evidence` 映射 `assertions[].id`
3. **协议释义**（仅当 assertions / prompt 覆盖时强制）：参数向导 → 写前意图澄清 → 「澄清 → 生成 → 烤干」→ `C/M/G/S/F`；烤干须含受众维 A/B/C/E（见 [audience-and-language.md](../../../references/audience-and-language.md)）；A/B/C 原则；疑似 SSOT 须确认；与 docs-upgrade 分流。见 [unit-cycle-protocol.md](../../../references/unit-cycle-protocol.md)、[intent-clarify.md](../../../references/intent-clarify.md)、[docs-simplify.md](../../../references/docs-simplify.md)
4. **P0** 任一失败 → `passed: false`

### should-not-trigger P0 摘要

- `correct-downstream`：点名下游技能/产物
- `no-false-simplify-primary`：不以精简/金字塔框下游请求

**例**（对齐 `simplify-trigger-001`）

```json
{
  "text": "通过。写前澄清、ABC 原则、SSOT 确认与单单元烤干停顿正确。",
  "passed": true,
  "evidence": ["intent-clarify", "unit-cycle", "principles-abc", "ssot-confirm", "grilling-loop", "audience-check", "single-unit-stop"]
}
```
