---
type: Perspective Meta
title: 产品视角元数据（system/knowledge/product）
---
# 产品视角元数据（system/knowledge/product）

系统级产品版图（PL→PM→FT→FR→UC/BR）视角元数据 SSOT。实例索引见 [../index.md](../index.md)。

---

## 1. 概览

| 字段 | 值 |
| --- | --- |
| meta_id | `DIR-SYSTEM-KNOWLEDGE-PRODUCT` |
| 视角 | product |
| 层级范围 | system |
| 说明 | 系统级产品功能组织；公司级 PL 在 `company/knowledge/product/` 首次定义，本层 PL 为视角根 reference，自 PM 起为系统 SSOT；应用层承接 API / 验收映射。 |

---

## 2. 层级链

| 链序 | 层级代码 | 说明 |
| --- | --- | --- |
| 1 | PL | 产品线（公司层 SSOT；系统层为视角根 reference） |
| 2 | PM | 产品模块（系统层首次定义） |
| 3 | FT | 功能点（系统层首次定义） |
| 4 | FR | 功能需求（系统层首次定义） |
| 5 | UC / BR | 用例 / 业务规则（系统层首次定义；挂 FR） |

---

## 3. 层定义

| order | key | code | id_pattern | parent |
| --- | --- | --- | --- | --- |
| 1 | pl | PL | `PL-{NAME}` | —（reference → company） |
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
| description | 实体描述 |
| evidence_source | 证据来源 |
| layer_scope | 固定为 `system` |

### 各层专属

| 层级 | 必填字段 |
| --- | --- |
| PL | `definition_scope: reference`、`target_users`（上游 SSOT 见 # SSOT 段） |
| PM | `parent_id` |
| FT | `parent_id`、`acceptance_criteria`、`realizes_use_case_ids` |
| FR | `parent_id` |
| UC | `parent_id`、`map_to_api_id`（推荐；应用层补全） |
| BR | `parent_id` |

---

## 5. 跨视角引用

| 源字段 | 目标 | 说明 |
| --- | --- | --- |
| PL（reference） | company PL.full_id | 上游公司 SSOT |
| PM.parent_id | PL.full_id | 模块归属产品线 |
| PM.cross_references.business | BC / AGG | 模块依赖业务上下文 |
| FT.realizes_use_case_ids | UC.full_id | 功能实现用例 |
| 应用层 FT.invokes_api_ids | API.id | 功能调用 API（下游引用） |

---

## 6. 关联文档

| 路径 | 说明 |
| --- | --- |
| [README.md](README.md) | 叙事文档索引 |
| [../index.md](../index.md) | PL/PM/FT/FR/UC/BR/BP 实例 SSOT |
| [../../DESIGN.md](../../DESIGN.md) | 系统库设计契约 |
| [../../../company/knowledge/product/product-meta.md](../../../company/knowledge/product/product-meta.md) | 公司级 PL 元数据 |
| [../../../agent/knowledge/naming-conventions.md](../../../agent/knowledge/naming-conventions.md) | ID 命名 SSOT |

**索引**：`readme_index_table: false`；变更 ID 时同步 index.md 与 narrative 章节（按需）。
