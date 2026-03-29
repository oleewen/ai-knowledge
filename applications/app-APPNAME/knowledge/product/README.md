# product — 产品视角

本目录描述产品功能、用户故事与需求规格，并通过 ID 与其他视角建立映射。

- **统一元数据**：[applications/app-APPNAME/knowledge/product/product_meta.yaml](product_meta.yaml) — 单文件 SSOT：`identity`、`repository`、`integration`、`layers`（pl / pm / ft / uc）。

---

## 产品线索引表（示例）

| 链序 | 层级 | 类型 | 名称 | 锚点目录 |
|:----:|------|------|------|----------|
| — | 索引 | 产品视角 | 产品视角 | [applications/app-APPNAME/knowledge/product/product_meta.yaml](product_meta.yaml) |
| L1 | 产品线 | PL | 示例产品线 | `product_knowledge.json`（`hierarchy=PL`） |
| L2 | 产品模块 | PM | 示例产品模块 | `product_knowledge.json`（`hierarchy=PM`） |
| L3 | 功能 | FT | 示例功能 | `product_knowledge.json`（`hierarchy=FT`） |
| L4 | 用例 | UC | 示例用例 | `product_knowledge.json`（`hierarchy=UC`） |

本目录仅保留**示例**，用于演示 PL/PM/FT/UC 的层级与字段形状。完整 ID 清单以 `product_knowledge.json` 为准。

---

## 文档与导航

| 推荐入口 | 说明 |
|---------|------|
| [applications/app-APPNAME/knowledge/product/product_knowledge.json](product_knowledge.json) | **本仓库产品层级（PL/PM/FT/UC）唯一事实来源**（含 `description / acceptance_criteria / invokes_api_ids / realizes_use_case_ids` 等字段） |
| [applications/app-APPNAME/knowledge/product/product_meta.yaml](product_meta.yaml) | 元模型与跨视角映射（字段模板、integration） |

---

## 层级结构

```
产品线 (PL) → 产品模块 (PM) → 功能 (FT) → 用例 (UC)   （内容整合于 product_knowledge.json）
```

- **层级与 ID 模式**：**`product_meta.yaml` → `layers`**
- **层级内容**：**`product_knowledge.json`**（本目录不再物化 `PL-*/PM-*/FT-*` Markdown 树）。

---

## 关键字段（用于映射）

- **PM**：`relies_on_context_ids`（→ business BC）
- **FT**：`invokes_api_ids`（→ technical API）、`realizes_use_case_ids`（→ UC）
- **UC**：`map_to_api_id`（→ technical API）

---

## 与其他视角的映射

- **产品 → 业务**：`relies_on_context_ids` → BC。
- **产品 → 技术**：`invokes_api_ids` / `map_to_api_id` → API（manifest）。

仓库根 Index Guide：[INDEX_GUIDE.md](../../../../INDEX_GUIDE.md)；中央库设计：[system/DESIGN.md](../../../../system/DESIGN.md)。
