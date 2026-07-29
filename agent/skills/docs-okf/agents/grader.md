# docs-okf Grader

据 **evals/evals.json** 输出 JSON：`text`、`passed`、`evidence`。

## 判定

1. 读 `category`：`should-trigger` / `should-not-trigger`
2. **硬门**：以本 eval 的 `assertions`（按 `priority`）为准；`evidence` 映射 `assertions[].id`
3. **协议释义**（仅当 assertions / prompt 覆盖时强制）：轻量参数向导 → refresh/validate/viz → 结果摘要；摘要出口受众 **A/B**（纯机器输出可跳过）；无 `.docsconfig` 或缺 `KNOWLEDGE_TYPE` 硬中止；validate ERROR 须停下；不引入单元循环/grilling。见 [audience-and-language.md](../../../references/audience-and-language.md)
4. **P0** 任一失败 → `passed: false`

### should-not-trigger P0 摘要

- `correct-downstream`：点名下游技能/产物
- `no-false-okf-primary`：不以 OKF refresh 框九章 INDEX 或实体提取

**例**（对齐 `okf-trigger-001`）

```json
{
  "text": "通过。先读 .docsconfig，硬中止条件与 dry-run 不写盘表述正确。",
  "passed": true,
  "evidence": ["docsconfig-hard-stop", "knowledge-type-required", "dry-run-no-write"]
}
```
