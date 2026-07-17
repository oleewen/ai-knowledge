# sdx-analysis 操作层陷阱

概念反模式：[references/anti-patterns.md](references/anti-patterns.md)。原则：[references/design-principles.md](references/design-principles.md)。

## 参数向导

- 支持逐项确认与快捷组合；不要强制退回会话 spec。
- `IDEA-ID` 须与 `SOLUTION-{IDEA-ID}.md` 同链。
- 用户若已给 `IDEA-ID`、章节范围、深度，直接确认缺口，不重复追问已知信息。

## Section Cycle（澄清 → 生成 → 烤干）

- 写入前先意图澄清（六项清单 + 阶段横幅）；未获写前 `C` 勿写正文。
- 一次只处理一个当前段；在 `§2` 可细到单个 `FR`。
- `C` 同符异义：须标「当前阶段：意图澄清」或「当前阶段：烤干」。
- 自动 `grilling` 要连续收敛，不要每一轮都停下来等用户。
- 当前段若有 `>=2` 条真实路径，先在当前段内完成方案比选。
- 语义性问题先给结论、推荐和数字选项，未确认不得改文。
- 非语义性修订可直改当前段，但不要扩展到前文章节。
- 前文一旦回改，当前段必须 `reopened`：再意图澄清 → 再写/修订 → 再 grill。
- 自动收敛后再给 `C/M/G/F`；不要默认替用户选下一步。
- 勿把 `G` 当意图澄清。

## 输入与歧义

- 无 `SOLUTION-{ID}`：终止并指向 `sdx-solution`。
- 方案结构不全：警告并列缺失，正文标“基于不完整方案，存在分析盲区”。
- 无 `knowledge/`：`§1.3` 标“缺少知识库基线，以下仅基于方案”。

## 文档内容

- `§1–§5`、`§6.1–§6.2`：技术词转需求分析语言；线索收 `§6.3` “待研发确认”。
- `§6.4`：对照 [references/quality-checklist.md](references/quality-checklist.md) 逐项勾选。
- `P0` `FR` 须落入首个合理 `MVP`；基础依赖随首个消费方 `MVP`。

## 批量补齐

- `F` 须先批确认剩余意图，再补齐剩余未完成章节；不能覆盖已确认前文。
- `F` 过程中若打出语义性问题或前文冲突，必须立刻停下等待用户确认。
