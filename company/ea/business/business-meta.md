# 业务视角元数据（company/ea/business）

公司级业务域（BD）与业务能力目录（CAP）的视角元数据 SSOT。实例索引见 [business-entities.md](business-entities.md)。

---

## 1. 概览

| 字段 | 值 |
| --- | --- |
| meta_id | `DIR-COMPANY-EA-BUSINESS` |
| 视角 | business |
| 层级范围 | company |
| 说明 | 公司级业务域划分与 L1/L2/L3 能力目录；系统/应用层引用 BD/CAP ID，不重复字段语义。 |

---

## 2. 层级链

| 链序 | 层级代码 | 说明 |
| --- | --- | --- |
| 1 | BD | 公司级业务域 |
| 2 | CAP | 公司级业务能力目录（L1/L2/L3，通过 `level` 与 `parent_id` 表达树形） |

---

## 3. 层定义

| order | key | code | id_pattern | parent |
| --- | --- | --- | --- | --- |
| 1 | bd | BD | `BD-{NAME}` | — |
| 2 | cap | CAP | `CAP-{NAME}` | CAP（L2/L3 的 `parent_id` 指向上级 CAP；L1 为空） |

---

## 4. 必填字段

### 通用字段（BD、CAP 均须）

| 字段 | 说明 |
| --- | --- |
| hierarchy | 层级标识：`BD` 或 `CAP` |
| full_id | 规范 ID，如 `BD-CHARGING-APPEAL` |
| name | 中文名称 |
| description | 实体描述 |
| evidence_source | 证据来源（叙事文档或章节，如 `business-domain-division.md`） |

### BD 专属

| 字段 | 说明 |
| --- | --- |
| strategic_classification | 战略分类：`core_domain` / `supporting` / `generic` |

### CAP 专属

| 字段 | 说明 |
| --- | --- |
| level | 能力层级：`L1` / `L2` / `L3` |
| parent_id | 上级 CAP 的 `full_id`；L1 留空 |
| maps_to_bd_id | 关联业务域 BD 的 `full_id`（推荐） |

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
| [business-entities.md](business-entities.md) | BD/CAP 实例 SSOT |
| [../../DESIGN.md](../../DESIGN.md) | 公司级实体定义 |
| [../../../agent/knowledge/naming-conventions.md](../../../agent/knowledge/naming-conventions.md) | ID 命名 SSOT |
