# 公司知识库（顶层 `company/`）

本目录为 **公司知识库根** 语义：公司级企业架构（`ea/`）与各 **`system-{name}/`** 系统镜像槽位。

> **路径 SSOT**：公司侧五视角企业架构目录为 **`ea/`**（非 `architecture/`）。详见 [DESIGN.md](DESIGN.md) 与 [agent/references/knowledge-layout.md](../agent/references/knowledge-layout.md)。

## 子目录

| 路径 | 说明 |
|------|------|
| [`DESIGN.md`](DESIGN.md) | 设计边界、目录契约、SDD 跨层衔接与同步闭环 |
| [`ea/`](ea/README.md) | 公司级企业架构（业务/产品/应用/数据/技术五视角，聚焦治理叙事） |
| [`solutions/`](solutions/README.md) | 公司级跨系统解决方案（明确哪个系统负责什么功能，作为 analysis 上游） |
| [`analysis/`](analysis/README.md) | 公司级跨系统需求分析（衔接 solutions，下游由各 `system/requirements/` 承接） |
| [`system-SYSNAME/`](system-SYSNAME/README.md) | 占位槽位；真实系统名替换 `SYSNAME`，内容经建联同步填入 |
| [`changelogs/`](changelogs/README.md) | 变更留痕与索引运维（CHANGE-LOG、INDEXING-LOG） |
| [`knowledge-links.yaml`](knowledge-links.yaml) | 系统建联清单，记录挂载关系与同步编排信息 |

## 阅读顺序

1. [ea/README.md](ea/README.md) — 五视角企业架构入口  
2. [solutions/README.md](solutions/README.md) / [analysis/README.md](analysis/README.md) — 跨系统 SDD 上游  
3. [system-SYSNAME/README.md](system-SYSNAME/README.md) — 系统镜像槽位（按需替换 `SYSNAME`）  

与系统知识库侧 [`../system/knowledge/`](../system/knowledge/README.md) 对照阅读；设计契约见 [DESIGN.md](DESIGN.md)。
