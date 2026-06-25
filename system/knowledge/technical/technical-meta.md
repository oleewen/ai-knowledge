---
type: Perspective Meta
title: 技术视角元数据（system/knowledge/technical）
---
# 技术视角元数据（system/knowledge/technical）

系统级技术域（TSD）视角元数据 SSOT。实例索引见 [KNOWLEDGE-INDEX.md](../KNOWLEDGE-INDEX.md)。

---

## 1. 概览

| 字段 | 值 |
| --- | --- |
| meta_id | `DIR-SYSTEM-ARCH-TECHNICAL` |
| 视角 | technical |
| 层级范围 | system |
| 说明 | 系统级技术域落地；引用公司级 TPL，应用层 MW/CMP 引用本层 TSD。 |

---

## 2. 层级链

| 链序 | 层级代码 | 说明 |
| --- | --- | --- |
| 1 | TSD | 系统级技术域（中间件域、可观测域等） |

---

## 3. 层定义

| order | key | code | id_pattern | parent |
| --- | --- | --- | --- | --- |
| 1 | tsd | TSD | `TSD-{NAME}` | TPL（逻辑归属，`parent_tpl_id`） |

---

## 4. 必填字段

### 通用字段

| 字段 | 说明 |
| --- | --- |
| hierarchy | 固定为 `TSD` |
| full_id | 规范 ID，如 `TSD` |
| name | 中文名称 |
| description | 实体描述 |
| evidence_source | 证据来源 |

### TSD 专属

| 字段 | 说明 |
| --- | --- |
| domain | 技术域分类（如 middleware、observability） |
| parent_tpl_id | 归属公司级 TPL 的 full_id |

---

## 5. 跨视角引用

| 源字段 | 目标 | 说明 |
| --- | --- | --- |
| TSD.parent_tpl_id | TPL.full_id | 归属平台能力 |
| MW.parent_tsd_id | TSD.full_id | 应用中间件绑定归属（下游引用） |

---

## 6. 关联文档

| 路径 | 说明 |
| --- | --- |
| [README.md](README.md) | 叙事文档索引 |
| [KNOWLEDGE-INDEX.md](../KNOWLEDGE-INDEX.md) | TSD 实例 SSOT |
| [../../../company/knowledge/technical/technical-meta.md](../../../company/knowledge/technical/technical-meta.md) | 公司级 TPL 元数据 |
| [../../../company/knowledge/KNOWLEDGE-INDEX.md](../../../company/knowledge/KNOWLEDGE-INDEX.md) | 公司级 TPL 实例 |
| [../../../agent/knowledge/naming-conventions.md](../../../agent/knowledge/naming-conventions.md) | 命名 SSOT |

**索引**：`readme_index_table: false`；变更 TSD ID 时同步 system/DESIGN.md 与 overview（按需）。
