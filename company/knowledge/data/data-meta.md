---
type: Perspective Meta
title: 数据视角元数据（company/knowledge/data）
---
# 数据视角元数据（company/knowledge/data）

公司级 MDG 视角元数据 SSOT。实例索引：[../index.md](../index.md)。

---

## 1. 概览

| 字段 | 值 |
| --- | --- |
| meta_id | `DIR-COMPANY-KNOWLEDGE-DATA` |
| 视角 | data |
| 层级范围 | company |
| 说明 | 公司级主数据治理目录；系统层 DS、应用层 ENT 引用 MDG ID（`authoritative_mdg_id` 等）。 |

---

## 2. 层级链

| 链序 | 层级代码 | 说明 |
| --- | --- | --- |
| 1 | MDG | 公司级主数据域 |

---

## 3. 层定义

| order | key | code | id_pattern | parent |
| --- | --- | --- | --- | --- |
| 1 | mdg | MDG | `MDG-{NAME}` | — |

---

## 4. 字段（OKF）

Frontmatter 10 必填 + 正文四段（`## 关系` · `## 跨视角` · `## 详细说明` · `## 依据与证据`）见 [okf-spec](../../../agent/knowledge/okf-spec.md) §2；本层 `layer_scope` 固定 `company`。

### MDG 专属（正文）

| 字段 | 说明 |
| --- | --- |
| governance_owner | 治理责任方（组织或角色） |

---

## 5. 跨视角引用

| 源字段 | 目标 | 说明 |
| --- | --- | --- |
| authoritative_mdg_id | MDG.full_id | 主数据权威域（下游引用） |

---

## 6. 关联文档

| 路径 | 说明 |
| --- | --- |
| [README.md](README.md) | 叙事文档索引 |
| [../index.md](../index.md) | MDG 实例 SSOT |
| [../../DESIGN.md](../../DESIGN.md) | 公司级实体定义 |
| [../../../agent/knowledge/naming-conventions.md](../../../agent/knowledge/naming-conventions.md) | ID 命名 SSOT |
