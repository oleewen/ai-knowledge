# docs-build 排错

| 症状 | 处理 |
| --- | --- |
| 在消费仓运行却写到技能安装仓 | 从目标仓运行，或传 `--repo`；目录与层分别用 `--bundle`、`--layer-scope` |
| DOC_DIR=docs 被当作 application | `docs` 不表达知识层；显式传 `.docsconfig` 已核实的层值 |
| 导航更新覆盖 4.6 或后续章节 | 只更完整标记块或 4.5 正文；残缺/重复标记先修复 |
| 旧 knowledge 索引仍存在 | 单独确认迁移；生成器不负责删除 |
| 正文出现 `id:` 却不算实体 | id 必须位于可解析 frontmatter；文件名与 ID 一致 |
| 要求每个视角都有实体 | 按层职责判断；应用业务/产品等空视角合法 |
| Dubbo Consumer 与 MQ Consumer 混淆 | Dubbo 只提 Provider；MQ 提 Consumer，不提 Producer |
| 把 Maven 模块直接当 MS | 按宿主类聚类；同模块允许多个不同宿主 MS |
| 同名表被误合并 | 先核实数据源与物理表身份，再做 ENT 去重 |
| README 指向 `../INDEX-GUIDE.md` | 该旧路径指向 knowledge 内旧索引；按治理移除违规导航，不改链到 knowledge 外 |
| 仍要求 JSON entities/metadata | 正式产物是实体 Markdown；JSON 仅兼容字段样例，见 [extraction-rules.md](references/extraction-rules.md) |
| 预检要求导航块已存在 | 归并前用 `--entities-only`，归并后用完整模式 |
| 结构校验通过但关系不对 | 按 [quality-checklist.md](references/quality-checklist.md) 核对关系、证据与引用边界 |
| 报告未开启却被要求写共享 meta | 会话交付增量即可；不把业务事实写入共享 Agent meta |
