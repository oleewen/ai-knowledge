# docs-tag 行为评分

使用 [evals.json](../evals/evals.json) 的场景与断言评估**实际响应和操作**；未执行的场景不记通过。评测可复用 [eval-metadata-template.json](../evals/eval-metadata-template.json) 记录证据。

1. 核对触发分类与主分流，再逐项判定 assertion。
2. P0 任一失败即不通过；P1 是改善建议。共享语义以 [gates.md](../references/gates.md) 和 [轻流程协议](../../../references/light-flow-actions.md) 为准。
3. 阶段要求按请求裁剪：仅 phase 3 不要求 keywords 或 1/2；已明确参数不重复索要授权。`all` 仍须等待用户选词。
4. 写后/摘要出口检查受众 A/B；不扩写业务正文，不强制语义族 grilling。

输出 JSON：`eval_id`、`passed`、`evidence`。每条 evidence 包含 `assertion_id`、`passed` 与可核对的响应摘句、命令或文件变化；缺证据不得按通过处理。失败诊断交 [analyzer.md](analyzer.md)。
