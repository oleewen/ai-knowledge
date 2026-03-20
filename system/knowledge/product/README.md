# product — 产品视角

本目录描述产品功能、用户故事与需求规格，并通过 ID 与其他视角建立映射。

- **产品视角索引**：[product_meta.yaml](./product_meta.yaml)（本目录说明与索引约定）。

---

## 产品线索引表（示例）

下表按 **PL → PM → FT** 链展开示例 ID；**PL / PM / FT 的元数据 YAML 均在本目录根目录**，与 `PL-ECOMMERCE/`、`PM-SHOPPING-CART/` 等子目录（导航锚点，可含 FEATURE-MAP 等文档）并列。实际项目请替换名称、ID。

| 链序 | 层级 | 类型 | 名称（示例） | ID（示例） | 元数据（YAML） | 说明 |
|:----:|------|------|--------------|------------|----------------|------|
| — | 索引 | 产品视角 | 产品视角（knowledge/product） | `DIR-KNOWLEDGE-PRODUCT` | [product_meta.yaml](./product_meta.yaml) | 本视角目录说明、输入输出与索引约定 |
| L1 | 产品线 | PL | 电商平台 | `PL-ECOMMERCE` | [PL_meta.yaml](./PL_meta.yaml) | 锚点目录 `{PL-ID}/` |
| L2 | 产品模块 | PM | 购物车模块 | `PM-SHOPPING-CART` | [PM_meta.yaml](./PM_meta.yaml) | 隶属 `PL-ECOMMERCE`，锚点 `{PL-ID}/{PM-ID}/`；`relies_on_context_ids` 见 YAML |
| L3 | 功能 | FT | 加入购物车 | `FT-ADD-TO-CART` | [FT_meta.yaml](./FT_meta.yaml) | 验收标准与 `invokes_api_ids` 等 |

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

- **产品线 / 产品模块 / 功能**：元数据分别为 **`PL_meta.yaml`、`PM_meta.yaml`、`FT_meta.yaml`**（位于本目录根）。
- **子目录** `{PL-ID}/{PM-ID}/`：作层级锚点，可放置概述、用户故事、功能地图等 Markdown；**不**再放置与根目录重复的层级目录索引 `*_meta.yaml`。

---

## 关键字段（用于映射）

- **PM（产品模块）**：`relies_on_context_ids`（→ business BC）
- **FT（功能点）**：`invokes_api_ids`（→ technical API，来自应用级 manifest）、`realizes_use_case_ids`（如使用）

---

## 与其他视角的映射

- **产品 → 业务**：产品模块的 `relies_on_context_ids` 指向 business 的 BC。
- **产品 → 技术**：功能点的 `invokes_api_ids` 指向 technical 的 API（应用级 manifest 中登记）。

系统索引：[../../INDEX.md](../../INDEX.md)；全库 Index Guide：[../../../INDEX.md](../../../INDEX.md)；设计：[../../DESIGN.md](../../DESIGN.md)。
