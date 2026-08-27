---
type: Perspective Meta
title: 技术视角元数据（system/knowledge/technical）
---
# 技术视角元数据（system/knowledge/technical）

系统级技术域（TSD）视角元数据 SSOT。实例索引：[index.md](../index.md)。

---

## 1. 概览

| 字段 | 值 |
| --- | --- |
| meta_id | `DIR-SYSTEM-ARCH-TECHNICAL` |
| 视角 | technical |
| 层级范围 | system |
| 说明 | 系统级 TSD SSOT；MW/CMP 首次在 application；本层可挂 MW reference。 |

---

## 2. 层级链

| 链序 | 层级代码 | 说明 |
| --- | --- | --- |
| 1 | TSD | 系统级技术域（中间件域、可观测域等） |
| 2 | MW | 应用层首次定义；本层可为 reference |

---

## 3. 层定义

| order | key | code | id_pattern | parent |
| --- | --- | --- | --- | --- |
| 1 | tsd | TSD | `TSD-{NAME}` | TPL（逻辑归属，`parent_tpl_id`） |

---

## 4. 字段（OKF）

Frontmatter 10 必填 + 正文四段（`## 关系` · `## 跨视角` · `## 详细说明` · `## 依据与证据`）见 okf-spec §2；本层 `layer_scope` 固定 `system`。

### TSD 专属（正文 / 扩展）

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
| [index.md](../index.md) | TSD 实例 SSOT |
| TPL-* | 公司层 TPL SSOT（reference） |
| naming-conventions（Agent 元知识） | 命名 SSOT |

**索引**：`readme_index_table: false`；变更 TSD ID 时同步 system/DESIGN.md 与 overview（按需）。
