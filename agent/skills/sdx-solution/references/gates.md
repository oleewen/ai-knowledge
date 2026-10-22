# sdx-solution 推进协议（binding）

主干：[SKILL.md](../SKILL.md)。流程：[workflow.md](workflow.md)。

当前对象是模板中的一段。写前 [意图澄清](../../../references/intent-clarify.md)，写后 [烤干](../../../references/grilling-skill.md)；动作、批确认与重开遵循 [单元推进协议](../../../references/unit-cycle-protocol.md)，不在本地重定义。生成与修订遵循 [精简原则](../../../references/simplify-principles.md)。

## 写入约束

- 六段标题与顺序以 [模板](../assets/solution-template.md) 为准。第一段：首份说明首次切分，后续说明相对 `parent` 的增量。
- 事实只来自当时 knowledge 里已有的 `PD`、`BP`、`BSP`、`MDG`、`TS`。缺 ID 则停，不现造。
- `范围内外` 用 `PD`。`流程怎么串` 用 `BP` / `BSP`。`主数据主权` 写哪个 `PD` 使用哪个 `MDG`。`技术例外` 写相对公司模板的例外，点 `TS`。
- 正文不出现 `SYS`，不写 `FR`、里程碑、`MVP`。
- 版本链与草稿续写遵循 [core-concepts.md](core-concepts.md#多份与现行)。

## 写后关注点

每段默认必须烤干，表见 [workflow.md](workflow.md#写后默认表)。核实本段引用的实体与关系、跨段范围一致性、前驱增量以及 [受众差额](audience-and-language.md)。技术基准未读、关系缺失或前文前提变化时，先收口问题，不能把未知写成「无例外」。

## 硬停

- `KNOWLEDGE_TYPE` 不是 `solution` 或 `sln`。
- 新建时选定的前驱已有后继；续写时目标已有后继，或用户未明确它是当前草稿。
- 要在正文引入 knowledge 中不存在的实体。
- 目标文件已存在而本次并非续写，或版本链存在重复 ID、悬空 `parent`、分叉、自指、环。
