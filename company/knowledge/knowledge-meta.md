---
type: Perspective Tree Meta
title: 知识树元数据（company/knowledge）
---
# 知识树元数据（company/knowledge）

公司层五视角知识树元数据 SSOT。实例索引：[index.md](index.md)。

---

## 1. 概览

| 字段 | 值 |
| --- | --- |
| meta_id | `DIR-COMPANY-KNOWLEDGE` |
| layer_scope | company |
| perspectives | business, product, application, data, technical |

---

## 2. 子目录

| 目录 | 视角 | meta | 实例索引 |
| --- | --- | --- | --- |
| business/ | 业务 | [business-meta.md](business/business-meta.md) | [index.md](index.md) §1 |
| product/ | 产品 | [product-meta.md](product/product-meta.md) | [index.md](index.md) §2 |
| application/ | 应用 | [application-meta.md](application/application-meta.md) | [index.md](index.md) §3 |
| data/ | 数据 | [data-meta.md](data/data-meta.md) | [index.md](index.md) §4 |
| technical/ | 技术 | [technical-meta.md](technical/technical-meta.md) | [index.md](index.md) §5 |

**子文件**：[README.md](README.md) · [overview/](overview/README.md)

---

## 3. 角色

| 字段 | 值 |
| --- | --- |
| is_single_source_of_truth | true（公司级实体正文 SSOT） |
| upstream | —（联邦顶层） |
| downstream | `system/knowledge/`、`application/knowledge/`（引用公司 ID） |

---

## 4. 索引

| 类型 | 路径 |
| --- | --- |
| company_index | [../index.md](../index.md) |
| entity_index | [index.md](index.md) |
| design | [../DESIGN.md](../DESIGN.md) |
| governance | [../../agent/knowledge/knowledge-governance.md](../../agent/knowledge/knowledge-governance.md) |

---

## 5. 公司层 BD 落盘

| 层级 | 路径 | 说明 |
| --- | --- | --- |
| company | `knowledge/business/BD-{NAME}/BD-{NAME}.md` | 公司 SSOT（目录锚点） |
| system | `system/knowledge/business/BD-{NAME}.md` | 视角根 reference |
| application | `application/knowledge/business/BD-{NAME}.md` | 视角根 reference |

---

## 6. 关联文档

| 路径 | 说明 |
| --- | --- |
| [README.md](README.md) | 五视角架构入口 |
| [../DESIGN.md](../DESIGN.md) | 公司库设计契约 |
| [../../agent/knowledge/naming-conventions.md](../../agent/knowledge/naming-conventions.md) | 命名 SSOT |
