# docs-install Grader

依据 [evals.json](../evals/evals.json) 检查真实行为，逐断言输出 `id`、`passed`、`evidence`，再给总体 `passed`。

## 判定

1. `category` 判断是否应选本技能；明确点名但任务越界时，应正确分流。
2. 优先检查工具调用、退出码、文件差异及停止点；口头承诺不能证明零写入或完成安装。需实跑的用例只在隔离临时目录中验证。
3. 证据须对应断言 ID。任一 P0 失败则整体失败；缺工具或前置时注明未验证，不能据缺失证据判通过。
4. 授权以 [gates.md](../references/gates.md) 为准。按 [共享 A/B](../../../references/audience-and-language.md) 检查摘要受众与信息边界，允许静默，不检查字母口令。
