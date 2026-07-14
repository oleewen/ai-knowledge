# docs-push 工作流

## 参数向导

按以下顺序收口参数；用户已明确时可跳过对应项：

1. `--specs-dir`
2. `--links`
3. `--mode`
4. `--git-op`
5. `--branch`（`mode=repo` 或 Git 档位需要时）
6. `--strict`

参数未收口前，不进入执行。

## 当前目标单元

一个当前目标单元就是单个目标 repo/path 组。

一次只处理一个当前目标单元，不并行推进多个目标。

## 执行循环

### 1 准备

- `knowledge-links.yaml` 中 **`path`** 为本机已存在目录（多为已 clone 的应用根）
- `app_name` 与文件名末段一致：legacy → `spec-…-{app}`；asd → `spec-asd-{IDEA}-{PHASE}-{app}` 最后一段
- **`--specs-dir`**：asd **递归**，通常取 `{DOC_DIR}` 根（非仅单层 `specs/`），除非你确定所有 `spec-asd` 都在该树下

### 2 dry-run 路由校核

建议先 `--dry-run` 核对当前目标单元的绝对路径：

```bash
bash agent/skills/docs-push/scripts/push-specs.sh copy \
  --specs-dir DIR --links system/knowledge-links.yaml --mode path --dry-run
```

dry-run 后立即校核：

- 目标 repo/path 是否符合路由预期
- `legacy` / `spec-asd` 是否落到正确目录
- `--strict` 是否符合用户预期

### 3 copy 执行

在当前目标单元路由已确认后，去掉 `--dry-run` 执行 `copy`。

### 4 Git 四档

同一套 `--specs-dir` / `--links` / `--mode` / `--branch`，向用户说明所选档位：

| 意图 | `--git-op` |
| ---- | ---------- |
| 只看工作区 | `none` |
| 暂存 | `stage` |
| 提交 | `commit`（须 `--message`） |
| 提交并推送 | `push`（须 `--message`；**执行前用户须明确同意**） |

不同 Git 根时脚本按**仓库根聚合**：每根一次 `add`，`commit` / `push` 各一次。

### 5 风险校核与动作停顿

当前目标单元完成后，立即校核：

- 目标文件是否写到预期目录
- `git-op` 是否仍符合用户授权
- 脏工作区策略是否满足当前目标
- 是否继续下一目标单元

当前目标单元收敛后，停下等待 `C/M/S/F`：

- `C`：确认当前目标单元并结束或进入下一目标
- `M`：修改参数、路由或 Git 档位，再重新校核
- `S`：跳过当前目标单元
- `F`：按已确认参数补齐剩余目标

## 脏工作区

默认：`repo` 切分支前、以及可能改 Git 状态前，`git status` 除**本次计划内文件**外不得有其余变更。放宽用 `--allow-dirty`（仍建议先清理无关变更）。
