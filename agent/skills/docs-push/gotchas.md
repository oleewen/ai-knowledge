# docs-push 陷阱

- **中央与应用路径**：中央权威仍可在 **`{DOC_DIR}/specs/spec-asd-*.md`** 撰稿；推送后应用侧落在 **`requirements/REQUIREMENT-*/MVP-Phase-*/specs/`**（或由 `requirements/` 前缀镜像）。若在 `application/DESIGN.md` 等处需字面统一，走 **docs-upgrade**，不在本脚本内改 SSOT。
- **macOS 路径**：脚本对 `--specs-dir` 做物理路径规范化；若手写对比 `find` 与 shell 扩展路径仍异常，统一到同一卷下再跑。
- **`--links` 相对路径**相对于**中央知识库 Git 根**，不是当前 shell 的 `$PWD`（除非你在根目录执行且使用相对路径）。
- **`repository` 字段**：不参与 clone 或 fetch；**写盘与 Git 操作均以条目的本机 `path` 为准**。
- **`git checkout -B <branch>`**：分支已存在时会重置检出到该分支（与 Git 语义一致）；不确定时先用独立 clone 或 worktree 验证。
- **`commit` / `push` 无变更**：若暂存区与 `HEAD` 无差异，脚本会跳过 commit 并告警，避免空提交失败。
- **Bash 版本**：须 Bash 5+（与 `docs-link` 测试要求一致）。
