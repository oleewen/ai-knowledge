# docs-archive 失败分析器

输入：失败样本、[SKILL.md](../SKILL.md)、[gates.md](../references/gates.md)、[workflow.md](../references/workflow.md)、[anti-patterns.md](../references/anti-patterns.md)、[gotchas.md](../gotchas.md)。

输出：

1. 失败模式；
2. 根因与证据；
3. P0/P1/P2 修复（目标、最小改动、影响、至少一个回归用例）；
4. 回归建议。

模式：路由误判、确认书或当前单元缺失、落盘顺序错误、回写或烤干缺失、冲突静默处理、范围扩张、证据不足。

回归：先跑全量 [evals.json](../evals/evals.json)，再做 archive 与 extract、distill、build、revise 的成对分流；同类失败连续两轮时收紧最小相关规则。
