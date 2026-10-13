---
type: Perspective Meta
title: 技术视角元数据
---
# 技术视角元数据

> 本视角四层实体字段 SSOT。边动词语义见 [glossary.md](glossary.md)；层职责见 [knowledge-governance.md](knowledge-governance.md)。两处全文不抄。公共 frontmatter 与正文四段见 [okf-spec.md](okf-spec.md) §2；`layer_scope` 等于该实体首次定义层。ID 语法见 [naming-conventions.md](naming-conventions.md)。

## 1. 实体总表

| 实体 | 首次定义层 | 链 | id_pattern | 说明 |
| --- | --- | --- | --- | --- |
| TPL | 公司 | L1 | `TPL-{NAME}` | 无 parent。公司级平台能力目录（云 / DevOps / 安全 / 开发环境 / 可观测） |
| TSD | 解决方案 | L2 | `TSD-{NAME}` | `implements_to` 公司 TPL，非 parent。TPL 不建本层文件，只写纯 ID |
| — | 系统 | — | — | 本层无首次定义。TPL、TSD 不建本层文件，只写纯 ID。本层不写 TSD 的边。下层实体不涉及 |
| MW | 应用 | L3 | `MW-{NAME}` | parent TSD（逻辑归属，`implements_to`）。TPL、TSD 不建本层文件，只写纯 ID |
| CMP | 应用 | L4 | `CMP-{NAME}` | parent MW |

## 2. 实体细则

无首次定义的层不设节。无 APP↔CMP、APP↔TPL 直连。

### TPL

| 项 | 值 |
| --- | --- |
| 层 | 公司 |
| id_pattern | `TPL-{NAME}` |
| 落盘 | 标准 `{ID}.md` |
| 字段 | `domain`：能力域为云基础设施 / DevOps / 安全 / 开发环境 / 可观测。`implemented_by` 必须 → TSD（纯 ID） |

### TSD

| 项 | 值 |
| --- | --- |
| 层 | 解决方案 |
| id_pattern | `TSD-{NAME}` |
| 落盘 | 标准 `{ID}.md` |
| 字段 | `implements_to` → 公司 TPL；`implemented_by` 必须 → MW（纯 ID）；`used_by` 可选 → SYS（纯 ID） |

组成边写在关系段。

### MW

| 项 | 值 |
| --- | --- |
| 层 | 应用 |
| id_pattern | `MW-{NAME}` |
| 落盘 | 标准 `{ID}.md`。实体 `{ID}.md` |
| 字段 | `implements_to` 必须 → TSD；`implemented_by` → CMP；`used_by` → APP；`uses_to` → DS |

绑定类型、配置键写入 MW 的详细说明，缺了不算失败。

### CMP

| 项 | 值 |
| --- | --- |
| 层 | 应用 |
| id_pattern | `CMP-{NAME}` |
| 落盘 | 标准 `{ID}.md`。实体 `{ID}.md` |
| 字段 | `maven_coordinates`、`implements_to`（详细说明 / 关系） |

## 3. 跨视角出边

解决方案：组成边写在关系段，不在此表。系统层不落 TSD 文件；`used_by` 写在解决方案 TSD 上。边在其首次定义层书写。

| 源.字段 | 目标 | 层 | 说明 |
| --- | --- | --- | --- |
| TSD.used_by | SYS.id | 解决方案 | 对端 SYS.uses_to；可选；纯 ID |
| MW.used_by | APP.id | 应用 | 被应用使用 |
| MW.uses_to | DS.id | 应用 | 中间件使用数据源（可选） |

## 4. 层入口

| 层 | 入口 | 索引 |
| --- | --- | --- |
| 公司 | [README](../../company/knowledge/technical/README.md) · [实体台账](../../company/knowledge/technical/README.md#实体) | — |
| 解决方案 | [README](../../solution/knowledge/technical/README.md) · [实例索引](../../solution/knowledge/index.md) | — |
| 系统 | [README](../../system/knowledge/technical/README.md) · [目录索引](../../system/knowledge/index.md) | `readme_index_table: false`；变更 TSD ID 时同步 index/overview（按需） |
| 应用 | [实体台账](../../application/knowledge/technical/README.md#实体) · [目录导航](../../application/knowledge/index.md) | `readme_index_table: true`；变更 ID 时同步 README、index.md（按需） |
