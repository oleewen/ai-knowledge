# docs-build 评测

读取 [evals.json](../evals/evals.json) 对应场景，按 assertion ID 给出观察证据。只复述「应校验」不能证明已运行；只给命令不能证明文件未被误写。

- `should-trigger`：检查实际产物、调用参数、当前单元边界及未闭合问题。
- `should-not-trigger`：检查是否正确分流且没有额外 build 写入。
- 任一适用断言失败则整例 fail；无失败但仍有未执行或无证据断言则 not_run；全部适用断言有证据通过才为 pass。
- 输出 `text`、`status`（pass/fail/not_run）、`evidence`；每条 evidence 含 assertion ID、状态及文件/命令证据。

复测时使用隔离临时仓，只给评测者真实请求、技能与必要原始资料，不附预期答案。脚本回归见 [test_tools.py](../tests/test_tools.py)；完整行为评测不能由字符串匹配代替。
