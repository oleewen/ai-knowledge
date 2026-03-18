# technical — 技术视角

本目录描述**系统的物理实现、部署架构与服务接口**。应用级仓库通过 `manifest.yaml` 上报，系统级在此维护应用注册与索引。

- **系统架构总览**：[SYSTEM-ARCHITECTURE.md](./SYSTEM-ARCHITECTURE.md)（各系统/子系统职责、边界与关系）

---

## 技术索引表

| 类型   | 名称                    | ID                     | 路径                                                           | 说明                |
|--------|-------------------------|------------------------|----------------------------------------------------------------|---------------------|
| 系统   | 电商后端                | SYS-ECOMMERCE-BACKEND  | [SYS-ECOMMERCE-BACKEND](./SYS-ECOMMERCE-BACKEND/)              | 电商业务核心系统；[应用架构](SYS-ECOMMERCE-BACKEND/APPLICATION-ARCHITECTURE.md) |
| 应用   | 订单服务                | APP-ORDER-SERVICE      | [APP-ORDER-SERVICE](./SYS-ECOMMERCE-BACKEND/APP-ORDER/APP-ORDER-SERVICE.yaml) | 订单领域服务       |


---

## 层级结构

```
系统 (SYS) → 应用 (APP) → 微服务 (MS)
```

- **系统**：如电商后端、中台，目录 `{SYS-ID}/`，含 `_meta.yaml`、`APPLICATION-ARCHITECTURE.md`。
- **应用目录**：系统目录下按应用建目录（如 `APP-ORDER/`），存放该应用的注册 `{APP-ID}.yaml` 及集成关系图等。
- **应用**：对应代码仓库/部署单元，文件 `{APP-ID}/{APP-ID}.yaml`（如 `APP-ORDER/APP-ORDER-SERVICE.yaml`）。
- **微服务**：在应用 YAML 中通过 `service_ids` 列出，详细定义可在应用级仓库的 docs 中维护。

---

## 应用注册 YAML 约定

应用文件（如 `APP-ORDER-SERVICE.yaml`）建议包含：

| 字段 | 说明 |
|------|------|
| id, name, description | 应用标识与描述 |
| repo_url | 代码仓库地址 |
| docs_manifest_path | 应用级文档清单路径，如 `/docs/manifest.yaml` |
| service_ids | 本应用包含的微服务 ID 列表 (MS-*) |
| owner_team | 负责团队（可选） |

CI/CD 可抓取各应用仓库的 `manifest.yaml`，更新此处元数据并做一致性检查。

---

## 与其他视角的映射

- **技术 ← 业务**：business 限界上下文的 `implemented_by_app_id` 指向本层 APP。
- **技术 ← 产品**：product 功能点的 `invokes_api_ids` 指向应用级 manifest 中登记的 API。

更多见仓库根目录 [INDEX.md](../../INDEX.md) 与 [DESIGN.md](../../DESIGN.md)。
