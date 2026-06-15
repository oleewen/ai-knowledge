# business — 业务视角

本目录描述业务版图与领域规则（DDD），不依赖具体技术实现。实体 SSOT：[business-meta.md](business-meta.md)、[business-entities.md](business-entities.md)。

---

## 层级结构

```
业务域 (BD) → 业务子域 (BSD) → 限界上下文 (BC) → 聚合 (AGG) → 能力 (AB)
```

| 层级    | 代码    | 物理形态 | 说明                  |
| ----- | ----- | ---- | ------------------- |
| 业务域   | `BD`  | Markdown 实体表 | 顶层业务边界              |
| 业务子域  | `BSD` | Markdown 实体表 | BD 下 0-N 个子域        |
| 限界上下文 | `BC`  | Markdown 实体表 | BSD 下 1-N 个上下文      |
| 聚合    | `AGG` | Markdown 实体表 | BC 下多个聚合，每个含业务规则    |
| 能力    | `AB`  | Markdown 实体表 | AGG 下多个能力（含 API 列表） |

**关键设计决策**：BD→AB 全层级内容整合进 [business-entities.md](business-entities.md)；以 Markdown 扁平实体表作为检索与引用的唯一事实来源。

---

## 目录树（示例）

```
business/
├── README.md              # 本文件（人类导航）
├── business-meta.md       # 视角 SSOT（元模型、层级约定、跨视角映射）
├── business-entities.md   # 扁平实体列表（AI 检索首选入口）
```

---

## AI 检索指南

| 检索需求            | 推荐入口 |
| --------------- | ---- |
| 快速枚举全部业务实体 ID   | [business-entities.md](business-entities.md)（`hierarchy` 列区分层级） |
| 了解某聚合的业务规则与能力   | `business-entities.md` 中 `hierarchy=AGG` 行 |
| 了解上下文边界与通用语言    | `business-entities.md` 中 `hierarchy=BC` 行 |
| 跨视角映射（业务→技术/数据） | [business-meta.md](business-meta.md) → §5 跨视角引用 |
| 全库五视角索引         | [../KNOWLEDGE_INDEX.md](../KNOWLEDGE_INDEX.md) |

---

## 业务索引表（示例）

本目录仅保留**示例**，用于演示 BD→AB 的层级与字段形状。完整 ID 清单以 [business-entities.md](business-entities.md) 为准。

| 链序  | 层级    | ID（示例）      | 名称（示例）  | 文件 |
| --- | ----- | ----------- | ------- | --- |
| L1  | 业务域   | BD-EXAMPLE  | 示例业务域   | [business-entities.md](business-entities.md) |
| L2  | 业务子域  | BSD-EXAMPLE | 示例业务子域  | 同上 |
| L3  | 限界上下文 | BC-EXAMPLE  | 示例限界上下文 | 同上 |
| L4  | 聚合    | AGG-EXAMPLE | 示例聚合    | 同上 |
| L5  | 能力    | AB-EXAMPLE  | 示例能力    | 同上 |

---

## 关键字段（用于映射）

- **BC（限界上下文）**：`implemented_by_app_id`（→ application APP）
- **AGG（聚合）**：`persisted_as_entity_ids`（→ data ENT）
- **AB（能力）**：`apis`（含 API-ID，→ application API）

（字段细则以 [business-entities.md](business-entities.md) 为准；映射见 [business-meta.md](business-meta.md)。）

---

## 与其他视角的映射

- **业务 → 技术**：BC/AGG/AB → APP/MS/API（见 business-meta.md §5）。
- **业务 → 数据**：AGG → ENT，见 [data/data-entities.md](../data/data-entities.md)。

仓库根 Index Guide：[INDEX_GUIDE.md](../../../INDEX_GUIDE.md)。
