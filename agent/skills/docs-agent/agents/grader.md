# docs-agent Grader

据 **evals/evals.json** 输出 JSON：`text`、`passed`、`evidence`。

## 判定

1. 读 `category`：`should-trigger` / `should-not-trigger`
2. **硬门**：以本 eval 的 `assertions`（按 `priority`）为准；`evidence` 映射 `assertions[].id`
3. **协议释义**（仅当 assertions / prompt 覆盖时强制）：参数向导 → 写前意图澄清 → 单单元「澄清 → 生成 → 烤干」→ `C/M/G/S/F`；烤干须含受众维 A/B/C/E（见 [audience-and-language.md](../../../references/audience-and-language.md)）；INDEX 驱动且不包揽 docs-indexing。见 [unit-cycle-protocol.md](../../../references/unit-cycle-protocol.md)、[intent-clarify.md](../../../references/intent-clarify.md)
4. **P0** 任一失败 → `passed: false`

### should-not-trigger P0 摘要

- `correct-downstream`：点名下游技能/产物
- `no-false-indexing`：不以本技能重写九章 INDEX

**例**（对齐 `docs-agent-trigger-001`）

```json
{
  "text": "通过。参数向导、写前澄清、单单元烤干停顿；INDEX 驱动且未包揽 docs-indexing。",
  "passed": true,
  "evidence": ["parameter-guidance", "intent-clarify-before-write", "audience-check", "single-unit-stop", "index-driven"]
}
```
