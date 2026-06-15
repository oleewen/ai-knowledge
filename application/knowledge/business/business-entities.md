# 业务视角实体索引（application/knowledge/business）

> **示例占位，非生产数据。** 字段定义见 [business-meta.md](business-meta.md)。

---

## 索引说明

| 字段 | 值 |
| --- | --- |
| schema_version | 2.1（语义等价） |
| perspective | business |
| layer_scope | application |
| confidence | example |

---

## 实体总表

| hierarchy | full_id | name | description | parent_id | strategic_classification | children | bounded_contexts | implemented_by_app_id | aggregates | root_entity | persisted_as_entity_ids | implemented_by_service_ids | abilities | capability | apis | evidence_source |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| BD | BD-EXAMPLE | 示例业务域 | 仅用于演示业务视角数据结构（示例）。 | — | supporting_domain | BSD-EXAMPLE | — | — | — | — | — | — | — | — | — | 示例数据 |
| BSD | BSD-EXAMPLE | 示例业务子域 | 仅用于演示业务视角数据结构（示例）。 | BD-EXAMPLE | — | — | BC-EXAMPLE | — | — | — | — | — | — | — | — | 示例数据 |
| BC | BC-EXAMPLE | 示例限界上下文 | 仅用于演示业务视角数据结构（示例）。 | BSD-EXAMPLE | — | — | — | APP-EXAMPLE | AGG-EXAMPLE | — | — | — | — | — | — | 示例数据 |
| AGG | AGG-EXAMPLE | 示例聚合 | 仅用于演示业务视角数据结构（示例）。 | BC-EXAMPLE | — | — | — | — | — | ExampleRoot | ENT-EXAMPLE | MS-EXAMPLE | AB-EXAMPLE | — | — | 示例数据 |
| AB | AB-EXAMPLE | 示例能力 | 仅用于演示业务视角数据结构（示例）。 | AGG-EXAMPLE | — | — | — | — | — | — | — | — | — | 示例能力描述 | API-EXAMPLE-001 / Example.create | 示例数据 |

---

## 统计

| 指标 | 值 |
| --- | --- |
| total_business_domains | 1 |
| total_business_subdomains | 1 |
| total_bounded_contexts | 1 |
| total_aggregates | 1 |
| total_abilities | 1 |
| total_entities | 5 |
| extraction_basis | 示例数据（非从代码/文档提取） |
