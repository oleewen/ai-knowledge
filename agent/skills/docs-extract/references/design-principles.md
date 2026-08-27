# docs-extract 设计原则

与 [anti-patterns.md](anti-patterns.md) 互补；易错见 [../gotchas.md](../gotchas.md)。

1. **附录为真源**：无附录或无效须停机补齐，勿用章节标题猜关键词。
2. **强相关才写**：弱相关、代码噪声、标题单行按 extract-spec / gotchas 过滤。
3. **先读后写**：federation-spec 去重后仅写 delta / A/U/D。
4. **无命中不改**：无命中小节保持原样，勿用 `—` 盖掉已有内容。
5. **第三列无脚注**：追溯放命中摘要或引用依据。
6. **原子落盘**：4.3 失败整篇回滚。
7. **风险先预览**：高风险场景优先 `--dry-run`。
