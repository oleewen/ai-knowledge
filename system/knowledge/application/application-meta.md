---
type: Perspective Meta
title: 应用视角元数据（system/knowledge/application）
---
# 应用视角元数据（system/knowledge/application）

系统级应用版图（SYS→APP→MS）视角元数据 SSOT。实例索引见 [../KNOWLEDGE-INDEX.md](../KNOWLEDGE-INDEX.md)。

---

## 1. 概览

| 字段 | 值 |
| --- | --- |
| meta_id | `DIR-SYSTEM-KNOWLEDGE-APPLICATION` |
| 视角 | application |
| 层级范围 | system |
| 说明 | 系统级服务拆分与集成边界；公司级 SYS 在 `company/knowledge/application/` 首次定义，本层 SYS 为视角根 reference，自 APP 起为系统 SSOT；API 在应用层首次定义。 |

---

## 2. 层级链

| 链序 | 层级代码 | 说明 |
| --- | --- | --- |
| 1 | SYS | 系统（公司层 SSOT；系统层为视角根 reference） |
| 2 | APP | 应用（代码仓库/部署单元，系统层首次定义） |
| 3 | MS | 对外入口宿主类聚类（系统层首次定义） |

---

## 3. 层定义

| order | key | code | id_pattern | parent |
| --- | --- | --- | --- | --- |
| 1 | sys | SYS | `SYS-{NAME}` | —（reference → company） |
| 2 | app | APP | `APP-{NAME}` | SYS |
| 3 | ms | MS | `MS-{NNN}` 或 `MS-{NAME}` | APP |

---

## 4. 必填字段

### 通用字段

| 字段 | 说明 |
| --- | --- |
| hierarchy | `SYS` / `APP` / `MS` |
| full_id | 规范 ID |
| name | 中文名称 |
| description | 实体描述 |
| evidence_source | 证据来源 |
| layer_scope | 固定为 `system` |

### 各层专属

| 层级 | 必填字段 |
| --- | --- |
| SYS | `definition_scope: reference`、`architecture`（apps / external_dependencies / ddd_layers）（上游 SSOT 见 # SSOT 段） |
| APP | `parent_sys_id`、`startup_class`、`maven_module`、`service_ids` |
| MS | `host_class`、`host_module`、`protocol` |

---

## 5. 跨层路径映射（MS/API 分层差异化）

application 层与 system 层 MS/API 落盘路径 **intentionally 不同**；跨层对照以本表为准，不强制文件搬迁。

> **架构登记约定**：system 层 MS 嵌于 `APP-{NAME}/MS-{NAME}.md` 为架构登记惯例；application 层 MS 为独立目录，二者 intentionally 不同。

| 实体 | system 路径 | application 路径 | 说明 |
|------|-------------|-------------------|------|
| SYS-EXAMPLE | `system/knowledge/application/SYS-EXAMPLE.md` | `application/knowledge/application/SYS-EXAMPLE.md` | 均为视角根 reference |
| APP-EXAMPLE | `system/knowledge/application/APP-EXAMPLE/APP-EXAMPLE.md` | `application/knowledge/application/APP-EXAMPLE.md` | system 有 APP 锚点目录 |
| MS-EXAMPLE | `system/knowledge/application/APP-EXAMPLE/MS-EXAMPLE.md` | `application/knowledge/application/MS-EXAMPLE/MS-EXAMPLE.md` | system 嵌于 APP；application 独立 MS 目录 |
| API-EXAMPLE-001 | （system 不登记） | `application/knowledge/application/MS-EXAMPLE/API-EXAMPLE-001.md` | API 仅 application SSOT |

**链接约定**：同 bundle 用 `/knowledge/...`；跨 bundle `# SSOT` 用仓库根相对路径。

---

## 6. 跨视角引用

| 源字段 | 目标 | 说明 |
| --- | --- | --- |
| SYS（reference） | company SYS.full_id | 上游公司 SSOT |
| BC.implemented_by_app_id | APP.full_id | 业务上下文实现 |
| DS.owned_by_app_id | APP.full_id | 数据源归属 |
| 应用层 AB.apis / API | API.id | 接口端点（下游引用） |

---

## 7. 关联文档

| 路径 | 说明 |
| --- | --- |
| [README.md](README.md) | 叙事文档索引 |
| [../KNOWLEDGE-INDEX.md](../KNOWLEDGE-INDEX.md) | SYS/APP/MS 实例 SSOT |
| [../../DESIGN.md](../../DESIGN.md) | 系统库设计契约 |
| [../../../company/knowledge/application/application-meta.md](../../../company/knowledge/application/application-meta.md) | 公司级 SYS 元数据 |
| [../../../agent/knowledge/naming-conventions.md](../../../agent/knowledge/naming-conventions.md) | ID 命名 SSOT |

**索引**：`readme_index_table: false`；变更 ID 时同步 KNOWLEDGE-INDEX.md 与 narrative 章节（按需）。
