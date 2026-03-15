# 软件系统知识文档库 (Knowledge Repository)

本仓库是企业级软件系统的**全局知识底座**。我们采用「单一事实源」和「联邦治理」的理念，将系统架构和知识体系划分为四大核心视角。

## 快速导航

| 文档 | 说明 |
|------|------|
| [INDEX.md](./INDEX.md) | **知识库全局索引** — 各视角入口、示例与映射速查 |
| [DESIGN.md](./DESIGN.md) | 设计方案摘录 — 设计哲学、目录约定、映射机制与演进路线 |
| [CONTRIBUTING.md](./CONTRIBUTING.md) | 贡献指南 — 如何新增/修改条目与 ADR |

## 目录结构说明

```text
/
├── knowledge/         # 知识库（四视角 + 宪法层）
│   ├── constitution/      # 宪法层：ADR、架构原则、命名规范与术语表
│   ├── business/          # 业务视角：业务域、子域、限界上下文、聚合
│   ├── product/           # 产品视角：产品线、模块、功能点与用例
│   ├── technical/         # 技术视角：系统、应用、微服务与接口
│   └── data/              # 数据视角：数据存储、数据实体与字典
├── solutions/         # 解决方案文档（业务诉求的解决方案，SOLUTION-{ID}.md）
├── analysis/          # 需求分析文档（REQUIREMENT-{ID}.md）
└── .ai/               # AI 助手配置与提示词约定
```

## 各视角直达

| 视角 | 说明 | README 链接 |
|------|------|-------------|
| 宪法与治理层 | 治理层使命、ADR、命名规范、架构原则 | [knowledge/constitution/README.md](./knowledge/constitution/README.md) |
| 业务视角 | 业务域、子域、限界上下文与聚合 | [knowledge/business/README.md](./knowledge/business/README.md) |
| 产品视角 | 产品线、模块、功能点与用例 | [knowledge/product/README.md](./knowledge/product/README.md) |
| 技术视角 | 系统、应用、微服务与服务接口 | [knowledge/technical/README.md](./knowledge/technical/README.md) |
| 数据视角 | 数据存储、数据实体与字典 | [knowledge/data/README.md](./knowledge/data/README.md) |
| 解决方案 | 业务诉求的解决方案文档 | [solutions/README.md](./solutions/README.md) |
| 需求分析 | 需求分析文档与 MVP 拆分 | [analysis/README.md](./analysis/README.md) |

## 核心设计原则

- **单一事实源 (SSOT)**：每个知识点只在一处定义，其他地方通过 ID 引用。
- **联邦治理**：本仓库（系统级）管理宏观架构与跨域引用；各应用代码库（应用级）管理 API/Schema，并通过 CI/CD 上报 `manifest.yaml` 更新索引。
- **去中心化映射**：在 `_meta.yaml` 或实体 YAML 中通过 ID 字段（如 `implemented_by_app_id`、`persisted_as_entity_ids`）建立视角间关联。

## 命名与 ID 规范

所有实体使用全局唯一 ID，格式 `{TYPE}-{NAME}`。常用前缀：

| 前缀 | 含义 |
|------|------|
| BD- / BSD- / BC- / AGG- | 业务域、子域、限界上下文、聚合根 |
| PL- / PM- / FT- / UC- | 产品线、产品模块、功能点、用例 |
| SYS- / APP- / MS- | 系统、应用、微服务 |
| DS- / ENT- | 数据存储、数据实体 |

完整规范见 [knowledge/constitution/standards/naming-conventions.md](./knowledge/constitution/standards/naming-conventions.md)。设计方案与演进路线见 [DESIGN.md](./DESIGN.md)。
