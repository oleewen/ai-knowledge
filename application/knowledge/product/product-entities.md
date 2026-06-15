# 产品视角实体索引（application/knowledge/product）

> **示例占位，非生产数据。** 字段定义见 [product-meta.md](product-meta.md)。

---

## 索引说明

| 字段 | 值 |
| --- | --- |
| schema_version | 2.1（语义等价） |
| perspective | product |
| layer_scope | application |
| confidence | example |

---

## 实体总表

| hierarchy | full_id | name | description | parent_id | target_users | invokes_api_ids | acceptance_criteria | realizes_use_case_ids | map_to_api_id | evidence_source |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| PL | PL-EXAMPLE | 示例产品线 | 仅用于演示产品视角数据结构（示例）。 | — | 示例用户 | — | — | — | — | 示例数据 |
| PM | PM-EXAMPLE | 示例产品模块 | — | PL-EXAMPLE | — | — | — | — | — | 示例数据 |
| FT | FT-EXAMPLE | 示例功能 | 仅用于演示产品视角数据结构（示例）。 | PM-EXAMPLE | — | API-EXAMPLE-001 | 示例验收标准A; 示例验收标准B | UC-EXAMPLE-001 | — | 示例数据 |
| UC | UC-EXAMPLE-001 | 示例用例 | 仅用于演示产品视角数据结构（示例）。 | PM-EXAMPLE | — | — | — | — | API-EXAMPLE-001 | 示例数据 |

---

## 统计

| 指标 | 值 |
| --- | --- |
| total_products | 1 |
| total_modules | 1 |
| total_features | 1 |
| total_use_cases | 1 |
| total_entities | 4 |
| extraction_basis | 示例数据（非从代码/文档提取） |
