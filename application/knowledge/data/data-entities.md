# 数据视角实体索引（application/knowledge/data）

> **示例占位，非生产数据。** 字段定义见 [data-meta.md](data-meta.md)。

---

## 索引说明

| 字段 | 值 |
| --- | --- |
| schema_version | 2.1（语义等价） |
| perspective | data |
| layer_scope | application |
| confidence | example |

---

## 实体总表

| hierarchy | full_id | name | description | parent_id | type | config_key | owned_by_app_id | logical_name | physical_table | maps_to_aggregate_id | evidence_source |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| DS | DS-EXAMPLE | 示例数据源 | 仅用于演示数据视角数据结构（示例）。 | — | ExampleDB | example_config_key | APP-EXAMPLE | — | — | — | 示例数据 |
| ENT | ENT-EXAMPLE | 示例实体 | — | DS-EXAMPLE | — | — | — | ExampleEntity | example_table | AGG-EXAMPLE | 示例数据 |

---

## 统计

| 指标 | 值 |
| --- | --- |
| total_datasources | 1 |
| total_entities | 1 |
| total_items | 2 |
| extraction_basis | 示例数据（非从代码/文档提取） |
