---
type: Perspective Meta
title: 应用视角元数据（company/knowledge/application）
---
# 应用视角元数据（company/knowledge/application）

公司级系统边界（SYS）的视角元数据 SSOT。实例索引见 [../KNOWLEDGE-INDEX.md](../KNOWLEDGE-INDEX.md)。

---

## 1. 概览

| 字段 | 值 |
| --- | --- |
| meta_id | `DIR-COMPANY-KNOWLEDGE-APPLICATION` |
| 视角 | application |
| 层级范围 | company |
| 说明 | 公司内系统边界目录；系统层 APP、应用层 MS/API 引用 SYS ID。 |

---

## 2. 层级链

| 链序 | 层级代码 | 说明 |
| --- | --- | --- |
| 1 | SYS | 公司内系统层 |

---

## 3. 层定义

| order | key | code | id_pattern | parent |
| --- | --- | --- | --- | --- |
| 1 | sys | SYS | `SYS-{NAME}` | — |

---

## 4. 必填字段

### 通用字段

| 字段 | 说明 |
| --- | --- |
| hierarchy | 固定为 `SYS` |
| full_id | 规范 ID，如 `SYS-BILLING-APPEAL` |
| name | 中文名称 |
| description | 实体描述 |
| evidence_source | 证据来源（如 `application-overview.md`） |

---

## 5. 跨视角引用

| 源字段 | 目标 | 说明 |
| --- | --- | --- |
| 系统层 APP.parent_sys_id | SYS.full_id | 应用归属系统（下游引用） |
| 系统层 PL 与 SYS 对齐 | SYS.full_id | 产品线常与 SYS 一一对应（叙事层约定） |

---

## 6. 关联文档

| 路径 | 说明 |
| --- | --- |
| [README.md](README.md) | 叙事文档索引 |
| [../KNOWLEDGE-INDEX.md](../KNOWLEDGE-INDEX.md) | SYS 实例 SSOT |
| [../../DESIGN.md](../../DESIGN.md) | 公司级实体定义 |
| [../../../agent/knowledge/naming-conventions.md](../../../agent/knowledge/naming-conventions.md) | ID 命名 SSOT |
