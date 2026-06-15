# application — 应用视角

本目录描述本应用的物理实现、部署架构与服务接口；应用注册与索引见 [application-meta.md](application-meta.md)、[application-entities.md](application-entities.md)，以及 **[../KNOWLEDGE_INDEX.md](../KNOWLEDGE_INDEX.md)**。

- **实现入口**：HTTP（`@GatewayApi`）与 ZSS Job 见 [INDEX_GUIDE.md](../../../INDEX_GUIDE.md) **第三节 · 3.1**、**第三节 · 3.3**。
- **统一元数据**：[application-meta.md](application-meta.md) — `layers`（sys / app / ms / api）。
- **系统架构总览/应用注册**：已整合进 [application-entities.md](application-entities.md)

---

## 应用索引表（示例）

| 类型 | 名称 | ID (KNOWLEDGE_INDEX) | 路径 / 说明 |
|------|------|----------------------|-------------|
| 系统 | 示例系统边界 | SYS-EXAMPLE | [application-entities.md](application-entities.md) |
| 应用 | 示例应用 | APP-EXAMPLE | 同上 |
| 微服务（MS） | 示例微服务 | MS-EXAMPLE | 同上 |
| 接口 | 示例 API | API-EXAMPLE-001 | 同上 |

本目录仅保留**示例**，用于演示 SYS/APP/MS/API 的层级与字段形状。完整 ID 清单以 [application-entities.md](application-entities.md) 为准。

---

## 层级结构

```
系统 (SYS) → 应用 (APP) → 微服务 (MS) → API   （架构/注册内容整合于 application-entities.md）
```

- **字段模板**：[application-meta.md](application-meta.md) → §4 必填字段
- **层级内容**：[application-entities.md](application-entities.md)

---

## 应用注册（最小字段）

- `id`, `name`, `description`
- `repo_url`
- `docs_manifest_path`（如 `/application/manifest.yaml`）
- `service_ids`（MS-*）
- `owner_team`（可选）

---

## 与其他视角的映射

- **应用 ← 业务**：`implemented_by_app_id` → APP。
- **应用 ← 产品**：`invokes_api_ids` → API。

仓库根 Index Guide：[INDEX_GUIDE.md](../../../INDEX_GUIDE.md)；设计：[../../DESIGN.md](../../DESIGN.md)。
