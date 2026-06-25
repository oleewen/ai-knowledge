---
type: Perspective Meta
title: 应用视角元数据（application/knowledge/application）
---
# 应用视角元数据（application/knowledge/application）

应用侧实现版图（SYS→APP→MS→API）实体登记与接口实现元数据。实例索引见 [../KNOWLEDGE-INDEX.md](../KNOWLEDGE-INDEX.md)（§3，扫描生成；实体文件 `{ID}.md` 为 SSOT）。

---

## 1. 概览

| 字段 | 值 |
| --- | --- |
| meta_id | `DIR-KNOWLEDGE-APPLICATION` |
| 视角 | application |
| 层级范围 | application |
| 说明 | 实现版图；公司级 SYS 在 `company/knowledge/application/` 首次定义，系统层自 APP 起首次定义，本层重点登记 API 与应用实现映射（示例含 SYS/APP/MS/API）。 |
| entities_shape | 实体文件 `{ID}.md`（OKF 概念实体）；索引见 KNOWLEDGE_INDEX §3 |

---

## 2. 层级链

| 链序 | 层级代码 | 说明 |
| --- | --- | --- |
| 1 | SYS | 系统（公司层首次定义） |
| 2 | APP | 应用（代码仓库/部署单元，系统层首次定义） |
| 3 | MS | 对外入口宿主类聚类（系统层首次定义） |
| 4 | API | 接口端点（HTTP/Dubbo/MQ/Job，应用层首次定义） |

---

## 3. 层定义

| order | key | code | id_pattern | parent |
| --- | --- | --- | --- | --- |
| 1 | sys | SYS | `SYS-{NAME}` | — |
| 2 | app | APP | `APP-{NAME}` | SYS |
| 3 | ms | MS | `MS-{NNN}` 或 `MS-{NAME}` | APP |
| 4 | api | API | `API-{NNN}` 或 `API-{NAME}-{NNN}` | MS |

---

## 4. 必填字段

### 通用字段

| 字段 | 说明 |
| --- | --- |
| hierarchy | `SYS` / `APP` / `MS` / `API` |
| full_id 或 id | 规范 ID（API 可用 `id` 字段） |
| name | 中文名称 |
| description | 实体描述 |
| evidence_source | 证据来源 |
| layer_scope | 固定为 `application` |

### 各层专属

| 层级 | 必填字段 |
| --- | --- |
| SYS | `architecture`（apps / external_dependencies / ddd_layers） |
| APP | `parent_sys_id`、`startup_class`、`maven_module`、`service_ids` |
| MS | `host_class`、`host_module`、`protocol` |
| API | `service_id`、`alias`、`method_signature`、`api_type`（DUBBO/HTTP/MQ/JOB） |

---

## 5. 跨层路径映射（MS/API 分层差异化）

application 层与 system 层 MS/API 落盘路径 **intentionally 不同**；跨层对照以本表为准，不强制文件搬迁。

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
| BC.implemented_by_app_id | APP.full_id | 业务上下文实现 |
| AB.apis[].id | API.id | 能力 API |
| FT.invokes_api_ids | API.id | 产品功能调用 |
| DS.owned_by_app_id | APP.full_id | 数据源归属 |

---

## 7. 关联文档

| 路径 | 说明 |
| --- | --- |
| [README.md](README.md) | 人类可读说明 |
| [../KNOWLEDGE-INDEX.md](../KNOWLEDGE-INDEX.md) | §3 应用视角实例索引（扫描生成） |
| [../KNOWLEDGE-INDEX.md](../KNOWLEDGE-INDEX.md) | 五视角索引 |

**索引**：`readme_index_table: true`；变更 ID 时同步 README、KNOWLEDGE-INDEX.md、manifest/OpenAPI（按需）。
