---
type: Documentation
title: product（产品视角）
---
索引入口见 [index.md](index.md)。

本目录描述产品功能、用户故事与需求规格，并通过 ID 与其他视角建立映射。本树承接产品实体登记与交互映射；元数据与实例索引见 [product-meta.md](product-meta.md)、[../index.md](../index.md)（§2）。

---

## 产品线索引表（示例）

| 链序 | 层级 | 类型 | 名称 | 锚点 |
| --- | --- | --- | --- | --- |
| — | 索引 | 产品视角 | 产品视角 | [product-meta.md](product-meta.md) |
| L1 | 产品线 | PL | 示例产品线 | [PL-EXAMPLE.md](PL-EXAMPLE.md) |
| L2 | 产品模块 | PM | 示例产品模块 | [PM-EXAMPLE/PM-EXAMPLE.md](PM-EXAMPLE/PM-EXAMPLE.md) |
| L3 | 功能 | FT | 示例功能 | [PM-EXAMPLE/FT-EXAMPLE/FT-EXAMPLE.md](PM-EXAMPLE/FT-EXAMPLE/FT-EXAMPLE.md) |
| L4 | 需求 | FR | 示例功能需求 | [PM-EXAMPLE/FT-EXAMPLE/FR-EXAMPLE/FR-EXAMPLE.md](PM-EXAMPLE/FT-EXAMPLE/FR-EXAMPLE/FR-EXAMPLE.md) |
| L5 | 用例 | UC | 示例用例 | [PM-EXAMPLE/FT-EXAMPLE/FR-EXAMPLE/UC-EXAMPLE.md](PM-EXAMPLE/FT-EXAMPLE/FR-EXAMPLE/UC-EXAMPLE.md) |
| L6 | 规则 | BR | 示例规则 | [PM-EXAMPLE/FT-EXAMPLE/FR-EXAMPLE/BR-EXAMPLE.md](PM-EXAMPLE/FT-EXAMPLE/FR-EXAMPLE/BR-EXAMPLE.md) |

本目录仅保留**示例**，用于演示 PL/PM/FT/FR/UC/BR 的层级与字段形状（另含 BP 流程叙事文件）。完整 ID 清单以 [../index.md](../index.md) §2 为准。

---

## 文档与导航

| 推荐入口 | 说明 |
| --- | --- |
| 实体文件 `{ID}.md` + [../index.md](../index.md) §2 | **产品层级（PL/PM/FT/FR/UC/BR）唯一事实来源** |
| [product-meta.md](product-meta.md) | 元模型与跨视角映射 |

---

## 层级结构

```text
产品线 (PL) → 产品模块 (PM) → 功能 (FT) → 需求 (FR) → 用例/规则 (UC/BR)   （实体文件 `{ID}.md` 为 SSOT；扫描索引见 KNOWLEDGE_INDEX §2）
```

- **层级与 ID 模式**：[product-meta.md](product-meta.md) → §3 层定义
- **层级内容**：实体文件 `{ID}.md`；枚举见 [../index.md](../index.md) §2

---

## 关键字段（用于映射）

- **PM**：`relies_on_context_ids`（→ business BC）
- **FT**：`invokes_api_ids`（→ application API）、`realizes_use_case_ids`（→ UC）
- **FR**：`children`（→ UC/BR）
- **UC**：`map_to_api_id`（→ application API）

---

## 与其他视角的映射

- **产品 → 业务**：`relies_on_context_ids` → BC。
- **产品 → 技术**：`invokes_api_ids` / `map_to_api_id` → API（manifest）。

仓库根 Index Guide：[index.md](../../../index.md)；设计：[../../DESIGN.md](../../DESIGN.md)。
