---
type: Perspective Meta
title: 数据视角元数据（solution/knowledge/data）
---
# 数据视角元数据（solution/knowledge/data）

**结论**：本层 SSOT 是 MDG。不写物理表。

## 1. 概览

| 字段 | 值 |
| --- | --- |
| meta_id | `DIR-SOLUTION-KNOWLEDGE-DATA` |
| 视角 | data |
| 层级范围 | solution |
| 说明 | MDG 本层 SSOT。一 SLN 可多条。DS / ENT 在系统层；TBL 在应用层。 |

## 2. 层级链

| 链序 | 代码 | 本层 |
| --- | --- | --- |
| — | MDG | 本层 SSOT |
| — | DS、ENT | 系统 |
| — | TBL | 应用 |

## 3. 层定义

| order | key | code | id_pattern | parent |
| --- | --- | --- | --- | --- |
| — | mdg | MDG | `MDG-{NAME}` | — |

## 4. 字段（OKF）

MDG 无 parent。对端关系见 §5。

## 5. 跨视角引用

| 源字段 | 目标 | 说明 |
| --- | --- | --- |
| SYS.uses_to | MDG.id | 系统声明使用的主数据域 |
| DS.implements_to | MDG.id | 数据源归属主数据域 |

## 6. 关联文档

| 路径 | 说明 |
| --- | --- |
| [README.md](README.md) | 叙事索引 |
| [index.md](../index.md) | 实例索引 |
