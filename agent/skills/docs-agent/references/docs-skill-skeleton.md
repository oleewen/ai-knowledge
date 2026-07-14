# docs 族 SKILL 结构 SSOT

供 `docs-*` Slash 技能对齐 `SKILL.md` 骨架；**不上收** `agent/references/`。改骨架须同步本文件与各技能 diff。

## Markdown 骨架（≤55 行）

```markdown
---
name: <skill>
description: >
  <第三人称能力句>。
  触发：<`/slash` 与口述同义>。
  分流：<docs vs sdx / 其他技能一句>。
  推进协议或约束：<参数向导 / 当前单元 / 轻量校核 / 真实硬约束一句>。
---

# <title>（一行定位）

## 边界

| 负责 | 不负责 |
|------|--------|
| … | … |

## 最短路径

1. [gates.md](references/gates.md)
2. [workflow.md](references/workflow.md)
3. …（仅文件名，无长解释）

## 最少输入 / 风险约束

（1–3 句 + 链 gates.md；描述参数向导、风险确认或真实硬约束）

## 产出

（路径 + 可选一条 bash invocation）

## 评测 / 脚本

（各 1–2 行指针；无则删节）
```

## description 规范

1. **第三人称**、动词开头；含触发、分流、推进协议或真实约束；≤1024 字符。
2. **不与**正文「边界」表逐字重复。
3. 采用当前交互主线的技能：description 写「参数向导 / 当前单元 / 轻量校核」或 `.docsconfig` 硬门禁等本技能真实约束。

## 禁止出现在 SKILL.md

- 与「最短路径」重复的「执行顺序 N 步」长表
- 「五步索引」等与 `workflow.md` 双表（workflow 为 SSOT）
- 与 `gates.md` / `workflow.md` 重复的参数长表（参数 SSOT → workflow 或 core-concepts）
- 「参考索引」全表（`references/README.md` 为 SSOT）

## references 分工（技能内）

| 文件 | SSOT |
| ---- | ---- |
| `gates.md` | 参数确认、风险边界、动作协议、例外 |
| `workflow.md` | 主线步骤、当前单元、参数与脚本 invocation |
| `brainstorming-integration.md` | ≤20 行 + 链 gates |
| `references/README.md` | 索引表（何时读） |
