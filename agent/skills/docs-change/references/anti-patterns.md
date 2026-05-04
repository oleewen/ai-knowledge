# docs-change 常见反模式

与 [design-principles.md](design-principles.md) 互补；**操作层易错点**仍见 [../gotchas.md](../gotchas.md)。

---

## 反模式与纠正动作

1. **baseline / cutoff 混用**
   - 表现：对 Git 用 `cutoff` 或对本地用 `baseline`。
   - 纠正：[core-concepts.md](core-concepts.md)、gotchas。

2. **未读文末基线即增量**
   - 表现：重复全量历史或时间窗错误。
   - 纠正：步骤 2 必须先解析 `CHANGE-LOG.md` 文末注释。

3. **输出目录参与本地扫描**
   - 表现：`CHANGE-LOG.md` 每次被当成「变更」再次收录。
   - 纠正：[collection-rules.md](collection-rules.md) 排除 `{output_dir}`。

4. **Git 失败即终止整 job**
   - 表现：无 Git 时直接退出。
   - 纠正：优雅降级，继续 CHANGELOG / local。

5. **把 docs-change 当 docs-indexing**
   - 表现：在本技能内生成 `INDEX_GUIDE.md`。
   - 纠正：[gates.md](gates.md) 分流。

6. **增量覆盖历史**
   - 表现：清空旧条目重写。
   - 纠正：[workflow.md](workflow.md) 步骤 4。

7. **合并后未按时间倒序**
   - 表现：三源乱序写入。
   - 纠正：写入前统一排序。

8. **条目缺少来源标签**
   - 表现：下游无法区分 git 与 local。
   - 纠正：每条必须带 `git` / `changelog` / `local`。
