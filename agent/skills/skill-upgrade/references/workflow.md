# skill-upgrade 工作流

## 参数向导

按序收口；用户已明确时可跳过：

1. 轨：`agent` / `ecosystem` / `both`（默认 both 进清单）
2. 本仓源：`--repo-path` → 工作区探测 → 远程 clone（须清单确认）
3. `--agents`：探测已有 Agent 目录；空则 `cursor`
4. `--target`：默认 `$HOME`
5. 本仓 scope 子树勾选 → 合成 `--scope`
6. 生态：默认 global；可选具名 skills
7. 无源集合（见下）→ **是否 find**（须明示；拒则本段跳过）
8. 是否先 dry-run（默认是）

参数与勾选未收口前，不进入实跑。

## 当前单元

**一次追新计划** = 一个当前单元（可含补源栏）。一次只推进一个计划。

## 源路径探测（本仓轨）

1. `--repo-path` / `REPO_ROOT` → 本地 `agent-install.sh`
2. 三文件齐备 → 本地 `agent-install.sh`
3. 否则 remote：`docs-bootstrap.sh --components=agent`（超出表面参则分步）

## 生态轨（有源）

1. 读 `$HOME/.agents/.skill-lock.json`
2. dry-run：lock 内可更新项（名 / source / updatedAt；可选 hash 提示）
3. overlap → 跳过（本仓优先）
4. 实跑：`npx skills update -g -y`（或具名）；失败项记入「无可用源」

## 无可用源 → find 补源

**无可用源**包括（凡命中均进入候选集，不限无 lock）：

- `~/.agents/skills/*` 无 lock 记录且非本仓 overlap
- lock 有记录但 update/检查失败（API/clone/多路径冲突等）
- 其他已判定「当前无法从已知源刷新」的已装技能

流程细节与置信规则见 [find-source.md](find-source.md)。摘要：

1. 列出无源清单 → 问「是否按 find-skills 查找？」→ **拒则跳过本段**
2. 若同意：对每个无源技能按 find-skills 流程搜（query=目录名）
3. 分流：建议桶（唯一+同名+信任 owner）vs 待决策总表（多/零候选）
4. 建议桶汇总确认；待决策批量选（过歧义再单问）
5. 选定的 `add` 命令并入总清单，与双轨一次 `C` 后实跑

## 执行循环

### 1 准备

Bash 5+；remote 本仓需 Git；生态/find 需 `npx` 与网络。

### 2 dry-run 清单

| 栏 | 内容 |
| --- | --- |
| 本仓 | 源、agents、target、子树、`agent-install --dry-run` 或 bootstrap 计划 |
| 生态 | lock 将更新、overlap 跳过、update 失败转无源 |
| 补源 | 无源列表；find 是否开启；建议桶；待决策（未决则不得宣称清单收口） |

### 3 实跑

用户 `C` 后：

1. 补源：`npx skills add … -g -y`（仅已确认项）
2. 生态：`npx skills update …`
3. 本仓：`agent-install` 或 `docs-bootstrap.sh --components=agent`

（若用户只要双轨、补源为空，则跳过 1。）失败整单停。

### 4 写后停顿

校核 → 受众 **A/B** → `C/M/S/F`。
