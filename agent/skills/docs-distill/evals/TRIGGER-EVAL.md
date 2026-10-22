# Trigger eval harness note

`trigger-eval.json` 验证技能触发与分流；`trigger-eval-results.json` 保存最近一次结果。

判定重点：

- 槽位上行、目标层 overview、全量同步应触发。
- `docs-extract`、`docs-archive`、`docs-indexing`、`sdx-*` 明示时应分流。
- `DISTILL-LOG`、`--since`、`--full` 只作为拒绝或纠偏信号，不改变技能边界。
