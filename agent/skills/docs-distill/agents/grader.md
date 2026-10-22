# docs-distill Grader

按 `evals/evals.json` 输出 JSON：`text`、`passed`、`evidence`。

## 判定

1. 按 `category` 区分 `should-trigger` 与 `should-not-trigger`。
2. 逐条核对 `assertions`；`evidence` 只填实际支持断言的 id。
3. 任一 P0 失败即 `passed: false`。
4. `should-trigger` 需同时检查：参数与边、写前澄清、职责/粒度契约、全量、第三列 delta、dry-run 不写盘、写后烤干。
5. `should-not-trigger` 需点名正确下游，并且不把槽位 distill 作为主路径。

评测提示覆盖「契约缺失硬停」「双边冲突不偏边」「受众违例改写或停问」时，必须验证停顿、数字选项和落盘路径，不得只看技能名是否触发。

示例：

```json
{
  "text": "通过。system 边，写前澄清，职责契约闭合，dry-run 不写盘。",
  "passed": true,
  "evidence": ["intent-clarify-before-write", "system-edge", "dry-run-no-write"]
}
```
