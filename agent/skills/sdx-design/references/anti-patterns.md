# sdx-design 反模式（概念层）

与 [design-principles.md](design-principles.md) 内「反模式清单」互补：**路由与产物**优先在此排查；细则以 design-principles 为准。

## 边界与产物

| 误判 | 纠正 |
|------|------|
| 未确认写 **DSD** 终稿 | [gates.md](gates.md)：会话 spec + Qclose-1 |
| 在详设「重写 ASD」且无 DD/回跳 | 回 architect 或在 DSD 显式决策记录 |
| 同 IDEA-ID 下无 **ASD-* 且无 spec-asd-*** 即写实现级契约 | 先补其一或用户明示例外留痕 |
| 服务边界级分叉在 Gd「悄悄改架构」 | 边界在 **`/sdx-architect`** 收口 |
| **§2 与 PRD/ASD** 无法在 §2 内互指编号 | 终检前对齐 [quality-checklist.md](quality-checklist.md) |
| **实现级正文**散落在 DSD **外**的第二份 Markdown | 合并进 **DSD §2**，保持单一真相源 |

## 与上游混淆

- 整段贴 **PRD** 叙事代替 **US-n/FR-n** 引用。  
- 把自动化用例写入 DSD 正文代替 **`sdx-test` / TDD**。

操作层：**[../gotchas.md](../gotchas.md)**。
