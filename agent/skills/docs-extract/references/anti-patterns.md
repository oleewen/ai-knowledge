# docs-extract 常见反模式

与 [design-principles.md](design-principles.md) 互补；**操作层易错点**仍见 [../gotchas.md](../gotchas.md)。

---

## 反模式与纠正动作

1. **未 CONFIRMED 即写 overview 第三列**
   - 表现：`PENDING` 或无同会话明示依据即执行阶段 4。
   - 纠正：完成 `dry-run` 与用户总确认。见 [gates.md](gates.md)。

2. **4.1 无命中仍写 4.3**
   - 表现：无段落过阈仍改第三列。
   - 纠正：无命中则结束于阶段 3 或 CLOSE，不落盘。见 [workflow.md](workflow.md)。

3. **把 overview 当 `--sources` 扫描**
   - 表现：循环读取 overview 自身段落参与命中。
   - 纠正：只扫描 `--sources`。见 gotchas。

4. **关键词过宽导致「全表重写」**
   - 表现：命中 > 50 等仍一次写入大量 `[U]`。
   - 纠正：收窄关键词或分批 sources；先 `dry-run`。见 [gates.md](gates.md)。

5. **整段粘贴源文件**
   - 表现：第三列成为原文存档。
   - 纠正：按 [extract-spec.md](extract-spec.md) 提炼改写。

6. **4.3 失败留部分写入**
   - 表现：部分章节已改、部分失败。
   - 纠正：整体回滚后重试。见 [workflow.md](workflow.md)。

7. **无命中章节被清空**
   - 表现：无命中却写 `—` 覆盖原内容。
   - 纠正：保持原样。见 gotchas。

8. **第三列写 `(来源：…)`**
   - 表现：脚注占满第三列。
   - 纠正：删除脚注，追溯走 spec。见 [design-principles.md](design-principles.md)。

9. **用户说「直接写」即跳过 HARD-GATE**
   - 表现：未 `dry-run`、未确认即落盘。
   - 纠正：仍须门禁与证据链，除非同会话**明示**合法例外。见 [gates.md](gates.md)。
