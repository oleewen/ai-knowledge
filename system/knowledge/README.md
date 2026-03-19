> **模板示例**：本文件为知识库模板示例，实际项目请按需替换内容与 ID。

# knowledge — 知识库目录

本目录为知识库主体（SSOT）：宪法层 + 业务/产品/技术/数据四视角。

## 结构与入口

| 路径 | 说明 |
|------|------|
| [constitution/](./constitution/) | 宪法与治理层：ADR、架构原则、命名规范、术语表 |
| [business/](./business/) | 业务视角：业务域、子域、限界上下文、聚合 |
| [product/](./product/) | 产品视角：产品线、模块、功能点与用例 |
| [technical/](./technical/) | 技术视角：系统、应用、微服务与接口 |
| [data/](./data/) | 数据视角：数据存储、数据实体与字典 |

推荐入口：

- [INDEX.md](../INDEX.md)（全局索引与映射速查）
- [DESIGN.md](../DESIGN.md)（目录结构与元模型规范）
- `constitution/README.md` 与各视角 README（各自的索引表与字段约定）

## 维护规则（最小集）

- 文档间使用 **相对工程根目录** 的路径引用（如 `knowledge/...`），便于跨文件跳转与工具解析。
- 更新任意知识条目后，需同步更新根目录 [INDEX.md](../INDEX.md)（必要时更新各视角 README）。
