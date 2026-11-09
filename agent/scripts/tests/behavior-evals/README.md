# 隔离行为评测

`scenarios.json` 定义本轮来源证据、升级兼容、联邦消费、安装和恢复的 10 组端到端场景。`run.sh` 为每组创建临时 HOME、临时元库副本和临时工作区，调用独立 Codex Agent，再调用独立评分 Agent；正式结果只保留场景状态和隔离产物标识，不保存临时绝对路径或会话材料路径。

```bash
bash agent/scripts/tests/behavior-evals/run.sh --timeout 600 --model gpt-5.6-luna
```

行为结果与脚本回归分开。`passed` 需要实际文件/命令证据；模型超时、缺少认证或夹具前提不足记为 `not_run`，不能改写为通过。2026-11-07 的 45 秒窗口未完成 10 组，均记为 `not_run`。2026-11-09 将默认隔离执行窗口调至 600 秒，并修正可用模型、Bash 5 入口、命令事件留档及可写评分产物后重跑；[11-09 结果](results-2026-11-09.json)显示 10 组均通过独立评分。该结果只证明隔离行为场景通过，不代表真实消费库或元仓四层模板全部通过。既有元仓模板数据问题与 docs-indexing 缓存污染仍由 TODO 独立跟踪。

旧格式兼容仅覆盖已有工具可核实的平铺 MS、带 `implements_to` 的旧 API、parent/child/meta 清单和系统历史 DSD 保留；不承诺历史英文 OKF fixtures 通过当前 runner。
