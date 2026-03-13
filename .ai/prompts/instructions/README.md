# 系统说明文档规范

本文档定义 AI SDD 项目中 **系统说明文档（instructions）** 的定位、结构及维护规则，供 Agent 在解决方案、需求分析、需求交付与归档阶段读写时遵循。

## 1. 定位与用途

- **instructions** 位于 `docs/instructions/`，是系统当前状态的「单源真相」说明，随需求交付动态更新。
- 需求归档阶段由 Agent 自动根据变更更新产品、架构、领域、API、依赖、测试等说明文档。
- 解决方案与需求分析阶段以 instructions 为输入，评估影响面与一致性。

## 2. 入口与结构

- **入口**：`docs/instructions/INDEX.md`，Agent 阅读系统文档时以此为索引。
- **结构**：与 `docs/README.md` 第 2.1 节「文档总体结构」中 `instructions/` 子树一致，包括：
  - `INDEX.md`、`GLOSSARY.md`、`CHANGELOG.md`
  - `product/`、`architecture/`、`domain/`、`api/`、`dependency/`、`test/` 各子目录及规定文件

## 3. 引用与可追溯

- 文档间使用 **相对工程根目录** 的路径引用（如 `docs/instructions/...`），便于跨文件跳转与工具解析。
- 更新任意说明文档后，需同步更新 `INDEX.md`（必要时更新 `CHANGELOG.md`）。

## 4. 与其它阶段的关系

| 阶段         | 与 instructions 的关系 |
|--------------|-------------------------|
| 解决方案     | 读取 instructions 评估现状与影响面 |
| 需求分析     | 读取 instructions 做深度研究与 MVP 拆分 |
| 需求交付     | PRD/ADD/TDD 可引用 instructions 中术语与架构 |
| 需求归档     | 根据交付结果自动更新 instructions 与 changelogs |

## 5. 参考

- 文档总体结构：`docs/README.md`
- Agent 指南：`AGENTS.md`
