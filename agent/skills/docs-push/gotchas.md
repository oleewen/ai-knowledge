# docs-push 陷阱

- **`--links` 相对路径**相对于**中央知识库 Git 根**，不是当前 shell 的 `$PWD`（除非你在根目录执行且使用相对路径）。
- **`repository` 字段**：不参与 clone 或 fetch；**写盘与 Git 操作均以条目的本机 `path` 为准**。
- **`git checkout -B <branch>`**：分支已存在时会重置检出到该分支（与 Git 语义一致）；不确定时先用独立 clone 或 worktree 验证。
- **`commit` / `push` 无变更**：若暂存区与 `HEAD` 无差异，脚本会跳过 commit 并告警，避免空提交失败。
- **Bash 版本**：须 Bash 5+（与 `docs-link` 测试要求一致）。
