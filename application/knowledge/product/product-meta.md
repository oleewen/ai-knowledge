---
type: Perspective Meta
title: 产品视角元数据（application/knowledge/product）
---

应用侧产品版图（PL→PM→FT→FR→UC/BR）实体登记与交互映射元数据。实例索引见 [../index.md](../index.md)（§2，扫描生成；实体文件 `{ID}.md` 为 SSOT）。

---

## 1. 概览

| 字段 | 值 |
| --- | --- |
| meta_id | `DIR-KNOWLEDGE-PRODUCT` |
| 视角 | product |
| 层级范围 | application |
| 说明 | 产品版图；公司级 PL 在 `company/knowledge/product/` 首次定义，系统层自 PM 起首次定义，本层承接 API / 验收映射与实例登记（示例含 PL/PM/FT/FR/UC/BR；另有 BP 叙事文件）。 |
| entities_shape | 实体文件 `{ID}.md`（OKF 概念实体）；索引见 KNOWLEDGE_INDEX §2 |

---

## 2. 层级链

| 链序 | 层级代码 | 说明 |
| --- | --- | --- |
| 1 | PL | 产品线（公司层首次定义） |
| 2 | PM | 产品模块（系统层首次定义） |
| 3 | FT | 功能点（系统层首次定义，应用层承接 API / 验收映射） |
| 4 | FR | 功能需求（系统层首次定义，应用层承接验收与接口映射） |
| 5 | UC | 用户用例（系统层首次定义，应用层承接 API 映射） |
| 6 | BR | 业务规则（系统层首次定义，应用层承接实现映射） |

---

## 3. 层定义

| order | key | code | id_pattern | parent |
| --- | --- | --- | --- | --- |
| 1 | pl | PL | `PL-{NAME}` | — |
| 2 | pm | PM | `PM-{NAME}` | PL |
| 3 | ft | FT | `FT-{NAME}` | PM |
| 4 | fr | FR | `FR-{NAME}` | FT |
| 5 | uc | UC | `UC-{NAME}` | FR |
| 6 | br | BR | `BR-{NAME}` | FR |

---

## 4. 必填字段

### 通用字段

| 字段 | 说明 |
| --- | --- |
| hierarchy | `PL` / `PM` / `FT` / `FR` / `UC` / `BR` |
| full_id | 规范 ID |
| name | 中文名称 |
| description | 实体描述（PM 可省略） |
| evidence_source | 证据来源 |
| layer_scope | 固定为 `application` |

### 各层专属

| 层级 | 必填字段 |
| --- | --- |
| PL | `target_users` |
| PM | `parent_id` |
| FT | `parent_id`、`invokes_api_ids`、`acceptance_criteria`（推荐） |
| FR | `parent_id`、`children`（UC/BR 文件 full_id 列表） |
| UC | `parent_id`、`map_to_api_id`（推荐） |
| BR | `parent_id` |

---

## 5. 跨视角引用

| 源字段 | 目标 | 说明 |
| --- | --- | --- |
| PM.cross_references.business | BC / AGG | 模块依赖业务上下文 |
| FT.invokes_api_ids | API.id | 功能调用 API |
| UC.map_to_api_id | API.id | 用例映射 API |

## 6. BP 叙事文件（不属于 hierarchy）

本视角可选维护 `BP-{NAME}.md` 作为流程叙事文件：

- 与 `PL-{NAME}.md` 同目录
- 文件内分 `M`、`S`、`B` 三层（用标题分节），仅通过正文引用 `PL/PM/FT`
- 不进入 `PL -> PM -> FT -> FR -> UC/BR` 正式实体链，不使用 `hierarchy`、`parent_id`、`children`

---

## 7. 关联文档

| 路径 | 说明 |
| --- | --- |
| [README.md](README.md) | 人类可读说明 |
| [../index.md](../index.md) | §2 产品视角实例索引（扫描生成） |
| [../index.md](../index.md) | 五视角索引 |

**索引**：`readme_index_table: true`；变更 ID 时同步 README、index.md（按需）。
