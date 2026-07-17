---
type: Design Document
title: 公司知识库设计
---
<!-- markdownlint-disable-next-line MD025 -->
# 公司知识库设计

`company/`：公司层知识编排与系统槽位治理。不承载系统实现细节。路径 SSOT 见 [knowledge-layout](../agent/references/knowledge-layout.md)。

## 阅读顺序

1. [README.md](README.md) — 定位  
2. 本文 — 边界、契约、同步  
3. [knowledge/README.md](knowledge/README.md) — 五视角  
4. [../system/DESIGN.md](../system/DESIGN.md) — 系统层对照  

## 1. 定位与边界

| 层 | 职责 |
|----|------|
| `company/` | 聚合视图、导航、公司级实体正文 SSOT |
| `system/` | 系统层治理与架构聚合 |
| `application/` | 实现级实体与字段语义 SSOT |

- **治理**：公司层结构语义、导航、归档入口  
- **内容**：公司级实体与企业架构顶层在 `company/knowledge/`；实现细节在 system/application  
- **流程**：`solutions/` + `analysis/` 跨系统上游；PRD/ASD/DSD/TDD 在各系统 `requirements/`  
- **引用**：路径与槽位映射，不复制下游正文  

## 2. 目录契约

| 层级 | 目录 | 职责 |
| --- | --- | --- |
| 企业架构 | `knowledge/` | 五视角治理叙事；[`overview/`](knowledge/overview/NAME-overview.md) 为 extract/archive/tag 缓冲区（非 docs-distill） |
| 方案 | `solutions/` | 跨系统 SOLUTION → `analysis/` |
| 分析 | `analysis/` | 跨系统 ANALYSIS → 各系统 `requirements/` |
| 槽位 | `system-{name}/` | 系统镜像入口 |
| 清单 | `knowledge-links.yaml` | 建联与同步编排（可空） |
| 运维 | `changelogs/` | CHANGE-LOG / INDEXING-LOG |

入口：[README](README.md) · [INDEX-GUIDE](INDEX-GUIDE.md) · [index.md](index.md) · [docs-meta](docs-meta.md)

### 公司级实体（正文 SSOT ∈ `knowledge/**`）

系统/应用仅引用 ID。overview 非实体 SSOT。完整字段表见 [application/DESIGN.md](../application/DESIGN.md) §2.2.1。

| 视角 | 实体 | 说明 |
| --- | --- | --- |
| 业务 | BD / CAP | 业务域；能力目录 L1–L3 |
| 产品 | PL | 跨系统产品族 |
| 应用 | SYS | 公司内系统边界 |
| 数据 | MDG | 主数据治理目录 |
| 技术 | TPL | 平台能力（云/DevOps/安全/开发环境） |

命名：[naming-conventions](../agent/knowledge/naming-conventions.md)

### 五视角聚焦

| 视角 | 公司层聚焦 |
| --- | --- |
| 业务 | BD、CAP、商业模式、价值链 |
| 产品 | PL、度量、体验 |
| 应用 | SYS、系统目录与治理 |
| 数据 | MDG、治理、湖仓、安全 |
| 技术 | TPL：云、DevOps、安全、开发环境、可观测标准 |

系统层落地见 [system/DESIGN.md](../system/DESIGN.md) §五架构视角。

### 系统镜像槽位

- 下行：`knowledge-links.yaml` → docs-link 建槽 → docs-pull（本地 `path`，不 clone）  
- 上行：公司 overview 用 extract/archive/tag；**docs-distill 仅写** `system/knowledge/overview/`  

### SDD 衔接

| 层级 | 方案 | 分析 | 需求交付 |
| --- | --- | --- | --- |
| 公司 | `company/solutions/` | `company/analysis/` | **无** |
| 系统 | `system/solutions/` | `system/analysis/` | `system/requirements/` |

同 IDEA-ID：`ANALYSIS` 拆归属 → 各系统 `REQUIREMENT-{IDEA-ID}/`。

治理：槽位名 `system-{sys_name}`；不写实现/字段；跨层用链接；改目录语义先改本文。

## 3. 同步与追溯

1. 下游 `system/` 整理可同步内容  
2. docs-pull → `company/system-{sys_name}/`（读目标 `.docsconfig` 的 DOC_ROOT/DOC_DIR）  
3. 校核 `knowledge/` 与 `knowledge-links.yaml`  
4. 追加槽位 `changelogs/CHANGE-LOG.md`（根 CHANGE-LOG 可选汇总）  

冲突以下游事实源为准；company 只修映射与导航。

## 4. 门禁与演进

- 命名统一；禁止实现细节入 company 正文  
- 跨层描述可追溯至 system/application  
- 槽位同步禁止覆盖槽位 `README.md` / `index.md` / `changelogs/`；默认单槽位（`--sys-name`），`--all` 才全量；仅本地 Git `path`  

演进：稳契约 → 完善 links 元数据 → 自动化巡检。

## 参考

[README](README.md) · [knowledge/](knowledge/README.md) · [system-SYSNAME](system-SYSNAME/README.md) · [knowledge-links.yaml](knowledge-links.yaml) · [knowledge-layout](../agent/references/knowledge-layout.md) · [system/DESIGN](../system/DESIGN.md)
