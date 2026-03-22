# product — 产品视角

本目录描述产品功能、用户故事与需求规格，并通过 ID 与其他视角建立映射。

- **统一元数据**：[product_meta.yaml](./product_meta.yaml) — 单文件 SSOT：`identity`、`repository`、`pipeline`、`integration`、`layers`（`key`: pl / pm / ft / uc）。

---

## 产品线索引表（示例）

下表按 **PL → PM → FT → UC** 链展开示例 ID；**层字段约定以 `product_meta.yaml` → `layers` 为准**；与 `PL-ECOMMERCE/`、`PM-SHOPPING-CART/` 等子目录（导航锚点）并列。实际项目请替换名称、ID。

| 链序 | 层级 | 类型 | 名称（示例） | ID（示例） | 元数据（YAML） | 说明 |
|:----:|------|------|--------------|------------|----------------|------|
| — | 索引 | 产品视角 | 产品视角（knowledge/product） | `DIR-KNOWLEDGE-PRODUCT` | [product_meta.yaml](./product_meta.yaml) | `identity` + `layers` + `integration` |
| L1 | 产品线 | PL | 电商平台 | `PL-ECOMMERCE` | 同上 · `key: pl` | 锚点目录 `{PL-ID}/` |
| L2 | 产品模块 | PM | 购物车模块 | `PM-SHOPPING-CART` | 同上 · `key: pm` | 隶属 `PL-ECOMMERCE`；`fields.relies_on_context_ids` |
| L3 | 功能 | FT | 加入购物车 | `FT-ADD-TO-CART` | 同上 · `key: ft` | `invokes_api_ids` 等 |
| L4 | 用例 | UC | 将商品加入购物车 | `UC-SHOPPING-001` | 同上 · `key: uc` | `map_to_api_id` |

---

## 文档与导航（示例）

| 产品线 | 产品模块 | 说明文档 |
|--------|----------|----------|
| [PL-ECOMMERCE](./PL-ECOMMERCE/) | [PM-SHOPPING-CART](./PL-ECOMMERCE/PM-SHOPPING-CART/) | [PRODUCT-OVERVIEW](./PL-ECOMMERCE/PRODUCT-OVERVIEW.md)、[FEATURE-MAP](./PL-ECOMMERCE/PM-SHOPPING-CART/FEATURE-MAP.md) 等 |

---

## 层级结构

```
产品线 (PL) → 产品模块 (PM) → 功能 (FT) → 用例 (UC)
```

- **产品线 / 产品模块 / 功能 / 用例**：字段模板见 **`product_meta.yaml` → `layers`**（按 `key` 或 `code` 查找）。
- **子目录** `{PL-ID}/{PM-ID}/`：作层级锚点，可放置概述、用户故事、功能地图等 Markdown；**不**再放置与根索引冲突的重复层级 meta。

---

## 关键字段（用于映射）

- **PM（产品模块）**：`relies_on_context_ids`（→ business BC）
- **FT（功能点）**：`invokes_api_ids`（→ technical API，来自应用级 manifest）、`realizes_use_case_ids`（→ product UC）
- **UC（用例）**：`map_to_api_id`（→ technical API，与 FT 的接口追溯对齐）

---

## 与其他视角的映射

- **产品 → 业务**：产品模块的 `relies_on_context_ids` 指向 business 的 BC。
- **产品 → 技术**：功能点的 `invokes_api_ids` 指向 technical 的 API（应用级 manifest 中登记）；用例的 `map_to_api_id` 指向具体 API。

系统索引：[../../INDEX.md](../../INDEX.md)；全库 Index Guide：[../../../INDEX_GUIDE.md](../../../INDEX_GUIDE.md)；设计：[../../DESIGN.md](../../DESIGN.md)。
