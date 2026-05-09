# docs-change 常见陷阱

## 时间

- **baseline ≠ cutoff**：Git 用 `baseline_time`；CHANGELOG / local 用 `cutoff_time`（`max(baseline, latest_git_commit)`）。混用会漏收或重复。
- **增量须读文末基线**：否则默认 `2020-01-01` 会全量重扫。
- **比较用毫秒戳**：勿用字符串比时间。

## 采集

- **排除 `{output_dir}`**：否则 `CHANGE-LOG` 等每次被当成变更，基线不稳定。
- **Git 不可用**：`[WARN]` 跳过 git，不终止；继续 changelog / local。
- **CHANGELOG 单条坏格式**：跳过该条并 `[WARN]`，勿丢整文件。

## 输出

- **增量**：新条目前插，历史不删；更新文末 `baseline_time_ms`。
- **写入前**：三源合并后须按时间倒序。
- **每条带来源**：供下游分流。
- **路径约定**：默认 `./changelogs/`；自定义 `--output` 时与 docs-indexing 读取路径对齐。

## 快速自查

- [ ] `--since` > 文末基线 > 默认，优先级正确
- [ ] `cutoff_time = max(baseline_time, latest_git_commit_time)`
- [ ] 时间比较用毫秒戳；输出目录已排除；Git/CHANGELOG 失败已降级
- [ ] 未清空历史；条目倒序；有来源标注；文末基线已更新
