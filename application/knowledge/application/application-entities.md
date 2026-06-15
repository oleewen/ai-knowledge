# 应用视角实体索引（application/knowledge/application）

> **示例占位，非生产数据。** 字段定义见 [application-meta.md](application-meta.md)。

---

## 索引说明

| 字段 | 值 |
| --- | --- |
| schema_version | 2.1（语义等价） |
| perspective | application |
| layer_scope | application |
| confidence | example |

---

## SYS

| full_id | name | description | architecture_summary | evidence_source |
| --- | --- | --- | --- | --- |
| SYS-EXAMPLE | 示例系统 | 仅用于演示应用视角数据结构（示例）。 | APP-EXAMPLE; 外部依赖 ExternalExample/HTTP; DDD 四层 | 示例数据 |

---

## APP

| full_id | parent_sys_id | name | startup_class | maven_module | service_ids | repo_url | docs_manifest_path | evidence_source |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| APP-EXAMPLE | SYS-EXAMPLE | 示例应用 | ExampleApp | example-module | MS-EXAMPLE | git@example.com:org/example.git | /application/manifest.yaml | 示例数据 |

---

## MS

| id | name | host_class | host_module | protocol | cross_references | evidence_source |
| --- | --- | --- | --- | --- | --- | --- |
| MS-EXAMPLE | 示例微服务 | ExampleApiImpl | example-module | HTTP | BC-EXAMPLE; PM-EXAMPLE; API-EXAMPLE-001 | 示例数据 |

---

## API

| id | name | service_id | alias | host_class | host_module | method_signature | evidence_source |
| --- | --- | --- | --- | --- | --- | --- | --- |
| API-EXAMPLE-001 | 示例 API：创建 | MS-EXAMPLE | ExampleService.create | ExampleApiImpl | example-module | create(ExampleReq req) | 示例数据 |

---

## 统计

| 指标 | 值 |
| --- | --- |
| total_systems | 1 |
| total_applications | 1 |
| total_services | 1 |
| total_apis | 1 |
| total_entities | 4 |
| extraction_basis | 示例数据（非从代码/文档提取） |
