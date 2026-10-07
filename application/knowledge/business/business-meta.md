---
type: Perspective Meta
title: 业务视角元数据（application/knowledge/business）
---

**结论**：本层无章、无首次定义实体。只写纯 ID。

## 1. 概览

| 字段 | 值 |
| --- | --- |
| meta_id | `DIR-KNOWLEDGE-BUSINESS` |
| 视角 | business |
| 层级范围 | application |
| 说明 | 无章、无首次定义实体。归属见 §2。 |

## 2. 层级链

**结论**：本层不落文件。

| 代码 | 首次定义 | 本层 |
| --- | --- | --- |
| BD、CAP、BSD-L1 | 公司 | 纯 ID |
| BSD-L2 | 解决方案 | 纯 ID |
| BSD-L3、BC、AGG、AB | 系统 | 纯 ID |

## 3. 层定义

本层无。

## 4. 字段（OKF）

本层无 per-entity 字段。

## 5. 跨视角引用

不在本文件写。

## 6. 关联文档

| 对象 | 说明 |
| --- | --- |
| [README.md](README.md) | 人类可读说明 |
| [index.md](../index.md) | §1 业务视角 |

**索引**：`readme_index_table: true`；变更 ID 时同步 README、index.md（按需）。
