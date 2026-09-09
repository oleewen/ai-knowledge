---
type: Perspective Meta
title: 产品视角元数据（application/knowledge/product）
---

应用侧产品版图（PL→PD→PM→FT→FR→UC/BR）实体登记与交互映射元数据。实例索引 [index.md](../index.md)（§2，扫描生成；实体 `{ID}.md` = SSOT）。

## 1. 概览

| 字段 | 值 |
| --- | --- |
| meta_id | `DIR-KNOWLEDGE-PRODUCT` |
| 视角 | product |
| 层级范围 | application |
| 说明 | 产品版图；公司 PL/PD 首次定义（本层不落 PL/PD 文件）；系统自 PM 起首次定义；本层承接 API / 验收映射与实例登记。`PM.parent_id` → 公司 `PD-*`（有 parent 则 HTTP，否则纯 ID）。 |
| entities_shape | 实体 `{ID}.md`（OKF）；索引见 KNOWLEDGE_INDEX §2 |

## 2. 层级链

| 链序 | 层级代码 | 说明 |
| --- | --- | --- |
| 1 | PL | 产品线（公司层首次定义；本层不落盘） |
| 2 | PD | 产品（公司层首次定义；本层不落盘） |
| 3 | PM | 产品模块（系统层首次定义） |
| 4 | FT | 功能点（系统层首次定义，应用层承接 API / 验收映射） |
| 5 | FR | 功能需求（系统层首次定义，应用层承接验收与接口映射） |
| 6 | UC | 用户用例（系统层首次定义，应用层承接 API 映射） |
| 7 | BR | 业务规则（系统层首次定义，应用层承接实现映射） |

## 3. 层定义

| order | key | code | id_pattern | parent |
| --- | --- | --- | --- | --- |
| 1 | pl | PL | `PL-{NAME}` | —（公司） |
| 2 | pd | PD | `PD-{NAME}` | PL（公司） |
| 3 | pm | PM | `PM-{NAME}` | PD（只许 PD） |
| 4 | ft | FT | `FT-{NAME}` | PM |
| 5 | fr | FR | `FR-{NAME}` | FT |
| 6 | uc | UC | `UC-{NAME}` | FR |
| 7 | br | BR | `BR-{NAME}` | FR |

## 4. 字段（OKF）

**Frontmatter（10 必填）**：`type` · `title` · `description` · `tags` · `timestamp` · `full_id` · `perspective` · `hierarchy` · `parent_id` · `layer_scope`（本层固定 `application`）。详见 okf-spec §2。

**正文四段**：`## 关系` · `## 跨视角` · `## 详细说明` · `## 依据与证据`。

### 各层专属（正文）

| 层级 | 字段 | 建议段落 |
| --- | --- | --- |
| PM | `relies_on_context_ids`、`depends_pm_ids` | 跨视角 / 关系 |
| FT | `invokes_api_ids`、`acceptance_criteria`（推荐） | 跨视角 / 详细说明 |
| FR | `children`（UC/BR） | 关系 |
| UC | `map_to_api_id`（推荐） | 跨视角 |
| BR | （实现映射按需） | 跨视角 / 详细说明 |

## 5. 跨视角引用

| 源字段 | 目标 | 说明 |
| --- | --- | --- |
| PM.parent_id | 公司 PD.full_id | 模块归属产品 |
| PM.depends_pm_ids | PM.full_id | 模块依赖其它模块 |
| PM.relies_on_context_ids | BC.full_id | 模块依赖限界上下文 |
| FT.invokes_api_ids | API.full_id | 功能调用 API |
| UC.map_to_api_id | API.full_id | 用例映射 API |

## 6. BP 流程叙事（旁路实体）

可选 `BP-{NAME}.md`（OKF：`hierarchy: BP`）：

- 与本视角实体同目录级；`parent_id` 可为 `PD-*` / `PM-*` / `null`
- 正文可分 M/S/B 节，引用 `PD/PM/FT`
- **不**挂入 `PL → PD → PM → FT → FR → UC/BR` 父子链

## 7. 关联文档

| 路径 | 说明 |
| --- | --- |
| [README.md](README.md) | 人类可读说明 |
| [index.md](../index.md) | §2 产品视角 + 五视角实例索引（扫描生成） |
| 公司 PD-* | 产品 SSOT（本层不落盘） |
| PM-*, FT-*, FR-*, UC-*, BR-* | 系统层 SSOT（reference / 本层映射） |

**索引**：`readme_index_table: true`；变更 ID 时同步 README、index.md（按需）。
