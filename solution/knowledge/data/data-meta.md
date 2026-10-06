---
type: Perspective Meta
title: 数据视角元数据（solution/knowledge/data）
---
# 数据视角元数据（solution/knowledge/data）

| 字段 | 值 |
| --- | --- |
| meta_id | `DIR-SOLUTION-KNOWLEDGE-DATA` |
| 视角 | data |
| 层级范围 | solution |
| 说明 | MDG 本层 SSOT（一 SLN 可多条）。关系只登记 SYS.uses_to 与 DS.implements_to。DS/ENT ∈ 系统；TBL ∈ 应用。 |

## 跨视角引用

| 源字段 | 目标 | 说明 |
| --- | --- | --- |
| SYS.uses_to | MDG.id | 系统声明使用的主数据域 |
| DS.implements_to | MDG.id | 数据源归属主数据域 |
