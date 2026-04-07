# business — 业务视角

本目录描述业务版图与领域规则（DDD），不依赖具体技术实现。

---

## 层级结构

```
业务域 (BD) → 业务子域 (BSD) → 限界上下文 (BC) → 聚合 (AGG) → 能力 (AB)
```

| 层级 | 代码 | 物理形态 | 说明 |
|------|------|----------|------|
| 业务域 | `BD` | JSON 实体 | 顶层业务边界 |
| 业务子域 | `BSD` | JSON 实体 | BD 下 0-N 个子域 |
| 限界上下文 | `BC` | JSON 实体 | BSD 下 1-N 个上下文 |
| 聚合 | `AGG` | JSON 实体 | BC 下多个聚合，每个含业务规则 |
| 能力 | `AB` | JSON 实体 | AGG 下多个能力（含 API 列表） |

**关键设计决策**：本仓库将 BD→AB 全层级内容 **整合进** `business_knowledge.json`；以 JSON 扁平实体列表作为检索与引用的唯一事实来源。

---

## 目录树（示例）

```
business/
├── README.md                          # 本文件（人类导航）
├── business_meta.yaml                 # 视角 SSOT（元模型、层级约定、跨视角映射）
├── business_knowledge.json            # 扁平实体列表（AI 检索首选入口）
```

---

## AI 检索指南

| 检索需求 | 推荐入口 |
|----------|----------|
| 快速枚举全部业务实体 ID | [business_knowledge.json](business_knowledge.json)（扁平 JSON，`hierarchy` 区分层级） |
| 了解某聚合的业务规则与能力 | `business_knowledge.json` 中 `hierarchy=AGG` 实体的 `invariants / abilities / cross_references` |
| 了解上下文边界与通用语言 | `business_knowledge.json` 中 `hierarchy=BC` 实体的 `implemented_by_app_id / ubiquitous_language / aggregates` |
| 跨视角映射（业务→技术/数据） | [business_meta.yaml](business_meta.yaml) → `integration.cross_perspective` |
| 全库四视角索引 | [../KNOWLEDGE_INDEX.md](../KNOWLEDGE_INDEX.md) |

---

## 业务索引表（示例）

本目录仅保留**示例**，用于演示 BD→AB 的层级与字段形状。完整 ID 清单以 `business_knowledge.json` 为准。

| 链序 | 层级 | ID（示例） | 名称（示例） | 文件/目录 |
|:----:|------|-----------|-------------|-----------|
| L1 | 业务域 | BD-EXAMPLE | 示例业务域 | `business_knowledge.json`（`hierarchy=BD`） |
| L2 | 业务子域 | BSD-EXAMPLE | 示例业务子域 | `business_knowledge.json`（`hierarchy=BSD`） |
| L3 | 限界上下文 | BC-EXAMPLE | 示例限界上下文 | `business_knowledge.json`（`hierarchy=BC`） |
| L4 | 聚合 | AGG-EXAMPLE | 示例聚合 | `business_knowledge.json`（`hierarchy=AGG`） |
| L5 | 能力 | AB-EXAMPLE | 示例能力 | `business_knowledge.json`（`hierarchy=AB`） |

---

## 关键字段（用于映射）

- **BC（限界上下文）**：`implemented_by_app_id`（→ technical APP）
- **AGG（聚合）**：`persisted_as_entity_ids`（→ data ENT）
- **AB（能力）**：`apis[]`（含 API-ID，→ technical API）

（字段细则以 `business_knowledge.json` 为准；映射见 `business_meta.yaml` → `integration`。）

---

## 与其他视角的映射

- **业务 → 技术**：见 `integration.cross_perspective`（BC/AGG/AB → APP/MS/API）。
- **业务 → 数据**：AGG → ENT，见同段与 `data_knowledge.json`。

仓库根 Index Guide：[INDEX_GUIDE.md](../../../INDEX_GUIDE.md)。
