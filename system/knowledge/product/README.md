> **模板示例**：本文件为知识库模板示例，实际项目请按需替换内容与 ID。

# product — 产品视角

本目录描述产品功能、用户故事与需求规格，并通过 ID 与其他视角建立映射。

---

## 产品线索引


| 产品线                             | 产品模块                                                 | 功能点                                                                            |
| ------------------------------- | ---------------------------------------------------- | ------------------------------------------------------------------------------ |
| [PL-ECOMMERCE](./PL-ECOMMERCE/) | [PM-SHOPPING-CART](./PL-ECOMMERCE/PM-SHOPPING-CART/) | [FT-ADD-TO-CART](./PL-ECOMMERCE/PM-SHOPPING-CART/features/FT-ADD-TO-CART.yaml) |


---

## 层级结构

```
产品线 (PL) → 产品模块 (PM) → 功能 (FT) → 用例 (UC)
```

- **产品线**：如电商平台、商家平台，目录 `{PL-ID}/`，含 `_meta.yaml`。
- **产品模块**：如购物车、订单中心，目录 `{PM-ID}/`，含 `_meta.yaml` 与 `features/`。
- **功能点**：可交付的功能，文件 `features/{FT-ID}.yaml`。
- **用例**：可在功能中通过 `realizes_use_case_ids` 引用，或独立维护。

---

## 关键字段（用于映射）

- **PM（产品模块）**：`relies_on_context_ids`（→ business BC）
- **FT（功能点）**：`invokes_api_ids`（→ technical API，来自应用级 manifest）、`realizes_use_case_ids`（如使用）

---

## 与其他视角的映射

- **产品 → 业务**：产品模块的 `relies_on_context_ids` 指向 business 的 BC。
- **产品 → 技术**：功能点的 `invokes_api_ids` 指向 technical 的 API（应用级 manifest 中登记）。

更多见仓库根目录 [INDEX.md](../../INDEX.md) 与 [DESIGN.md](../../DESIGN.md)。