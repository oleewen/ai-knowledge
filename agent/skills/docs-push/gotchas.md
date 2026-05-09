# docs-push 陷阱

- **路径**：中央常写 `{DOC_DIR}/specs/spec-asd-*.md`；推到应用为 `requirements/REQUIREMENT-*/MVP-Phase-*/specs/`（或 `requirements/` 前缀镜像）。跨文档字面统一走 **docs-upgrade**，非本脚本。
- **macOS**：脚本对 `--specs-dir` 规范化；手写路径与 `find` 前缀不一致时统一到同卷。
- **相对 `--links`**：相对**中央库 Git 根**，非任意 `$PWD`（在根执行时二者可能一致）。
- **`repository`**：不参与 clone/fetch；**一律以条目的本机 `path` 为准**。
- **`git checkout -B`**：分支已存在会按 Git 语义移动 HEAD；不熟先用独立 clone/worktree。
- **空提交**：暂存区与 `HEAD` 无差时跳过 commit 并告警。
- **Bash 5+**（与 docs-link 等一致）。
