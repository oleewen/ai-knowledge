# 软件系统知识文档库 (Knowledge Repository)

本仓库是企业级软件系统的**全局知识底座**。我们采用「单一事实源」和「联邦治理」的理念，将系统架构和知识体系划分为四大核心视角。

## 快速导航


| 文档                                   | 说明                                          |
| ------------------------------------ | ------------------------------------------- |
| **[知识库全局索引](./INDEX.md)**            | 各类文档入口、示例与映射速查                              |
| **[设计方案摘录](./DESIGN.md)**            | 设计哲学、目录约定、映射机制与演进路线                         |
| **[业务知识](./knowledge/README.md)**    | 宪法层、业务/产品/技术/数据四视角                          |
| **[解决方案](./solutions/README.md)**    | 业务诉求的解决方案文档（SOLUTION-{ID}.md）               |
| **[需求分析](./analysis/README.md)**     | 需求分析文档与 MVP 拆分（REQUIREMENT-{ID}.md）         |
| **[需求交付](./requirements/README.md)** | 按 MVP 阶段的 PRD/ADD/TDD 交付（REQUIREMENT-{ID}/） |
| **[需求规约](./specs/)**                 | 服务/接口等规格（供 solutions、analysis 引用）           |
| **[贡献指南](./CONTRIBUTING.md)**        | 如何新增/修改条目与ADR                               |


## 目录结构

```text
system/
├── knowledge/         # 知识库（四视角 + 宪法层）
│   ├── constitution/      # 宪法层：ADR、架构原则、命名规范与术语表
│   ├── business/          # 业务视角：业务域、子域、限界上下文、聚合
│   ├── product/           # 产品视角：产品线、模块、功能点与用例
│   ├── technical/         # 技术视角：系统、应用、微服务与接口
│   └── data/              # 数据视角：数据存储、数据实体与字典
├── solutions/         # 解决方案文档（SOLUTION-{ID}.md，含 archive/）
├── analysis/          # 需求分析文档（REQUIREMENT-{ID}.md）
├── requirements/      # 需求交付文档（REQUIREMENT-{ID}/ 按 MVP 阶段，PRD/ADD/TDD）
├── specs/             # 需求规约文档（服务/接口等规格，供 solutions、analysis 引用）
├── changelogs/        # 变更日志（CHANGELOG.md）
├── INDEX.md / DESIGN.md / CONTRIBUTING.md 等
```

## 设计原则

- **单一事实源 (SSOT)**：每个知识点只在一处定义，其他地方通过 ID 引用。
- **联邦治理**：本仓库（系统级）管理宏观架构与跨域引用；各应用代码库（应用级）管理 API/Schema，并通过 CI/CD 上报 `manifest.yaml` 更新索引。
- **去中心化映射**：在 `_meta.yaml` 或实体 YAML 中通过 ID 字段（如 `implemented_by_app_id`、`persisted_as_entity_ids`）建立视角间关联。

## 命名规范

所有实体使用全局唯一 ID，格式 `{TYPE}-{NAME}`。常用前缀：


| 前缀                      | 含义               |
| ----------------------- | ---------------- |
| BD- / BSD- / BC- / AGG- | 业务域、子域、限界上下文、聚合根 |
| PL- / PM- / FT- / UC-   | 产品线、产品模块、功能点、用例  |
| SYS- / APP- / MS-       | 系统、应用、微服务        |
| DS- / ENT-              | 数据存储、数据实体        |


完整规范见 [knowledge/constitution/standards/naming-conventions.md](./knowledge/constitution/standards/naming-conventions.md)。设计方案与演进路线见 [DESIGN.md](./DESIGN.md)。