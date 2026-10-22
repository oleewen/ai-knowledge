# docs-okf 评测

读取 [evals.json](../evals/evals.json) 中当前样本的 `category` 与 `assertions`，核对回答、工具轨迹及实际产物。未执行的操作不得判作通过；权限或环境阻断须在证据中说明。

- `should-trigger`：检查所选模式、配置门禁、写入范围与失败处理。
- `should-not-trigger`：检查是否转交正确任务，且未误跑 OKF。
- 每条断言用其 `id` 记录可核实证据；任一 P0 失败，整体 `passed` 为 `false`。未覆盖的断言标「未验证」。
- 摘要按 [受众 A/B](../../../references/audience-and-language.md#轻流程-ab含-okf) 检查；纯机器输出可跳过。运行契约见 [工作流](../references/workflow.md)，不另写第二套规则。

输出 JSON：`text` 为结论，`passed` 为整体判断，`evidence` 为各断言的证据记录。
