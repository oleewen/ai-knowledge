# agent-install Grader

按 [evals.json](../evals/evals.json) 逐条输出 `id`、`passed`、`evidence`；证据应来自实际回复、工具调用或产物，不能用预期答案代替观察。

- 触发评测检查主路径；行为评测检查参数、授权和实际副作用，不要求固定措辞或字母口令。
- 任一 P0 断言失败则该例失败。询问已提供的参数、擅自扩大 IDE/scope、把预览说成安装均须记录。
- 行为用临时目录和隔离 HOME；无额外授权不得测试真实安装树。脚本行为另由 [tests/run.sh](../tests/run.sh) 验证，不能以文字承诺替代。
