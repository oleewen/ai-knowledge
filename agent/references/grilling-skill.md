# grilling 能力契约（Agent SSOT）

> **定位**：跨 skill 复用的 `grilling`（写后**烤干**）能力唯一真源。已装 `grilling` Skill 则优先调用，否则走本文 fallback。  
> **分工**：写前澄清见 [intent-clarify.md](intent-clarify.md)；推进环/动作/重开见 [unit-cycle-protocol.md](unit-cycle-protocol.md)；受众维见 [audience-and-language.md](audience-and-language.md)。本文不定义写前门禁、动作字母、写入权限或前文回改。

**最后更新**: 2026-10-23

---

## TODO-LIST

烤干未闭合动作按 [开放代办契约](todo-protocol.md) 自动落盘、更新与勾销；本文只交付问题、建议及影响范围。

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

检查维、读者差额与举证格式见 [audience-and-language.md](audience-and-language.md)；调用时机与完成门禁分别由 [单元推进协议](unit-cycle-protocol.md#写后完成条件共通) 和 [轻流程动作](light-flow-actions.md#边界) 规定。

---

## 边界

修订授权、语义停问、前文回改、动作与推进只按 [单元推进协议](unit-cycle-protocol.md)；本地技能仅补业务检查问题，须链本文，不复制整套 fallback，也不重定义公共权限。

本文不取代 brainstorming，不授予写权限，不定义业务文档结构或技能特有 gates / workflow / integration。能力路由见 [workflow-routing.md](workflow-routing.md)。
