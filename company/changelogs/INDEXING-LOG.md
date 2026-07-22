---
type: Indexing Log
title: INDEXING-LOG
---
# INDEXING-LOG

> **docs-indexing** 维护。增量基线 = 主表**第一行** `indexing_finished_ms`（`index` 落盘成功后再写；新行最新在上）。兼容：无表可解析时回退文内最后一次 `<!-- sdx-indexing:indexing_finished_ms=... -->`。

| indexing_finished_ms | indexed_at | mode | depth | since_ms | output_path | file_count | duration_ms | summary |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1782099595327 | 2026-06-22T03:39:55Z | full | 3 | 0 | company/index.md | 72 | 180000 | full d3 company 索引 |
