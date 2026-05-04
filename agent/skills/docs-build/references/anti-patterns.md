# docs-build 常见反模式

与 [design-principles.md](design-principles.md) 互补；操作层见 [../gotchas.md](../gotchas.md)。

---

## 反模式与纠正

1. **未 CONFIRMED 即写 knowledge JSON**
   - 纠正：完成 Qclose-1 与 `docs-build-gate`。见 [gates.md](gates.md)。

2. **打乱四视角顺序或回写前序 JSON**
   - 纠正：见 [workflow.md](workflow.md)。

3. **无证据编造 ID**
   - 纠正：零幻觉；见 [extraction-rules.md](extraction-rules.md) 与 gotchas。

4. **用 docs-build 更新根目录 INDEX_GUIDE**
   - 纠正：用 `docs-indexing`。见 [SKILL.md](../SKILL.md) 分工表。

5. **占位示例行冒充真实索引**
   - 纠正：见 [readme-fill-spec.md](readme-fill-spec.md) 与 [quality-checklist.md](quality-checklist.md)。

6. **跳过 validate-extraction 即宣称完成**
   - 纠正：阶段 4 命令见 [workflow.md](workflow.md)。

7. **虚构 `docs-build-gate` 绕过钩子**
   - 纠正：须真实会话 spec 与文件名引用；见 [gates.md](gates.md)。
