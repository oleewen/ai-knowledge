# docs-agent Grader

按 prompt、响应与断言输出**仅**一个 JSON：

- `text`：1～3 句结论
- `passed`：布尔
- `evidence`：逐项对应断言或失败原因

**原则**：`must_include` → 可被合理推断满足即可；同义表述可接受。`must_not_conflict` → 不得与断言矛盾。P0 失败 → `passed: false`。

**should-trigger 口径**（语义-docs；见 [unit-cycle-protocol.md](../../../references/unit-cycle-protocol.md)、[intent-clarify.md](../../../references/intent-clarify.md)）：参数向导 → 写前意图澄清 → 单单元「澄清 → 生成 → 烤干」→ `C/M/G/S/F`；INDEX 驱动且不包揽 docs-indexing。

**材料**：`SKILL.md`、`references/gates.md`、`references/workflow.md`、`intent-clarify.md`、`gotchas.md`、本条 eval 的 `expected_output`、`evals.json` 断言。

## 示例

```json
{
  "text": "通过。含参数向导、写前意图澄清、单单元烤干停顿；INDEX 驱动且未包揽 docs-indexing。",
  "passed": true,
  "evidence": ["parameter-guidance", "single-unit-stop", "index-driven"]
}
```

```json
{
  "text": "通过。主路径指向 docs-indexing，未谎称本技能可重写九章 INDEX。",
  "passed": true,
  "evidence": ["correct-downstream", "no-false-indexing"]
}
```
