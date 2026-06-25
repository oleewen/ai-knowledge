---
type: Perspective Meta
title: 技术视角元数据（application/knowledge/technical）
---
# 技术视角元数据（application/knowledge/technical）

应用层技术版图（MW→CMP）视角元数据 SSOT。实例索引见 [../KNOWLEDGE-INDEX.md](../KNOWLEDGE-INDEX.md)（§5，扫描生成；实体文件 `{ID}.md` 为 SSOT）。

---

## 1. 概览

| 字段 | 值 |
| --- | --- |
| meta_id | `DIR-KNOWLEDGE-TECHNICAL` |
| 视角 | technical |
| 层级范围 | application |
| 说明 | 中间件绑定与关键组件；公司级 TPL、系统级 TSD 在对应层首次定义，本层登记 MW/CMP。 |
| entities_shape | 实体文件 `{ID}.md`（OKF 概念实体）；索引见 KNOWLEDGE_INDEX §5 |

---

## 2. 层级链

| 链序 | 层级代码 | 说明 |
| --- | --- | --- |
| 1 | MW | 中间件绑定实例 |
| 2 | CMP | 关键 Maven 依赖 / 运行时组件 |

---

## 3. 层定义

| order | key | code | id_pattern | parent |
| --- | --- | --- | --- | --- |
| 1 | mw | MW | `MW-{NAME}` | TSD（逻辑归属，`parent_tsd_id`） |
| 2 | cmp | CMP | `CMP-{NAME}` | MW |

---

## 4. 必填字段

### 通用字段

| 字段 | 说明 |
| --- | --- |
| hierarchy | `MW` / `CMP` |
| full_id | 规范 ID |
| name | 中文名称 |
| description | 实体描述 |
| evidence_source | 证据来源 |
| layer_scope | 固定为 `application` |

### 各层专属

| 层级 | 必填字段 |
| --- | --- |
| MW | `binding_type`、`config_key`、`parent_tsd_id`、`bound_app_id` |
| CMP | `maven_coordinates`、`parent_mw_id` 或 `parent_app_id`（二选一） |

---

## 5. 跨视角引用

| 源字段 | 目标 | 说明 |
| --- | --- | --- |
| MW.parent_tsd_id | TSD.full_id | 归属系统技术域 |
| MW.bound_app_id | APP.full_id | 绑定应用 |
| MW.related_ds_id | DS.full_id | 关联数据源（可选） |
| CMP.parent_mw_id | MW.full_id | 组件挂载中间件 |
| APP.implements_tpl_ids | TPL.full_id | 应用实现平台能力 |

---

## 6. 关联文档

| 路径 | 说明 |
| --- | --- |
| [README.md](README.md) | 人类可读说明 |
| [../KNOWLEDGE-INDEX.md](../KNOWLEDGE-INDEX.md) | MW/CMP 实例索引 |
| [../../../company/knowledge/technical/technical-meta.md](../../../company/knowledge/technical/technical-meta.md) | 公司级 TPL 元数据 |
| [../../../company/knowledge/KNOWLEDGE-INDEX.md](../../../company/knowledge/KNOWLEDGE-INDEX.md) | 公司级 TPL 实例 |
| [../../../system/knowledge/technical/technical-meta.md](../../../system/knowledge/technical/technical-meta.md) | 系统级 TSD 元数据 |
| [../../../system/knowledge/KNOWLEDGE-INDEX.md](../../../system/knowledge/KNOWLEDGE-INDEX.md) | 系统级 TSD 实例 |

**索引**：`readme_index_table: true`；变更 ID 时同步 README、KNOWLEDGE-INDEX.md（按需）。
