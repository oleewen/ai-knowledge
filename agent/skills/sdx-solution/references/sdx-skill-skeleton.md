# sdx 族 SKILL 结构 SSOT

供 `sdx-*` Slash 技能对齐 `SKILL.md` 骨架。docs 族见 [docs-agent/references/docs-skill-skeleton.md](../../docs-agent/references/docs-skill-skeleton.md)。

## Markdown 骨架（≤60 行）

```markdown
---
name: <skill>
description: >
  <第三人称能力句>。
  触发：/slash 与口述同义。
  分流：docs vs sdx 一句。
  推进协议：动作、写入约束与例外指针 gates.md。
compatibility: Bash 5+；校验脚本或钩子指针。
---

# <title>

## 边界
| 负责 | 不负责 |

## 路由
| 目的 | 文件 |

## 最少输入
（bullet ≤5）

## 推进协议
（链 gates.md；动作协议、写入约束、例外）

## 产出与校验
（路径 + validate-*.sh 或等价校验）

## 评测 / 钩子
（指针）
```

## description 规范

1. 第三人称；触发 + 分流 + 推进协议/写入规则。
2. 保留 `compatibility:` 一行（钩子/脚本/bootstrap/校验）。
3. 不与边界表逐字重复。

## 禁止出现在 SKILL.md

- 「路由表」+「执行路由（先读后写）」双列表（合并为一张路由表）
- 「技能包」表（`references/README.md` 为 SSOT）
- 「阶段摘要」长段（进 workflow）
- KNOWLEDGE_TYPE 正文（SSOT：`sdx-architect/references/knowledge-type-modes.md`，其余一行链）

## references 分工

| 文件 | SSOT |
| --- | --- |
| `gates.md` | 动作协议、写入约束、例外 |
| `workflow.md` | 阶段、状态机、参数、公司库等特殊路径 |
| `brainstorming-integration.md` | ≤20 行 + 链 gates |
| `agent/references/grilling-skill.md` | 公共 `grilling` 能力契约；Skill 优先、fallback 协议、统一输出 |
| `knowledge-type-modes.md` | KNOWLEDGE_TYPE 正文（architect） |
