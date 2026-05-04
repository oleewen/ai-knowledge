# docs-pull 参考文档索引

渐进披露：执行技能时**先读上级 [SKILL.md](../SKILL.md)**，再按 [SKILL.md](../SKILL.md)「执行路由」打开下列文件。

| 文档 | 内容摘要 | 何时打开 |
|-----|---------|----------|
| [gates.md](gates.md) | 写盘 HARD-GATE、与 SDX 闸门差异、何时停问、实跑前确认 | 多应用/分支/`--force`/实跑前 |
| [workflow.md](workflow.md) | 术语、IO、参数、四步、脚本调用、核心约束 | 每次执行前 |
| [manifest-spec.md](manifest-spec.md) | manifest 字段与示例 | 解析或修改 manifest 时 |
| [core-concepts.md](core-concepts.md) | 联邦镜像、manifest、分支优先级 | 术语混淆时 |
| [design-principles.md](design-principles.md) | 拉取设计原则（短） | 与协作者对齐范围时 |
| [anti-patterns.md](anti-patterns.md) | 概念层反模式 | 收敛方案前 |
| [quality-checklist.md](quality-checklist.md) | 实跑前后勾选表 | 步骤 2–4 前后 |
| [brainstorming-integration.md](brainstorming-integration.md) | 与 SDD/brainstorming 边界 | 需求超出「拉镜像」时 |

脚本与模板：[../scripts/pull-docs.sh](../scripts/pull-docs.sh)、[../assets/pull-log-template.md](../assets/pull-log-template.md)。操作层陷阱见 [../gotchas.md](../gotchas.md)。可选一纸流：[../assets/docs-pull-run-checklist.md](../assets/docs-pull-run-checklist.md)。
