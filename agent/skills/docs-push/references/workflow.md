# docs-push 工作流

## 1. 准备

- 确认 `knowledge-links.yaml` 中目标 **`path`** 为本机已存在目录（通常为已 clone 的应用库根）。
- 确认 `app_name` 与 spec 文件名后缀一致。

## 2. 拷贝（`copy`）

1. 建议先 `--dry-run` 核对目标绝对路径。
2. 去掉 `--dry-run` 实跑 `copy`。
3. **`--strict`**：CI 或「不允许部分成功」时使用；否则无法路由的文件仅告警并跳过。

## 3. Git 四档（`git`）

在 **`copy` 成功后**，向用户说明四档并给出可选命令（同一套 `--specs-dir` / `--links` / `--mode` / `--branch`）：

| 用户意图 | `--git-op` |
|----------|------------|
| 只确认工作区 | `none` |
| 暂存不提交 | `stage` |
| 提交 | `commit`（须 `--message`） |
| 提交并推送 | `push`（须 `--message`；**执行前须用户明确同意**） |

每个登记目标若对应**不同** Git 根，脚本按**仓库根聚合**：每个根一次 `add`，`commit`/`push` 各一次。

## 4. 脏工作区

默认在 `repo` 模式切换分支前、以及 `git` 子命令在可能改写 Git 状态前，会检查 `git status --porcelain`：除**本次计划内的目标文件相对路径**外不得有其它变更。若需放宽，使用 `--allow-dirty`（仍建议先清理无关变更）。
