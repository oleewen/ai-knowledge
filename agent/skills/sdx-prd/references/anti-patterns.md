# sdx-prd 反模式（叙事）

与 [design-principles.md](design-principles.md) 表格互补；操作层见 [../gotchas.md](../gotchas.md)。

| 反模式 | 纠正 |
|--------|------|
| 未确认写 **PRD** 终稿 | 会话 spec + Qclose-1 + `CONFIRMED` 或合法例外；[gates.md](gates.md) |
| 无 ANALYSIS / 未锁 MVP | 停；`sdx-analysis`；只纳当前 MVP FR；[gotchas.md](../gotchas.md) |
| 用独立 brainstorming 替本会话 spec | 仍以 `...-sdx-prd.md` + Gn；[brainstorming-integration.md](brainstorming-integration.md) |
| 实现细节进正文 | Path/表字段/选型 → DSD；[design-principles.md](design-principles.md) |
| 臆测 / 吞没歧义 | 证据 + 单题 Q-n |
| 跳章 / 空章 | 跟 `prd-template`；空节标不适用 |
| MVP 越界 | 对照 ANALYSIS 裁剪 |
| UC↔US 断 | 双向互标；用例要素齐 |
| §9 与 §10.2 NAC 断 | 互链或「不适用」 |
| BR 不落 §7 | §7 集中表 + UC 关联 |
| §11.3 假勾选 | 对照 [quality-checklist.md](quality-checklist.md) |
| 元数据错 | 要求文首 frontmatter；字段齐；[workflow.md](workflow.md) |
| Mermaid 错 | 输出前自检图类型语法 |
| 未 validate 收尾 | `validate-prd.sh`（按需 `--gate-check`）；[SKILL.md](../SKILL.md) |
