---
type: Perspective Meta
title: 技术视角元数据（application/knowledge/technical）
---

应用层技术版图（TSD→MW→CMP）视角元数据 SSOT。实例索引 [../index.md](../index.md)（§5，扫描生成；实体 `{ID}.md` = SSOT）。

## 1. 概览

| 字段 | 值 |
| --- | --- |
| meta_id | `DIR-KNOWLEDGE-TECHNICAL` |
| 视角 | technical |
| 层级范围 | application |
| 说明 | 中间件绑定与关键组件；公司级 TPL、系统级 TSD 在对应层首次定义，本层补齐 TSD reference 并登记 MW/CMP。 |
| entities_shape | 实体 `{ID}.md`（OKF）；索引见 KNOWLEDGE_INDEX §5 |

## 2. 层级链

| 链序 | 层级代码 | 说明 |
| --- | --- | --- |
| 1 | TSD | 系统级技术域（系统层 SSOT；本层为视角根 reference） |
| 2 | MW | 中间件绑定实例 |
| 3 | CMP | 关键 Maven 依赖 / 运行时组件 |

## 3. 层定义

| order | key | code | id_pattern | parent |
| --- | --- | --- | --- | --- |
| 1 | tsd | TSD | `TSD-{NAME}` | —（reference → system） |
| 2 | mw | MW | `MW-{NAME}` | TSD（逻辑归属，`parent_tsd_id`） |
| 3 | cmp | CMP | `CMP-{NAME}` | MW |

## 4. 字段（OKF）

**Frontmatter（10 必填）**：`type` · `title` · `description` · `tags` · `timestamp` · `full_id` · `perspective` · `hierarchy` · `parent_id` · `layer_scope`（本层固定 `application`）。详见 [okf-spec](../../../agent/knowledge/okf-spec.md) §2。

**正文四段**：`## 关系` · `## 跨视角` · `## 详细说明` · `## 依据与证据`。

### 各层专属（正文 / 扩展）

| 层级 | 字段 | 建议段落 |
| --- | --- | --- |
| TSD | `definition_scope: reference` | FM 扩展 / 详细说明 |
| MW | `binding_type`、`config_key`、`parent_tsd_id`、`bound_app_id` | 详细说明 / 关系 / 跨视角 |
| CMP | `maven_coordinates`；`parent_mw_id` 或 `parent_app_id`（二选一） | 详细说明 / 关系 |

## 5. 跨视角引用

| 源字段 | 目标 | 说明 |
| --- | --- | --- |
| TSD（reference） | system TSD.full_id | 上游系统 SSOT |
| MW.parent_tsd_id | TSD.full_id | 归属系统技术域 |
| MW.bound_app_id | APP.full_id | 绑定应用 |
| MW.related_ds_id | DS.full_id | 关联数据源（可选） |
| CMP.parent_mw_id | MW.full_id | 组件挂载中间件 |
| APP.implements_tpl_ids | TPL.full_id | 应用实现平台能力 |

## 6. 关联文档

| 路径 | 说明 |
| --- | --- |
| [README.md](README.md) | 人类可读说明 |
| [../index.md](../index.md) | MW/CMP 实例索引 |
| [../../../company/knowledge/technical/technical-meta.md](../../../company/knowledge/technical/technical-meta.md) | 公司级 TPL 元数据 |
| [../../../company/knowledge/index.md](../../../company/knowledge/index.md) | 公司级 TPL 实例 |
| [../../../system/knowledge/technical/technical-meta.md](../../../system/knowledge/technical/technical-meta.md) | 系统级 TSD 元数据 |
| [../../../system/knowledge/index.md](../../../system/knowledge/index.md) | 系统级 TSD 实例 |

**索引**：`readme_index_table: true`；变更 ID 时同步 README、index.md（按需）。
