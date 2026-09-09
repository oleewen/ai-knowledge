---
type: Perspective Meta
title: 产品视角元数据（company/knowledge/product）
---
# 产品视角元数据（company/knowledge/product）

公司级 PL→PD 视角元数据 SSOT。实例索引：[index.md](../index.md)。

---

## 1. 概览

| 字段 | 值 |
| --- | --- |
| meta_id | `DIR-COMPANY-KNOWLEDGE-PRODUCT` |
| 视角 | product |
| 层级范围 | company |
| 说明 | 公司级跨系统产品目录：PL=一套解决方案集合，PD=单个解决方案（Product）；系统/应用自 PM 起引用公司 `PD-*`（有 parent 则 HTTP，否则纯 ID；不落本地 PD 文件）。 |

---

## 2. 层级链

| 链序 | 层级代码 | 说明 |
| --- | --- | --- |
| 1 | PL | 公司级产品线（一套解决方案集合） |
| 2 | PD | 公司级产品（单个解决方案） |

---

## 3. 层定义

| order | key | code | id_pattern | parent |
| --- | --- | --- | --- | --- |
| 1 | pl | PL | `PL-{NAME}` | — |
| 2 | pd | PD | `PD-{NAME}` | PL |

目录：`PL-{NAME}/PL-{NAME}.md` + `PL-{NAME}/PD-{NAME}.md`。

---

## 4. 字段（OKF）

Frontmatter 10 必填 + 正文四段（`## 关系` · `## 跨视角` · `## 详细说明` · `## 依据与证据`）见 okf-spec §2；本层 `layer_scope` 固定 `company`。

### 各层专属（正文）

| 层级 | 字段 | 说明 |
| --- | --- | --- |
| PL | `target_users` | 目标用户角色列表（逗号分隔或简述） |
| PD | （按需） | 解决方案定位、范围；可空子（暂无下游 PM） |

空节点：公司层允许 PL 暂无 PD、PD 暂无下游 PM。

---

## 5. 跨视角引用

| 源字段 | 目标 | 说明 |
| --- | --- | --- |
| PD.parent_id | PL.full_id | 产品归属产品线 |
| 系统/应用 PM.parent_id | PD.full_id | 模块归属产品（下游引用；无本地 PD stub） |

---

## 6. 关联文档

| 路径 | 说明 |
| --- | --- |
| [README.md](README.md) | 叙事文档索引 |
| [index.md](../index.md) | PL/PD 实例 SSOT |
| DESIGN（库外，纯文本） | 公司级实体定义 |
| naming-conventions（Agent 元知识） | ID 命名 SSOT |
