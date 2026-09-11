# docs-install 工作流

## 参数向导

按序收口；用户已明确时可跳过对应项：

1. `--target`（目标工程文档目录，必填）
2. `--scope`（默认 `knowledge`；仅写 `.docsconfig` 时用 `config`）
3. `--type` / `--mode`（scope=knowledge 时；application 可选 central）
4. `--force` / `-r`（创建工程根等高风险项）
5. 是否先 `--dry-run`（默认是）

参数未收口前，不进入执行。

## 当前单元

**一次装机计划** = 一个 `--target` 的 docs-install（含全部参数）。

一次只推进一个目标；多目标用 `F` 逐个补齐。

## 执行循环

### 1 准备

- Bash 5+；本仓或已 clone 的中央库树
- 目标父目录存在（或用户确认 `-r` 创建）

### 2 dry-run

```bash
bash agent/skills/docs-install/scripts/docs-install.sh --target <PATH> [选项] --dry-run
```

展示将同步的路径、`.docsconfig` 变更摘要；停下等 `C/M/S/F`。

### 3 实跑

用户 `C` 后去掉 `--dry-run` 重跑同一参数集。失败则整单停。

### 4 写后停顿

1. 校核 `DOC_ROOT`、`.docsconfig`、`knowledge-links.yaml`（若新建）
2. 受众维 **A/B**
3. 停下等待 `C/M/S/F`

未过 A/B → 不得宣称单元完成。

## 与 agent-install 编排

对话中「知识库 + Agent」双轨：**先** docs-install **后** agent-install。自动化用仓根 `bootstrap.sh`（`--components=both`）。
