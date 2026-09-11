---
name: docs-install
description: >
  知识库初始化：按 --target 同步 knowledge 骨架并写入 .docsconfig（含 KNOWLEDGE_TYPE）。
  薄封装 agent/skills/docs-install/scripts/docs-install.sh（--scope/--type/--mode/--force/--dry-run）。
  用户提到 /docs-install、初始化知识库、写 .docsconfig、standalone/central、scope=config 时，使用本技能。
  分流：Agent 树 → agent-install；双轨装机 → 先本技能后 agent-install（自动化用仓根 bootstrap.sh）；
  联邦登记 → docs-link；元库对齐 → docs-upgrade；已装生态技能追新 → skill-upgrade。
  推进见 light-flow-actions（C/M/S/F，无 G）与 references/gates.md。
---

# docs-install

## 输出硬约束（P0）

- 当前单元：单个 `--target` 的一次 docs-install 计划（含全部已收口参数）。
- 轻流程：参数向导 → 风险校核 → `C/M/S/F`（无 `G`、不绑意图澄清）→ [light-flow-actions.md](../../references/light-flow-actions.md)；细节 [gates.md](references/gates.md)。参数未收口前不得实跑写盘。
- 默认先 **--dry-run**；dry-run 摘要未确认前，不得静默实跑。
- `--force`、覆盖已有目标 docs、`--scope=knowledge` 重置 DOC_DIR 等须用户明示；未确认不得默认开启。
- 建联脚本**不**向目标仓落盘；联邦登记走 `/docs-link`（脚本在 `agent/skills/docs-link/scripts/`）。
- 宣称单元完成前须按 [audience-and-language.md](../../references/audience-and-language.md) 轻流程默认读者表做写后 **A/B**。

## 边界

| 负责 | 不负责 |
| --- | --- |
| 编排 `docs-install.sh`；参数向导与写盘闸门；knowledge 同步 + `.docsconfig` | Agent 树（→ agent-install）；联邦登记（→ docs-link）；元库对齐（→ docs-upgrade）；生态 skills 追新（→ skill-upgrade） |

## 不这样用

- 不把「先 dry-run 再实跑」写成无停顿流水线
- 不在未确认时对已有文档树强制 `--force`
- 不把 docs-link / agent-install / docs-upgrade 主路径收成本技能
- 不向目标工程拷贝 `docs-link.sh` / `link-config.sh`

## 路由

| 目的 | 文件 |
| --- | --- |
| 流程 / 风险 | [workflow.md](references/workflow.md)、[gates.md](references/gates.md) |
| 参数 | [parameters.md](references/parameters.md) |
| 轻流程动作 | [light-flow-actions.md](../../references/light-flow-actions.md) |
| 易错 | [gotchas.md](gotchas.md) |

## 最少输入

- `--target`（目标工程文档目录，必填）
- `--scope`（`knowledge` / `config`，可默认 `knowledge`）
- knowledge 时：`--type` / `--mode` 等已收口
- 是否 dry-run / force 等高风险项已收口

## 产出与脚本

- 正式：目标工程知识库目录 + `.docsconfig`（scope 决定是否写 KNOWLEDGE_TYPE）
- 收敛后：产物校核 + 受众 A/B → 动作见 [light-flow-actions.md](../../references/light-flow-actions.md)（本技能有 `S`，无 `G`）

```bash
bash agent/skills/docs-install/scripts/docs-install.sh --target PATH [--scope=knowledge] [--type=application] [--mode=standalone] --dry-run
```

## 评测

`evals/evals.json`、[grader.md](agents/grader.md)（P0 断言为准）。重点：dry-run 闸门、高风险确认、不写 link 脚本、与 agent-install 分流。
