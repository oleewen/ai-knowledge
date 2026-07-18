# sdx-analysis 操作层陷阱

概念反模式：[references/anti-patterns.md](references/anti-patterns.md)。原则：[references/design-principles.md](references/design-principles.md)。

## 参数向导

- 支持逐项确认与快捷组合。
- 禁止退回已删除的 HTML gate / `PENDING→CONFIRMED` / 会话 spec 写前主线；主线=参数向导 + 「澄清 → 生成 → 烤干」（见 [unit-cycle-protocol.md](../../references/unit-cycle-protocol.md)）。
- `IDEA-ID` 须与 `SOLUTION-{IDEA-ID}.md` 同链。
- 用户若已给 `IDEA-ID`、章节范围、深度，直接确认缺口，不重复追问已知信息。

## 推进环（澄清 → 生成 → 烤干）

协议正文见 [unit-cycle-protocol.md](../../references/unit-cycle-protocol.md) 与 [intent-clarify.md](../../references/intent-clarify.md)（sdx 无 `S`）。本文件只补技能特有陷阱。

- 一次只处理一个当前段；在 `§2` 可细到单个 `FR`。
- 当前段若有 `>=2` 条真实路径，先在当前段内完成方案比选。

## 输入与歧义

- 无 `SOLUTION-{ID}`：终止并指向 `sdx-solution`。
- 方案结构不全：警告并列缺失，正文标“基于不完整方案，存在分析盲区”。
- 无 `knowledge/`：`§1.3` 标“缺少知识库基线，以下仅基于方案”。

## 文档内容

- `§1–§5`、`§6.1–§6.2`：技术词转需求分析语言；线索收 `§6.3` “待研发确认”。
- `§6.4`：对照 [references/quality-checklist.md](references/quality-checklist.md) 逐项勾选。
- `P0` `FR` 须落入首个合理 `MVP`；基础依赖随首个消费方 `MVP`。
