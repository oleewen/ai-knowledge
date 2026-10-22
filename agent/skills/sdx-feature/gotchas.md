# sdx-feature 排障

流程错误见 [反模式](references/anti-patterns.md)；本表处理输入与校验问题。

| 症状 | 检查与处置 |
| --- | --- |
| 扫描未找到 FEATURE | 核对 `.docsconfig` 的文档根和 `features/`；可用 `--file` 指定文件，空扫描不代表通过验收 |
| 草稿出现大量 warning | 对照当前已写范围判断；整篇终检才用 `--strict`，不要为了消警告编造缺失章节 |
| 概览看似合规但 FR 校验失败 | 核对真实 §2 表头、编号集合、标题同名及 Unicode 长度；附录、注释和围栏示例不算正文 |
| MVP 装载重复 | 以 §4.1 清单计归属；§4.2 只展开同一归属，语义一致性仍须评审 |
| ADR 引用未通过 | 检查 §6.2 链接、本层文件及 CONTEXT 登记；完整要求见 [ADR 门禁](references/gates.md#技术决策推进门禁) |
| 想按样例直接交稿 | [mini-feature-example.md](assets/samples/mini-feature-example.md) 仅为节选；终稿使用完整模板 |
