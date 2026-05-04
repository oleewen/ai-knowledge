# docs-pull 常见反模式

与 [design-principles.md](design-principles.md) 互补；**操作层**见 [../gotchas.md](../gotchas.md)。

---

## 反模式与纠正

1. **无 manifest 仍 clone**
   - 纠正：终止，先挂载建联。见 [gates.md](gates.md)。

2. **多应用时静默「全部同步」**
   - 纠正：逐应用确认或取得明确授权。见 [gates.md](gates.md)。

3. **`--force` 无确认**
   - 纠正：一句显式确认后再执行。见 [gates.md](gates.md)。

4. **宣称完成但未追加 pull-log**
   - 纠正：步骤 3 必做。见 [workflow.md](workflow.md)。

5. **把本技能当 docs-distill**
   - 纠正：上行系统 overview 走 distill/extract；本技能只维护 `applications/app-*`。见 [workflow.md](workflow.md)。

6. **覆盖后未校验 manifest**
   - 纠正：步骤 4 检查，必要时 `git checkout` manifest。见 gotchas。

7. **编造未拉到的文件或提交号**
   - 纠正：零幻觉；提交失败写「获取失败」。见 gotchas。
