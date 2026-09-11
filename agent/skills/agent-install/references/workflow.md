# agent-install 工作流

## 参数向导

按序收口；用户已明确时可跳过：

1. `--agents`（探测已有 IDE 目录；空则 `cursor`）
2. `--target`（默认 `$HOME`；工程级须已有 `.docsconfig`）
3. `--scope` 子树勾选（`a`/`r`/`s`/`h`/`sh`/`k`）
4. 是否先 `--dry-run`（默认是）

参数未收口前，不进入执行。

## 当前单元

**一次装机计划** = 单次 agent-install（含全部参数）。

## 执行循环

### 1 准备

- Bash 5+；本仓或已 clone 的中央库树
- 工程级 `--target` 时：目标须有 `.docsconfig`（否则先 docs-install）

### 2 dry-run

```bash
bash agent/skills/agent-install/scripts/agent-install.sh [选项] --dry-run
```

展示将安装/链接的路径；停下等 `C/M/S/F`。

### 3 实跑

用户 `C` 后去掉 `--dry-run` 重跑。失败则整单停。

### 4 写后停顿

校核 `~/.agents`、IDE 链接、`.docsconfig`（若更新）→ **A/B** → `C/M/S/F`。

## 与 docs-install 编排

双轨装机：**先** docs-install **后** agent-install。自动化用仓根 `bootstrap.sh`。
