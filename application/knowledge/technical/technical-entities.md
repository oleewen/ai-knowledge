# 技术视角实体索引（application/knowledge/technical）

> **示例占位，非生产数据。** 字段定义见 [technical-meta.md](technical-meta.md)。

---

## 索引说明

| 字段 | 值 |
| --- | --- |
| schema_version | 2.1（语义等价） |
| perspective | technical |
| layer_scope | application |
| confidence | example |

---

## 实体总表

| hierarchy | full_id | name | description | binding_type | config_key | parent_tsd_id | bound_app_id | maven_coordinates | parent_mw_id | evidence_source |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| MW | MW-EXAMPLE | 示例中间件绑定 | 仅用于演示技术视角 MW 数据结构（示例）。 | kafka | example.kafka.topic | TSD-MIDDLEWARE | APP-EXAMPLE | — | — | application.yml（示例） |
| CMP | CMP-EXAMPLE | 示例组件 | 仅用于演示技术视角 CMP 数据结构（示例）。 | — | — | — | — | org.example:example-client:1.0.0 | MW-EXAMPLE | pom.xml（示例） |

---

## 统计

| 指标 | 值 |
| --- | --- |
| total_mw | 1 |
| total_cmp | 1 |
| total_entities | 2 |
| extraction_basis | 示例占位 |
| schema_notes | 应用层仅登记 MW/CMP；TPL/TSD 见公司/系统层 technical-entities.md |
