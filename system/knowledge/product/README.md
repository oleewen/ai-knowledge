# product — 产品视角

本目录描述**产品功能、用户故事与需求规格**。与业务、技术、数据视角通过 ID 显式关联。

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

## 元数据约定

### _meta.yaml 常用字段


| 层级   | 建议字段                                                      | 说明                                                    |
| ---- | --------------------------------------------------------- | ----------------------------------------------------- |
| 产品线  | id, name, description, target_users, product_owner        |                                                       |
| 产品模块 | id, name, description, module_type, relies_on_context_ids | **relies_on_context_ids**：依赖的 business 限界上下文 ID 列表 |


### 功能点 YAML 常用字段

- `id`, `name`, `description`, `priority`, `status`, `acceptance_criteria`
- **invokes_api_ids**：调用的 technical API ID 列表（核心映射）
- **realizes_use_case_ids**：实现的用例 ID 列表

---

## 与其他视角的映射

- **产品 → 业务**：产品模块的 `relies_on_context_ids` 指向 business 的 BC。
- **产品 → 技术**：功能点的 `invokes_api_ids` 指向 technical 的 API（应用级 manifest 中登记）。

更多见仓库根目录 [INDEX.md](../../INDEX.md) 与 [DESIGN.md](../../DESIGN.md)。