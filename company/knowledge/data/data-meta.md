---
type: Perspective Meta
title: 数据视角元数据（company/knowledge/data）
---
# 数据视角元数据（company/knowledge/data）

公司级数据视角：**本层无实体**。主数据域 MDG ∈ 系统库 `knowledge/data/MDG-*`。实例索引：[index.md](../index.md) §4（空表）。

---

## 1. 概览

| 字段 | 值 |
| --- | --- |
| meta_id | `DIR-COMPANY-KNOWLEDGE-DATA` |
| 视角 | data |
| 层级范围 | company |
| 说明 | 仅治理/湖仓/安全等叙事；不登记 MDG/DS/ENT；MDG 由各系统 `SYS.uses_mdg_ids` 引用本系统 `MDG-*`。 |

---

## 2. 层级链

| 链序 | 层级代码 | 说明 |
| --- | --- | --- |
| — | （无） | 公司层数据视角不落实体 |

---

## 3. 层定义

| order | key | code | id_pattern | parent |
| --- | --- | --- | --- | --- |
| — | — | — | — | — |

---

## 4. 字段（OKF）

本层无 per-entity frontmatter。MDG 字段见系统 `data-meta.md`。

---

## 5. 跨视角引用

| 源字段 | 目标 | 说明 |
| --- | --- | --- |
| 系统 SYS.uses_mdg_ids | 系统 MDG.full_id | 系统声明使用的主数据域 |
| 系统 DS.authoritative_mdg_id | 系统 MDG.full_id | 数据源归属主数据域 |

---

## 6. 关联文档

| 路径 | 说明 |
| --- | --- |
| [README.md](README.md) | 叙事文档索引 |
| [index.md](../index.md) | 公司实体索引（§4 无行） |
| 系统 `knowledge/data/` | MDG/DS/ENT SSOT |
| naming-conventions（Agent 元知识） | ID 命名 SSOT |
