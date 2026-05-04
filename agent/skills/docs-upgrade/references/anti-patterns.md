# docs-upgrade 常见反模式

与 [design-principles.md](design-principles.md) 互补；**操作层易错点**仍见 [../gotchas.md](../gotchas.md)。

---

## 反模式与纠正动作

1. **未确认即多文件写入**
   - 表现：未收到 `C`/`S` 已批量 `Write`/`StrReplace`。
   - 纠正：[gates.md](gates.md)。

2. **过度统一**
   - 表现：仅用词相似即改不同概念段落。
   - 纠正：[related-doc-discovery.md](related-doc-discovery.md)「同类表述」、gotchas。

3. **短词全库替换**
   - 表现：`rg` 上千命中仍一次替换。
   - 纠正：缩小路径或先确认模式；[semantic-keyword-discovery.md](semantic-keyword-discovery.md)。

4. **把 docs-upgrade 当 docs-archive / docs-change**
   - 表现：用本技能做 overview 行归档或只写 CHANGE-LOG。
   - 纠正：[gates.md](gates.md) 分流。

5. **编造不可核实事实**
   - 表现：无出处补全指标或决策结论。
   - 纠正：[workflow.md](workflow.md) 步骤 5、上级 `SKILL.md` 决策情形。

6. **破坏链接与代码块**
   - 表现：改路径或替换时弄断相对链或 fence。
   - 纠正：[workflow.md](workflow.md) 步骤 4、[quality-checklist.md](quality-checklist.md)。
