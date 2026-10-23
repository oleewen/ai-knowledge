# Trigger eval harness note

`trigger-eval.json` 验证技能触发与分流；`trigger-eval-results.json` 保留历史执行结果；当前标记为 `historical-stale`，其 query 与 description 早于现行契约，不能当作当前套件通过证据。修订套件后须实际重跑才可更新结果，不能改写历史 query 或沿用旧通过数。

判定重点：

- 槽位上行、目标层 overview、全量同步应触发。
- `docs-extract`、`docs-archive`、`docs-indexing`、`sdx-*` 明示时应分流。
- `DISTILL-LOG`、`--since`、`--full` 只作为拒绝或纠偏信号，不改变技能边界。
