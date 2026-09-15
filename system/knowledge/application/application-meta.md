---
type: Perspective Meta
title: 应用视角元数据（system/knowledge/application）
---
# 应用视角元数据（system/knowledge/application）

系统级应用版图（SYS→APP→MS）视角元数据 SSOT。实例索引：[index.md](../index.md)。

---

## 1. 概览

| 字段 | 值 |
| --- | --- |
| meta_id | `DIR-SYSTEM-KNOWLEDGE-APPLICATION` |
| 视角 | application |
| 层级范围 | system |
| 说明 | SYS 本层首次定义（`parent_id→公司 SLN`）；APP/MS 本层 SSOT；API 在应用层。5A：AA implements BA；AA uses DA/TA；PA↔AA 经 PD/SYS。 |

---

## 2. 层级链

| 链序 | 层级代码 | 说明 |
| --- | --- | --- |
| 1 | SYS | 系统（别名：应用服务；本层 SSOT；挂公司 SLN） |
| 2 | APP | 应用 |
| 3 | MS | 入口簇 |

---

## 3. 层定义

| order | key | code | id_pattern | parent |
| --- | --- | --- | --- | --- |
| 1 | sys | SYS | `SYS-{NAME}` | SLN（公司） |
| 2 | app | APP | `APP-{NAME}` | SYS |
| 3 | ms | MS | `MS-{NAME}` | APP |

落盘：`SYS-{NAME}.md` 单文件；`APP-{NAME}/` 平铺（不强制收进 SYS 目录）。

---

## 4. 字段（OKF）

| 层级 | 字段 | 说明 |
| --- | --- | --- |
| SYS | `uses_mdg_ids`、`uses_tsd_ids`、`uses_tpl_ids` | AA uses DA/TA |
| APP | `implements_bc_ids`、`uses_ds_ids`、`uses_mw_ids`、`implements_tpl_ids` | implements BA / uses DA·TA |
| MS | `implements_agg_ids`、`uses_ent_ids`、`uses_tbl_ids` | implements BA / uses DA |

过渡：`BC.implemented_by_app_id`、`AGG.implemented_by_service_ids`、`MW.bound_app_id`、`DS.owned_by_app_id` 为镜像，SSOT 迁至上表。

---

## 5. 跨视角引用

| 源字段 | 目标 | 说明 |
| --- | --- | --- |
| SYS.parent_id | 公司 SLN.full_id | 系统归属解决方案 |
| SYS.uses_mdg_ids | MDG.full_id | 系统声明使用的主数据域 |
| PD.maps_to_sys_id | SYS.full_id | 产品服务对标（[glossary](../../../agent/knowledge/glossary.md#映射关系常用)） |
| APP.parent_id | SYS.full_id | 应用归属系统 |

---

## 6. 关联文档

| 路径 | 说明 |
| --- | --- |
| [README.md](README.md) | 叙事文档索引 |
| [index.md](../index.md) | SYS/APP/MS 实例 SSOT |
| 公司 SLN-* | 解决方案台账 |
