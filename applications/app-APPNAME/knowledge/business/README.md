# business — 业务视角

本目录描述业务版图与领域规则（DDD），不依赖具体技术实现。

---

## 层级结构

```
业务域 (BD) → 业务子域 (BSD) → 限界上下文 (BC) → 聚合 (AGG) → 能力 (AB)
```

- **统一元数据**：[business_meta.yaml](./business_meta.yaml) — 单文件 SSOT，包含：
  - **`identity` / `role`**：视角身份；
  - **`repository`**：目录锚点与 `directory_patterns`；
  - **`pipeline`**：全视角共享的阶段 **inputs**（不在各层重复）；
  - **`integration`**：跨视角 **cross_perspective** 边与 **key_fields**；
  - **`layers`**：DDD 各层一条记录（`key` / `code` / `id_pattern` / `fields` / `tree` / `artifacts` / `indexing`）。
- **按层查阅**：在 `layers` 数组中按 **`key`**（`bd` … `ab`）或 **`code`**（`BD` … `AB`）定位；例如 BC 层字段见 **`layers` 中 `key: bc` 的 `fields`**。

### 业务索引表（示例）

下表按 **BD → BSD → BC → AGG → AB** 链展开示例 ID；约定均见 [business_meta.yaml](./business_meta.yaml) 的 **`layers`**。实际项目请替换名称、ID，并在需要时为 `{BD-ID}/{BSD-ID}/{BC-ID}/` 等建立目录锚点。

| 链序 | 层级 | 类型 | 名称（示例） | ID（示例） | 元数据（YAML） | 说明 |
|:----:|------|------|--------------|------------|----------------|------|
| — | 索引 | 业务视角 | 业务视角（knowledge/business） | `DIR-KNOWLEDGE-BUSINESS` | [business_meta.yaml](./business_meta.yaml) | `identity` + `layers` + `integration` |
| L1 | 业务域 | BD | 订单域 | `BD-ORDER` | 同上 · `layers` → `key: bd` | 锚点目录 `{BD-ID}/`；订单相关核心业务 |
| L2 | 业务子域 | BSD | 履约子域 | `BSD-FULFILLMENT` | 同上 · `key: bsd` | 隶属 `BD-ORDER`，锚点 `{BD-ID}/{BSD-ID}/`；履约与配送 |
| L3 | 限界上下文 | BC | 订单管理上下文 | `BC-ORDER-MGMT` | 同上 · `key: bc` | 隶属上一链；`fields.implemented_by_app_id` |
| L4 | 聚合 | AGG | 订单聚合 | `AGG-ORDER` | 同上 · `key: agg` | `fields.persisted_as_entity_ids` 等 |
| L5 | 能力 | AB | 取消订单能力 | `AB-CANCEL-ORDER` | 同上 · `key: ab` | `fields.implemented_by_api_id` |

---

## 关键字段（用于映射）

- **BC（限界上下文）**：`implemented_by_app_id`（→ technical APP）
- **AGG（聚合）**：`persisted_as_entity_ids`（→ data ENT）
- **AB（能力）**：`implemented_by_api_id`（→ technical API）

（字段说明以 `business_meta.yaml` → `layers[].fields` 与 `integration.key_fields` 为准。）

---

## 与其他视角的映射

- **业务 → 技术**：见 `integration.cross_perspective`（BC/AGG/AB → APP/MS/API）。
- **业务 → 数据**：AGG → ENT，见同段与 `DESIGN.md` 映射表。

系统索引：[../../INDEX.md](../../INDEX.md)；全库 Index Guide：[../../../INDEX.md](../../../INDEX.md)；设计：[../../DESIGN.md](../../DESIGN.md)。
