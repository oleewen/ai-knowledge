# sdx-design 推进协议（binding）

主干：[SKILL.md](../SKILL.md)。流程：[workflow.md](workflow.md)。

## 定位

本文件只定义 `sdx-design` 对共享协议的 **binding**（对象=段落）。  
不复制状态机、动作字母全文、`F` 批确认细则或共通 mermaid 环。

契约：

- [intent-clarify.md](../../../references/intent-clarify.md) — 写前意图澄清
- [unit-cycle-protocol.md](../../../references/unit-cycle-protocol.md) — 段落推进环 / `C·M·G·F` / 重开 / 前文回改（**`sdx-*` 无 `S`**）
- [grilling-skill.md](../../../references/grilling-skill.md) — 写后烤干能力

主线口令：`澄清 → 生成 → 烤干`。

---

## 对象定义

**当前段**：`DSD-{IDEA-ID}-{N}.md` 中的一个章节、子章节，或 `§2` 内单个 `API` / `DDL/TBL` / `LOGIC` / 错误码组 / 幂等·事务·时序·安全策略块（`§1-§3`）。

产物路径见 [workflow.md](workflow.md)。

---

## 技能追加澄清字段

- 上游追溯：`PRD` / `ASD` / `spec-asd` / `FR` 对齐点
- 当前段类型：`§1` 决策 / `API` / `DDL` / `LOGIC` / 错误码 / 幂等 / 时序 / 非功能
- 实现路径预判：是否已有 `>=2` 条真实实现路径需段内比选
- `IDEA-ID`、`N` / `MVP-Phase-{N}`、`depth`

---

## 语义问题清单（烤干须停）

- 接口语义、数据模型、事务边界
- 错误码口径、幂等策略、服务归属
- 非功能取舍、优先级、术语

---

## 前文回改触发例（技能特有）

- 接口语义漂移、DDL 调整
- 错误码冲突
- 上游追溯变化
- 非功能口径变化

---

## 失败停顿

- 当前段（含单个 API/DDL/LOGIC 块）未收敛前，不得自动推进下一段
- 语义问题或前文回改：立即停下确认
- 收口前 `validate-dsd.sh` 失败时，不得宣称完成
