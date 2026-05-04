# 设计原则（sdx-solution）

验收勾选项见 [quality-checklist.md](quality-checklist.md)；语言规范见 [audience-and-language.md](audience-and-language.md)；反模式清单见 [anti-patterns.md](anti-patterns.md)。

---

## 原则

| 原则 | 要求 |
|------|------|
| 模板驱动 | 严格遵循 [../assets/solution-template.md](../assets/solution-template.md) 七章结构；无内容章节标「不适用」或「待补充」，禁止整节空白 |
| 业务可读 | 正文（§1–§6 及 §7.1–§7.2）无接口名、表名/字段名、中间件、模块名、协议栈；技术线索仅在 §7.3 并含「待研发确认」 |
| 证据优先 | 影响面、冲突、风险须引用 `knowledge/` 事实或原始需求材料，禁止臆测 |
| 歧义标注 | 歧义、矛盾、信息缺失须标注为 Q-n，逐一向用户提问，禁止自行假设后继续 |
| 按需加载 | 仅在本轮任务需要时打开文件，禁止通读 `knowledge/**` 或全仓源码 |
| 可追溯 | G-n 可指回需求来源；C-n、R-n 可指回业务能力/协作环节；编号连续无断号 |

**证据引用格式**：

| 证据类型 | 格式 | 示例 |
|---------|------|------|
| 业务目标 | `G-{N}` | `G-1 提升申诉处理效率` |
| 知识库实体 | `{视角}-{ID}` | `BC-001 FeeAppealContext` |
| 文档章节 | `{文件} §{章节}` | `INDEX_GUIDE.md §3.2` |

---

## 错误处理

| 错误场景 | 处理方式 |
|---------|---------|
| 业务描述过于简短 | 暂停，请求用户补充背景与期望价值，不凭印象推测 |
| knowledge 目录缺失 | 发出警告，仅基于原始需求描述完成分析，在 §7.2 标注「缺少知识库基线」 |
| 模板文件不存在 | 终止，提示创建 `agent/skills/sdx-solution/assets/solution-template.md` |
| MVP 拆分出现循环依赖 | 终止拆分，输出依赖图，请求用户确认调整方案 |
| 输出目录不存在 | 自动创建 `{DOC_DIR}/solutions/` 目录 |
