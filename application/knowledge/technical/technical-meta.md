---
type: Perspective Meta
title: 技术视角元数据（application/knowledge/technical）
---

应用层技术版图（TSD→MW→CMP）视角元数据 SSOT。实例索引 [index.md](../index.md)（§5，扫描生成；实体 `{ID}.md` = SSOT）。

## 1. 概览

| 字段 | 值 |
| --- | --- |
| meta_id | `DIR-KNOWLEDGE-TECHNICAL` |
| 视角 | technical |
| 层级范围 | application |
| 说明 | 中间件绑定与关键组件；公司级 TPL、解决方案 TSD 在对应层首次定义，本层补齐 TSD reference 并登记 MW/CMP。 |
| entities_shape | 实体 `{ID}.md`（OKF）；索引见 INDEX-GUIDE 第四章 §5 |

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
| 2 | mw | MW | `MW-{NAME}` | TSD（逻辑归属，`implements_to`） |
| 3 | cmp | CMP | `CMP-{NAME}` | MW |

## 4. 字段（OKF）

**Frontmatter（9 必填）**：`type` · `title` · `description` · `tags` · `timestamp` · `id` · `perspective` · `hierarchy` · `layer_scope`（本层固定 `application`）。详见 okf-spec §2。关系字段见 glossary § 映射关系。无 APP↔CMP / APP↔TPL 直连。

**正文四段**：`## 关系` · `## 跨视角` · `## 详细说明` · `## 依据与证据`。

### 各层专属（正文 / 扩展）

| 层级 | 字段 | 建议段落 |
| --- | --- | --- |
| TSD | `definition_scope: reference` | FM 扩展 / 详细说明 |
| MW | `binding_type`、`config_key`、`implements_to`、`used_by`、`uses_to` | 详细说明 / 关系 / 跨视角 |
| CMP | `maven_coordinates`、`implements_to` | 详细说明 / 关系 |

## 5. 跨视角引用

| 源字段 | 目标 | 说明 |
| --- | --- | --- |
| TSD（reference） | solution TSD.id | 上游解决方案 SSOT |
| MW.implements_to | TSD.id | 归属解决方案技术域 |
| MW.used_by | APP.id | 被应用使用（对端 APP.uses_to） |
| MW.uses_to | DS.id | 中间件使用数据源（可选） |
| CMP.implements_to | MW.id | 组件挂载中间件 |
| MS.uses_to | CMP.id | 入口簇使用组件 |

## 6. 关联文档

| 路径 | 说明 |
| --- | --- |
| [README.md](README.md) | 人类可读说明 |
| [index.md](../index.md) | MW/CMP 实例索引 |
| TPL-* | 公司层 TPL SSOT（reference） |
| TSD-* | 解决方案 TSD SSOT（reference） |

**索引**：`readme_index_table: true`；变更 ID 时同步 README、index.md（按需）。
