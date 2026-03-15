# knowledge — 知识库目录

本目录为全局软件系统知识文档库的主体，包含四视角与宪法层。本文档定义知识库的定位、结构及维护规则，供 Agent 在解决方案、需求分析、需求交付与归档阶段读写时遵循。

## 1. 定位与用途

- **knowledge** 是系统当前状态的「单源真相」说明，随需求交付动态更新。
- 知识库包含四视角与宪法层：constitution、business、product、technical、data。
- 需求归档阶段由 Agent 根据变更更新产品、架构、领域、API、依赖、测试等说明文档。
- 解决方案与需求分析阶段以 knowledge 为输入，评估影响面与一致性。

## 2. 结构

| 路径 | 说明 |
|------|------|
| [constitution/](./constitution/) | 宪法与治理层：ADR、架构原则、命名规范、术语表 |
| [business/](./business/) | 业务视角：业务域、子域、限界上下文、聚合 |
| [product/](./product/) | 产品视角：产品线、模块、功能点与用例 |
| [technical/](./technical/) | 技术视角：系统、应用、微服务与接口 |
| [data/](./data/) | 数据视角：数据存储、数据实体与字典 |

**与 knowledge 平级**：仓库根目录下 [solutions/](../solutions/)（解决方案文档）、[analysis/](../analysis/)（需求分析文档）。

## 3. 入口

- 仓库根目录 [INDEX.md](../INDEX.md) — 全局索引与映射速查
- 仓库根目录 [DESIGN.md](../DESIGN.md) — 设计方案与演进路线
- 本目录 [constitution/README.md](./constitution/README.md) 及各视角 README（constitution、business、product、technical、data）— Agent 阅读系统文档时以此为索引。

## 4. 引用与可追溯

- 文档间使用 **相对工程根目录** 的路径引用（如 `knowledge/...`），便于跨文件跳转与工具解析。
- 更新任意知识条目后，需同步更新根目录 [INDEX.md](../INDEX.md)（必要时更新各视角 README）。

## 5. 与其它阶段的关系

| 阶段         | 与 knowledge 的关系 |
|--------------|----------------------|
| 解决方案     | 读取 knowledge 评估现状与影响面 |
| 需求分析     | 读取 knowledge 做深度研究与 MVP 拆分 |
| 需求交付     | PRD/ADD/TDD 可引用 knowledge 中术语与架构 |
| 需求归档     | 根据交付结果自动更新 knowledge 与 changelogs |

## 6. 参考

- 知识库索引与设计：根目录 [README.md](../README.md)、[INDEX.md](../INDEX.md)、[DESIGN.md](../DESIGN.md)
- Agent 指南： [.ai/README.md](../.ai/README.md)
