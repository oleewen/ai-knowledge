---
type: Documentation
title: technical（技术视角）
---
# technical（技术视角）

索引入口见 [index.md](index.md)。

本目录描述中间件绑定、关键运行时组件，并通过 ID 与其他视角建立映射。公司级 **TPL-***、系统级 **TSD-*** 在对应层目录首次定义；本层主定义并登记 **MW-*** 与 **CMP-***。元数据与实例索引见 [technical-meta.md](technical-meta.md)、[../index.md](../index.md)（§5）。

---

## 技术线索引表（示例）

| 链序 | 层级 | 类型 | 名称 | 锚点 |
|:----:|------|------|------|------|
| — | 索引 | 技术视角 | 技术视角 | [technical-meta.md](technical-meta.md) |
| L1 | 中间件绑定 | MW | 示例中间件绑定 | [MW-EXAMPLE/MW-EXAMPLE.md](MW-EXAMPLE/MW-EXAMPLE.md) |
| L2 | 组件 | CMP | 示例组件 | [MW-EXAMPLE/CMP-EXAMPLE.md](MW-EXAMPLE/CMP-EXAMPLE.md) |

---

## 层级结构

```
中间件绑定 (MW) → 组件 (CMP)   （实体文件 `{ID}.md` 为 SSOT；扫描索引见 KNOWLEDGE_INDEX §5）
```

- **字段模板**：[technical-meta.md](technical-meta.md) → §4 必填字段
- **层级内容**：实体文件 `{ID}.md`；枚举见 [../index.md](../index.md) §5

**边界**：MW 登记基础设施绑定（数据源、缓存、MQ Topic/集群等）；MS/API 仍登记业务入口宿主类，不迁入本视角。

---

## 关键字段（用于映射）

- **MW**：`parent_tsd_id`（→ TSD）、`bound_app_id`（→ APP）、`related_ds_id`（→ DS，可选）
- **CMP**：`parent_mw_id`（→ MW）或 `parent_app_id`（→ APP）、`maven_coordinates`

---

## 与其他视角的映射

- **技术 ← 应用**：`bound_app_id` → APP；`implements_tpl_ids`（APP 字段）→ TPL。
- **技术 ← 数据**：`related_ds_id` → DS（数据源类绑定）。

仓库根 Index Guide：[index.md](../../../index.md)；设计：[../../DESIGN.md](../../DESIGN.md)；命名：[../../../agent/knowledge/naming-conventions.md](../../../agent/knowledge/naming-conventions.md)。
