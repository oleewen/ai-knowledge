# business — 业务视角

本目录描述业务版图与领域规则（DDD），并通过 ID 与其他视角建立映射。

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

## 关键字段（用于映射）

- **BC（限界上下文）**：`implemented_by_app_id`（→ 本应用的 technical APP）
- **AGG（聚合）**：`persisted_as_entity_ids`（→ 本应用的 data ENT）

---

## 与其他视角的映射

- **业务 → 技术**：限界上下文的 `implemented_by_app_id` 指向 technical 的 APP。
- **业务 → 数据**：聚合的 `persisted_as_entity_ids` 指向 data 的 ENT。

更多见仓库根目录 [INDEX.md](../../../INDEX.md) 与系统设计说明 [system/DESIGN.md](../../../system/DESIGN.md)。
