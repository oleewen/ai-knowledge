---
type: Perspective Meta
title: 业务视角元数据（company/knowledge/business）
---
# 业务视角元数据（company/knowledge/business）

公司级 BU / BD / CAP 视角元数据 SSOT。实例索引：[index.md](../index.md)。

---

## 1. 概览

| 字段 | 值 |
| --- | --- |
| meta_id | `DIR-COMPANY-KNOWLEDGE-BUSINESS` |
| 视角 | business |
| 层级范围 | company |
| 说明 | BA 两张图：BU→CAP（能力目录）∥ BD（域模型）；CAP 经 `maps_to_bd_id` 桥接提供域。 |

---

## 2. 层级链

| 链序 | 层级代码 | 说明 |
| --- | --- | --- |
| 1a | BU | 业务单元（能力目录根） |
| 1b | BD | 业务域（与 BU 平行；对标 PL） |
| 2 | CAP | 业务能力（`parent_id→BU`；`maps_to_bd_id→BD`） |

---

## 3. 层定义

| order | key | code | id_pattern | parent |
| --- | --- | --- | --- | --- |
| 1 | bu | BU | `BU-{NAME}` | — |
| 2 | bd | BD | `BD-{NAME}` | —（平铺单文件） |
| 3 | cap | CAP | `CAP-{NAME}` | BU |

目录：`BU-{NAME}/BU-{NAME}.md` + `BU-{NAME}/CAP-*.md`；`BD-{NAME}.md` 平铺。

---

## 4. 字段（OKF）

Frontmatter 10 必填 + 正文四段见 okf-spec §2；本层 `layer_scope` 固定 `company`。

| 层级 | 字段 | 说明 |
| --- | --- | --- |
| BD | `maps_to_pl_id` | **必填**；与 PL 同建 1:1 |
| CAP | `maps_to_bd_id` | **必填**；一 CAP 一 BD |
| BD | `strategic_classification` | 正文扩展 |

---

## 5. 跨视角引用

| 源字段 | 目标 | 说明 |
| --- | --- | --- |
| CAP.parent_id | BU.full_id | 能力归属业务单元 |
| CAP.maps_to_bd_id | BD.full_id | 能力由哪个域提供 |
| BD.maps_to_pl_id | PL.full_id | 域对标产品线 |

---

## 6. 关联文档

| 路径 | 说明 |
| --- | --- |
| [README.md](README.md) | 叙事文档索引 |
| [index.md](../index.md) | BU/BD/CAP 实例 SSOT |
| naming-conventions（Agent 元知识） | ID 命名 SSOT |
