# knowledge — 知识库目录

本目录为 app-APPNAME 的应用级知识库：结构与命名对齐 system，沉淀本应用相关的事实与映射。

## 结构与入口

| 路径 | 说明 |
|------|------|
| [constitution/](./constitution/) | 宪法与治理层：ADR、架构原则、命名规范、术语表 |
| [business/](./business/) | 业务视角：业务域、子域、限界上下文、聚合 |
| [product/](./product/) | 产品视角：产品线、模块、功能点与用例 |
| [technical/](./technical/) | 技术视角：系统、应用、微服务与接口 |
| [data/](./data/) | 数据视角：数据存储、数据实体与字典 |

推荐入口：

- [applications/INDEX.md](../../INDEX.md)
- [system/DESIGN.md](../../../system/DESIGN.md)
- [system/INDEX.md](../../../system/INDEX.md)

## 维护规则（最小集）

- 文档间使用 **相对工程根目录** 的路径引用（如 `knowledge/...`），便于跨文件跳转与工具解析。
- 更新条目后，必要时同步更新 applications 的索引与各视角 README（保持可追溯）。
