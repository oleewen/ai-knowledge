# 知识库 · 四视角实体 ID 索引（SSOT）

> 本文件仅保留示例，用于演示四视角索引结构与字段形状。

---

## 统一表头规范

- **标准表头**：`["层级","ID","别名（英文名）","名称","证据链"]`
- **字段语义**：`ID` 为示例编码，`别名（英文名）` 为英文编码，`名称` 为中文名称
- **唯一性约束**：`层级+ID` 全知识库唯一；`层级+别名（英文名）` 全知识库唯一

---

## §1 业务视角（business · BD → BSD → BC → AGG → AB）

| 层级 | ID | 别名（英文名） | 名称 | 证据链 |
|------|----|--------------|------|---------|
| BD | EXAMPLE | ExampleBusinessDomain | 示例业务域 | `business/business_knowledge.json`（示例） |
| BSD | EXAMPLE | ExampleBusinessSubdomain | 示例业务子域 | `business/business_knowledge.json`（示例） |
| BC | EXAMPLE | ExampleBoundedContext | 示例限界上下文 | `business/business_knowledge.json`（示例） |
| AGG | EXAMPLE | ExampleAggregate | 示例聚合 | `business/business_knowledge.json`（示例） |
| AB | EXAMPLE | ExampleAbility | 示例能力 | `business/business_knowledge.json`（示例） |

---

## §2 产品视角（product · PL → PM → FT → UC）

| 层级 | ID | 别名（英文名） | 名称 | 证据链 |
|------|----|--------------|------|---------|
| PL | EXAMPLE | ExampleProductLine | 示例产品线 | `product/product_knowledge.json`（示例） |
| PM | EXAMPLE | ExampleProductModule | 示例产品模块 | `product/product_knowledge.json`（示例） |
| FT | EXAMPLE | ExampleFeature | 示例功能 | `product/product_knowledge.json`（示例） |
| UC | EXAMPLE | ExampleUseCase | 示例用例 | `product/product_knowledge.json`（示例） |

---

## §3 技术视角（technical · SYS → APP → MS → API）

| 层级 | ID | 别名（英文名） | 名称 | 证据链 |
|------|----|--------------|------|---------|
| SYS | EXAMPLE | ExampleSystem | 示例系统 | `technical/technical_knowledge.json`（示例） |
| APP | EXAMPLE | ExampleApp | 示例应用 | `technical/technical_knowledge.json`（示例） |
| MS | EXAMPLE | ExampleService | 示例微服务 | `technical/technical_knowledge.json`（示例） |
| API | EXAMPLE-001 | ExampleService.create | 示例 API | `technical/technical_knowledge.json`（示例） |

---

## §4 数据视角（data · DS → ENT）

| 层级 | ID | 别名（英文名） | 名称 | 证据链 |
|------|----|--------------|------|---------|
| DS | EXAMPLE | ExampleDatasource | 示例数据源 | `data/data_knowledge.json`（示例） |
| ENT | EXAMPLE | ExampleEntity | 示例实体 | `data/data_knowledge.json`（示例） |

---

## 物化目录映射（示例）

| 索引 ID | 命名式 ID（锚点目录） |
|---------|----------------------|
| BD-EXAMPLE | `business/BD-EXAMPLE/` |
| PL-EXAMPLE | `product/PL-EXAMPLE/` |
| SYS-EXAMPLE | `technical/SYS-EXAMPLE/` |
| DS-EXAMPLE | `data/DS-EXAMPLE/` |

---

## 交叉引用

- 技术：`technical/technical_knowledge.json`
- 业务：`business/business_knowledge.json`
- 产品：`product/product_knowledge.json`
- 数据：`data/data_knowledge.json`
- 知识库总说明：`README.md`
