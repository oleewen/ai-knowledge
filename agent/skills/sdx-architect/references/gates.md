# sdx-architect 推进协议（binding）

主干：[SKILL.md](../SKILL.md)。流程：[workflow.md](workflow.md)。

## 定位

本文件只定义 `sdx-architect` 对共享协议的 **binding**（对象=段落）。  
不复制状态机、动作字母全文、`F` 批确认细则或共通 mermaid 环。

契约：

- [intent-clarify.md](../../../references/intent-clarify.md) — 写前意图澄清
- [unit-cycle-protocol.md](../../../references/unit-cycle-protocol.md) — 段落推进环 / `C·M·G·F` / 重开 / 前文回改（**`sdx-*` 无 `S`**）
- [grilling-skill.md](../../../references/grilling-skill.md) — 写后烤干能力

主线口令：`澄清 → 生成 → 烤干`。

---

## 对象定义

**当前段**：`ASD-{IDEA-ID}-{N}.md` 中的一个章节、子章节，或 `§1.3 / §2 / §3` 内单个 `DD`、服务变更项、交互链路、规约摘要行（`§1-§3`）。

产物路径见 [workflow.md](workflow.md)。

---

## 技能追加澄清字段

- 上游 `PRD-{IDEA-ID}-{N}` 对齐点
- `IDEA-ID`、`N` / `MVP-Phase-{N}`
- `KNOWLEDGE_TYPE`（影响输出粒度 / 联邦模式）
- `depth`：`quick | standard | deep`
- 是否需要联邦概要或 `spec-asd-*` 指针

---

## 语义问题清单（烤干须停）

- 目标、范围、边界、能力归属、服务拆分
- 规约口径、风险、优先级
- 联邦模式、术语

---

## 前文回改触发例（技能特有）

- 边界漂移
- 服务归属变化
- 联邦模式切换
- 规约口径 / 术语冲突

---

## 失败停顿

- 当前段未收敛前，不得自动推进下一段
- 语义问题或前文回改：立即停下确认
