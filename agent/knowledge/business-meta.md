---
type: Perspective Meta
title: 业务视角元数据
---
# 业务视角元数据

> 本视角四层实体字段 SSOT。边动词语义见 [glossary.md](glossary.md)；层职责见 [knowledge-governance.md](knowledge-governance.md)。两处全文不抄。公共 frontmatter 与正文四段见 [okf-spec.md](okf-spec.md) §2；`layer_scope` 等于该实体首次定义层。ID 语法见 [naming-conventions.md](naming-conventions.md)。

## 1. 实体总表

无首次定义的层占一行。企业标准写在说明列。

| 实体 | 首次定义层 | 链 | id_pattern | 说明 |
| --- | --- | --- | --- | --- |
| VC | 公司 | 能力链 L1 | `VC-{NAME}` | 无 parent |
| CAP | 公司 | 能力链 L2 | `CAP-{NAME}` | `implements_to` VC，非同类树 parent |
| BD | 公司 | 域模型 L1 | `BD-{NAME}` | 无 parent |
| BSD-L1 | 公司 | 域模型 L2 | `BSD-{NAME}` | `level: 1`；parent BD |
| BL | 公司 | 不进链 | `BL-{NAME}` | 无 parent；`maps_to` BSD-L1 一对一 |
| BSD-L2 | 解决方案 | 域模型 L3 | `BSD-{NAME}-L2` | parent 公司 BSD-L1；`level: 2`。BD、BSD-L1 不建本层文件，只写纯 ID |
| BS | 解决方案 | 不进域模型链 | `BS-{NAME}` | 无 parent；`maps_to` BSD-L2，1:1 |
| BSD-L3 | 系统 | 域模型 L4 | `BSD-{NAME}-L3` | parent BSD-L2；`level: 3`。BD、BSD-L1、BSD-L2 不建本层文件，只写纯 ID |
| BC | 系统 | L5 | `BC-{NAME}` | parent BSD-L3 |
| AGG | 系统 | L6 | `AGG-{NAME}` | parent BC |
| AB | 系统 | L7 | `AB-{NAME}` | parent AGG |
| — | 应用 | — | — | 本层无首次定义。VC、CAP、BD、BSD-L1、BL、BSD-L2、BS、BSD-L3、BC、AGG、AB 不建本层文件，只写纯 ID |

## 2. 实体细则

无首次定义的层不设节。

### VC

| 项 | 值 |
| --- | --- |
| 层 | 公司 |
| id_pattern | `VC-{NAME}` |
| 落盘 | `VC-{NAME}/VC-{NAME}.md`，其下 `CAP-*.md` |
| 字段 | `supported_by`、`implemented_by` 可选 |

### CAP

| 项 | 值 |
| --- | --- |
| 层 | 公司 |
| id_pattern | `CAP-{NAME}` |
| 落盘 | `VC-{NAME}/CAP-*.md` |
| 字段 | `implements_to` 必须；`mapped_by` 可选 |

### BD

| 项 | 值 |
| --- | --- |
| 层 | 公司 |
| id_pattern | `BD-{NAME}` |
| 落盘 | `BD-{NAME}/BD-{NAME}.md`，其下 `BSD-*.md`。解决方案不落 BD、BSD-L1。系统不落 BD、BSD-L1、BSD-L2 文件 |
| 字段 | `children` 必须，仅 BSD-L1；`supports_to` 可选 |

### BSD-L1

| 项 | 值 |
| --- | --- |
| 层 | 公司 |
| id_pattern | `BSD-{NAME}` |
| 落盘 | `BD-{NAME}/BSD-*.md` |
| 字段 | `level` 固定 `1`，必须；`parent` 必须；`maps_to`、`mapped_by` 可选 |

### BL

| 项 | 值 |
| --- | --- |
| 层 | 公司 |
| id_pattern | `BL-{NAME}` |
| 落盘 | `BL/BL-{NAME}.md`（单文件） |
| 字段 | `maps_to` 必须，一对一 |

### BSD-L2

| 项 | 值 |
| --- | --- |
| 层 | 解决方案 |
| id_pattern | `BSD-{NAME}-L2` |
| 落盘 | 标准 `{ID}.md` |
| 字段 | `parent`、`mapped_by` 写在关系段。`parent` 必须，→ 公司 BSD-L1；`mapped_by` 可选，→ BS |

### BS

| 项 | 值 |
| --- | --- |
| 层 | 解决方案 |
| id_pattern | `BS-{NAME}` |
| 落盘 | 标准 `{ID}.md` |
| 字段 | `maps_to` 写在关系段，→ BSD-L2，1:1 |

### BSD-L3

| 项 | 值 |
| --- | --- |
| 层 | 系统 |
| id_pattern | `BSD-{NAME}-L3` |
| 落盘 | `knowledge/business/BSD-{L3}/BSD-{L3}.md`（例：`BSD-EXAMPLE-L3/`）；其下 BC→AGG→AB。公司 BD 落 `BD-{NAME}.md`。解决方案不落 BD、BSD-L1。系统不落 BD、BSD-L1、BSD-L2 文件 |
| 字段 | `level` 固定 `3`，与 `parent` 必须；`implemented_by` 可选 |

### BC

| 项 | 值 |
| --- | --- |
| 层 | 系统 |
| id_pattern | `BC-{NAME}` |
| 落盘 | BSD-L3 目录之下 |
| 字段 | `implements_to`、`implemented_by` 必须；`supported_by` 可选 |

### AGG

| 项 | 值 |
| --- | --- |
| 层 | 系统 |
| id_pattern | `AGG-{NAME}` |
| 落盘 | BSD-L3 目录之下 |
| 字段 | `implements_to`、`implemented_by` 必须；`mapped_by` 可选 |

### AB

| 项 | 值 |
| --- | --- |
| 层 | 系统 |
| id_pattern | `AB-{NAME}` |
| 落盘 | BSD-L3 目录之下 |
| 字段 | `implements_to` 必须；`mapped_by` 可选 |

能力概述写入 AB 的详细说明，缺了不算失败。

## 3. 跨视角出边

公司：组成边和同类树写在关系段。解决方案：同视角对标写在关系段。应用：不在本文件写。

| 源.字段 | 目标 | 层 | 说明 |
| --- | --- | --- | --- |
| BC.supported_by | APP.id | 系统 | 上下文由应用支撑（对端 APP.supports_to）；可选 |
| AGG.mapped_by | ENT.id \| MS.id | 系统 | 对端 ENT.maps_to / MS.maps_to；可选 |
| AB.mapped_by | UC.id | 系统 | 对端 UC.maps_to；可选 |

## 4. 层入口

| 层 | 入口 | 索引 |
| --- | --- | --- |
| 公司 | [README](../../company/knowledge/business/README.md) · [实体台账](../../company/knowledge/business/README.md#实体) | — |
| 解决方案 | [README](../../solution/knowledge/business/README.md) · [实例索引](../../solution/knowledge/index.md) | — |
| 系统 | [README](../../system/knowledge/business/README.md) · [实例索引](../../system/knowledge/index.md) | `readme_index_table: false`；变更 ID 时同步 index.md 与 narrative（按需） |
| 应用 | [实体台账](../../application/knowledge/business/README.md#实体) · [目录导航](../../application/knowledge/index.md) | `readme_index_table: true`；变更 ID 时同步 README、index.md（按需） |
