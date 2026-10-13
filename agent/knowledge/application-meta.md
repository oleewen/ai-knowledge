---
type: Perspective Meta
title: 应用视角元数据
---
# 应用视角元数据

> 本视角四层实体字段 SSOT。边动词语义见 [glossary.md](glossary.md)；层职责见 [knowledge-governance.md](knowledge-governance.md)。两处全文不抄。公共 frontmatter 与正文四段见 [okf-spec.md](okf-spec.md) §2；`layer_scope` 等于该实体首次定义层。ID 语法见 [naming-conventions.md](naming-conventions.md)。

## 1. 实体总表

| 实体 | 首次定义层 | 链 | id_pattern | 说明 |
| --- | --- | --- | --- | --- |
| — | 公司 | — | — | 企业应用架构标准。本层无首次定义。下层实体不涉及 |
| SLN | 解决方案 | L1 | `SLN-{NAME}` | 无 parent。一仓一 SLN |
| SYS | 系统 | L2 | `SYS-{NAME}` | parent 解决方案 SLN。SLN 不建本层文件，只写纯 ID |
| APP | 系统 | L3 | `APP-{NAME}` | parent SYS |
| MS | 系统 | L4 | `MS-{NAME}` | parent APP |
| API | 应用 | L5 | `API-{NNN}` 或 `API-{NAME}-{NNN}` | parent MS。SLN、SYS、APP、MS 不建本层文件，只写纯 ID |

## 2. 实体细则

无首次定义的层不设节。无 APP/SYS↔TPL 直连。

### SLN

| 项 | 值 |
| --- | --- |
| 层 | 解决方案 |
| id_pattern | `SLN-{NAME}` |
| 落盘 | 标准 `{ID}.md`。系统不登记。应用不落盘，纯 ID |
| 字段 | `maps_to` 必须，→ PL，1:1；`implemented_by` 必须 → BP、SYS（SYS 为纯 ID） |

### SYS

| 项 | 值 |
| --- | --- |
| 层 | 系统 |
| id_pattern | `SYS-{NAME}` |
| 落盘 | `SYS-{NAME}.md` 单文件。应用不落盘，纯 ID |
| 字段 | `implements_to`、`implemented_by` 必须，→ SLN、← APP；`maps_to` → PD；`uses_to` → MDG\|TSD |

### APP

| 项 | 值 |
| --- | --- |
| 层 | 系统 |
| id_pattern | `APP-{NAME}` |
| 落盘 | `APP-{NAME}/` 平铺（不强制收进 SYS 目录）。应用不落盘，纯 ID |
| 字段 | `implements_to`、`implemented_by` 必须，→ SYS、← MS；`supports_to` → BC；`uses_to` → DS\|MW（MW 为纯 ID） |

### MS

| 项 | 值 |
| --- | --- |
| 层 | 系统 |
| id_pattern | `MS-{NAME}` |
| 落盘 | 系统 `APP-{NAME}/MS-{NAME}/`。应用不落 MS 实体；`MS-{NAME}/` 可作 API 宿主目录 |
| 字段 | `implements_to` 必须，→ APP；`implemented_by` 必须 → API（纯 ID）；`maps_to` → AGG；`uses_to` → ENT |

对端镜像：`BC.supported_by`、`AGG.mapped_by`（MS）、`DS.used_by`、`ENT.used_by` 须与上表双向同步。

### API

| 项 | 值 |
| --- | --- |
| 层 | 应用 |
| id_pattern | `API-{NNN}` 或 `API-{NAME}-{NNN}` |
| 落盘 | `MS-EXAMPLE/API-*.md`。API 为叶子。系统不登记。实体 `{ID}.md` |
| 字段 | `implements_to` 必须；`supports_to`、`maps_to` 可选 |

别名、方法签名、入口类型写入 API 的详细说明，缺了不算失败。同 bundle 用相对路径。无 parent 时跨层只写实体 ID。

## 3. 跨视角出边

| 源.字段 | 目标 | 层 | 说明 |
| --- | --- | --- | --- |
| SLN.maps_to | PL.id | 解决方案 | 1:1 |
| SLN.implemented_by | BP.id | 解决方案 | 对端 BP.implements_to |
| SYS.uses_to | MDG.id \| TSD.id | 系统 | 声明使用的主数据域 / 技术域；可选 |
| SYS.maps_to | PD.id | 系统 | 系统对标产品服务（glossary）；可选 |
| APP.supports_to | BC.id | 系统 | 应用支撑限界上下文；可选 |
| APP.uses_to | DS.id \| MW.id | 系统 | 应用使用数据源或中间件（对端 DS.used_by / MW.used_by）；MW 为纯 ID |
| MS.maps_to | AGG.id | 系统 | 入口簇对标聚合；可选 |
| MS.uses_to | ENT.id | 系统 | 入口簇使用实体（对端 ENT.used_by） |
| BC.supported_by | APP.id | 系统 | 业务上下文由应用支撑；可选 |
| API.maps_to | UC.id | 应用 | 接口对标用例。用例再对标能力（UC → AB）；可选 |
| API.supports_to | FT.id | 应用 | 接口支撑功能点；可选 |

## 4. 层入口

| 层 | 入口 | 索引 |
| --- | --- | --- |
| 公司 | [README](../../company/knowledge/application/README.md) · [实体台账](../../company/knowledge/application/README.md#实体) | 本视角无实体 |
| 解决方案 | [README](../../solution/knowledge/application/README.md) · [实例索引](../../solution/knowledge/index.md) | — |
| 系统 | [README](../../system/knowledge/application/README.md) · [实例索引](../../system/knowledge/index.md) | — |
| 应用 | [实体台账](../../application/knowledge/application/README.md#实体) · [目录导航](../../application/knowledge/index.md) | `readme_index_table: true`；变更 ID 时同步 README、index.md、manifest/OpenAPI（按需） |
