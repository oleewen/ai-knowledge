---
type: Perspective Meta
title: 业务视角元数据（company/knowledge/business）
---
# 业务视角元数据（company/knowledge/business）

公司级 VC / BD / 一级 BSD / CAP 视角元数据 SSOT。实例索引：[index.md](../index.md)。

---

## 1. 概览

| 字段 | 值 |
| --- | --- |
| meta_id | `DIR-COMPANY-KNOWLEDGE-BUSINESS` |
| 视角 | business |
| 层级范围 | company |
| 说明 | BA：VC→CAP 能力目录 ∥ BD 域模型；一级 BSD 桥接 CAP 与 PL。 |

---

## 2. 层级链

| 链序 | 层级代码 | 说明 |
| --- | --- | --- |
| 1 | VC | 价值链（能力目录根） |
| 2 | BD | 业务域（支撑 VC） |
| 3 | 一级 BSD | 业务子域（`level: 1`；挂 BD；对标 PL） |
| 4 | CAP | 业务能力（实现 VC；一对一映射一级 BSD） |

---

## 3. 层定义

| order | key | code | id_pattern | parent |
| --- | --- | --- | --- | --- |
| 1 | vc | VC | `VC-{NAME}` | — |
| 2 | bd | BD | `BD-{NAME}` | —（平铺单文件） |
| 3 | bsd1 | BSD | `BSD-{NAME}` | BD（`level: 1`） |
| 4 | cap | CAP | `CAP-{NAME}` | VC（经 `implements_to_vc`，非 `parent_id`） |

目录：`VC-{NAME}/VC-{NAME}.md` + `VC-{NAME}/CAP-*.md`；`BD-{NAME}.md`、一级 `BSD-{NAME}.md` 平铺。

---

## 4. 字段（OKF）

Frontmatter 10 必填 + 正文四段见 okf-spec §2；本层 `layer_scope` 固定 `company`。

| 层级 | 字段 | 说明 |
| --- | --- | --- |
| VC | `supported_by_bd`、`implemented_by_cap` | 均为列表必填；与 BD/CAP 双向同步 |
| BD | `supports_to_vc`、`children` | 单值必填；列表必填；children 仅一级 BSD |
| 一级 BSD | `level`、`parent`、`maps_to_pl`、`maps_to_cap` | 固定 `1`；均单值必填 |
| CAP | `implements_to_vc`、`maps_to_bsd` | 均单值必填；目标必须为一级 BSD |
| BD | `strategic_classification` | 正文扩展 |

---

## 5. 跨视角引用

| 源字段 | 目标 | 说明 |
| --- | --- | --- |
| CAP.implements_to_vc | VC.id | CAP 实现价值链 |
| CAP.maps_to_bsd | 一级 BSD.id | CAP 与一级 BSD 一对一映射 |
| BD.supports_to_vc | VC.id | BD 支撑价值链 |
| 一级 BSD.maps_to_pl | PL.id | 一级 BSD 对标产品线 |

---

## 6. 关联文档

| 路径 | 说明 |
| --- | --- |
| [README.md](README.md) | 叙事文档索引 |
| [index.md](../index.md) | VC/BD/一级 BSD/CAP 实例 SSOT |
| naming-conventions（Agent 元知识） | ID 命名 SSOT |
