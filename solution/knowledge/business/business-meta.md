---
type: Perspective Meta
title: 业务视角元数据（solution/knowledge/business）
---
# 业务视角元数据（solution/knowledge/business）

**结论**：本层 SSOT 是 BSD-L2 与 BS。BC 及以下在系统层。

## 1. 概览

| 字段 | 值 |
| --- | --- |
| meta_id | `DIR-SOLUTION-KNOWLEDGE-BUSINESS` |
| 视角 | business |
| 层级范围 | solution |
| 说明 | BSD-L2 与 BS 本层 SSOT。公司 BD / BSD-L1 只写纯 ID。 |

## 2. 层级链

| 链序 | 代码 | 本层 |
| --- | --- | --- |
| 1–2 | BD、BSD-L1 | 公司首次定义；纯 ID |
| 3 | BSD-L2 | 本层 SSOT |
| — | BS | 本层 SSOT |
| — | BC 及以下 | 系统；本层不落 |

## 3. 层定义

| order | key | code | id_pattern | parent |
| --- | --- | --- | --- | --- |
| 3 | bsd2 | BSD | `BSD-{NAME}-L2` | 公司 BSD-L1（`level: 2`） |
| — | bs | BS | `BS-{NAME}` | —（无 parent） |

## 4. 字段（OKF）

| 层级 | 字段 | 说明 |
| --- | --- | --- |
| BSD-L2 | `parent`、`mapped_by` | `parent` → 公司 BSD-L1；`mapped_by` → BS |
| BS | `maps_to` | → BSD-L2，1:1 |

## 5. 跨视角引用

| 源字段 | 目标 | 说明 |
| --- | --- | --- |
| BSD-L2.parent | 公司 BSD-L1.id | 上级子域 |
| BSD-L2.mapped_by | BS.id | 对端业务服务 |
| BS.maps_to | BSD-L2.id | 1:1 |

## 6. 关联文档

| 路径 | 说明 |
| --- | --- |
| [README.md](README.md) | 叙事索引 |
| [index.md](../index.md) | 实例索引 |
