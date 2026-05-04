# docs-distill 参考文档索引

渐进披露：执行技能时**先读上级 [SKILL.md](../SKILL.md)**，再按 [SKILL.md](../SKILL.md)「执行路由」顺序打开下列文件。

| 文档 | 内容摘要 | 何时打开 |
|-----|---------|----------|
| [gates.md](gates.md) | 核心门禁、合法例外、HARD-GATE 条件表、标记与钩子关系 | 任意写入前；需判定能否落盘 |
| [workflow.md](workflow.md) | 两日志、参数契约、五阶段、命令示例、脚本表、核心约束摘要 | 每次执行前；编排阶段 1–5 |
| [interaction-gate.md](interaction-gate.md) | 与 sdx-* 对齐表、推荐交互节奏 | 阶段 2–3；多确认点与 dry-run 节奏 |
| [core-concepts.md](core-concepts.md) | APPNAME、changelog_id、日志与 A/U/D 语义 | 术语不清或路径混淆时 |
| [distill-spec.md](distill-spec.md) | 系统侧蒸馏目标范围、变更发现方式 | 定蒸馏范围、写批次文档 |
| [federation-spec.md](federation-spec.md) | 联邦层级、overview 规则、五架构视角、质量自检 | 阶段 4.2–4.3 |
| [distill-log-spec.md](distill-log-spec.md) | DISTILL-LOG 格式、增量逻辑、dry-run 规则 | 读/写锚点、步骤 4.4 |
| [design-principles.md](design-principles.md) | 蒸馏设计原则（短） | 与业务方对齐「写到什么粒度」 |
| [anti-patterns.md](anti-patterns.md) | 概念层反模式与纠正动作 | 收敛方案前、评审前 |
| [quality-checklist.md](quality-checklist.md) | 落盘前验收勾选表 | 阶段 4 末、CLOSE 前 |
| [brainstorming-integration.md](brainstorming-integration.md) | 与多方案/澄清节奏、会话模板指针 | 多方案或长澄清链时 |

陷阱与操作层细节见上级目录 [gotchas.md](../gotchas.md)。
