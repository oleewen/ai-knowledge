# docs-merge 失败分析器

输入失败用例、原始文件、执行轨迹、实际差异及 [评分结果](grader.md)。先复现，再判断问题位于技能、工具、样本还是执行过程。

| 失败位置 | 核查依据 |
| --- | --- |
| 路由、参数、重复询问 | [workflow.md](../references/workflow.md)、实际用户授权 |
| 切块、落位、重复增量、链接 | [merge-spec.md](../references/merge-spec.md) 与输入/输出文件 |
| 清点、逐项决议、越过停点 | 清单、对话顺序及 [gates.md](../references/gates.md) |
| 越界写入、并发覆盖、错误恢复 | 基线、最终文件、工具日志 |
| 断言误报或证据缺失 | [evaluation.md](../references/evaluation.md)、评测工具自测 |

输出：失败证据、影响与 P0/P1/P2、最小修复位置、对应回归用例。修复规则放回唯一真源；相同失败复发时重查根因，不叠加通用禁令。
