# sdx 族 SKILL 结构参考

本页供维护技能时参考，不是生成 ANALYSIS 的前置阅读。保留各技能的真实契约，不以统一行数或文件数代替可用性。

| 位置 | 内容 |
| --- | --- |
| frontmatter | name；简明说明能力与触发条件的 description；运行依赖放正文或 metadata |
| SKILL.md | 目的、边界、最短执行路径、按需加载入口、校验方式 |
| references/workflow.md | 参数、输入输出、操作步骤与写后默认表 |
| references/gates.md | 绑定共享协议，补本技能对象、语义边界和失败停顿 |
| assets/ | 产物模板；避免把维护说明带入生成正文 |
| scripts/、tests/ | 有实际价值的确定性检查及行为回归 |
| evals/、agents/ | 现实使用案例与证据判定；按需提供 UI 元数据 |

共享状态机、意图澄清、烤干与精简原则保留在各自事实源，不复制到每个入口。description 不承载完整流程；无需为凑目录增加文件。docs 族结构参考见 [docs-skill-skeleton.md](../../docs-agent/references/docs-skill-skeleton.md)。
