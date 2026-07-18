# sdx-architect 操作层陷阱

概念反模式：[references/anti-patterns.md](references/anti-patterns.md)。

## 参数向导

- 支持逐项确认与快捷组合。
- 禁止退回已删除的 HTML gate / `PENDING→CONFIRMED` / 会话 spec 写前主线；主线=参数向导 + 「澄清 → 生成 → 烤干」（见 [unit-cycle-protocol.md](../../references/unit-cycle-protocol.md)）。
- `IDEA-ID`、`N` 须与 `PRD-{IDEA-ID}-{N}.md` 同链。
- `KNOWLEDGE_TYPE=system|company` 时优先约束输出粒度，避免写成应用级详设。

## 推进环（澄清 → 生成 → 烤干）

协议正文见 [unit-cycle-protocol.md](../../references/unit-cycle-protocol.md) 与 [intent-clarify.md](../../references/intent-clarify.md)（sdx 无 `S`）。本文件只补技能特有陷阱。

- 一次只处理一个当前段；可细到单个 `DD`、服务变更项、交互链路或规约摘要行。
- 当前段若有 `>=2` 条真实架构路径，先在当前段内完成方案比选。

## 内容边界

- `§1` 写目标、约束、关键决策，不要混进实现细节。
- `§2` 写架构边界、服务变更、交互关系；不要在 ASD 中展开完整接口契约。
- `§3` 写规约摘要和下游承接；详细 API/DDL/错误码留给 DSD。
- `spec-asd-*` 只作可选细粒度指针，不取代主 `ASD-*.md`。

## 联邦模式

- `system/company` 只写联邦概要：能力归属、服务边界、变更方向、下游承接。
- 本库不落 DSD；详设应转到应用库 `/sdx-design`。
