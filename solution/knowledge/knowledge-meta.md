---
type: Perspective Tree Meta
title: 知识树元数据（solution/knowledge）
---
# 知识树元数据（solution/knowledge）

**结论**：解决方案层五视角知识树元数据 SSOT。实例：[index.md](index.md)。

## 1. 概览

| 字段 | 值 |
| --- | --- |
| meta_id | `DIR-SOLUTION-KNOWLEDGE` |
| layer_scope | solution |
| perspectives | business, product, application, data, technical |

## 2. 子目录

| 目录 | 视角 | meta |
| --- | --- | --- |
| business/ | 业务 | [business-meta.md](business/business-meta.md) |
| product/ | 产品 | [product-meta.md](product/product-meta.md) |
| application/ | 应用 | [application-meta.md](application/application-meta.md) |
| data/ | 数据 | [data-meta.md](data/data-meta.md) |
| technical/ | 技术 | [technical-meta.md](technical/technical-meta.md) |

**子文件**：[README.md](README.md) · [overview/](overview/README.md)

## 3. 角色

| 字段 | 值 |
| --- | --- |
| is_single_source_of_truth | true（本层首次定义实体） |
| upstream | 公司 VC/BD/BSD-L1/CAP/BL/TPL |
| downstream | SYS 及实现链 ∈ 系统；API/TBL/MW/CMP ∈ 应用 |

## 4. 索引

| 类型 | 路径 |
| --- | --- |
| 目录索引 | [index.md](index.md) |
| 层九章 | INDEX-GUIDE |
