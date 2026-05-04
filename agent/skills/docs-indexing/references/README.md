# docs-indexing 参考文档索引

渐进披露：先读上级 [SKILL.md](../SKILL.md)，再按 [SKILL.md](../SKILL.md)「执行路由」打开下列文件。

| 文档 | 内容摘要 | 何时打开 |
|------|----------|----------|
| [gates.md](gates.md) | 高风险门禁、双层确认、路径证据、钩子 | 任意写入 `INDEX_GUIDE.md` / `INDEXING-LOG.md` 前 |
| [workflow.md](workflow.md) | 六步流程、参数、脚本、质量与输出 | 每次执行前 |
| [interaction-gate.md](interaction-gate.md) | spec 路径、交互节奏、路径清单 | 参数确认后、多轮确认时 |
| [scan-config-onboarding.md](scan-config-onboarding.md) | 上下文探索、便捷预设、话术 | 步骤 1～2 |
| [scan-spec.md](scan-spec.md) | 深度/模式/过滤/日志/错误处理 | 步骤 4 |
| [nine-chapter-spec.md](nine-chapter-spec.md) | 九章结构 | 步骤 6 |
| [quality-standards.md](quality-standards.md) | 质量验证 | 步骤 5 |
| [indexing-log-spec.md](indexing-log-spec.md) | INDEXING-LOG 表、锚点、增量 | 读/写日志时 |
| [brainstorming-integration.md](brainstorming-integration.md) | 与 SDD / brainstorming 边界 | 需求超范围时 |
| [anti-patterns.md](anti-patterns.md) | 概念层反模式 | 收敛执行策略前 |

资产与脚本：[../assets/index-guide-template.md](../assets/index-guide-template.md)、[../scripts/indexing.sh](../scripts/indexing.sh)、[../scripts/indexing_log.py](../scripts/indexing_log.py)。操作层见 [../gotchas.md](../gotchas.md)。
