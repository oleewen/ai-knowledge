---
type: Perspective Meta
title: 产品视角元数据（application/knowledge/product）
---
# 产品视角元数据（application/knowledge/product）

应用侧产品版图（PL→PM→FT→UC）实体登记与交互映射元数据。实例索引见 [product-entities.md](product-entities.md)。

---

## 1. 概览

| 字段 | 值 |
| --- | --- |
| meta_id | `DIR-KNOWLEDGE-PRODUCT` |
| 视角 | product |
| 层级范围 | application |
| 说明 | 产品版图；公司级 PL 在 `company/knowledge/product/` 首次定义，系统层自 PM 起首次定义，本层承接 API / 验收映射与实例登记（示例含 PL/PM/FT/UC）。 |

---

## 2. 层级链

| 链序 | 层级代码 | 说明 |
| --- | --- | --- |
| 1 | PL | 产品线（公司层首次定义） |
| 2 | PM | 产品模块（系统层首次定义） |
| 3 | FT | 功能点（系统层首次定义，应用层承接 API / 验收映射） |
| 4 | UC | 用户用例（系统层首次定义，应用层承接 API 映射） |

---

## 3. 层定义

| order | key | code | id_pattern | parent |
| --- | --- | --- | --- | --- |
| 1 | pl | PL | `PL-{NAME}` | — |
| 2 | pm | PM | `PM-{NAME}` | PL |
| 3 | ft | FT | `FT-{NAME}` | PM |
| 4 | uc | UC | `UC-{NAME}` 或 `UC-{NAME}-{NNN}` | FT |

---

## 4. 必填字段

### 通用字段

| 字段 | 说明 |
| --- | --- |
| hierarchy | `PL` / `PM` / `FT` / `UC` |
| full_id | 规范 ID |
| name | 中文名称 |
| description | 实体描述（PM 可省略） |
| evidence_source | 证据来源 |

### 各层专属

| 层级 | 必填字段 |
| --- | --- |
| PL | `target_users` |
| PM | `parent_id` |
| FT | `parent_id`、`invokes_api_ids`、`acceptance_criteria`、`realizes_use_case_ids` |
| UC | `map_to_api_id`（推荐） |

---

## 5. 跨视角引用

| 源字段 | 目标 | 说明 |
| --- | --- | --- |
| PM.cross_references.business | BC / AGG | 模块依赖业务上下文 |
| FT.invokes_api_ids | API.id | 功能调用 API |
| FT.realizes_use_case_ids | UC.full_id | 功能实现用例 |
| UC.map_to_api_id | API.id | 用例映射 API |

---

## 6. 关联文档

| 路径 | 说明 |
| --- | --- |
| [README.md](README.md) | 人类可读说明 |
| [product-entities.md](product-entities.md) | 扁平实体索引与登记主表 |
| [../KNOWLEDGE_INDEX.md](../KNOWLEDGE_INDEX.md) | 五视角索引 |

**索引**：`readme_index_table: true`；变更 ID 时同步 README、KNOWLEDGE_INDEX.md（按需）。
