# docs-change 设计原则

与 [anti-patterns.md](anti-patterns.md) 互补；易错见 [../gotchas.md](../gotchas.md)。

1. **零幻觉**：只录可核验数据。
2. **时间**：比较用毫秒；展示格式统一。
3. **增量**：新条目前插，历史保留，文末基线更新。
4. **幂等**：同输入同基线下结果一致。
5. **降级**：Git 或部分 CHANGELOG 不可用则跳过该源，流程继续。
6. **下游契约**：每条带来源标签，供 docs-indexing / docs-build 消费。
