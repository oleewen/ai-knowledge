# docs-tag 失败分析

输入：请求、实际响应/操作、[grader](grader.md) 证据和对应 eval。只分析已观察到的失败。

| 失败类别 | 检查入口 |
| --- | --- |
| 误把提炼、术语修订、索引当 tag | [SKILL.md](../SKILL.md) 的触发边界 |
| 重复确认、未经选词写入、擅自续阶段或扩文件 | [gates.md](../references/gates.md) |
| 命令不可用、路径推断或产物格式不符 | [workflow.md](../references/workflow.md)、[脚本](../scripts/keyword_tag.py) |
| 命中范围错误、正文丢失或兼容回归 | [gotchas.md](../gotchas.md)、[tests](../tests/) |
| 无结果证据就宣称成功 | [grader.md](grader.md) |

每项输出：现象与证据、根因、P0/P1/P2 优先级、最小修复位置、对应回归场景。先复现失败，再验证修复；行为 eval 与脚本测试分别报告，不互相替代。
