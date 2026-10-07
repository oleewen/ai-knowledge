---
type: Perspective Meta
title: 应用视角元数据（solution/knowledge/application）
---
# 应用视角元数据（solution/knowledge/application）

**结论**：本层 SSOT 是 SLN。不落 SYS 正文。

## 1. 概览

| 字段 | 值 |
| --- | --- |
| meta_id | `DIR-SOLUTION-KNOWLEDGE-APPLICATION` |
| 视角 | application |
| 层级范围 | solution |
| 说明 | SLN 本层 SSOT。一仓一 SLN。SYS 在系统层。 |

## 2. 层级链

| 链序 | 代码 | 本层 |
| --- | --- | --- |
| — | SLN | 本层 SSOT |
| — | SYS | 系统；本层不落正文 |

## 3. 层定义

| order | key | code | id_pattern | parent |
| --- | --- | --- | --- | --- |
| — | sln | SLN | `SLN-{NAME}` | — |

## 4. 字段（OKF）

| 层级 | 字段 | 说明 |
| --- | --- | --- |
| SLN | `maps_to`、`implemented_by` | `maps_to` → PL，1:1；`implemented_by` → SYS |

## 5. 跨视角引用

| 源字段 | 目标 | 说明 |
| --- | --- | --- |
| SLN.maps_to | PL.id | 1:1 |
| SLN.implemented_by | SYS.id | SYS 在系统层 |

## 6. 关联文档

| 路径 | 说明 |
| --- | --- |
| [README.md](README.md) | 叙事索引 |
| [index.md](../index.md) | 实例索引 |
