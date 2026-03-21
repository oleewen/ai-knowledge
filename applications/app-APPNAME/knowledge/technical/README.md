# technical — 技术视角

本目录描述本应用的物理实现、部署架构与服务接口，并与中央库 `system/knowledge/technical/` 约定对齐；应用注册与索引见本目录 `technical_meta.yaml` 与 `../INDEX.md`。

- **统一元数据**：[technical_meta.yaml](./technical_meta.yaml) — 单文件 SSOT：`identity`、`repository`、`pipeline`、`integration`、`layers`（sys / app / ms / api）。
- **系统架构总览**：[SYSTEM-ARCHITECTURE.md](./SYSTEM-ARCHITECTURE.md)（各系统/子系统职责、边界与关系）

---

## 技术索引表

| 类型   | 名称                    | ID                     | 路径                                                           | 说明                |
|--------|-------------------------|------------------------|----------------------------------------------------------------|---------------------|
| 系统   | 电商后端                | SYS-ECOMMERCE-BACKEND  | [SYS-ECOMMERCE-BACKEND](./SYS-ECOMMERCE-BACKEND/)              | [technical_meta.yaml](./technical_meta.yaml) `layers` → `key: sys`；[应用架构](SYS-ECOMMERCE-BACKEND/APPLICATION-ARCHITECTURE.md) |
| 应用   | 订单服务                | APP-ORDER-SERVICE      | [APP-ORDER-SERVICE](./SYS-ECOMMERCE-BACKEND/APP-ORDER/APP-ORDER-SERVICE.yaml) | 同上 · `key: app` |
| 微服务 | 订单核心服务            | MS-ORDER-CORE          | （见 APP.service_ids）                                         | 同上 · `key: ms` |
| 接口   | 加入购物车              | API-CART-ADD-ITEM      | （见 manifest/OpenAPI）                                        | 同上 · `key: api` |


---

## 层级结构

```
系统 (SYS) → 应用 (APP) → 微服务 (MS) → API
```

- **系统 / 应用 / 微服务 / 接口**：字段模板见 **`technical_meta.yaml` → `layers`**（`key`: sys / app / ms / api）；目录 `{SYS-ID}/` 作系统锚点，含 `APPLICATION-ARCHITECTURE.md` 等。
- **应用目录**：系统目录下按应用建目录（如 `APP-ORDER/`），存放该应用的注册 `{APP-ID}.yaml` 及集成关系图等。
---

## 应用注册（最小字段）

- `id`, `name`, `description`
- `repo_url`
- `docs_manifest_path`（如 `/docs/manifest.yaml`）
- `service_ids`（MS-*）
- `owner_team`（可选）

---

## 与其他视角的映射

- **技术 ← 业务**：business 限界上下文的 `implemented_by_app_id` 指向本层 APP。
- **技术 ← 产品**：product 功能点的 `invokes_api_ids` 指向应用级 manifest 中登记的 API。

系统索引：[../../INDEX.md](../../INDEX.md)；全库 Index Guide：[../../../INDEX.md](../../../INDEX.md)；设计：[../../DESIGN.md](../../DESIGN.md)。
