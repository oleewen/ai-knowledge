---
name: skill-upgrade
description: >
  已装环境生态 skills 追新：npx skills update -g（lock 内有源可更）；凡无可用源
  （无 lock、lock 失联等）经用户确认后按 /find-skills 流程补源；不能自动抉择则待决策表问用户。
  默认先 dry-run 清单勾选再实跑。
  用户提到 /skill-upgrade、skills update、无源技能补登记、升级 ~/.agents/skills 生态包时，使用本技能。
  分流：本仓 Agent 树 → agent-install；知识库模板对齐 → docs-upgrade；知识库装机 → docs-install；
  纯发现/按需新装（非追新补源）→ find-skills。
  推进见 light-flow-actions（C/M/S/F，无 G）与 references/gates.md。
---

# skill-upgrade

## 输出硬约束（P0）

- 当前单元：一次「生态 skills 追新」计划（可含无源补源栏）。
- 轻流程：参数向导 → 风险校核 → `C/M/S/F`（无 `G`、不绑意图澄清）→ [light-flow-actions.md](../../references/light-flow-actions.md)；细节 [gates.md](references/gates.md)。参数与勾选未收口前不得写盘。
- 默认先 **dry-run 清单**（update + 可选补源）；清单未 `C` 前不得实跑。
- 写 `$HOME` / `~/.agents/skills` 须用户明示；未确认不得默认实跑。
- **本仓 Agent 树**（rules/skills/hooks 等）**不在本技能**；须分流 `/agent-install`。
- **无可用源**：列清单后问是否按 [find-skills](references/find-source.md) 查找；拒 → 本段跳过。搜后建议桶仍须确认才 `add`；多/零候选进待决策表，**不得擅自选源**。
- 宣称单元完成前须按 [audience-and-language.md](../../references/audience-and-language.md) 轻流程默认读者表做写后 **A/B**。

## 边界

| 负责 | 不负责 |
| --- | --- |
| 生态 `npx skills update`；无源时编排 find-skills 补源与决策闸门；dry-run 清单 | 本仓 `agent/` 树（→ agent-install）；知识库装机（→ docs-install）；知识库模板升级（→ docs-upgrade）；纯「找个 skill 做 X」发现（→ find-skills） |

## 不这样用

- 不把追新写成无清单流水线或默认静默写 `$HOME`
- 不在用户拒绝 find 后仍搜；不在多候选时自动挑包
- 不把无源补源做成免确认 `skills add`
- 不把本仓 Agent 树安装/追新收成本技能（→ agent-install）
- 不把 docs-install / docs-upgrade 主路径收成本技能

## 路由

| 目的 | 文件 |
| --- | --- |
| 流程 / 风险 | [workflow.md](references/workflow.md)、[gates.md](references/gates.md) |
| 参数 | [parameters.md](references/parameters.md) |
| 无源补源 | [find-source.md](references/find-source.md) |
| 轻流程动作 | [light-flow-actions.md](../../references/light-flow-actions.md) |
| 易错 | [gotchas.md](gotchas.md) |

## 最少输入

- 生态：global（默认 `-g`）；可选具名 skills
- 无源：是否允许 find（默认先问）；建议桶 / 待决策结果
- 是否 dry-run（默认是）已收口

## 产出与命令

- 正式：更新后的生态 lock skills；经确认的 `npx skills add -g` 补源
- 预览：update 清单 + 无源栏（建议桶 / 待决策 / 跳过）

```bash
npx skills update -g -y
# 补源（仅建议桶确认后）
npx skills add <owner/repo@skill> -g -y
```

## 评测

`evals/evals.json`、[grader.md](agents/grader.md)（P0 断言为准）。重点：无源 find 闸门、建议桶确认、待决策不擅自选、与 agent-install 分流、写后 A/B。
