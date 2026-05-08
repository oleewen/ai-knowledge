# 反模式（概念层，sdx-design）

本文件与 [design-principles.md](design-principles.md) 中的「反模式清单」互补：此处强调**路由与产物**类误判；细则与表格仍以 `design-principles.md` 为准。

---

## 技能边界类（优先纠正）

1. **未确认写 DSD 终稿**：跳过会话 spec 或 Qclose-1 即写入 `{DOC_DIR}/requirements/**/DSD-*.md` —— 违反 [gates.md](gates.md)。
2. **在详设阶段重写 ASD**：在 DSD 中替代或漂移 **ASD §1–§3** 已收口结论而不标注 DD-n 或回跳 —— 应回 **sdx-architect** 或显式决策记录。
3. **无上游硬输入**：同 IDEA-ID 下既无 **`ASD-*.md`** 又无 **`{DOC_DIR}/specs/spec-{IDEA-ID}-{N}-{service-name}.md`**（需求规约 Markdown，结构见 [spec-template](../assets/spec-template.md) 或上游 [asd-spec-template](../../sdx-architect/assets/asd-spec-template.md)）即大写 API/DDL/实现级契约 —— 须先补齐其一或用户明示例外并留痕。
4. **把架构选型当 Gd 独断**：服务边界级分叉应在 **`/sdx-architect`**（Ga）收口，不在 DSD 内「悄悄改架构」。
5. **规约与 DSD §2/§3 脱钩**：`specs/spec-{IDEA-ID}-{N}-{service-name}.md` 汇总稿或 §3 规约表与 **DSD** 无法互指 —— 终检前须对齐 [quality-checklist.md](quality-checklist.md)。

---

## 与上游文档混淆

- 把 **PRD 叙事**整段贴入 DSD 代替可追溯引用（US-n/FR-n）。
- 把 **测试用例/自动化脚本**写入 DSD 正文代替 **sdx-test** 的 TDD。

---

## 操作层补充

操作层易错点（闸门、spec 路径、Mermaid、元数据等）见 [../gotchas.md](../gotchas.md)。
