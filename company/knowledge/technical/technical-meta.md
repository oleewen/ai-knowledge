---
type: Perspective Meta
title: 技术视角元数据（company/knowledge/technical）
---
# 技术视角元数据（company/knowledge/technical）

**结论**：TPL 视角元数据 SSOT。无 APP↔TPL 直连。实例：[index.md](../index.md)。

## 1. 概览

| 字段 | 值 |
| --- | --- |
| meta_id | `DIR-COMPANY-KNOWLEDGE-TECHNICAL` |
| 视角 | technical |
| 层级范围 | company |
| 说明 | 公司级平台能力目录（云/DevOps/安全/开发环境/可观测）。 |

## 2. 层级链

| 链序 | 层级代码 | 说明 |
| --- | --- | --- |
| 1 | TPL | 公司级技术平台能力 |

## 3. 层定义

| order | key | code | id_pattern | parent |
| --- | --- | --- | --- | --- |
| 1 | tpl | TPL | `TPL-{NAME}` | — |

## 4. 字段（OKF）

Frontmatter 10 必填 + 正文四段见 [okf-spec](../../../agent/knowledge/okf-spec.md) §2；`layer_scope` = `company`。

| 字段 | 说明 |
| --- | --- |
| domain | 能力域：云基础设施 / DevOps / 安全 / 开发环境 / 可观测 |

## 5. 跨视角引用

本层不写非公司实体的字段。入边由对端在其首次定义层书写。

## 6. 关联文档

| 路径 | 说明 |
| --- | --- |
| [README.md](README.md) | 叙事索引 |
| [index.md](../index.md) | TPL 实例 SSOT |
| [knowledge-governance](../../../agent/knowledge/knowledge-governance.md) | 公司级实体定义 |
| [naming-conventions](../../../agent/knowledge/naming-conventions.md) | ID 命名 |
