# sdx-solution 操作层陷阱

概念反模式：[references/anti-patterns.md](references/anti-patterns.md)。原则表：[references/design-principles.md](references/design-principles.md)。

## 参数向导

- 参数可逐项确认，也可走快捷组合；勿强制一次性抛全。
- IDEA-ID：主题以中文为主；若用 ASCII slug，本行备注中文题名。
- 快捷组合只是起点；用户仍可改单项，勿把预设当硬锁。
- 禁止退回已删除的 HTML gate / `PENDING→CONFIRMED` / 会话 spec 写前主线；主线=参数向导 + 「澄清 → 生成 → 烤干」（见 [unit-cycle-protocol.md](../../references/unit-cycle-protocol.md)）。

## 推进环（澄清 → 生成 → 烤干）

协议正文见 [unit-cycle-protocol.md](../../references/unit-cycle-protocol.md) 与 [intent-clarify.md](../../references/intent-clarify.md)（sdx 无 `S`）。本文件只补技能特有陷阱。

- 当前段若存在 ≥2 条真实路径，须在**本段**内比选收口。

## 输入与歧义

- 无原始描述不开写；过短则补背景。
- 歧义优先在当前段内通过追问、grilling 或局部比选收口；勿默认升级为整篇阻塞。

## 影响面与冲突

- 影响面至少覆盖：功能、数据、接口/对外承诺、下游协作。
- `--depth=quick` 可压缩但不得整块省略；须保留高影响项。
- 每项 C-n 须有化解策略、成本档（高/中/低）、残余风险。

## 收尾验证

- 每个 G-n 须可度量（表「度量」列）或标「待澄清」；预期收益不可空。
- §6.1 里程碑须有验收与退出；需切换者在 §6.2 建行。MVP 切分归 ANALYSIS。
- §1–§6 / §7.1–§7.2：技术名词转业务表述；确需保留的线索放 §7.3。
- §7.4：须对照 [references/quality-checklist.md](references/quality-checklist.md) 逐项勾选，勿未核全选。
