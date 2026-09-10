---
name: docs-bootstrap
description: >
  知识库与 Agent 装机编排：可选 docs / agent / both。本仓按 components 分步调
  docs-install.sh / agent-install.sh 并透传各自全参数；remote 且参数未超出
  bootstrap 表面时，可调 docs-bootstrap.sh（现支持 --components）。单选 docs/agent
  在 local 仍分步；remote + 仅表面参可用 bootstrap --components=docs|agent|both。
  默认 dry-run（或计划摘要）后确认再实跑。
  用户提到 /docs-bootstrap、初始化知识库、装 agent、docs-install、agent-install、curl bootstrap 时，使用本技能。
  分流：已装环境追新（双轨）→ skill-upgrade；已有库对齐元库最新（不丢正文）→ docs-upgrade；
  发现/新增生态技能 → find-skills；联邦建联 → docs-link 脚本；规约下发/回拉 → docs-push / docs-pull；日常改文 → docs-revise / docs-simplify。
  推进见 light-flow-actions（C/M/S/F，无 G）与 references/gates.md。
---

# docs-bootstrap

## 输出硬约束（P0）

- 当前单元：单次装机计划（含所选 components 与全部已收口参数）。
- 轻流程：参数向导 → 风险校核 → `C/M/S/F`（无 `G`、不绑意图澄清）→ [light-flow-actions.md](../../references/light-flow-actions.md)；细节 [gates.md](references/gates.md)。参数未收口前不得实跑写盘。
- 默认先 **dry-run**；dry-run 摘要未确认前，不得静默实跑。
- `--force`、覆盖已有目标 docs、`agent-scope=home` / `--target $HOME` 写 Agent 树等须用户明示；未确认不得默认开启。
- `--components=docs|agent|both`（默认 `both`）。脚本与技能同名同义。
- 本仓快路径判定：工作区根同时存在 `scripts/docs-bootstrap.sh`、`scripts/docs-install.sh`、`agent/scripts/docs-core.sh` → 本地分步。`docs-bootstrap.sh` 仅当 remote + 未超出表面参时可用（含单选 docs/agent）。
- 宣称单元完成前须按 [audience-and-language.md](../../references/audience-and-language.md) 轻流程默认读者表做写后 **A/B**。

## 边界

| 负责 | 不负责 |
| --- | --- |
| 编排 `docs-install.sh` / `agent-install.sh` / `docs-bootstrap.sh`；参数向导与写盘闸门 | 已装追新（→ skill-upgrade）；`docs-link.sh` 联邦登记；docs-push / docs-pull；语义改文；改装机脚本契约本身 |

## 不这样用

- 不把「先 dry-run 再实跑」写成无停顿流水线
- 不在未确认时对 `$HOME` 或已有文档树强制 `--force`
- 不把 docs-link / push / pull / revise / skill-upgrade 主路径收成本技能
- 超出表面参时不假装可走 `docs-bootstrap.sh` 全透传

## 路由

| 目的 | 文件 |
| --- | --- |
| 流程 / 风险 | [workflow.md](references/workflow.md)、[gates.md](references/gates.md) |
| 参数 | [parameters.md](references/parameters.md) |
| 轻流程动作 | [light-flow-actions.md](../../references/light-flow-actions.md) |
| 脚本说明 SSOT | [scripts/README.md](../../../scripts/README.md) |
| 易错 | [gotchas.md](gotchas.md) |

## 最少输入

- `--components`（可默认 both）
- docs 侧：`--target` / `--doc-target`（目标工程文档目录）
- agent 侧：`--agents`、安装根（`--agent-scope` 或 agent `--target`）
- 是否 dry-run / force 等高风险项已收口

## 产出与脚本

- 正式：目标工程知识库 + `.docsconfig`（若选 docs）；Agent 树（若选 agent）
- 收敛后：产物校核 + 受众 A/B → 动作见 [light-flow-actions.md](../../references/light-flow-actions.md)（本技能有 `S`，无 `G`）

```bash
# 本仓快路径示例（components=both）
bash scripts/docs-install.sh --target PATH --dry-run
bash scripts/agent-install.sh --agents=cursor --target "$HOME" --dry-run

# 远程 + 表面参（含单选）
bash scripts/docs-bootstrap.sh --components=both --doc-target PATH --agents=cursor --agent-scope=home
bash scripts/docs-bootstrap.sh --components=agent --agents=cursor --agent-scope=home
```

## 评测

`evals/evals.json`、[grader.md](agents/grader.md)（P0 断言为准）。重点：components 路由、本仓快路径、超出表面禁 bootstrap、dry-run 闸门、高风险确认、写后 A/B。
