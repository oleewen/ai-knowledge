---
type: Perspective Meta
title: 应用视角元数据（company/knowledge/application）
---
# 应用视角元数据（company/knowledge/application）

公司级 **SLN**（解决方案）= 企业 AA 台账 SSOT。**不落 SYS**（SYS ∈ 系统库，`parent_id→SLN`）。

---

## 1. 概览

| 字段 | 值 |
| --- | --- |
| meta_id | `DIR-COMPANY-KNOWLEDGE-APPLICATION` |
| 视角 | application |
| 层级范围 | company |
| 说明 | SLN=解决方案（对应 PL）（公司 AA 台账）；与 PL 经 `maps_to_pl_id` 1:1 同建。 |

---

## 2. 层级链

| 链序 | 层级代码 | 说明 |
| --- | --- | --- |
| 1 | SLN | 解决方案（企业 AA 台账） |

---

## 3. 层定义

| order | key | code | id_pattern | parent |
| --- | --- | --- | --- | --- |
| 1 | sln | SLN | `SLN-{NAME}` | —（`maps_to_pl_id→PL`） |

落盘：`application/SLN-{NAME}.md` 平铺。

---

## 4. 字段（OKF）

| 层级 | 字段 | 说明 |
| --- | --- | --- |
| SLN | `maps_to_pl_id` | **必填**；与 PL 同建 1:1 |
| SLN | `uses_mdg_ids` | AA uses DA（可选） |

---

## 5. 跨视角引用

| 源字段 | 目标 | 说明 |
| --- | --- | --- |
| SLN.maps_to_pl_id | PL.full_id | 方案对标产品线（[glossary](../../../agent/knowledge/glossary.md#映射关系常用)） |
| 系统 SYS.parent_id | SLN.full_id | 系统归属解决方案 |

---

## 6. 关联文档

| 路径 | 说明 |
| --- | --- |
| [README.md](README.md) | 入口 |
| [index.md](../index.md) | SLN 实例 |
| 各系统 `SYS-*.md` | 系统 SSOT |
