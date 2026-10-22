# docs-install 风险控制与确认点

本技能绑定 [CONVENTIONS 的工程同步门禁](../../../rules/CONVENTIONS.md#artifact-gates) 与 [轻流程 C/M/S/F](../../../references/light-flow-actions.md)，不进入语义族的意图澄清或 `G` 环。

## 授权单元

一个 `--target` 及其完整参数集是一单。默认先预览，摘要确认后实跑；已有授权明确覆盖该预览、目标与参数集时直接沿用。`F` 只涵盖已确认的同类计划，不能扩展目标或覆盖权限。

预览摘要至少列：源、target、scope、type/mode（适用时）、`-r`、force、`.docsconfig` 写入位置，以及已有目标会被如何处理。需要决策时给结论、推荐和数字选项。

## 特有风险

| 操作 | 写前确认内容 |
| --- | --- |
| knowledge 重装非空目标 | 备份并重置整个目标，根级 `DESIGN.md` 亦整文件替换；获明确覆盖授权后才带 `--force` |
| `-r` 创建缺失工程根 | 确认实际绝对路径；预览只展示创建计划 |
| config 重写 `.docsconfig` | 只写路径键与 `AGENT_*`；已有 `KNOWLEDGE_TYPE` 不保留。需要保留类型时先澄清配置目标，不能以 knowledge 重装代替局部修订 |
| 计划改变或预览失败 | 报告差异或失败原因；重新收口后预览，不能静默改参数继续实跑 |

脚本拒绝非法参数、无效前置和源目标重叠；`--force` 不能越过这些检查。CLI 标志表达执行选择，不代替会话授权。

写后按 [workflow.md](workflow.md) 校核，再做 [受众 A/B](../../../references/audience-and-language.md)：摘要面向装机者，全过静默。完成后按轻流程等待下一动作。
