# docs-change 闸门与边界

与 [collection-rules.md](collection-rules.md) 互补；操作易错见 [gotchas.md](../gotchas.md)。

## 边界

- **负责**：Git、`CHANGELOG*` / `CHANGE-LOG`、本地 mtime 采集，聚合 `{output_dir}/CHANGE-LOG.md`，文末 `<!-- docs-change:baseline_time_ms=... -->`。
- **不负责**：`INDEX_GUIDE`、知识实体、批量改 `README`/`AGENTS`（→ docs-indexing、docs-build 等）。
- **分流**：只要全量/增量文档地图、`INDEX_GUIDE` 时，主路径为 **docs-indexing**，不以仅跑 docs-change 替代。

## 前置确认

**默认**：无歧义则直接执行 [workflow.md](workflow.md)、[collection-rules.md](collection-rules.md)。

下列情况须先与用户确认：

- 时间基准不清（无 `--since`、无有效文末基线、用户未说明范围）
- `--output` 多候选且优先级与用户意图可能不符
- 用户要求**仅采单一来源**

**约定**

- **仅 Git**：`git log` 仍用 `baseline_time`；不写 changelog/local 条目；文末基线照常更新。
- **多输出目录**：以用户选择为准；未表态则按 collection-rules「输出目录定位」。

上级 [SKILL.md](../SKILL.md)「前置确认」锚点指向本节细则。
