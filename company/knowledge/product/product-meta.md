---
type: Perspective Meta
title: 产品视角元数据（company/knowledge/product）
---
# 产品视角元数据（company/knowledge/product）

公司级 **PL** 视角元数据 SSOT。实例索引：[index.md](../index.md)。

---

## 1. 概览

| 字段 | 值 |
| --- | --- |
| meta_id | `DIR-COMPANY-KNOWLEDGE-PRODUCT` |
| 视角 | product |
| 层级范围 | company |
| 说明 | PL=产品线（支持 BD）。**不落 PD**（系统首次定义）。**不落 SLN**（SLN ∈ 公司 application / AA）。 |

---

## 2. 层级链

| 链序 | 层级代码 | 说明 |
| --- | --- | --- |
| 1 | PL | 产品线 |

---

## 3. 层定义

| order | key | code | id_pattern | parent |
| --- | --- | --- | --- | --- |
| 1 | pl | PL | `PL-{NAME}` | — |

目录：`PL-{NAME}/PL-{NAME}.md`。

对标：`BD.maps_to_pl_id`；方案台账：`SLN.maps_to_pl_id`（AA）。CAP↔PL 由 `CAP.maps_to_bd_id` + `BD.maps_to_pl_id` 推导。

---

## 4. 字段（OKF）

| 层级 | 字段 | 说明 |
| --- | --- | --- |
| PL | `target_users` | 目标用户 |

**无** `supports_cap_ids`。

---

## 5. 跨视角引用

| 源字段 | 目标 | 说明 |
| --- | --- | --- |
| BD.maps_to_pl_id | PL.full_id | BD 由 PL 提供产品支撑（[glossary](../../../agent/knowledge/glossary.md#映射关系常用)） |
| SLN.maps_to_pl_id | PL.full_id | 解决方案对标产品线（AA；同上） |
| 系统 PD.parent_id | PL.full_id | 产品服务挂产品线 |

---

## 6. 关联文档

| 路径 | 说明 |
| --- | --- |
| [README.md](README.md) | 叙事文档索引 |
| [index.md](../index.md) | PL 实例 SSOT |
| 公司 application · SLN | AA 解决方案台账 |
