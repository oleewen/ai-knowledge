# sdx-analysis 反模式

用于识别误用；处置细节见所链事实源，不作为额外流程。

| 反模式 | 处置入口 |
| --- | --- |
| 用户要 FEATURE/PRD/ASD 等，却强制先写 ANALYSIS | [SKILL 边界](../SKILL.md) |
| 把参数向导变成反复确认，或用模板覆盖已有内容 | [workflow](workflow.md) |
| 用 F 重写已确认前文，或回改后沿用旧确认 | [单元推进协议](../../../references/unit-cycle-protocol.md) |
| 把业务 Q-n、技术 ADR 和研发线索混为一表 | [gates](gates.md) |
| 为业务可读而丢失数值承诺，或把需求写成已有事实 | [受众要求](audience-and-language.md)、[写作原则](design-principles.md) |
| 把「脚本退出 0」当业务共识，未核实便全勾 §7.4 | [质量清单](quality-checklist.md) |

不恢复已移除的 HTML gate、CONFIRMED 或写前 hook 流程。
