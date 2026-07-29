# grilling 能力契约（Agent SSOT）

> **定位**：跨 skill 复用的 `grilling`（写后**烤干**）能力唯一真源。若环境已安装 `grilling` Skill，则优先调用；若未安装，则按本文 fallback 协议执行。
> **边界**：本文只定义能力选择、fallback 提问协议、探索优先与统一输出格式；不定义具体 skill 的写入权限、前文回改边界或段落推进动作。
> **分工**：写前**意图澄清**见 [intent-clarify.md](intent-clarify.md)；推进环/动作/重开见 [unit-cycle-protocol.md](unit-cycle-protocol.md)；受众质检维见 [audience-and-language.md](audience-and-language.md)；主线口令 `澄清 → 生成 → 烤干`。本文不承担写前门禁或动作字母定义。

**最后更新**: 2026-07-29

---

## 能力选择顺序

1. 若环境已安装 `grilling` Skill，优先调用该 Skill。
2. 若未安装 `grilling` Skill，则转入本文定义的 fallback 协议。
3. 两条路径的输出必须能被当前 skill 以统一方式消费。

---

## fallback 协议

fallback 必须满足以下要求：

- 围绕当前计划、当前段或当前决策分支逐枝下钻，直到达成共享理解。
- 一次只问一个问题；等待用户反馈后再继续。
- 每个问题都必须给出推荐答案。
- 每个问题都必须给出快捷数字选项。
- 若可根据仓库文档或代码回答时，先读文档、查代码，再问人。

---

## 问题输出格式

fallback 的每一轮问题建议使用如下结构：

```text
问题：<当前唯一问题>
推荐：<推荐答案 + 简短理由>
选项：
1. <推荐项>
2. <备选项>
3. <另一备选项>
4. 其他，我补充
```

要求：

- `1` 默认为推荐项；若无推荐项，须显式说明原因。
- 选项宜保持 2 到 4 个，避免一次抛出过多分支。
- 若问题本身已可由仓库事实回答，则不应先把该问题抛给用户。

---

## 统一输出语义

无论来自已安装的 `grilling` Skill，还是来自 fallback，当前 skill 至少应能获得：

- 当前问题或当前发现
- 推荐答案
- 快捷数字选项
- 是否建议修订当前对象
- 是否涉及上游前提、前文或跨段影响

---

## 受众质检（烤干必跑）

`sdx-*` 与语义族 docs-* 在写后烤干中**必须**按 [audience-and-language.md](audience-and-language.md) 跑 **A/B/C/E**：

1. 对照技能本地 `references/audience-and-language.md`（主读者 / 宜写宜弱化 / 特殊允许区）。
2. 违例分流与举证格式以该契约为准（全过静默；违例短表）。
3. 统一输出在违例时应能表达：哪一维未过、是否建议自动修订、是否须语义停问。
4. 受众维未过 → 当前 skill 不得将对象标为已烤干收敛。

轻流程 A/B 不经本文；见 [light-flow-actions.md](light-flow-actions.md)。

---

## 与本地 Skill Binding 的边界

以下内容由各 skill 自行定义，不在本文统一：

- 是否允许直接修订当前段或当前对象
- 是否允许前文回改自动执行
- 用户动作协议（如 `C/M/G/S/F`）如何衔接
- 何时进入下一段、下一阶段或整体验证

各 skill 应在本地文档中明确自身 binding，并引用本文，不得重复复制整套 fallback 协议。

---

## 非目标

本文不负责：

- 取代 `brainstorming` 的独立设计流程
- 为任意 skill 默认授予写权限
- 规定具体业务文档的段落结构
- 替代各 skill 自己的 gates / workflow / integration 文档
