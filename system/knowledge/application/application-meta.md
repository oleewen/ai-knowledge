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
| 说明 | SYS 本层首次（`implements_to→解决方案 SLN`）；APP/MS 本层 SSOT；API ∈ 应用层。 |

## 2. 层级链

| 链序 | 层级代码 | 说明 |
| --- | --- | --- |
| 1 | SYS | 系统（别名应用服务；本层 SSOT；挂公司 SLN） |
| 2 | APP | 应用 |
| 3 | MS | 入口簇 |

## 3. 层定义

| order | key | code | id_pattern | parent |
| --- | --- | --- | --- | --- |
| 1 | sys | SYS | `SYS-{NAME}` | SLN（公司） |
| 2 | app | APP | `APP-{NAME}` | SYS |
| 3 | ms | MS | `MS-{NAME}` | APP |

落盘：`SYS-{NAME}.md` 单文件；`APP-{NAME}/` 平铺（不强制收进 SYS 目录）。

## 4. 字段（OKF）

关系字段见 [glossary § 映射关系](../../../agent/knowledge/glossary.md#映射关系常用)。无 APP/SYS↔TPL 直连。

| 层级 | 字段 | 说明 |
| --- | --- | --- |
| SYS | `implements_to`、`implemented_by`、`uses_to` | →SLN；←APP；`uses_to`→MDG\|TSD |
| APP | `implements_to`、`implemented_by`、`supports_to`、`uses_to` | →SYS；←MS；`supports_to`→BC；`uses_to`→DS\|MW |
| MS | `implements_to`、`implemented_by`、`maps_to`、`uses_to` | →APP；←API；`maps_to`→AGG；`uses_to`→ENT\|TBL\|CMP |

对端镜像：`BC.supported_by`、`AGG.maps_to`（MS）、`MW.used_by`、`DS.used_by` 须与上表双向同步。

## 5. 跨视角引用

| 源字段 | 目标 | 说明 |
| --- | --- | --- |
| SYS.implements_to | 公司 SLN.id | 归属解决方案 |
| SYS.uses_to | MDG.id \| TSD.id | 声明使用的主数据域 / 技术域 |
| PD.maps_to | SYS.id | 产品服务对标（[glossary](../../../agent/knowledge/glossary.md#映射关系常用)） |
| APP.implements_to | SYS.id | 应用归属系统 |
| APP.supports_to | BC.id | 应用支撑限界上下文 |
| MS.maps_to | AGG.id | 入口簇对标聚合 |

## 6. 关联文档

| 路径 | 说明 |
| --- | --- |
| [README.md](README.md) | 叙事索引 |
| [index.md](../index.md) | 实例 SSOT |
| 公司 SLN-* | 解决方案台账 |
