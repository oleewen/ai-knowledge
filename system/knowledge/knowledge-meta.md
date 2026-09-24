---
type: Perspective Tree Meta
title: 知识树元数据（system/knowledge）
---
# 知识树元数据（system/knowledge）

系统层五视角知识树元数据 SSOT。实例索引：[index.md](index.md)。

---

## 1. 概览

| 字段 | 值 |
| --- | --- |
| meta_id | `DIR-SYSTEM-KNOWLEDGE` |
| layer_scope | system |
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
| is_single_source_of_truth | true（系统层实体与叙事 SSOT） |
| upstream | 公司级 VC/BD/BSD(L1)/CAP/PL/SLN/TPL 首次定义 |
| downstream | API/TBL/MW/CMP 及实现映射 |

---

## 4. 索引

| 类型 | 路径 |
| --- | --- |
| system_index | index.md（库外） |
| entity_index | [index.md](index.md) |
| design / governance | [knowledge-governance](../../agent/knowledge/knowledge-governance.md) |

---

## 5. 系统层 BD 落盘例外

路径契约见 [knowledge-governance](../../agent/knowledge/knowledge-governance.md)。视角路径 SSOT：[business-meta §4](business/business-meta.md#4-bd-落盘例外)。

`okf_lib.entity_relpath(bundle="system", BD)` → `knowledge/business/{id}.md`

---

## 6. 关联文档

| 路径 | 说明 |
| --- | --- |
| [README.md](README.md) | 五视角架构入口 |
| [knowledge-governance](../../agent/knowledge/knowledge-governance.md) | 系统库设计契约 |
| BD-* / BSD-L1-* / PL-* / SLN-* / TPL-* / CAP-* / VC-* | 公司层实体 SSOT（上层 reference） |
| [naming-conventions](../../agent/knowledge/naming-conventions.md) | 命名 SSOT |

---

## 7. docs-build meta_read_order

| 顺序 | 路径 |
| --- | --- |
| 1 | docs-meta.md |
| 2 | knowledge/knowledge-meta.md |
| 3 | knowledge/business/business-meta.md |
| 4 | knowledge/product/product-meta.md |
| 5 | knowledge/application/application-meta.md |
| 6 | knowledge/data/data-meta.md |
| 7 | knowledge/technical/technical-meta.md |
| 8 | changelogs/README.md |
| 9 | knowledge-governance（Agent 元知识） |
