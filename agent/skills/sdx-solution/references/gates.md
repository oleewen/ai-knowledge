# sdx-solution 推进协议（binding）

主干：[SKILL.md](../SKILL.md)。流程：[workflow.md](workflow.md)。

主线口令：`澄清 → 生成 → 烤干`。动作 `C/M/G/F`（无 `S`）。一次一段，除非 `F` 且已批确认意图。

## 写入约束

- 顺序固定：`这次改了什么` → `为什么这样切` → `范围内外` → `流程怎么串` → `主数据主权` → `技术例外`。
- 事实只来自当时 knowledge 里已有的 `PD`、`BP`、`BSP`、`MDG`、`TSD`。缺 ID 则停，不现造。
- `范围内外` 用 `PD`。`流程怎么串` 用 `BP` / `BSP`。`主数据主权` 写哪个 `PD` 使用哪个 `MDG`。`技术例外` 写相对公司模板的例外，点 `TSD`。
- 正文不出现 `SYS`，不写 `FR`、里程碑、`MVP`。
- `parent` 只指向已有的 `SOLUTION-{IDEA-ID}`，或第一份为空。
- 不修改上一份正文。

## 硬停

- `KNOWLEDGE_TYPE` 不是 `solution` 或 `sln`。
- 选定的上一份已经被另一份 `SOLUTION` 写成 `parent`。
- 要在正文引入 knowledge 中不存在的实体。
