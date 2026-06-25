---
type: Documentation
title: data（数据视角）
---
# data（数据视角）

索引入口见 [index.md](index.md)。

本目录描述数据存储结构、数据实体与治理属性，并通过 ID 与其他视角建立映射；系统层 `DS/ENT` 在此承接实例登记与物理落地，应用层 `TBL` 作为物理表锚点在本树主定义。元数据与实例索引见 [data-meta.md](data-meta.md)、[../index.md](../index.md)（§4）。

---

## 数据线索引表（示例）

| 链序 | 层级 | 类型 | 名称 | 锚点 |
|:----:|------|------|------|------|
| — | 索引 | 数据视角 | 数据视角 | [data-meta.md](data-meta.md) |
| L1 | 数据存储 | DS | 示例数据源 | [DS-EXAMPLE.md](DS-EXAMPLE.md) |
| L2 | 数据实体 | ENT | 示例实体 | [ENT-EXAMPLE/ENT-EXAMPLE.md](ENT-EXAMPLE/ENT-EXAMPLE.md) |

---

## 层级结构

```
数据存储 (DS) → 数据实体 (ENT)   （实体文件 `{ID}.md` 为 SSOT；扫描索引见 KNOWLEDGE_INDEX §4）
```

- **字段模板**：[data-meta.md](data-meta.md) → §4 必填字段
- **层级内容**：实体文件 `{ID}.md`；枚举见 [../index.md](../index.md) §4

---

## 关键字段（用于映射）

- **DS**：`owned_by_app_id`（→ APP/MS）
- **ENT**：`maps_to_aggregate_id`（→ AGG）

---

## 本视角导航

- 数据存储与实体清单（唯一事实来源）：实体文件 `{ID}.md` + [../index.md](../index.md) §4

---

## 与其他视角的映射

- **数据 ← 业务**：`persisted_as_entity_ids` ↔ ENT。
- **数据 ← 技术**：`owned_by_app_id` → APP/MS。

仓库根 Index Guide：[index.md](../../../index.md)；设计：[../../DESIGN.md](../../DESIGN.md)。
