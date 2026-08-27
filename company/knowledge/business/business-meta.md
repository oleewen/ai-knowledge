---
type: Perspective Meta
title: 业务视角元数据（company/knowledge/business）
---
# 业务视角元数据（company/knowledge/business）

公司级 BD / CAP 视角元数据 SSOT。实例索引：[index.md](../index.md)。

---

## 1. 概览

| 字段 | 值 |
| --- | --- |
| meta_id | `DIR-COMPANY-KNOWLEDGE-BUSINESS` |
| 视角 | business |
| 层级范围 | company |
| 说明 | 公司级业务域与 L1/L2/L3 能力目录；系统/应用引用 BD/CAP ID，不重复字段语义。 |

---

## 2. 层级链

| 链序 | 层级代码 | 说明 |
| --- | --- | --- |
| 1 | BD | 公司级业务域 |
| 2 | CAP | 公司级业务能力目录（L1/L2/L3，`level` + `parent_id` 树形） |

---

## 3. 层定义

| order | key | code | id_pattern | parent |
| --- | --- | --- | --- | --- |
| 1 | bd | BD | `BD-{NAME}` | — |
| 2 | cap | CAP | `CAP-{NAME}` | CAP（L2/L3 的 `parent_id` 指向上级 CAP；L1 为空） |

---

## 4. 字段（OKF）

Frontmatter 10 必填 + 正文四段（`## 关系` · `## 跨视角` · `## 详细说明` · `## 依据与证据`）见 okf-spec §2；本层 `layer_scope` 固定 `company`。

### BD / CAP 专属（正文）

| 层级 | 字段 | 建议段落 |
| --- | --- | --- |
| BD | `strategic_classification`（`core_domain` / `supporting` / `generic`） | 详细说明 |
| CAP | `level`（L1/L2/L3）、`parent_id`（L1 可空）、`maps_to_bd_id`（推荐） | 关系 / 跨视角 |

---

## 5. 跨视角引用

| 源字段 | 目标 | 说明 |
| --- | --- | --- |
| CAP.maps_to_bd_id | BD.full_id | 能力归属业务域 |
| 系统层 maps_to_cap_ids | CAP.full_id | 系统能力映射到公司级 CAP（下游引用，不在此定义） |

---

## 6. 关联文档

| 路径 | 说明 |
| --- | --- |
| [README.md](README.md) | 叙事文档索引 |
| [index.md](../index.md) | BD/CAP 实例 SSOT |
| DESIGN（库外，纯文本） | 公司级实体定义 |
| naming-conventions（Agent 元知识） | ID 命名 SSOT |
