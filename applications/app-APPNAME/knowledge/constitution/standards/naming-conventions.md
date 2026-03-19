> **模板示例**：本文件为知识库模板示例，实际项目请按需替换内容与 ID。

# ID 命名规范

知识库中所有**知识实体**必须拥有**全局唯一**的 ID，用于跨视角引用与追溯。本规范为必遵项。

---

## 1. 格式约定

- **通用格式**：`{TYPE}-{NAME}`，其中 `TYPE` 为下表所列前缀，`NAME` 为英文短名（建议大写+连字符）。
- **示例**：`BD-ORDER`、`BC-ORDER-MGMT`、`FT-ADD-TO-CART`、`APP-ORDER-SERVICE`、`ENT-T_ORDER`。

---

## 2. 各视角前缀一览

### 业务视角 (business)

| 前缀 | 英文全称 | 含义 |
|------|----------|------|
| BD- | Business Domain | 业务域 |
| BSD- | Business Subdomain | 业务子域 |
| BC- | Bounded Context | 限界上下文 |
| AGG- | Aggregate | 聚合根 |

### 产品视角 (product)

| 前缀 | 英文全称 | 含义 |
|------|----------|------|
| PL- | Product Line | 产品线 |
| PM- | Product Module | 产品模块 |
| FT- | Feature | 功能点 |
| UC- | Use Case | 用例 |
| BP- | Business Process | 业务流程 |
| BR- | Business Rule | 业务规则 |

### 技术视角 (technical)

| 前缀 | 英文全称 | 含义 |
|------|----------|------|
| SYS- | System | 系统 |
| APP- | Application | 应用（代码仓库/部署单元） |
| MS- | Microservice | 微服务 |
| API- | API Endpoint | 接口端点 |

### 数据视角 (data)

| 前缀 | 英文全称 | 含义 |
|------|----------|------|
| DS- | Data Store | 数据存储 |
| ENT- | Entity | 数据实体（表/集合） |

---

## 3. 文件与目录命名

- **目录**：与实体 ID 一致（如 `BD-ORDER`、`PL-ECOMMERCE`），或与 ID 中 NAME 部分对应（如 `order` 与 `BD-ORDER` 对应时，以 ID 为准在索引中查找）。
- **实体定义文件**：`{id}.yaml`，例如 `AGG-ORDER.yaml`、`FT-ADD-TO-CART.yaml`、`APP-ORDER-SERVICE.yaml`、`ENT-T_ORDER.yaml`。
- **元数据文件**：固定为 `_meta.yaml`，置于对应层级目录下。

---

## 4. 引用规则

- 跨文件、跨视角引用**只写 ID 字符串**，不写名称或路径。
- 例如：在聚合中写 `persisted_as_entity_ids: ["ENT-T_ORDER"]`，在功能中写 `invokes_api_ids: ["API-CART-ADD-ITEM"]`。

---

*本规范与仓库根目录 [DESIGN.md](../../../DESIGN.md) 中的「ID 命名规范」一致。*
