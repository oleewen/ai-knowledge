# 知识库治理规则

本文件只定义 **三层知识库职责边界**。组件索引、使用顺序见同目录 [README.md](README.md)。

协作闸门与编码规范见 [CONVENTIONS.md](../rules/CONVENTIONS.md)。路径/overview/流水线见 [knowledge-layout.md](../references/knowledge-layout.md)。

## 使命

决策 **透明、一致、可追溯**，避免架构随口语漂移。

## 三层职责边界

| 层级 | 目录 | 治理职责 | 实体 SSOT |
| --- | --- | --- | --- |
| 公司 | `company/` | 公司级 EA 叙事、跨系统方案与分析、系统槽位 | BD、PL、SYS、CAP、MDG、TPL（公司级目录实体） |
| 系统 | `system/` | 系统级架构聚合、应用镜像槽位、蒸馏归档 | BSD、PM、APP、DS、TSD 等（见各层 DESIGN §2.2.1） |
| 应用 | `application/` | 五视角实体事实源、SDD 阶段交付 | BC、AGG、AB、FT、UC、MS、API、ENT、MW、CMP 等 |

**命名、术语与 OKF 文件分型**：统一以 `agent/knowledge/` 为准（见 [README.md](README.md)）；`system/` / `company/` 维护本层目录语义与映射。

## 设计入口

- [application/DESIGN.md](../../application/DESIGN.md)
- [system/DESIGN.md](../../system/DESIGN.md)
- [company/DESIGN.md](../../company/DESIGN.md)
