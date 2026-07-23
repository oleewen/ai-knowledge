---
type: Perspective Meta
title: 应用视角元数据（system/knowledge/application）
---
# 应用视角元数据（system/knowledge/application）

系统级应用版图（SYS→APP→MS）视角元数据 SSOT。实例索引：[../index.md](../index.md)。

---

## 1. 概览

| 字段 | 值 |
| --- | --- |
| meta_id | `DIR-SYSTEM-KNOWLEDGE-APPLICATION` |
| 视角 | application |
| 层级范围 | system |
| 说明 | 系统级服务拆分与集成边界；SYS 为 company reference，自 APP 起为本层 SSOT；API 在应用层首次定义。 |

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
| 3 | ms | MS | `MS-{NAME}` | APP |

---

## 4. 字段（OKF）

Frontmatter 10 必填 + 正文四段（`## 关系` · `## 跨视角` · `## 详细说明` · `## 依据与证据`）见 [okf-spec](../../../agent/knowledge/okf-spec.md) §2；本层 `layer_scope` 固定 `system`。

### 各层专属（正文 / 扩展）

| 层级 | 字段 | 建议段落 |
| --- | --- | --- |
| SYS | `definition_scope: reference`、`architecture` | FM 扩展 / 详细说明 |
| APP | `parent_sys_id`、`service_ids`、`startup_class`、`maven_module` | 关系 / 详细说明 |
| MS | `host_class`、`host_module`、`protocol` | 详细说明 |

---

## 5. 跨层路径映射（MS/API）

MS 路径三层同构：`MS-{NAME}/MS-{NAME}.md`。APP 在 system 为目录锚点，在 application 可为视角根单文件。

| 实体 | system 路径 | application 路径 | 说明 |
|------|-------------|-------------------|------|
| SYS-EXAMPLE | `system/knowledge/application/SYS-EXAMPLE.md` | `application/knowledge/application/SYS-EXAMPLE.md` | company reference |
| APP-EXAMPLE | `system/knowledge/application/APP-EXAMPLE/APP-EXAMPLE.md` | `application/knowledge/application/APP-EXAMPLE.md` | system SSOT；app 可为实例 |
| MS-EXAMPLE | `system/knowledge/application/MS-EXAMPLE/MS-EXAMPLE.md` | `application/knowledge/application/MS-EXAMPLE/MS-EXAMPLE.md` | 同构；system SSOT |
| API-EXAMPLE-001 | （system 不登记） | `application/knowledge/application/MS-EXAMPLE/API-EXAMPLE-001.md` | API 仅 application SSOT |

**链接约定**：同 bundle 用 `/knowledge/...`；跨层（如 system→application API/TBL/MW/CMP）用仓库相对路径，勿写他层不存在的 bundle-absolute `/knowledge/...`。

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
| [../index.md](../index.md) | SYS/APP/MS 实例 SSOT |
| [../../DESIGN.md](../../DESIGN.md) | 系统库设计契约 |
| [../../../company/knowledge/application/application-meta.md](../../../company/knowledge/application/application-meta.md) | 公司级 SYS 元数据 |
| [../../../agent/knowledge/naming-conventions.md](../../../agent/knowledge/naming-conventions.md) | ID 命名 SSOT |

**索引**：`readme_index_table: false`；变更 ID 时同步 index.md 与 narrative 章节（按需）。
