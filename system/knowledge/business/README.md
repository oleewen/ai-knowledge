# business — 业务视角

本目录描述**业务版图、领域逻辑与规则**，不依赖具体技术实现。与产品、技术、数据视角通过 ID 显式关联。

---

## 业务索引表

| 类型   | 名称         | ID            | 路径                                                              | 说明                      |
|--------|--------------|---------------|-------------------------------------------------------------------|---------------------------|
| 业务域 | 订单         | BD-ORDER      | [BD-ORDER](./BD-ORDER/)                                           | 订单相关核心业务           |
| 子域   | 履约         | BSD-FULFILLMENT | [BSD-FULFILLMENT](./BD-ORDER/BSD-FULFILLMENT/)                  | 订单履约、配送等            |
| 限界上下文 | 订单管理     | BC-ORDER-MGMT | [BC-ORDER-MGMT](./BD-ORDER/BSD-FULFILLMENT/BC-ORDER-MGMT/)        | 订单生命周期管理            |
| 聚合   | 订单         | AGG-ORDER     | [AGG-ORDER](./BD-ORDER/BSD-FULFILLMENT/BC-ORDER-MGMT/aggregates/AGG-ORDER.yaml) | 聚合根-订单，一致性边界     |


---

## 层级结构

```
业务域 (BD) → 业务子域 (BSD) → 限界上下文 (BC) → 聚合 (AGG)
```

- **业务域**：如订单域、用户域，目录 `{BD-ID}/`，含 `_meta.yaml`。
- **业务子域**：域下子划分，如订单履约，目录 `{BSD-ID}/`，含 `_meta.yaml`。
- **限界上下文**：DDD 边界与统一语言，目录 `{BC-ID}/`，含 `_meta.yaml` 与 `aggregates/`。
- **聚合**：以聚合根为核心的一致性边界，文件 `aggregates/{AGG-ID}.yaml`。

---

## 元数据约定

### _meta.yaml 常用字段

| 层级 | 建议字段 | 说明 |
|------|----------|------|
| 业务域 | id, name, description, owner, strategic_classification | strategic_classification 可选：core_domain / supporting_domain / generic_domain |
| 子域 | id, name, description, domain_expert | |
| 限界上下文 | id, name, description, ubiquitous_language, implemented_by_app_id | **implemented_by_app_id**：实现该上下文的 technical 应用 ID |

### 聚合 YAML 常用字段

- `id`, `name`, `description`, `root_entity`, `entities`, `invariants`
- **persisted_as_entity_ids**：持久化到的 data 数据实体 ID 列表（核心映射）

---

## 与其他视角的映射

- **业务 → 技术**：限界上下文的 `implemented_by_app_id` 指向 technical 的 APP。
- **业务 → 数据**：聚合的 `persisted_as_entity_ids` 指向 data 的 ENT。

更多见仓库根目录 [INDEX.md](../../INDEX.md) 与 [DESIGN.md](../../DESIGN.md)。
