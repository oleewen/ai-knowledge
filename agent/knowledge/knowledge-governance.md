# 知识库治理规则

本文件约束 `application/`、`system/`、`company/` 三层知识库的术语边界、命名 SSOT 与 Agent 协作入口。原 `*/constitution/` 目录内容位于 `agent/knowledge/`。

## 使命

决策 **透明、一致、可追溯**，避免架构随口语漂移。

## 组件索引

| 组件 | 路径 | 说明 |
| --- | --- | --- |
| 命名规范 | [naming-conventions.md](naming-conventions.md) | 实体 ID 前缀、文件命名、IDEA-ID |
| OKF 共享规范 | [okf-spec.md](okf-spec.md) | 文件分类方式、concept schema、三层共享模板 |
| 术语表 | [glossary.md](glossary.md) | 全局术语与跨视角映射字段 |
| 架构原则 | [architecture-principles.md](architecture-principles.md) | 原则条目 |
| ADR 模板 | [adr-template.md](adr-template.md) | 决策记录正文结构 |
| ADR 约定 | [adr-guidelines.md](adr-guidelines.md) | 落盘目录与评审顺序 |
| ADR 正文 | [application/adr/](../../application/adr/README.md) · [system/adr/](../../system/adr/README.md) | 按决策范围分域落盘 |
| 规则总入口 | [CONVENTIONS.md](../rules/CONVENTIONS.md) | Agent 协作、闸门与分类索引 |

## 三层职责边界

| 层级 | 目录 | 治理职责 | 实体 SSOT |
| --- | --- | --- | --- |
| 公司 | `company/` | 公司级 EA 叙事、跨系统方案与分析、系统槽位 | BD、PL、SYS、CAP、MDG、TPL（公司级目录实体） |
| 系统 | `system/` | 系统级架构聚合、应用镜像槽位、蒸馏归档 | BSD、PM、APP、DS、TSD 等（见 DESIGN §2.2.1） |
| 应用 | `application/` | 五视角实体事实源、SDD 阶段交付 | BC、AGG、AB、FT、UC、MS、API、ENT、MW、CMP 等 |

**命名、术语与 OKF 文件分型 SSOT**：统一以 `agent/knowledge/` 为准；`system/` 与 `company/` 维护本层目录语义与映射。

## 使用顺序

1. 新词 / 歧义 → [glossary.md](glossary.md)
2. 新实体 / 文件 → [naming-conventions.md](naming-conventions.md)
3. 判断文件分型与 concept 结构 → [okf-spec.md](okf-spec.md)
4. 跨域或长期后果的决策 → [application/adr/](../../application/adr/README.md) 或 [system/adr/](../../system/adr/README.md)，按 [adr-template.md](adr-template.md)

## 索引指针

- 仓库根：[INDEX-GUIDE.md](../../INDEX-GUIDE.md)、[AGENTS.md](../../AGENTS.md)
- 应用层设计：[application/DESIGN.md](../../application/DESIGN.md)
- 系统层设计：[system/DESIGN.md](../../system/DESIGN.md)
- 公司层设计：[company/DESIGN.md](../../company/DESIGN.md)
