# docs-archive 常见反模式

与 [design-principles.md](design-principles.md) 互补；**操作层易错点**仍见 [../gotchas.md](../gotchas.md)。

---

## 反模式与纠正动作

1. **未确认方案确认书就写入目标**
   - 表现：仍为 `PENDING` 或口头同意即 `Write`/`StrReplace` 目标文件。
   - 纠正：见 [gates.md](gates.md)；用户说「直接改」仍须概括风险并取得明确同意。

2. **静默合并冲突**
   - 表现：来源与目标矛盾时自行选边写入。
   - 纠正：列冲突点清单，单次一问裁决。见 [workflow.md](workflow.md)、[quality-checklist.md](quality-checklist.md)。

3. **把来源写进正文**
   - 表现：目标段落带 `(来源：…)`、参见链接堆叠。
   - 纠正：见 [design-principles.md](design-principles.md)。

4. **结构照搬来源**
   - 表现：忽略目标模板固定层级。
   - 纠正：服从目标体例。见 [workflow.md](workflow.md) 步骤 4。

5. **未解析副标题链接就落盘**
   - 表现：缺链、断链仍写入。
   - 纠正：先写入冲突清单并请用户决策。见 [core-concepts.md](core-concepts.md)。

6. **与 docs-build / docs-upgrade 抢职责**
   - 表现：在本技能中造实体 ID，或做全库术语链式替换当「归档」。
   - 纠正：分流到 `docs-build`、`docs-upgrade`。见上级 `SKILL.md` 适用边界。

7. **擅自扩大映射表**
   - 表现：方案确认书未列主题仍写入目标。
   - 纠正：先更新确认书再获确认。见 [gates.md](gates.md)。

8. **未完成步骤 5 就硬删 overview**
   - 表现：易断链或半句残留。
   - 纠正：按行落盘与自检后再回写清理；默认优先「仅保留索引壳」。见 [gotchas.md](../gotchas.md)。
