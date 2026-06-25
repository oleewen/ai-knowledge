---
type: Perspective Meta
title: 技术视角元数据（company/knowledge/technical）
---
# 技术视角元数据（company/knowledge/technical）

公司级技术平台能力（TPL）的视角元数据 SSOT。实例索引见 [../index.md](../index.md)。

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

## 4. 必填字段

### 通用字段

| 字段 | 说明 |
| --- | --- |
| hierarchy | 固定为 `TPL` |
| full_id | 规范 ID，如 `TPL-K8S-PLATFORM` |
| name | 中文名称 |
| description | 实体描述 |
| evidence_source | 证据来源（如 `technical-overview.md`） |

### TPL 专属

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
| [../index.md](../index.md) | TPL 实例 SSOT |
| [../../DESIGN.md](../../DESIGN.md) | 公司级实体定义 |
| [../../../agent/knowledge/naming-conventions.md](../../../agent/knowledge/naming-conventions.md) | ID 命名 SSOT |
