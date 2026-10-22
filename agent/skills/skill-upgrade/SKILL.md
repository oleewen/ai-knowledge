---
name: skill-upgrade
description: >
  升级已安装的第三方生态 skills，并为缺失或失效的来源整理补源候选。
  用于 /skill-upgrade、skills update、已装技能追新或补登记来源。
  本仓 Agent 树同步用 agent-install；知识库模板升级用 docs-upgrade；新技能发现用 find-skills。
---

# skill-upgrade

先预览已装生态技能的升级计划，经确认后执行并核验结果。一个计划为一个当前单元；动作采用 [轻流程 C/M/S/F](../../references/light-flow-actions.md)。

## 执行

1. **盘点**：读取所选安装范围与 lock，区分有源、缺源、检查失败和本仓管理项。详见 [workflow.md](references/workflow.md)。
2. **预览**：列出技能、来源、检查证据、拟执行动作与待决策项。默认只读；本地记录不等于远端存在更新。
3. **补源（按需）**：仅在用户允许搜索时读 [find-source.md](references/find-source.md)。搜索许可不等于安装许可；候选须由用户确认。
4. **执行与核验**：按 [gates.md](references/gates.md) 确认具体范围、命令和覆盖风险；只执行已确认项，报告成功、失败、跳过与未核实项。

## 边界

- 仅升级生态 skills；本仓 rules/skills/hooks 同步交给 [agent-install](../agent-install/SKILL.md)。
- 不猜 CLI 参数。具名更新、global 范围与非交互能力须先核实，见 [parameters.md](references/parameters.md)。
- 网络、认证或限流失败不证明来源失效；不据此替换来源。
- 用户未确认前不写安装目录或 lock；未知来源、多候选、本地修改和额外写入目标均须在计划中明确。
- 完成前做 [受众 A/B](../../references/audience-and-language.md#轻流程-ab含-okf)；全过可静默。

## 维护与验证

易错处见 [gotchas.md](gotchas.md)；行为场景见 [evals/evals.json](evals/evals.json)，评分见 [grader.md](agents/grader.md)。本技能无自有执行脚本；命令由已核实的生态 CLI 提供。
