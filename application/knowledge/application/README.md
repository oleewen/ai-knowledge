---
type: Documentation
title: application（应用视角）
---
# application（应用视角）

索引入口见 [index.md](index.md)。

本目录描述本应用的物理实现、部署架构与服务接口；系统层 `APP/MS` 在此承接实例登记与实现映射，应用层 `API` 在此主定义。应用注册与索引见 [application-meta.md](application-meta.md) 与 **[../KNOWLEDGE-INDEX.md](../KNOWLEDGE-INDEX.md)**（§3）。

- **实现入口**：HTTP（`@GatewayApi`）与 ZSS Job 见 [INDEX-GUIDE.md](../../../INDEX-GUIDE.md) **第三节 · 3.1**、**第三节 · 3.3**。
- **统一元数据**：[application-meta.md](application-meta.md) — `layers`（sys / app / ms / api）。

---

## 应用索引表（示例）

| 类型 | 名称 | ID (KNOWLEDGE_INDEX) | 路径 / 说明 |
|------|------|----------------------|-------------|
| 系统 | 示例系统边界 | SYS-EXAMPLE | [SYS-EXAMPLE.md](SYS-EXAMPLE.md) |
| 应用 | 示例应用 | APP-EXAMPLE | [APP-EXAMPLE.md](APP-EXAMPLE.md) |
| 微服务（MS） | 示例微服务 | MS-EXAMPLE | [MS-EXAMPLE/MS-EXAMPLE.md](MS-EXAMPLE/MS-EXAMPLE.md) |
| 接口 | 示例 API | API-EXAMPLE-001 | [MS-EXAMPLE/API-EXAMPLE-001.md](MS-EXAMPLE/API-EXAMPLE-001.md) |

本目录仅保留**示例**，用于演示 SYS/APP/MS/API 的层级与字段形状。完整 ID 清单以 [../KNOWLEDGE-INDEX.md](../KNOWLEDGE-INDEX.md) §3 为准。

---

## 层级结构

```
系统 (SYS) → 应用 (APP) → 微服务 (MS) → API   （实体文件 `{ID}.md` 为 SSOT；扫描索引见 KNOWLEDGE_INDEX §3）
```

- **字段模板**：[application-meta.md](application-meta.md) → §4 必填字段
- **层级内容**：实体文件 `{ID}.md`；枚举见 [../KNOWLEDGE-INDEX.md](../KNOWLEDGE-INDEX.md) §3

---

## 应用注册（最小字段）

- `id`, `name`, `description`
- `repo_url`
- `docs_manifest_path`（如 `/application/manifest.md`）
- `service_ids`（MS-*）
- `owner_team`（可选）

---

## 与其他视角的映射

- **应用 ← 业务**：`implemented_by_app_id` → APP。
- **应用 ← 产品**：`invokes_api_ids` → API。

仓库根 Index Guide：[INDEX-GUIDE.md](../../../INDEX-GUIDE.md)；设计：[../../DESIGN.md](../../DESIGN.md)。
