# docs-build 参考文档索引

渐进披露：先读上级 [SKILL.md](../SKILL.md)，再按 [SKILL.md](../SKILL.md)「执行路由」打开下列文件。

| 文档 | 内容摘要 | 何时打开 |
|-----|---------|----------|
| [gates.md](gates.md) | 高风险门禁、Qclose-1、`docs-build-gate`、钩子 | 任意写入 `{DOC_DIR}/knowledge/` 前 |
| [workflow.md](workflow.md) | 四阶段、参数、视角顺序、验证命令、预检策略 | 每次执行前 |
| [interaction-gate.md](interaction-gate.md) | spec 路径、交互节奏、边界 | 阶段 1 末、多轮确认时 |
| [builtin-config.md](builtin-config.md) | 内置配置、完整约束、错误处理 | 阶段 1；配置/异常 |
| [extraction-rules.md](extraction-rules.md) | 四视角提取规则（TOC） | 阶段 2 |
| [readme-fill-spec.md](readme-fill-spec.md) | README 列映射与版式 | 阶段 3 |
| [consolidation-spec.md](consolidation-spec.md) | 归并与 KNOWLEDGE_INDEX | 阶段 4 |
| [quality-checklist.md](quality-checklist.md) | 提取后自查表 | 阶段 4 后 |
| [core-concepts.md](core-concepts.md) | 术语、视角缩写 | 混淆时 |
| [design-principles.md](design-principles.md) | 设计原则（短） | 对齐范围时 |
| [anti-patterns.md](anti-patterns.md) | 概念反模式 | 收敛前 |
| [brainstorming-integration.md](brainstorming-integration.md) | 与 brainstorming/SDD 边界 | 需求超范围时 |

资产与脚本：[../assets/knowledge-schema-template.json](../assets/knowledge-schema-template.json)、[../assets/knowledge-index-template.md](../assets/knowledge-index-template.md)、[../scripts/validate-extraction.sh](../scripts/validate-extraction.sh)。操作层见 [../gotchas.md](../gotchas.md)。
