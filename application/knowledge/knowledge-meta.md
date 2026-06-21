---
type: Perspective Tree Meta
title: 知识树元数据（application/knowledge）
---
# 知识树元数据（application/knowledge）

应用知识库五视角知识树的联邦单元元数据 SSOT。

---

## 1. 概览

| 字段 | 值 |
| --- | --- |
| meta_id | `DIR-KNOWLEDGE` |
| 名称 | 应用知识库（knowledge） |
| 说明 | 五视角 business / product / application / data / technical；治理与命名 SSOT 见 agent/knowledge/。 |

---

## 2. 子目录

| 目录 | 视角 | meta | entities |
| --- | --- | --- | --- |
| business/ | 业务 | [business-meta.md](business/business-meta.md) | [business-entities.md](business/business-entities.md) |
| product/ | 产品 | [product-meta.md](product/product-meta.md) | [product-entities.md](product/product-entities.md) |
| application/ | 应用 | [application-meta.md](application/application-meta.md) | [application-entities.md](application/application-entities.md) |
| data/ | 数据 | [data-meta.md](data/data-meta.md) | [data-entities.md](data/data-entities.md) |
| technical/ | 技术 | [technical-meta.md](technical/technical-meta.md) | [technical-entities.md](technical/technical-entities.md) |

**子文件**：[README.md](README.md)

---

## 3. 角色

| 字段 | 值 |
| --- | --- |
| is_single_source_of_truth | true |
| perspectives | business, product, application, data, technical |

---

## 4. 索引

| 类型 | 路径 |
| --- | --- |
| application_index | [../INDEX_GUIDE.md](../INDEX_GUIDE.md) |
| per_perspective_readmes | business/README.md, product/README.md, application/README.md, data/README.md, technical/README.md |
| governance | [../../agent/knowledge/knowledge-governance.md](../../agent/knowledge/knowledge-governance.md) |
| entity_index | [KNOWLEDGE_INDEX.md](KNOWLEDGE_INDEX.md) |

---

## 5. 关联文档

| 路径 | 说明 |
| --- | --- |
| [README.md](README.md) | 知识树说明 |
| [../INDEX_GUIDE.md](../INDEX_GUIDE.md) | 应用索引 |
| [../../INDEX_GUIDE.md](../../INDEX_GUIDE.md) | 仓库根索引 |
| [../../README.md](../../README.md) | 应用 README |
| [../../AGENTS.md](../../AGENTS.md) | Agent 契约 |
| [../../agent/knowledge/naming-conventions.md](../../agent/knowledge/naming-conventions.md) | 命名 SSOT |

---

## 6. docs-build meta_read_order

| 顺序 | 路径 |
| --- | --- |
| 1 | docs_meta.md |
| 2 | knowledge/knowledge-meta.md |
| 3 | knowledge/business/business-meta.md |
| 4 | knowledge/product/product-meta.md |
| 5 | knowledge/application/application-meta.md |
| 6 | knowledge/data/data-meta.md |
| 7 | knowledge/technical/technical-meta.md |
| 8 | requirements/README.md |
| 9 | changelogs/README.md |
| 10 | ../agent/knowledge/knowledge-governance.md |
