---
type: Perspective Meta
title: 产品视角元数据（system/knowledge/product）
---
# 产品视角元数据（system/knowledge/product）

系统级产品版图（PL→PD→PM→FT→FR→UC/BR · BP）视角元数据 SSOT。实例索引：[index.md](../index.md)。

---

## 1. 概览

| 字段 | 值 |
| --- | --- |
| meta_id | `DIR-SYSTEM-KNOWLEDGE-PRODUCT` |
| 视角 | product |
| 层级范围 | system |
| 说明 | 系统级产品功能组织；PL/PD 为公司 SSOT（本层不落 PL/PD 文件）；自 PM 起为本层 SSOT；应用层承接 API / 验收映射。引用公司 PD：有 parent 则 HTTP，否则纯 ID。 |

---

## 2. 层级链

| 链序 | 层级代码 | 说明 |
| --- | --- | --- |
| 1 | PL | 产品线（公司层 SSOT；本层不落盘） |
| 2 | PD | 产品 / 解决方案（公司层 SSOT；本层不落盘） |
| 3 | PM | 产品模块（系统层首次定义） |
| 4 | FT | 功能点（系统层首次定义） |
| 5 | FR | 功能需求（系统层首次定义） |
| 6 | UC / BR | 用例 / 业务规则（系统层首次定义；挂 FR） |
| 7 | BP | 业务流程（系统层首次定义；可挂 PD/PM，非 FR 子树） |

---

## 3. 层定义

| order | key | code | id_pattern | parent |
| --- | --- | --- | --- | --- |
| 1 | pl | PL | `PL-{NAME}` | —（公司 SSOT） |
| 2 | pd | PD | `PD-{NAME}` | PL（公司 SSOT） |
| 3 | pm | PM | `PM-{NAME}` | PD（只许 PD） |
| 4 | ft | FT | `FT-{NAME}` | PM |
| 5 | fr | FR | `FR-{NAME}` | FT |
| 6 | uc | UC | `UC-{NAME}` | FR |
| 7 | br | BR | `BR-{NAME}` | FR |
| 8 | bp | BP | `BP-{NAME}` | PD / PM（可选） |

空节点：系统出现对某 `PD-*` 的引用时，宜已有或即将有本系统 PM。

---

## 4. 字段（OKF）

Frontmatter 10 必填 + 正文四段（`## 关系` · `## 跨视角` · `## 详细说明` · `## 依据与证据`）见 okf-spec §2；本层 `layer_scope` 固定 `system`。

### 各层专属（正文 / 扩展）

| 层级 | 字段 | 建议段落 |
| --- | --- | --- |
| PM | `relies_on_context_ids`、`depends_pm_ids` | 跨视角 / 关系 |
| FT | `acceptance_criteria`、`realizes_use_case_ids`（`invokes_api_ids` 多在应用层） | 详细说明 / 跨视角 |
| FR | （UC/BR 子链） | 关系 |
| UC | `map_to_api_id`（推荐；可应用层补全） | 跨视角 |
| BR | （按需） | 跨视角 / 详细说明 |
| BP | 旁路流程叙事；`parent_id` 可选 PD/PM | 关系 |

`depends_pm_ids`：消费方 PM 声明依赖的其它 PM（同 PD 或跨 PD）；主属仍唯一 `parent_id → PD`。

---

## 5. 跨视角引用

| 源字段 | 目标 | 说明 |
| --- | --- | --- |
| PM.parent_id | 公司 PD.full_id | 模块归属产品（HTTP 或纯 ID） |
| PM.depends_pm_ids | PM.full_id | 模块依赖其它模块 |
| PM.relies_on_context_ids | BC.full_id | 模块依赖限界上下文 |
| FT.realizes_use_case_ids | UC.full_id | 功能实现用例 |
| 应用层 FT.invokes_api_ids | API.full_id | 功能调用 API（下游引用） |

---

## 6. 关联文档

| 路径 | 说明 |
| --- | --- |
| [README.md](README.md) | 叙事文档索引 |
| [index.md](../index.md) | PM/FT/FR/UC/BR/BP 实例 SSOT |
| DESIGN（库外，纯文本） | 系统库设计契约 |
| 公司 PD-* | 产品 SSOT（不落本层文件） |
| naming-conventions（Agent 元知识） | ID 命名 SSOT |

**索引**：`readme_index_table: false`；变更 ID 时同步 index.md 与 narrative 章节（按需）。
