# sdx-analysis 操作层陷阱

概念反模式：[references/anti-patterns.md](references/anti-patterns.md)。原则：[references/design-principles.md](references/design-principles.md)。

## 参数向导

- 支持逐项确认与快捷组合。
- 禁止退回已删除的 HTML gate / `PENDING→CONFIRMED` / 会话 spec 写前主线；主线=参数向导 + 「澄清 → 生成 → 烤干」（见 [unit-cycle-protocol.md](../../references/unit-cycle-protocol.md)）。
- `IDEA-ID` 须与 `SOLUTION-{IDEA-ID}.md` 同链。
- 用户若已给 `IDEA-ID`、章节范围、深度，直接确认缺口，不重复追问已知信息。

## 推进环（澄清 → 生成 → 烤干）

协议正文见 [unit-cycle-protocol.md](../../references/unit-cycle-protocol.md) 与 [intent-clarify.md](../../references/intent-clarify.md)（sdx 无 `S`）。本文件只补技能特有陷阱。

- 一次只处理一个当前段；`§2` 先独立确认 `### 概览`，再可细到单个 `FR`。
- 概览未写后 `C` 前不得写 FR 正文；概览段 `F` 不能跳过该确认。
- 当前段若有 `>=2` 条真实路径，先在当前段内完成方案比选。
- 技术决策：实现向可新建 ADR；改边界回 SOLUTION；引用进 §6.2；见 [sdx-adr-protocol.md](../../references/sdx-adr-protocol.md)。
- 选 **C** 前清 `ADR-待定`；写前查 CONTEXT，冲突停问。

## 输入与歧义

- 无 `SOLUTION-{ID}`：终止并指向 `sdx-solution`。
- 上游 §6.1 里程碑空/过粗无法落到能力：硬停，回补 SOLUTION 或用户提供等价里程碑清单；勿自拟阶段骨架。
- 方案其他结构不全：警告并列缺失，正文标“基于不完整方案，存在分析盲区”。
- 无 `knowledge/`：`§1.3` 标“缺少知识库基线，以下仅基于方案”。

## 文档内容

- 概览拆 FR：主料 = §6.1 覆盖范围；场景/In Scope 补漏；可独立验收能力 = 1 FR；支撑项并入消费方。
- 概览表须含「需求概要」（一句话能力）；需求名称 ≤30 字、需求概要 ≤60 字（Unicode 码点，含空格/标点）；`### FR-n:` 标题 = 概览名称且 ≤30；超限烤干须改，不过写后 C。「所属里程碑」原样抄 §6.1（`M{n}（短名）`；非空、禁 `MVP{n}`、一 FR 一里程碑）；FR→`MVP{n}` 到 §4 再划。
- 优先级按成功标准 / In Scope 关键性（与里程碑序解耦）；`P0` FR 通常仍落在首个可交付里程碑。
- 基础依赖随首个消费方 MVP；§4 写作 `MVP{n}（{短名}）`；与里程碑不硬对齐；每 FR 恰好一 MVP；个数建议 ≈ 里程碑数，偏离须说明。
- FR 段可改概览对应行；§2 整章收口强制对齐。
- `§1–§5`、`§6.1–§6.2`：技术词转需求分析语言；线索收 `§6.3` “待研发确认”。
- `§6.4`：对照 [references/quality-checklist.md](references/quality-checklist.md) 逐项勾选。
