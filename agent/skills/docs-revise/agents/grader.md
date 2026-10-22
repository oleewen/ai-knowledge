# docs-revise 评测判定

对 [evals.json](../evals/evals.json) 的每个断言分别判定。输入须包含原始请求、前序授权、模型响应、工具轨迹及实际文件差异；只评估该用例要求的证据。

- `pass`：有证据支持断言。给出响应片段、动作位置或文件差异。
- `fail`：有证据显示违反断言。指出反例及位置。
- `not_run`：未执行或缺少足以判定的证据；不要从模型自述推断文件动作。

写入 [结果模板](../evals/eval-metadata-template.json) 的 `results`。每项包含 `eval_id` 与逐断言 `id/status/evidence`；`evidence` 写观察及来源，不能只重复断言 ID。既有语境未覆盖的步骤不额外强制，也不要求成功受众检查打印维表。

用 [score_evals.py](../scripts/score_evals.py) 汇总：P0 任一失败则该例失败；P0 缺测则该例未测；全部 P0 通过才通过。P1/P2 单列，不改变硬门判定。脚本只检查记录并汇总，语义与证据真实性仍由评审者核对。

用例附有 `grading_examples` 时，按断言读取样例响应、`after_files` 和可选的 `actions`，同原始 fixture 比较后逐项判定，再对照 `expected_failed_assertions` 校准。独立判分时先隐藏样例名称、预期失败列表及 `reason`；这些样例只验证判分边界，不计作新增任务执行结果。
