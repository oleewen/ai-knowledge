# docs-merge 反模式

原则：[design-principles.md](design-principles.md)。操作陷阱：[../gotchas.md](../gotchas.md)。

| 反模式 | 纠正 |
| --- | --- |
| 参数未收口即改 target | 收口后再写；[gates.md](gates.md) |
| 跳过写前澄清 | 六项 + 写前 C |
| 落位不明仍写 / 冲突打包源胜 / 边决边写 / **跳过变更清单或批量抛项** | [merge-spec.md](merge-spec.md) §3–§7 |
| 自动新建 target / 改源 | 中止新建；源只读 |
| 第三列提炼当 merge | docs-extract |
| dry-run 改文件 / knowledge 链出爬层 | 只出计划；引用边界 |
