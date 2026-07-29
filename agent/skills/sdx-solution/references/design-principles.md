# sdx-solution 设计原则

终检勾选：[quality-checklist.md](quality-checklist.md)。语言：[audience-and-language.md](audience-and-language.md)。

## 原则

| 原则 | 要求 |
|------|------|
| 模板驱动 | 七章结构与 [solution-template.md](../assets/solution-template.md) 一致；无内容标「不适用/待补充」，禁整节空白 |
| 业务可读 | §1–§6、§7.1–§7.2 无工程标识；§7.3 可收技术线索并标「待研发确认」 |
| 证据优先 | 影响面/冲突/风险须有可指材料；禁臆测 |
| 歧义标注 | Q-n 单题澄清，禁自担假设推进 |
| 按需加载 | 仅打开本轮必需文件；禁通扫 `knowledge/**` |
| 可追溯 | G-n、C-n、R-n 可指回来源；编号连贯 |

### 证据引用格式

| 类型 | 格式 | 例 |
|------|------|-----|
| 业务目标 | `G-{N}` | `G-1 …` |
| 知识实体 | `{视角}-{ID}` | `BC-001 FeeAppealContext` |
| 文档 | `{文件} §{节}` | `index.md §3.2` |

## 异常处理

| 场景 | 处理 |
|------|------|
| 业务描述过短 | 停，请用户补背景与价值 |
| 无 `knowledge/` | 警告；基于原始需求写，§7.2 标「缺少知识库基线」 |
| 模板缺失 | 终止：需 `assets/solution-template.md` |
| 里程碑前置成环 | 终止：输出依赖图请用户决断 |
| 无 `solutions/` | 可建 `{DOC_DIR}/solutions/` |
