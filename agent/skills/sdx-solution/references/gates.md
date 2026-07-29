# sdx-solution 推进协议（binding）

主干：[SKILL.md](../SKILL.md)。流程：[workflow.md](workflow.md)。

## 定位

本文件只定义 `sdx-solution` 对共享协议的 **binding**（对象=段落）。  
不复制状态机、动作字母全文、`F` 批确认细则或共通 mermaid 环。

契约：

- [intent-clarify.md](../../../references/intent-clarify.md) — 写前意图澄清
- [unit-cycle-protocol.md](../../../references/unit-cycle-protocol.md) — 段落推进环 / `C·M·G·F` / 重开 / 前文回改（**`sdx-*` 无 `S`**）
- [grilling-skill.md](../../../references/grilling-skill.md) — 写后烤干能力

主线口令：`澄清 → 生成 → 烤干`。

---

## 对象定义

**当前段**：`SOLUTION-{IDEA-ID}.md` 中的一个章节或子章节（七章模板）。  
一次只打开一段；默认按模板顺序，也可跳转到用户指定段。

产物路径见 [workflow.md](workflow.md)。

---

## 技能追加澄清字段

在公共六项之外可追加（不可删减公共项）：

- `depth`：`quick | standard | deep`
- 本轮起始章节 / 范围
- 表达粒度与语言风格
- 公司库时：跨系统功能边界归属摘要

---

## 语义问题清单（烤干须停）

改变以下任一项时，须先给结论 / 推荐 / 数字选项，用户确认前不得修订：

- 业务目标、范围 / 非范围、承诺口径
- 取舍、风险、里程碑、切换方案（MVP 切分归 ANALYSIS）
- 术语定义、冲突化解策略

---

## 前文回改触发例（技能特有）

协议正文见 [unit-cycle-protocol.md](../../../references/unit-cycle-protocol.md)。本技能常见触发：

- 前文范围边界定义不准确
- 业务目标与前文不一致
- 术语定义冲突
- 前文冲突化解策略已不足以支撑当前段

---

## 失败停顿

- 当前段未收敛前，不得自动推进到下一段
- 语义问题或前文回改：立即停下，确认后再修订 / 重开
