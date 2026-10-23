# agent-install Grader

按 [evals.json](../evals/evals.json) 逐条输出 `id`、`status`（pass/fail/not_run）、`evidence`；证据应来自实际回复、工具调用或产物，不能用预期答案代替观察。缺少证据记 not_run，不能默认为通过；执行与证据要求见 [evaluation.md](../references/evaluation.md)。

- 触发评测检查主路径；行为评测检查参数、授权和实际副作用，不要求固定措辞或字母口令。
- 任一 P0 断言失败则该例失败。询问已提供的参数、擅自扩大 IDE/scope、把预览说成安装均须记录。
- 推断冲突未获选择便显式补参实跑，或已有明确选择仍重复询问，均记失败。多轮用例必须先观察首轮响应及快照，再交付下一条用户消息。
- 行为用临时目录和隔离 HOME；无额外授权不得测试真实安装树。脚本行为另由 [tests/run.sh](../tests/run.sh) 验证，不能以文字承诺替代。
