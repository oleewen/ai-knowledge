# skill-upgrade 工作流

## 参数向导

按序收口；用户已明确时可跳过：

1. 生态范围：默认 global；可选具名 skills
2. 无源集合（见下）→ **是否 find**（须明示；拒则本段跳过）
3. 是否先 dry-run（默认是）

参数与勾选未收口前，不进入实跑。

## 当前单元

**一次追新计划** = 一个当前单元（可含补源栏）。一次只推进一个计划。

## 生态轨（有源）

1. 读 `$HOME/.agents/.skill-lock.json`
2. dry-run：lock 内可更新项（名 / source / updatedAt；可选 hash 提示）
3. 实跑：`npx skills update -g -y`（或具名）；失败项记入「无可用源」

## 无可用源 → find 补源

**无可用源**包括：

- `~/.agents/skills/*` 无 lock 记录
- lock 有记录但 update/检查失败
- 其他已判定「当前无法从已知源刷新」的已装技能

流程见 [find-source.md](find-source.md)。摘要：

1. 列出无源清单 → 问「是否按 find-skills 查找？」→ **拒则跳过本段**
2. 若同意：对每个无源技能按 find-skills 流程搜
3. 分流：建议桶 vs 待决策总表
4. 建议桶汇总确认；待决策批量选
5. 选定的 `add` 命令并入总清单，一次 `C` 后实跑

## 执行循环

### 1 准备

`npx` 与网络；Bash 5+（读 lock 辅助脚本时）。

### 2 dry-run 清单

| 栏 | 内容 |
| --- | --- |
| 生态 | lock 将更新、update 失败转无源 |
| 补源 | 无源列表；find 是否开启；建议桶；待决策 |

### 3 实跑

用户 `C` 后：

1. 补源：`npx skills add … -g -y`（仅已确认项）
2. 生态：`npx skills update …`

失败整单停。

### 4 写后停顿

校核 → 受众 **A/B** → `C/M/S/F`。

## 与本仓 Agent 树分流

用户要更新 `agent/rules`、`agent/skills`（本仓树）→ **停止**，分流 `/agent-install`（`bash agent/skills/agent-install/scripts/agent-install.sh`）。
