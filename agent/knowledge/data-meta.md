---
type: Perspective Meta
title: 数据视角元数据
---
# 数据视角元数据

> 本视角四层实体字段 SSOT。边动词语义见 [glossary.md](glossary.md)；层职责见 [knowledge-governance.md](knowledge-governance.md)。两处全文不抄。公共 frontmatter 与正文四段见 [okf-spec.md](okf-spec.md) §2；`layer_scope` 等于该实体首次定义层。ID 语法见 [naming-conventions.md](naming-conventions.md)。

## 1. 实体总表

| 实体 | 首次定义层 | 链 | id_pattern | 说明 |
| --- | --- | --- | --- | --- |
| — | 公司 | — | — | 企业数据架构标准。本层无首次定义。下层实体不涉及 |
| MDG | 解决方案 | L1 | `MDG-{NAME}` | 无 parent。一 SLN 可多条 |
| DS | 系统 | L2 | `DS-{NAME}` | parent MDG（逻辑归属，`implements_to`）。MDG 不建本层文件，只写纯 ID |
| ENT | 系统 | L3 | `ENT-{NNN}` 或 `ENT-{NAME}` | parent DS |
| TBL | 应用 | L4 | `TBL-{NAME}` | parent ENT（`implements_to`）。MDG、DS、ENT 不建本层文件，只写纯 ID |

## 2. 实体细则

无首次定义的层不设节。

### MDG

| 项 | 值 |
| --- | --- |
| 层 | 解决方案 |
| id_pattern | `MDG-{NAME}` |
| 落盘 | 标准 `{ID}.md`。系统不在本层首次 |
| 字段 | 无 parent。`implemented_by` 必须 → DS（纯 ID）；`used_by` 可选 → SYS（纯 ID） |

### DS

| 项 | 值 |
| --- | --- |
| 层 | 系统 |
| id_pattern | `DS-{NAME}` |
| 落盘 | `DS-{NAME}/` 含 DS/ENT |
| 字段 | `implements_to` 必须 → MDG；`implemented_by` 必须 → ENT；`used_by` 可选 → APP\|MW |

存储类型、配置键写入 DS 的详细说明，缺了不算失败。

### ENT

| 项 | 值 |
| --- | --- |
| 层 | 系统 |
| id_pattern | `ENT-{NNN}` 或 `ENT-{NAME}` |
| 落盘 | `DS-{NAME}/` 之下 |
| 字段 | `implements_to` 必须 → DS；`implemented_by` 必须 → TBL（纯 ID）；`maps_to` → AGG；`used_by` → MS |

类名、物理表名写入 ENT 的详细说明，缺了不算失败。

### TBL

| 项 | 值 |
| --- | --- |
| 层 | 应用 |
| id_pattern | `TBL-{NAME}` |
| 落盘 | 标准 `{ID}.md`。实体 `{ID}.md` |
| 字段 | `implements_to`（关系） |

物理表名写入 TBL 的详细说明，缺了不算失败。

## 3. 跨视角出边

解决方案：MDG 写对端纯 ID。下层不在本层建文件。

| 源.字段 | 目标 | 层 | 说明 |
| --- | --- | --- | --- |
| SYS.uses_to | MDG.id | 系统 | 系统声明使用的主数据域；可选 |
| DS.used_by | APP.id \| MW.id | 系统 | 数据源被应用或中间件使用（对端 APP.uses_to / MW.uses_to）；可选 |
| ENT.maps_to | AGG.id | 系统 | 实体对标聚合；可选 |
| ENT.used_by | MS.id | 系统 | 对端 MS.uses_to |
| MDG.used_by | SYS.id | 解决方案 | 对端 SYS.uses_to；可选；纯 ID |
| MDG（纯 ID） | solution MDG.id | 应用 | 上游解决方案 SSOT |

## 4. 层入口

| 层 | 入口 | 索引 |
| --- | --- | --- |
| 公司 | [README](../../company/knowledge/data/README.md) · [实体台账](../../company/knowledge/data/README.md#实体) | 本视角无实体 |
| 解决方案 | [README](../../solution/knowledge/data/README.md) · [实例索引](../../solution/knowledge/index.md) | — |
| 系统 | [README](../../system/knowledge/data/README.md) · [实例索引](../../system/knowledge/index.md) | `readme_index_table: false`；变更 ID 时同步 index.md 与 narrative（按需） |
| 应用 | [实体台账](../../application/knowledge/data/README.md#实体) · [目录导航](../../application/knowledge/index.md) | `readme_index_table: true`；变更 ID 时同步 README、index.md（按需） |
