# sdx-prd 推进协议（binding）

主干：[SKILL.md](../SKILL.md)。流程：[workflow.md](workflow.md)。

## 定位

本文件只定义 `sdx-prd` 对共享协议的 **binding**（对象=段落）。  
不复制状态机、动作字母全文、`F` 批确认细则或共通 mermaid 环。

契约：

- [intent-clarify.md](../../../references/intent-clarify.md) — 写前意图澄清
- [unit-cycle-protocol.md](../../../references/unit-cycle-protocol.md) — 段落推进环 / `C·M·G·F` / 重开 / 前文回改（**`sdx-*` 无 `S`**）
- [grilling-skill.md](../../../references/grilling-skill.md) — 写后烤干能力

主线口令：`澄清 → 生成 → 烤干`。

---

## 对象定义

**当前段**：`PRD-{IDEA-ID}-{N}.md` 中的一个章节、子章节，或 `§4/§5/§10` 内单个 `UC` / `US` / `AC/NAC`（十一章模板）。

产物路径见 [workflow.md](workflow.md)。

---

## 技能追加澄清字段

- 上游 `ANALYSIS-{IDEA-ID}` 对齐点
- `IDEA-ID`、`N` / `MVP-Phase-{N}`
- `depth`：`quick | standard | deep`
- 本轮起始章节 / 范围（含是否细化到单个 `US` / `UC`）

---

## 语义问题清单（烤干须停）

- 目标、范围、承诺、口径、取舍、风险、MVP、优先级
- 角色、主流程、用例边界、故事拆分
- 验收标准（`AC/NAC`）、术语

---

## 前文回改触发例（技能特有）

- MVP 切分失真
- 角色定义冲突
- 流程主干变化
- 验收口径变化

---

## 失败停顿

- 当前段（含单个 `US` / `UC` / `AC`）未收敛前，不得自动推进下一段
- 语义问题或前文回改：立即停下确认
