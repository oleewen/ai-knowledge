# INDEXING-LOG

> 由 **docs-indexing** 维护。增量基线取自主表**第一行**的 `indexing_finished_ms`（`INDEX_GUIDE` 落盘成功后再写本表；新行**最新在上**）。兼容：若无表可解析，可回退读文内最后一次 `<!-- sdx-indexing:indexing_finished_ms=... -->`。


| indexing_finished_ms | indexed_at | mode | depth | since_ms | output_path | file_count | duration_ms | summary |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1781755355802 | 2026-06-18T04:02:35Z | full | 3 | 0 | INDEX_GUIDE.md | 513 | 120000 | full d3 根索引刷新（quick-start、统计、CHANGE-LOG 联动） |
