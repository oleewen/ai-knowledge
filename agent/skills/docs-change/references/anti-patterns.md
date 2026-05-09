# docs-change 反模式

与 [design-principles.md](design-principles.md) 互补；操作细节见 [../gotchas.md](../gotchas.md)。

| 反模式 | 纠正 |
|--------|------|
| baseline / cutoff 混用 | [core-concepts.md](core-concepts.md)、gotchas |
| 增量未读文末基线 | 步骤 2 先解析 `baseline_time_ms` |
| `{output_dir}` 参与本地扫描 | collection-rules 排除输出目录 |
| Git 失败即退出整 job | 降级，继续 changelog / local |
| 把 docs-change 当 docs-indexing | [gates.md](gates.md) 分流 |
| 增量覆盖历史 | workflow 步骤 4：前插、不删历史 |
| 合并后未倒序 | 写入前统一按时间倒序 |
| 条目无来源标签 | 每条须 `git` / `changelog` / `local` |
