---
type: Perspective Meta
title: 技术视角元数据（company/knowledge/technical）
---
# 技术视角元数据（company/knowledge/technical）

公司级 TPL 视角元数据 SSOT。实例索引：[index.md](../index.md)。

---

## 1. 概览

| 字段 | 值 |
| --- | --- |
| meta_id | `DIR-COMPANY-KNOWLEDGE-TECHNICAL` |
| 视角 | technical |
| 层级范围 | company |
| 说明 | 公司级平台能力目录（云/DevOps/安全/开发环境）；系统层 TSD、应用层 MW/CMP 引用 TPL ID。 |

---

## 2. 层级链

| 链序 | 层级代码 | 说明 |
| --- | --- | --- |
| 1 | TPL | 公司级技术平台能力 |

---

## 3. 层定义

| order | key | code | id_pattern | parent |
| --- | --- | --- | --- | --- |
| 1 | tpl | TPL | `TPL-{NAME}` | — |

---

## 4. 字段（OKF）

Frontmatter 10 必填 + 正文四段（`## 关系` · `## 跨视角` · `## 详细说明` · `## 依据与证据`）见 okf-spec §2；本层 `layer_scope` 固定 `company`。

### TPL 专属（正文）

| 字段 | 说明 |
| --- | --- |
| domain | 能力域：云基础设施 / DevOps / 安全 / 开发环境 等 |

---

## 5. 跨视角引用

| 源字段 | 目标 | 说明 |
| --- | --- | --- |
| TSD.parent_tpl_id | TPL.full_id | 系统级技术域归属平台能力（下游引用） |
| APP.implements_tpl_ids | TPL.full_id | 应用实现的平台能力（下游引用） |

---

## 6. 关联文档

| 路径 | 说明 |
| --- | --- |
| [README.md](README.md) | 叙事文档索引 |
| [index.md](../index.md) | TPL 实例 SSOT |
| DESIGN（库外，纯文本） | 公司级实体定义 |
| naming-conventions（Agent 元知识） | ID 命名 SSOT |
