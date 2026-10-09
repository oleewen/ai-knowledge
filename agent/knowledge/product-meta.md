---
type: Perspective Meta
title: 产品视角元数据
---
# 产品视角元数据

> 本视角四层实体字段 SSOT。边动词语义见 [glossary.md](glossary.md)；层职责见 [knowledge-governance.md](knowledge-governance.md)。两处全文不抄。公共 frontmatter 与正文四段见 [okf-spec.md](okf-spec.md) §2；`layer_scope` 等于该实体首次定义层。ID 语法见 [naming-conventions.md](naming-conventions.md)。

## 1. 实体总表

| 实体 | 首次定义层 | 链 | id_pattern | 说明 |
| --- | --- | --- | --- | --- |
| — | 公司 | — | — | 企业产品标准（概述、度量、体验）。本层无首次定义。下层实体不涉及 |
| PL | 解决方案 | 产品链 L1 | `PL-{NAME}` | 无 parent |
| PD | 解决方案 | 产品链 L2 | `PD-{NAME}` | `implements_to` PL，非 parent |
| BP | 解决方案 | 流程链 L1 | `BP-{NAME}` | `implements_to` SLN，非 parent。不挂入 `PL → PD → PM → FT → FR → UC/BR` 组成链 |
| BSP | 解决方案 | 流程链 L2 | `BSP-{NAME}` | parent BP |
| PM | 系统 | 产品链 L3 | `PM-{NAME}` | parent 为 PD（纯 ID；无 parent 时不写跨层路径或 HTTP）。PL、PD、BP、BSP 不建本层文件，只写纯 ID |
| FT | 系统 | 产品链 L4 | `FT-{NAME}` | parent PM |
| FR | 系统 | 产品链 L5 | `FR-{NAME}` | parent FT |
| UC | 系统 | 产品链 L6 | `UC-{NAME}` | parent FR |
| BR | 系统 | 产品链 L7 | `BR-{NAME}` | parent FR |
| — | 应用 | — | — | 本层无首次定义。PL、PD、PM、FT、FR、UC、BR、BP、BSP 不建本层文件，只写纯 ID。本层不落 BP |

## 2. 实体细则

无首次定义的层不设节。

### PL

| 项 | 值 |
| --- | --- |
| 层 | 解决方案 |
| id_pattern | `PL-{NAME}` |
| 落盘 | 标准 `{ID}.md` |
| 字段 | `maps_to` → 公司 BL，1:1 |

### PD

| 项 | 值 |
| --- | --- |
| 层 | 解决方案 |
| id_pattern | `PD-{NAME}` |
| 落盘 | 标准 `{ID}.md`。系统层宿主目录 `PD-{NAME}/` 可留，其下 `PM-{NAME}/` 树。不建 `PD-{NAME}.md` |
| 字段 | `implements_to` → PL；`maps_to` → BS，1:1 |

### BP

| 项 | 值 |
| --- | --- |
| 层 | 解决方案 |
| id_pattern | `BP-{NAME}` |
| 落盘 | 标准 `{ID}.md` |
| 字段 | `implements_to` → SLN |

### BSP

| 项 | 值 |
| --- | --- |
| 层 | 解决方案 |
| id_pattern | `BSP-{NAME}` |
| 落盘 | 标准 `{ID}.md` |
| 字段 | `parent` → BP；`implements_to` → PD |

### PM

| 项 | 值 |
| --- | --- |
| 层 | 系统 |
| id_pattern | `PM-{NAME}` |
| 落盘 | `PD-{NAME}/PM-{NAME}/` 树。不建 `PD-{NAME}.md` |
| 字段 | `implements_to`、`implemented_by` 必须；`maps_to`、`depends_to` 可选 |

**硬约束**：`SYS.maps_to` PD 与 `PD.maps_to` BS **成对填写**；禁跨系统 `PM→PD`。组成链用 `implements_to` / `implemented_by`（非同类树 `parent`）。BSP→BP 使用 `parent`。

### FT

| 项 | 值 |
| --- | --- |
| 层 | 系统 |
| id_pattern | `FT-{NAME}` |
| 落盘 | PM 目录之下 |
| 字段 | `implements_to`、`implemented_by` 必须 |

### FR

| 项 | 值 |
| --- | --- |
| 层 | 系统 |
| id_pattern | `FR-{NAME}` |
| 落盘 | PM 目录之下 |
| 字段 | `implements_to`、`implemented_by` 必须 |

### UC

| 项 | 值 |
| --- | --- |
| 层 | 系统 |
| id_pattern | `UC-{NAME}` |
| 落盘 | PM 目录之下 |
| 字段 | `implements_to` 必须；`maps_to` 可选 |

### BR

| 项 | 值 |
| --- | --- |
| 层 | 系统 |
| id_pattern | `BR-{NAME}` |
| 落盘 | PM 目录之下 |
| 字段 | `implements_to` 必须，→ FR |

## 3. 跨视角出边

应用：不在本文件写 PM / FT / UC 字段。API 对 FT 的绑定写在 API 实体。

| 源.字段 | 目标 | 层 | 说明 |
| --- | --- | --- | --- |
| PL.maps_to | 公司 BL.id | 解决方案 | 1:1 |
| PD.maps_to | BS.id | 解决方案 | 1:1 |
| PD.implements_to | 解决方案 PL.id | 系统 | 归属产品线 |
| PD.maps_to | 解决方案 BS.id | 系统 | 对标业务服务（glossary） |
| PM.maps_to | BC.id | 系统 | 模块对标限界上下文；可选 |
| UC.maps_to | AB.id | 系统 | 用例对标能力；可选 |

## 4. 层入口

| 层 | 入口 | 索引 |
| --- | --- | --- |
| 公司 | [README](../../company/knowledge/product/README.md) · [实体台账](../../company/knowledge/product/README.md#实体) | 本视角无实体 |
| 解决方案 | [README](../../solution/knowledge/product/README.md) · [实例索引](../../solution/knowledge/index.md) | — |
| 系统 | [README](../../system/knowledge/product/README.md) · [实例索引](../../system/knowledge/index.md) | — |
| 应用 | [实体台账](../../application/knowledge/product/README.md#实体) · [目录导航](../../application/knowledge/index.md) | `readme_index_table: true`；变更 ID 时同步 README、index.md（按需） |
