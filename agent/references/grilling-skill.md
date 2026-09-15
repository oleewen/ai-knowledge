# grilling 能力契约（Agent SSOT）

> **定位**：跨 skill 复用的 `grilling`（写后**烤干**）能力唯一真源。已装 `grilling` Skill 则优先调用，否则走本文 fallback。  
> **分工**：写前澄清见 [intent-clarify.md](intent-clarify.md)；推进环/动作/重开见 [unit-cycle-protocol.md](unit-cycle-protocol.md)；受众维见 [audience-and-language.md](audience-and-language.md)。本文不定义写前门禁、动作字母、写入权限或前文回改。

**最后更新**: 2026-09-15

---

## GRILL-LOG

根路径 [`changelogs/GRILL-LOG.md`](../../changelogs/GRILL-LOG.md) 是烤干**未闭合代办**清单，不是决策日志或运行史。

| 项 | 约定 |
| --- | --- |
| 职责 | 只记可执行、未勾销的烤干代办 |
| 格式 | 顶层 `- [ ]` 动作句 + 可选依赖；明细用子 checkbox |
| 写入 | 烤干收敛后，若仍有未执行动作，Agent 自动落盘/更新；纯问答不成动作则不写 |
| 勾销 | 用户确认已完成后**即删条**；不留已完成史（落痕用 git / 域 `INDEXING-LOG`） |
| 空壳 | 无开放代办时保留文件：标题 + 导语 +「当前无开放代办」 |

不替代 git 变更溯源 / `INDEXING-LOG`。

---

## fallback

1. 已装 `grilling` Skill → 优先调用。  
2. 未装 → 走下列协议。  
3. 两条路径的输出须能被当前 skill 以统一方式消费。

硬规则：

- 围绕当前计划、当前段或当前决策分支逐枝下钻，直到共享理解。
- 一次只问一个问题；等反馈再继续。
- 每问必须给推荐答案与快捷数字选项。
- 仓库文档或代码能答的，先读再问人。

每轮建议结构：

```text
问题：<当前唯一问题>
推荐：<推荐答案 + 简短理由>
选项：
1. <推荐项>
2. <备选项>
3. <另一备选项>
4. 其他，我补充
```

- `1` 默认为推荐项；无推荐须显式说明原因。
- 选项宜 2–4 个。
- 仓库事实已能答的问题，不先抛给用户。

Skill 与 fallback 至少须交付：当前问题或发现；推荐答案；数字选项；是否建议修订当前对象；是否涉及上游前提、前文或跨段影响。

---

## 受众质检（烤干必跑）

`sdx-*` 与语义族 docs-* 写后烤干**必须**按 [audience-and-language.md](audience-and-language.md) 跑 **A/B/C/E**。

- 对照技能本地 audience（主读者 / 宜写宜弱化 / 特殊允许区）。
- 违例分流与举证格式以该契约为准（全过静默；违例短表）。
- 受众维未过 → 不得标为已烤干收敛。

轻流程 A/B 不经本文；见 [light-flow-actions.md](light-flow-actions.md)。

---

## 边界

各 skill 本地定义、不在本文统一：是否直接修订当前对象；前文回改是否自动执行；`C/M/G/S/F` 如何衔接；何时进入下一段/阶段或整体验证。本地须链本文，不得复制整套 fallback。

本文不负责：取代 `brainstorming`；为任意 skill 默认授予写权限；规定业务文档段落结构；替代各 skill 的 gates / workflow / integration。
