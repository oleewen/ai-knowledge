---
type: Perspective Meta
title: 产品视角元数据（application/knowledge/product）
---

**结论**：本层无章、无首次定义实体。只写纯 ID。

## 1. 概览

| 字段 | 值 |
| --- | --- |
| meta_id | `DIR-KNOWLEDGE-PRODUCT` |
| 视角 | product |
| 层级范围 | application |
| 说明 | 无章、无首次定义实体。归属见 §2。 |

## 2. 层级链

**结论**：本层不落文件。

| 代码 | 首次定义 | 本层 |
| --- | --- | --- |
| PL、PD、BP、BSP | 解决方案 | 纯 ID |
| PM、FT、FR、UC、BR | 系统 | 纯 ID |

## 3. 层定义

本层无。

## 4. 字段（OKF）

本层无 per-entity 字段。

## 5. 跨视角引用

不在本文件写 PM / FT / UC 字段。API 对 FT 的绑定写在 API 实体。

## 6. BP 流程叙事（旁路实体）

**结论**：本层不落 BP。

- BP 首次定义在解决方案；`implements_to` SLN
- 不挂入 `PL → PD → PM → FT → FR → UC/BR` 组成链

## 7. 关联文档

| 对象 | 说明 |
| --- | --- |
| [README.md](README.md) | 人类可读说明 |
| [index.md](../index.md) | §2 产品视角 |

**索引**：`readme_index_table: true`；变更 ID 时同步 README、index.md（按需）。
