---
type: Perspective Tree Meta
title: 知识树元数据（application/knowledge）
---
# 知识树元数据（application/knowledge）

应用层五视角知识树元数据 SSOT。

## 1. 概览

| 字段 | 值 |
| --- | --- |
| meta_id | `DIR-KNOWLEDGE` |
| 名称 | 应用知识库（knowledge） |
| 说明 | 五视角 business / product / application / data / technical；治理与命名 SSOT 见 Agent 元知识（库外）。 |

## 2. 子目录

| 目录 | 视角 | meta | entities |
| --- | --- | --- | --- |
| business/ | 业务 | [business-meta.md](business/business-meta.md) | [index.md](index.md) §1 |
| product/ | 产品 | [product-meta.md](product/product-meta.md) | [index.md](index.md) §2 |
| application/ | 应用 | [application-meta.md](application/application-meta.md) | [index.md](index.md) §3 |
| data/ | 数据 | [data-meta.md](data/data-meta.md) | [index.md](index.md) §4 |
| technical/ | 技术 | [technical-meta.md](technical/technical-meta.md) | [index.md](index.md) §5 |

**子文件**：[README.md](README.md)

## 3. 角色

| 字段 | 值 |
| --- | --- |
| is_single_source_of_truth | true |
| perspectives | business, product, application, data, technical |

## 4. 索引

| 类型 | 路径 |
| --- | --- |
| application_index | index.md（库外） |
| per_perspective_readmes | business/README.md, product/README.md, application/README.md, data/README.md, technical/README.md |
| governance | knowledge-governance（Agent 元知识） |
| entity_index | [index.md](index.md) |

## 5. 关联文档

| 路径 | 说明 |
| --- | --- |
| [README.md](README.md) | 知识树说明 |
| index.md（库外） | 应用索引 |
| index.md（库外） | 仓库根目录索引页 |
| README.md（库外） | 应用 README |
| AGENTS（库外） | Agent 契约 |
| naming-conventions（Agent 元知识） | 命名 SSOT |

## 6. docs-build meta_read_order

| 顺序 | 路径 |
| --- | --- |
| 1 | docs-meta.md |
| 2 | knowledge/knowledge-meta.md |
| 3 | knowledge/business/business-meta.md |
| 4 | knowledge/product/product-meta.md |
| 5 | knowledge/application/application-meta.md |
| 6 | knowledge/data/data-meta.md |
| 7 | knowledge/technical/technical-meta.md |
| 8 | requirements/README.md |
| 9 | changelogs/README.md |
| 10 | knowledge-governance（Agent 元知识） |
