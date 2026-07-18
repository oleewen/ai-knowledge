---
type: Perspective Meta
title: 应用视角元数据（company/knowledge/application）
---
# 应用视角元数据（company/knowledge/application）

公司级系统边界（SYS）的视角元数据 SSOT。实例索引见 [../index.md](../index.md)。

---

## 1. 概览

| 字段 | 值 |
| --- | --- |
| meta_id | `DIR-COMPANY-KNOWLEDGE-APPLICATION` |
| 视角 | application |
| 层级范围 | company |
| 说明 | 公司内系统边界目录；系统层 APP、应用层 MS/API 引用 SYS ID。 |

---

## 2. 层级链

| 链序 | 层级代码 | 说明 |
| --- | --- | --- |
| 1 | SYS | 公司内系统层 |

---

## 3. 层定义

| order | key | code | id_pattern | parent |
| --- | --- | --- | --- | --- |
| 1 | sys | SYS | `SYS-{NAME}` | — |

---

## 4. 字段（OKF）

**Frontmatter（10 必填）**：`type` · `title` · `description` · `tags` · `timestamp` · `full_id` · `perspective` · `hierarchy` · `parent_id` · `layer_scope`（本层固定 `company`）。详见 [okf-spec](../../../agent/knowledge/okf-spec.md) §2。

**正文四段**：`## 关系` · `## 跨视角` · `## 详细说明` · `## 依据与证据`。

### SYS 专属（正文）

| 字段 | 说明 |
| --- | --- |
| architecture | apps / external_dependencies / ddd_layers（摘要即可） |
| definition_scope | 本层主定义多为 `local` |

---

## 5. 跨视角引用

| 源字段 | 目标 | 说明 |
| --- | --- | --- |
| 系统层 APP.parent_sys_id | SYS.full_id | 应用归属系统（下游引用） |
| 系统层 PL 与 SYS 对齐 | SYS.full_id | 产品线常与 SYS 一一对应（叙事层约定） |

---

## 6. 关联文档

| 路径 | 说明 |
| --- | --- |
| [README.md](README.md) | 叙事文档索引 |
| [../index.md](../index.md) | SYS 实例 SSOT |
| [../../DESIGN.md](../../DESIGN.md) | 公司级实体定义 |
| [../../../agent/knowledge/naming-conventions.md](../../../agent/knowledge/naming-conventions.md) | ID 命名 SSOT |
