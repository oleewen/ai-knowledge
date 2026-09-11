---
name: agent-install
description: >
  安装整棵 Agent 树到 $HOME/.agents/ 并按 --agents 链接 IDE 目录；可选更新目标工程 .docsconfig 的 AGENT_*。
  薄封装 agent/skills/agent-install/scripts/agent-install.sh（--agents/--target/--scope/--dry-run）。
  用户提到 /agent-install、装 agent、更新 ~/.agents、安装 rules/skills/hooks 时，使用本技能。
  分流：知识库骨架 → docs-install；双轨 → 先 docs-install 后本技能；生态 skills 追新 → skill-upgrade；
  元库对齐 → docs-upgrade；联邦登记 → docs-link。
  推进见 light-flow-actions（C/M/S/F，无 G）与 references/gates.md。
---

# agent-install

## 输出硬约束（P0）

- 当前单元：单次 agent-install 计划（含 `--agents`、`--target`、`--scope` 等全部参数）。
- 轻流程：参数向导 → 风险校核 → `C/M/S/F`（无 `G`、不绑意图澄清）→ [light-flow-actions.md](../../references/light-flow-actions.md)；细节 [gates.md](references/gates.md)。参数未收口前不得实跑写盘。
- 默认先 **--dry-run**；dry-run 摘要未确认前，不得静默实跑。
- 写 `$HOME` / `~/.agents` 或工程级 `--target` 须用户明示；未确认不得默认实跑。
- 宣称单元完成前须按 [audience-and-language.md](../../references/audience-and-language.md) 轻流程默认读者表做写后 **A/B**。

## 边界

| 负责 | 不负责 |
| --- | --- |
| 编排 `agent-install.sh`；参数向导与写盘闸门；Agent 树 + `docs-core.sh` 分发 | 知识库同步（→ docs-install）；生态 `npx skills` 追新（→ skill-upgrade）；联邦登记（→ docs-link） |

## 不这样用

- 不把「先 dry-run 再实跑」写成无停顿流水线
- 不在未确认时对 `$HOME` 或工程级 target 静默写盘
- 不把 docs-install / skill-upgrade 主路径收成本技能
- 工程级 target 无 `.docsconfig` 时不假装可更新 AGENT_*（应先 docs-install）

## 路由

| 目的 | 文件 |
| --- | --- |
| 流程 / 风险 | [workflow.md](references/workflow.md)、[gates.md](references/gates.md) |
| 参数 | [parameters.md](references/parameters.md) |
| 轻流程动作 | [light-flow-actions.md](../../references/light-flow-actions.md) |
| 易错 | [gotchas.md](gotchas.md) |

## 最少输入

- `--agents`（可探测或默认 `cursor`）
- `--target`（默认 `$HOME`）
- `--scope`（子树勾选，可默认 `a`）
- 是否 dry-run 已收口

## 产出与脚本

- 正式：`~/.agents/` 实体树 + 各 IDE 目录软链；可选更新目标 `.docsconfig` 的 `AGENT_ROOT`/`AGENT_DIRS`
- 收敛后：产物校核 + 受众 A/B → [light-flow-actions.md](../../references/light-flow-actions.md)

```bash
bash agent/skills/agent-install/scripts/agent-install.sh --agents=cursor --target "$HOME" --dry-run
```

## 评测

`evals/evals.json`、[grader.md](agents/grader.md)（P0 断言为准）。重点：dry-run 闸门、home/target 高风险确认、与 docs-install 分流。
