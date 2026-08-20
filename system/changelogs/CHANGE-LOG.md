---
type: Change Log
title: CHANGE-LOG
---
# CHANGE-LOG

本文件为 `system/` 侧**维护性变更与文档聚合**的 Markdown 日志入口。

## 2026-08-20

### 变更摘要

**system MS 改挂 parent APP 目录：**

- 样例：`system/knowledge/application/APP-EXAMPLE/MS-EXAMPLE/`
- `entity_relpath(bundle=system, MS)` 用 `parent_id`；缺则报错
- 约定：`application-meta`、`naming-conventions`、`system/DESIGN.md`；application 层 MS 仍平铺

<!-- change_time=2026-08-20 00:00:00 -->

## 2026-07-18

### 变更摘要

**对齐三层实体分治与演示链（grilling 共识落盘）：**

- 短契约：`system/DESIGN.md` / `README.md` / `INDEX-GUIDE.md`；五视角 README 精简
- §2.2.1 + naming 增补 **FR**；MS 路径同构 `MS-EXAMPLE/`；MW 系统侧降为 reference
- SDD EXAMPLE：`SOLUTION` / `ANALYSIS` / `REQUIREMENT…/MVP-Phase-1` 骨架
- fixtures：`UC-EXAMPLE` 统一；`okf_lib` / `generate_knowledge_index` 同步
- 同伴：`application/INDEX-GUIDE` frontmatter；application 侧 MS SSOT 路径注释
- `knowledge/**/chapters/` 33 章压成 company 短章；修正 SSOT 相对路径（`../../../../company/…`）
- `generate_knowledge_index` 不再写入 `knowledge/index.md` frontmatter（OKF §6）；重生后 WARN 消除
- 跨层 API 链改为仓库相对路径（UC/FT/AB → `application/.../API-EXAMPLE-001.md`）；`validate system` 0 WARN
- `validate_bundle`：system/company 绝对 `/knowledge/…` 本层缺失时回退查下游 bundle

<!-- change_time=2026-07-18 00:00:00 -->

## 2026-04-25 09:30:00（时间示例）

### 变更摘要

**变更点：**

- 变更点1

<!-- change_time=2026-04-26 00:00:00 -->
