# docs-distill 常见反模式

与 [design-principles.md](design-principles.md) 互补；**操作层易错点**仍见 [../gotchas.md](../gotchas.md)。

---

## 反模式与纠正动作

1. **未 CONFIRMED 即写入 overview 或 DISTILL-LOG**
   - 表现：会话 spec 仍为 `PENDING` 或无同会话明示依据，即执行阶段 4 落盘。
   - 纠正：完成 `dry-run` 与用户总确认，改 `CONFIRMED`；或记录合法例外 / `DOCS_DISTILL_ALLOW_WRITE` 依据。见 [gates.md](gates.md)。

2. **4.3 失败仍写 DISTILL-LOG**
   - 表现：overview 第三列未成功即追加蒸馏记录。
   - 纠正：仅 4.3 成功后执行 4.4。见 [workflow.md](workflow.md)。

3. **把应用 CHANGE-LOG 与 DISTILL-LOG 职责混淆**
   - 表现：在错误文件上推断「上次蒸馏到哪」；或多应用时未按 `app` 过滤取锚点。
   - 纠正：两日志表见 [workflow.md](workflow.md)；细节见 [distill-log-spec.md](distill-log-spec.md)。

4. **`--full` 无预览直接覆盖**
   - 表现：未 `dry-run`、未说明影响面即全量重炼。
   - 纠正：先 `dry-run`，再门禁确认。见 [gates.md](gates.md) 与 gotchas。

5. **第三列整段粘贴应用文档**
   - 表现：第三列成为原文存档，失去系统级摘要语义。
   - 纠正：按 [federation-spec.md](federation-spec.md) 提炼；反查 gotchas「整段复制」。

6. **锚点 id 丢失时静默全量**
   - 表现：`CHANGELOG` 中找不到锚点 id 仍自动 `--full`。
   - 纠正：停机询问用户。见 [gates.md](gates.md)。

7. **五架构视角跳节**
   - 表现：只改有 PR 的视角，其余行不读不写。
   - 纠正：逐节处理；无内容写 `—`。见 gotchas。

8. **首次创建 overview 时只改文件名不改标题**
   - 表现：`NAME` 与 `{APPNAME}` 不一致。
   - 纠正：文件名与文内标题同步替换。见 gotchas。

9. **overview 第三列写来源脚注**
   - 表现：`(来源：…)`、参见链接塞满第三列。
   - 纠正：删除脚注，追溯走日志与 spec。见 [design-principles.md](design-principles.md)。

10. **多应用无 `--app` 通读全库**
    - 表现：对全部应用 deep read 知识库。
    - 纠正：轻量扫描 CHANGE-LOG / 锚点，分批 `--app`。见 [gates.md](gates.md) 与 gotchas。
