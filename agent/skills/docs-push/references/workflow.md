# docs-push 工作流

## 1. 准备

- `knowledge-links.yaml` 中 **`path`** 为本机已存在目录（多为已 clone 的应用根）。
- `app_name` 与文件名末段一致：legacy → `spec-…-{app}`；asd → `spec-asd-{IDEA}-{PHASE}-{app}` 最后一段。
- **`--specs-dir`**：asd **递归**，通常取 `{DOC_DIR}` 根（非仅单层 `specs/`），除非你确定所有 `spec-asd` 都在该树下。

## 2. copy

1. 建议先 `--dry-run` 核对目标绝对路径。
2. 去掉 `--dry-run` 执行 `copy`。
3. **`--strict`**：CI 或不允许部分成功；否则无法路由的条仅告警跳过。

## 3. Git 四档（`copy` 成功后）

同一套 `--specs-dir` / `--links` / `--mode` / `--branch`，向用户说明所选档位：

| 意图 | `--git-op` |
|------|------------|
| 只看工作区 | `none` |
| 暂存 | `stage` |
| 提交 | `commit`（须 `--message`） |
| 提交并推送 | `push`（须 `--message`；**执行前用户须明确同意**） |

不同 Git 根时脚本按**仓库根聚合**：每根一次 `add`，`commit`/`push` 各一次。

## 4. 脏工作区

默认：`repo` 切分支前、以及可能改 Git 状态前，`git status` 除**本次计划内文件**外不得有其余变更。放宽用 `--allow-dirty`（仍建议先清理无关变更）。
