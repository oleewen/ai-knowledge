---
type: Perspective Meta
title: 技术视角元数据（solution/knowledge/technical）
---
# 技术视角元数据（solution/knowledge/technical）

**结论**：本层 SSOT 是 TSD。不写 MW / CMP 字段。

## 1. 概览

| 字段 | 值 |
| --- | --- |
| meta_id | `DIR-SOLUTION-KNOWLEDGE-TECHNICAL` |
| 视角 | technical |
| 层级范围 | solution |
| 说明 | TSD 本层 SSOT。`implements_to` 公司 TPL。MW / CMP 在应用层。 |

## 2. 层级链

| 链序 | 代码 | 本层 |
| --- | --- | --- |
| — | TPL | 公司首次定义；纯 ID |
| — | TSD | 本层 SSOT |
| — | MW、CMP | 应用；本层不写字段 |

## 3. 层定义

| order | key | code | id_pattern | parent |
| --- | --- | --- | --- | --- |
| — | tsd | TSD | `TSD-{NAME}` | —（`implements_to` 公司 TPL，非 parent） |

## 4. 字段（OKF）

| 层级 | 字段 | 说明 |
| --- | --- | --- |
| TSD | `implements_to` | → 公司 TPL |

## 5. 跨视角引用

| 源字段 | 目标 | 说明 |
| --- | --- | --- |
| TSD.implements_to | 公司 TPL.id | 采用的企业技术标准 |

## 6. 关联文档

| 路径 | 说明 |
| --- | --- |
| [README.md](README.md) | 叙事索引 |
| [index.md](../index.md) | 实例索引 |
