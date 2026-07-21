# docs-simplify 推进协议（binding）

主干：[SKILL.md](../SKILL.md)。流程：[workflow.md](workflow.md)。

## 定位

本文件只做 `docs-simplify` 对共享契约的 **binding**，不复制协议正文。

契约：

- [intent-clarify.md](../../../references/intent-clarify.md) — 写前意图澄清
- [unit-cycle-protocol.md](../../../references/unit-cycle-protocol.md) — 单元推进、`C/M/G/S/F`、重开与前文回改
- [grilling-skill.md](../../../references/grilling-skill.md) — 写后烤干能力
- [docs-simplify.md](../../../references/docs-simplify.md) — A/B/C 写作原则

主线口令：`澄清 → 生成 → 烤干`。

## 单元定义

**当前单元**可以是：

- 单个主文件
- 单个已确认扩批（多文件须用户明示）

一次只处理一个。快路径（单文件、用户已限「仅本文件」）：可一屏六项摘要 + 范围确认书后写前 `C`。

**本技能对 `S` 的补充语义**：暂存时优先表示「跳过当前改写或扩批」（仍不落盘当前单元）。

## 技能追加澄清字段 / 边界

公共六项落点示例见 [workflow.md](workflow.md)。可用 [docs-simplify-scope-ack-template.md](../assets/docs-simplify-scope-ack-template.md)。

本技能：结构 + 激进精简 + SSOT 去重引用。  
**不作为主路径**：术语统一（docs-upgrade）、CHANGE-LOG、INDEX、overview 归档、实体索引，除非用户明说附加。

澄清阶段须额外关注：是否点名默认排除类文件；疑似重复候选如何处理；与 docs-upgrade 主目标是否冲突。

## 写后默认

见 [workflow.md](workflow.md)「写后默认表」。本技能各当前单元默认必须烤干。

## 高风险场景

须先给结论、推荐与数字选项，确认后再执行：

- 是否扩批改第二份文件
- 疑似重复是否改成引用 / 删段
- 是否改动 C4 契约面（ID、frontmatter、稳定锚、代码字面量、扫描列）
- 与 docs-upgrade 双目标时的执行顺序

## 原子性 / 失败停顿

- 未获写前 `C`，不得写入当前单元或扩批
- 范围或原则被 `M` 修改 → 回到澄清并重获写前 `C`
- 疑似 SSOT 未确认前，不得删段或改引用
- 当前单元未收敛前，不得自动推进扩批

## 典型语义问题（烤干）

- 是否误删约束/例外/验收
- 金字塔/MECE 是否成立
- 导航路径、相对链接、`#anchor` 是否仍有效
- 是否残留第二份正文真源
