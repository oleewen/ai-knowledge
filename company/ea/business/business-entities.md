# 业务视角实体索引（company/ea/business）

> **示例占位，非生产数据。** 字段定义见 [business-meta.md](business-meta.md)。

---

## 索引说明

| 字段 | 值 |
| --- | --- |
| schema_version | 2.1（语义等价） |
| perspective | business |
| layer_scope | company |
| confidence | example |

---

## 实体总表

| hierarchy | full_id | name | description | strategic_classification | level | parent_id | maps_to_bd_id | evidence_source |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| BD | BD-EXAMPLE | 示例业务域 | 仅用于演示公司级 BD 数据结构。 | core_domain | — | — | — | business-domain-division.md（示例） |
| CAP | CAP-EXAMPLE-L1 | 示例一级能力 | 仅用于演示 CAP L1 占位。 | — | L1 | — | BD-EXAMPLE | business-capability.md（示例） |
| CAP | CAP-EXAMPLE | 示例二级能力 | 仅用于演示 CAP L2 与 parent_id 关系。 | — | L2 | CAP-EXAMPLE-L1 | BD-EXAMPLE | business-capability.md（示例） |

---

## 统计

| 指标 | 值 |
| --- | --- |
| total_bd | 1 |
| total_cap | 2 |
| total_entities | 3 |
| extraction_basis | 示例占位 |
