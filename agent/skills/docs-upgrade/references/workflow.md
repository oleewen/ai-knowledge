# docs-upgrade 主流程（顺序执行）

须与 [gates.md](gates.md) 的范围确认书一致后再写盘。预检与同步前闸门见 [brainstorming-integration.md](brainstorming-integration.md)。

---

## 步骤 1：锁定目标

解析用户给出的路径；无路径时用搜索定位候选，多候选则列出选项后再编辑。预检指引见 [brainstorming-integration.md](brainstorming-integration.md)。

---

## 步骤 2：主修改

按用户意图完成增写、改写或替换（含注释与字符串中的文档性表述）。替换简写见 [core-concepts.md](core-concepts.md)。

---

## 步骤 3：关联与语义同步

大范围同步或命中数/概念边界存疑时，先完成 [brainstorming-integration.md](brainstorming-integration.md) 中的**同步前闸门**再扩展。

**默认**（用户未声明「只改本文件」时）对本轮已修改的每个文件同时做：

- **引用链检索**：[related-doc-discovery.md](related-doc-discovery.md)
- **关键词/语义检索**：[semantic-keyword-discovery.md](semantic-keyword-discovery.md)

**例外**：用户明确「只改本文件」「不要同步关联文档」「不要全库搜」时，跳过扩展检索。

---

## 步骤 4：回链校验

若存在互链，确认相对路径、锚点与反引号路径仍有效。

---

## 步骤 5：不确定项门禁

无法在仓库内核实的内容 → **停止并输出编号选项**，待用户选择后再改。复杂项可拆成多轮单问，见 [brainstorming-integration.md](brainstorming-integration.md)。

须由用户决策的情形列表见上级 [SKILL.md](../SKILL.md)「须由用户决策的情形」。
