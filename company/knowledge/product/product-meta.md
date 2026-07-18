---
type: Perspective Meta
title: 产品视角元数据（company/knowledge/product）
---
# 产品视角元数据（company/knowledge/product）

公司级产品线（PL）的视角元数据 SSOT。实例索引见 [../index.md](../index.md)。

---

## 1. 概览

| 字段 | 值 |
| --- | --- |
| meta_id | `DIR-COMPANY-KNOWLEDGE-PRODUCT` |
| 视角 | product |
| 层级范围 | company |
| 说明 | 公司级跨系统产品族目录；系统层 PM、应用层 FT/UC 引用 PL ID。 |

---

## 2. 层级链

| 链序 | 层级代码 | 说明 |
| --- | --- | --- |
| 1 | PL | 公司级产品线 |

---

## 3. 层定义

| order | key | code | id_pattern | parent |
| --- | --- | --- | --- | --- |
| 1 | pl | PL | `PL-{NAME}` | — |

---

## 4. 字段（OKF）

**Frontmatter（10 必填）**：`type` · `title` · `description` · `tags` · `timestamp` · `full_id` · `perspective` · `hierarchy` · `parent_id` · `layer_scope`（本层固定 `company`）。详见 [okf-spec](../../../agent/knowledge/okf-spec.md) §2。

**正文四段**：`## 关系` · `## 跨视角` · `## 详细说明` · `## 依据与证据`。

### PL 专属（正文）

| 字段 | 说明 |
| --- | --- |
| target_users | 目标用户角色列表（逗号分隔或简述） |

---

## 5. 跨视角引用

| 源字段 | 目标 | 说明 |
| --- | --- | --- |
| 系统层 PM.parent_id | PL.full_id | 产品模块归属产品线（下游引用） |

---

## 6. 关联文档

| 路径 | 说明 |
| --- | --- |
| [README.md](README.md) | 叙事文档索引 |
| [../index.md](../index.md) | PL 实例 SSOT |
| [../../DESIGN.md](../../DESIGN.md) | 公司级实体定义 |
| [../../../agent/knowledge/naming-conventions.md](../../../agent/knowledge/naming-conventions.md) | ID 命名 SSOT |
