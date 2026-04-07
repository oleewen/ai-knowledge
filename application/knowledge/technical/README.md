# technical — 技术视角

本目录描述本应用的物理实现、部署架构与服务接口；应用注册与索引见 **technical_meta.yaml** 与 **technical_knowledge.json**，以及 **[../KNOWLEDGE_INDEX.md](../KNOWLEDGE_INDEX.md)**。

- **实现入口**：HTTP（`@GatewayApi`）与 ZSS Job 见 [INDEX_GUIDE.md](../../../INDEX_GUIDE.md) **第三节 · 3.1**、**第三节 · 3.3**。
- **统一元数据**：[technical_meta.yaml](technical_meta.yaml) — `layers`（sys / app / ms / api）。
- **系统架构总览/应用注册**：已整合进 [technical_knowledge.json](technical_knowledge.json)（`entities.systems[].architecture` / `entities.applications[]`）

---

## 技术索引表（示例）

| 类型 | 名称 | ID (KNOWLEDGE_INDEX) | 路径 / 说明 |
|------|------|----------------------|-------------|
| 系统 | 示例系统边界 | SYS-EXAMPLE | `technical_knowledge.json`（`hierarchy=SYS` / `full_id=SYS-EXAMPLE`） |
| 应用 | 示例应用 | APP-EXAMPLE | `technical_knowledge.json`（`hierarchy=APP` / `full_id=APP-EXAMPLE`） |
| 微服务（MS） | 示例微服务 | MS-EXAMPLE | `technical_knowledge.json`（`hierarchy=MS` / `id=MS-EXAMPLE`） |
| 接口 | 示例 API | API-EXAMPLE-001 | `technical_knowledge.json`（`hierarchy=API` / `id=API-EXAMPLE-001`） |

本目录仅保留**示例**，用于演示 SYS/APP/MS/API 的层级与字段形状。完整 ID 清单以 `technical_knowledge.json` 为准。

---

## 层级结构

```
系统 (SYS) → 应用 (APP) → 微服务 (MS) → API   （架构/注册内容整合于 technical_knowledge.json）
```

- **字段模板**：**`technical_meta.yaml` → `layers`**
- **层级内容**：**`technical_knowledge.json`**（本目录不再物化 `SYS-*` 子目录与架构 Markdown/YAML 文件）。

---

## 应用注册（最小字段）

- `id`, `name`, `description`
- `repo_url`
- `docs_manifest_path`（如 `/application/manifest.yaml`）
- `service_ids`（MS-*）
- `owner_team`（可选）

---

## 与其他视角的映射

- **技术 ← 业务**：`implemented_by_app_id` → APP。
- **技术 ← 产品**：`invokes_api_ids` → API。

仓库根 Index Guide：[INDEX_GUIDE.md](../../../INDEX_GUIDE.md)；设计：[../../DESIGN.md](../../DESIGN.md)。
