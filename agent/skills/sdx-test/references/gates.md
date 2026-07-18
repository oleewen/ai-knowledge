# sdx-test 推进协议（binding）

主干：[SKILL.md](../SKILL.md)。流程：[workflow.md](workflow.md)。

## 定位

本文件只定义 `sdx-test` 对共享协议的 **binding**（对象=段落）。  
不复制状态机、动作字母全文、`F` 批确认细则或共通 mermaid 环。

契约：

- [intent-clarify.md](../../../references/intent-clarify.md) — 写前意图澄清
- [unit-cycle-protocol.md](../../../references/unit-cycle-protocol.md) — 段落推进环 / `C·M·G·F` / 重开 / 前文回改（**`sdx-*` 无 `S`**）
- [grilling-skill.md](../../../references/grilling-skill.md) — 写后烤干能力

主线口令：`澄清 → 生成 → 烤干`。

---

## 对象定义

**当前段**：`TDD-{IDEA-ID}-{N}.md` 中的一个章节、子章节，或单个功能用例组 / 接口异常组 / 业务规则组 / 数据准备块 / 环境块 / 进出标准块 / 回归范围块（六章模板）。

产物路径见 [workflow.md](workflow.md)。

---

## 技能追加澄清字段

- 上游 `PRD` / `DSD` / `ASD` 对齐点（缺 `DSD` 时须声明范围收窄或技术基线盲区）
- `IDEA-ID`、`N` / `MVP-Phase-{N}`
- `depth`：`quick | standard | deep`
- 优先展开面：`功能 / 接口 / 业务规则 / 异常 / 性能 / 回归`

---

## 语义问题清单（烤干须停）

- 测试范围、优先级、回归边界
- 环境约束、数据准备口径
- 退出标准、术语

---

## 前文回改触发例（技能特有）

- 测试范围漂移
- 回归边界 / 环境约束变化
- 数据策略变化
- 上游追溯变化

---

## 失败停顿

- 当前段未收敛前，不得自动推进下一段
- 语义问题或前文回改：立即停下确认
- 本技能不产出自动化代码与执行报告；若用户要求越界，停下确认范围
