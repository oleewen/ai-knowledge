# docs-upgrade 推进协议（binding）

主干：[SKILL.md](../SKILL.md)。流程：[workflow.md](workflow.md)。

## 定位

本文件只做 `docs-upgrade` 对共享契约的 **binding**，不复制协议正文。

契约：

- [intent-clarify.md](../../../references/intent-clarify.md) — 写前意图澄清
- [unit-cycle-protocol.md](../../../references/unit-cycle-protocol.md) — 单元推进、`C/M/G/S/F`、重开与前文回改
- [grilling-skill.md](../../../references/grilling-skill.md) — 写后烤干能力

主线口令：`澄清 → 生成 → 烤干`。用户动作与状态机见 unit-cycle-protocol（含 docs 语义族 `S`）。

预检：[brainstorming-integration.md](brainstorming-integration.md)。实操：[gotchas.md](../gotchas.md)。

## 单元定义

**当前单元**可以是：

- 单个主文件
- 单个已确认关联批次
- 单个回链修复批次

一次只处理一个。快路径（单点修复、用户已限「仅本文件」）：可一屏六项摘要 + 范围确认书后写前 `C`。

**本技能对 `S` 的补充语义**：暂存时优先表示「仅主文件 / 跳过关联扩展或写入」（仍不落盘当前扩展单元）。

## 技能追加澄清字段 / 边界

公共六项落点示例见 [workflow.md](workflow.md)。可用 [docs-upgrade-scope-ack-template.md](../assets/docs-upgrade-scope-ack-template.md) 承载。

本技能：定向改文 + 默认链式（引用 + 关键词）；简写 `a - b` / `a > b` / `a 2 b`。  
**不作为主路径**：CHANGE-LOG 聚合（docs-change）、INDEX 重建（docs-indexing）、overview 行归档（docs-archive）、实体索引（docs-build），除非用户明说附加。

澄清阶段须额外关注：多文件或大目录替换；术语边界不清；是否扩展关联未说明；意图可能越过 docs-upgrade 边界。

## 写后默认

见 [workflow.md](workflow.md)「写后默认表」。本技能各当前单元默认必须烤干。

## 高风险场景

须先给结论、推荐与数字选项，确认后再执行：

- 是否把术语替换扩展到引用链和关键词链
- 是否只改当前主文件
- 术语或表述是否跨越业务语义边界
- 关联文件是否应按同一口径统一

## 原子性 / 失败停顿

- 未获写前 `C`，不得写入当前单元正文或扩展关联
- 范围或术语边界被 `M` 修改 → 回到澄清并重获写前 `C`
- 当前单元未收敛前，不得自动推进关联批次

## 典型语义问题（烤干）

- 术语边界、是否扩展、是否批量替换
- 导航路径、相对链接、`#anchor` 变更
