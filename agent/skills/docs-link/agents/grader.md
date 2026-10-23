# docs-link 评分规则

输入：[evals.json](../evals/evals.json) 中一个场景，以及实际响应、工具轨迹、产物快照。评估者的自述或“将运行”不证明执行。

逐条覆盖该场景全部 `assertions`，输出 JSON：

```json
{
  "text": "结论与未测范围",
  "passed": false,
  "evidence": [
    "<断言 id> | pass/fail/not_run | <命令、退出码、产物差异或响应位置>"
  ]
}
```

- `must_include` 检查实际决定、操作或结果，不要求复述某个标题或固定口令。
- `must_not_conflict` 核对完整响应和工具轨迹；只凭没有出现某句话不能通过。
- 副作用断言须有文件前后对照；执行断言须有命令及退出码。缺证据用 `not_run`，不编造日志。
- 任一 P0 为 `fail` 或 `not_run`，`passed` 为 `false`；全部 P0 有证据通过才为 `true`。P1 也逐条报告。
- should-not-trigger 以正确分流且未调用建联写入为准；受众检查以摘要是否足以核对 links、槽位、模式及未完成项为准，不强求输出“A/B”字样。

执行与证据采集见 [评测方法](../references/evaluation.md)。
