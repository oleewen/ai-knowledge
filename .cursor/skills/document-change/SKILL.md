---
name: document-change
description: >
  检查最近变动内容，建立“变动内容索引 + 变动时间（毫秒）”。优先从 git commit 提取变更；其次从 CHANGELOG 提取；
  最后以文件 mtime（毫秒）补齐变更文件列表，产出可追溯的变更索引。
---

## 变更文档索引（document-change）

> **形态说明**：`/document-change` 为 **Cursor Slash 技能**（本 `SKILL.md`）；由 Agent 按本文步骤执行，产出 `changes-index.*`。**不是** `scripts/` 目录下的 Bash 可执行脚本，仓库亦**无**同名 shell 脚本。与 `.ai/skills/document-change/SKILL.md` 内容对齐（初始化拷贝到目标工程时二选一存在即可）。

你扮演 **变更审计与文档索引工程师**。目标：生成一份可追溯的变更索引（`changes-index.json` + `changes-index.md`），用于驱动增量索引与审计。

## 0. 输入/输出（契约）

- **输入**
  - 可选：`since_time`（格式：`yyyy-MM-dd HH:mm:ss.SSS`；或提供 `since_time_ms`）
  - 可选：`output_dir`（默认按“changelogs 目录判定逻辑”自动选择）
- **输出**（落盘到 `output_dir`）
  - `changes-index.json`（结构化，可机读）
  - `changes-index.md`（人类摘要，不截断）

## 1. 硬性约束

- **零幻觉**：只记录可从 git / CHANGELOG / 文件元信息读取的事实。
- **路径精确**：所有路径使用项目根相对路径（如 `./system/changelogs/`）。
- **时间统一**：主展示时间均为 `yyyy-MM-dd HH:mm:ss.SSS`；可选附带 `*_ms` 供核对。
- **收录阈值**：
  - 有 git 仓库时：仅收录 **时间 > 最后一次 git commit 时间** 的 CHANGELOG 与本地文件变更（同时也必须满足 `> baseline_time`）。
  - 无 git 仓库时：仅收录 **时间 > baseline_time** 的 CHANGELOG 与本地文件变更。
- **不截断**：凡满足阈值的记录全部写入产物，不取前 N。

## 2. 目录判定（output_dir）

- 若工程存在 `./changelogs/`：取 `./changelogs/`
- 否则：搜索 `**/changelogs/`，若有多个，取“路径最短（最接近根目录）”
- 若不存在：创建 `./changelogs/`

## 3. 核心时间定义（baseline_time 与 cutoff_time）

### 3.1 baseline_time（滚动基线）

优先使用上一次运行产物（形成稳定滚动基线）：

- 若 `output_dir/changes-index.json` 存在且可解析：取其中 `baseline_time`（可选 `baseline_time_ms`）
- 否则默认 `baseline_time = 2020-01-01 00:00:00.000`

### 3.2 cutoff_time（实际收录阈值）

- 若工程为 git 仓库：`cutoff_time = max(baseline_time, latest_git_commit_time)`
- 若非 git 仓库：`cutoff_time = baseline_time`

> 汇总规则：
>
> - **git commits**：仅收录 `commit_time > baseline_time`
> - **CHANGELOG / 本地文件 mtime**：仅收录 `time > cutoff_time`

## 4. 执行步骤（顺序固定）

### Step 1：探测 git 与最新 commit 时间（若是 git 仓库）

- 判断：`git rev-parse --is-inside-work-tree`
- 取 `latest_git_commit_time`

### Step 2：读取上次基线（若存在）并计算 baseline_time / cutoff_time

按 §3 规则得到 `baseline_time` 与 `cutoff_time`。

### Step 3：收集并过滤三类变更（全部 time > cutoff_time）

- **git commits**
  - 提取 commit 元信息与变更文件列表
  - 仅收录 `commit_time > baseline_time`
- **changelog entries**
  - 解析条目时间（不可解析则跳过）
  - 仅收录 `entry_time > cutoff_time`
- **local files by mtime**
  - 递归遍历文件（忽略 `.git/`、`node_modules/`、`.venv/`、`__pycache__/`、以及输出目录）
  - 仅收录 `mtime > cutoff_time`

### Step 4：生成并落盘产物（不截断）

写入 `output_dir/changes-index.json` 与 `output_dir/changes-index.md`，并在两份产物中显式记录：

- `generated_at`
- `baseline_time`
- `cutoff_time`
- 各来源计数与明细（均为“全部”）

