# business — 业务视角

本目录描述业务版图与领域规则（DDD），不依赖具体技术实现。

---

## 层级结构

```
业务域 (BD) → 业务子域 (BSD) → 限界上下文 (BC) → 聚合 (AGG)
```

- **业务视角索引**：[business_meta.yaml](./business_meta.yaml)（本目录说明与索引约定）。
- **业务域**：如订单域、用户域，目录 `{BD-ID}/` 作层级锚点；元数据为 **`BD_meta.yaml`**。
- **业务子域**：域下子划分，如订单履约，目录 `{BSD-ID}/` 作锚点；元数据为 **`BSD_meta.yaml`**。
- **限界上下文**：DDD 边界与统一语言，目录 `{BC-ID}/` 作锚点；元数据为 **`BC_meta.yaml`**。
- **聚合**：以聚合根为核心的一致性边界，元数据为 **`AGG_meta.yaml`**。

### 业务索引表（示例）

下表按 **BD → BSD → BC → AGG** 链展开示例 ID；元数据文件均在本目录根目录，与上文「业务视角索引 / BD / BSD / BC / AGG」文件名一致。实际项目请替换名称、ID，并在需要时为 `{BD-ID}/{BSD-ID}/{BC-ID}/` 建立目录锚点。

| 链序 | 层级 | 类型 | 名称（示例） | ID（示例） | 元数据（YAML） | 说明 |
|:----:|------|------|--------------|------------|----------------|------|
| — | 索引 | 业务视角 | 业务视角（knowledge/business） | `DIR-KNOWLEDGE-BUSINESS` | [business_meta.yaml](./business_meta.yaml) | 本视角目录说明、输入输出与索引约定 |
| L1 | 业务域 | BD | 订单域 | `BD-ORDER` | [BD_meta.yaml](./BD_meta.yaml) | 锚点目录 `{BD-ID}/`；订单相关核心业务 |
| L2 | 业务子域 | BSD | 履约子域 | `BSD-FULFILLMENT` | [BSD_meta.yaml](./BSD_meta.yaml) | 隶属 `BD-ORDER`，锚点 `{BD-ID}/{BSD-ID}/`；履约与配送 |
| L3 | 限界上下文 | BC | 订单管理上下文 | `BC-ORDER-MGMT` | [BC_meta.yaml](./BC_meta.yaml) | 隶属上一链，锚点 `{BD-ID}/{BSD-ID}/{BC-ID}/`；统一语言见 YAML |
| L4 | 聚合 | AGG | 订单聚合 | `AGG-ORDER` | [AGG_meta.yaml](./AGG_meta.yaml) | 聚合根与不变量；`persisted_as_entity_ids` 映射 data |

---

## 关键字段（用于映射）

- **BC（限界上下文）**：`implemented_by_app_id`（→ technical APP）
- **AGG（聚合）**：`persisted_as_entity_ids`（→ data ENT）

---

## 与其他视角的映射

- **业务 → 技术**：限界上下文的 `implemented_by_app_id` 指向 technical 的 APP。
- **业务 → 数据**：聚合的 `persisted_as_entity_ids` 指向 data 的 ENT。

系统索引：[../../INDEX.md](../../INDEX.md)；全库 Index Guide：[../../../INDEX.md](../../../INDEX.md)；设计：[../../DESIGN.md](../../DESIGN.md)。
