# 反模式（概念层，sdx-test）

本文件与 [design-principles.md](design-principles.md) 中的「反模式清单」互补：此处强调**路由与产物**类误判；细则与表格仍以 `design-principles.md` 为准。

---

## 技能边界类（优先纠正）

1. **未确认写 TDD 终稿**：跳过会话 spec 或 Qclose-1 即写入 `{DOC_DIR}/requirements/**/TDD-*.md` —— 违反 [gates.md](gates.md)。
2. **无 PRD 硬输入仍定稿 TDD**：未说明例外即宣称完成可评审 TDD —— 须先 **sdx-prd** 或显式风险标注。
3. **用 TDD 替代 DSD/规约**：在 TDD 中扩写 API/DDL 实现契约代替 **sdx-design** —— 测试设计应追溯 **DSD**/`specs`，不吞并详设职责。
4. **产出可执行测试代码或测试报告**：本技能只产出 **TDD** 文档，不写自动化脚本、执行报告。
5. **臆测用例无追溯**：TC 无 US/API/BR/影响面锚点 —— 见 `design-principles` 与 [gotchas.md](../gotchas.md)。

---

## 与上游文档混淆

- 把 **PRD 全文**贴入 TDD 代替 Given-When-Then 与编号引用。
- 把 **docs-*** 蒸馏/归档当作测试设计主路径。

---

## 操作层补充

操作层易错点见 [../gotchas.md](../gotchas.md)。
