# sdx-test 边界与路由反模式

细则与表格见 [design-principles.md](design-principles.md)；操作层：[../gotchas.md](../gotchas.md)。

| # | 反模式 | 纠正 |
|---|--------|------|
| 1 | 未确认写 `TDD-*.md` 终稿 | [gates.md](gates.md) |
| 2 | 无 PRD 宣称可评审 TDD | 先 **sdx-prd** 或显式风险收窄 |
| 3 | 在 TDD 里扩写 API/DDL 替代 DSD | 追溯 DSD/specs，不吞详设 |
| 4 | 产出自动化代码或执行报告 | 仅 **TDD** 文档 |
| 5 | TC 无 US/API/BR/影响面锚点 | [design-principles.md](design-principles.md)、gotchas |
| 6 | PRD 全文贴进 TDD | 用 Given-When-Then 与编号引用 |
| 7 | 把 **docs-*** 当作测试设计主路径 | 分流 docs 技能 |
