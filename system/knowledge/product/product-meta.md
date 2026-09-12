---
type: Perspective Meta
title: 产品视角元数据（system/knowledge/product）
---
# 产品视角元数据（system/knowledge/product）

系统级产品能力版图（PD→PM→FT→FR→UC/BR · BP）视角元数据 SSOT。实例索引：[index.md](../index.md)。

---

## 1. 概览

| 字段 | 值 |
| --- | --- |
| meta_id | `DIR-SYSTEM-KNOWLEDGE-PRODUCT` |
| 视角 | product |
| 层级范围 | system |
| 说明 | PD 本层首次定义（产品能力）；PL 为公司产品 SSOT；SLN 为公司 AA（本层不落盘）。PM 须与 PD 同库。 |

---

## 2. 层级链

| 链序 | 层级代码 | 说明 |
| --- | --- | --- |
| — | PL | 公司产品 SSOT；本层不落盘 |
| — | SLN | 公司 AA SSOT；本层不落盘 |
| 1 | PD | 产品能力（系统首次定义） |
| 2 | PM | 产品模块 |
| 3 | FT | 功能点 |
| 4 | FR | 功能需求 |
| 5 | UC / BR | 用例 / 业务规则 |
| 6 | BP | 业务流程（可挂 PD/PM） |

---

## 3. 层定义

| order | key | code | id_pattern | parent |
| --- | --- | --- | --- | --- |
| 1 | pd | PD | `PD-{NAME}` | PL（公司） |
| 2 | pm | PM | `PM-{NAME}` | PD（只许本库 PD） |
| 3 | ft | FT | `FT-{NAME}` | PM |
| 4 | fr | FR | `FR-{NAME}` | FT |
| 5 | uc | UC | `UC-{NAME}` | FR |
| 6 | br | BR | `BR-{NAME}` | FR |
| 7 | bp | BP | `BP-{NAME}` | PD / PM（可选） |

目录：`PD-{NAME}/PD-{NAME}.md` + 其下 `PM-{NAME}/` 树。

硬约束：`PD.maps_to_sys_id` 与首层 `BSD.maps_to_pd_id` **同建同填**；禁跨系统 `PM→PD`。

---

## 4. 字段（OKF）

| 层级 | 字段 | 说明 |
| --- | --- | --- |
| PD | `maps_to_sys_id` | 必填；对标本库 SYS |
| PM | `relies_on_context_ids`、`depends_pm_ids` | 跨视角 / 关系 |
| FT | `realizes_use_case_ids`、`invokes_api_ids` | 跨视角 |
| BP | `parent_id` 可选 PD/PM | 关系 |

---

## 5. 跨视角引用

| 源字段 | 目标 | 说明 |
| --- | --- | --- |
| PD.parent_id | 公司 PL.full_id | 产品能力归属产品线 |
| PD.maps_to_sys_id | 本库 SYS.full_id | 对标系统 |
| PM.parent_id | 本库 PD.full_id | 模块归属产品能力 |
| PM.relies_on_context_ids | BC.full_id | 模块依赖上下文 |

---

## 6. 关联文档

| 路径 | 说明 |
| --- | --- |
| [README.md](README.md) | 叙事文档索引 |
| [index.md](../index.md) | PD/PM/… 实例 SSOT |
| 公司 PL-* | 上游产品线 |
| 公司 SLN-* | 上游解决方案（AA） |
