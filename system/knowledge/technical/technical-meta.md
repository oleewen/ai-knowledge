---
type: Perspective Meta
title: 技术视角元数据（system/knowledge/technical）
---
# 技术视角元数据（system/knowledge/technical）

**结论**：本层无 TSD SSOT。TSD 为解决方案 reference。MW/CMP 首次 ∈ application。实例：[index.md](../index.md)。

## 1. 概览

| 字段 | 值 |
| --- | --- |
| meta_id | `DIR-SYSTEM-ARCH-TECHNICAL` |
| 视角 | technical |
| 层级范围 | system |
| 说明 | TSD 为解决方案 reference；MW/CMP 首次 ∈ application。 |

## 2. 层级链

| 链序 | 层级代码 | 说明 |
| --- | --- | --- |
| — | TSD | 解决方案 SSOT；本层 reference |
| 2 | MW | 应用层首次；本层可为 reference |

## 3. 层定义

| order | key | code | id_pattern | parent |
| --- | --- | --- | --- | --- |
| — | tsd | TSD | `TSD-{NAME}` | TPL（解决方案首次；本层 reference） |

## 4. 字段（OKF）

Frontmatter 9 必填 + 正文四段见 okf-spec §2；`layer_scope` = `system`。

| 字段 | 说明 |
| --- | --- |
| domain | 技术域分类（如 middleware、observability） |
| implements_to | 归属公司级 TPL 的 id |

## 5. 跨视角引用

| 源字段 | 目标 | 说明 |
| --- | --- | --- |
| TSD.implements_to | TPL.id | 归属平台能力 |
| MW.implements_to | TSD.id | 应用中间件绑定（下游） |

## 6. 关联文档

| 路径 | 说明 |
| --- | --- |
| [README.md](README.md) | 叙事索引 |
| [index.md](../index.md) | TSD reference |
| TPL-* | 公司 TPL SSOT（reference） |
| naming-conventions | 命名 SSOT |
| knowledge-governance | 层语义 |

**索引**：`readme_index_table: false`；变更 TSD ID 时同步 index/overview（按需）。
