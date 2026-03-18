# technical — 技术视角

本目录描述系统的物理实现、部署架构与服务接口，并维护应用注册与索引。

- **系统架构总览**：[SYSTEM-ARCHITECTURE.md](./SYSTEM-ARCHITECTURE.md)（各系统/子系统职责、边界与关系）

---

## 技术索引表

| 类型   | 名称                    | ID                     | 路径                                                           | 说明                |
|--------|-------------------------|------------------------|----------------------------------------------------------------|---------------------|
| 应用   | 订单服务                | APP-ORDER-SERVICE      | [APP-ORDER](./APP-ORDER/) | 订单领域服务（注册信息见 `APP-ORDER/APP-ORDER-SERVICE.yaml`） |


---

## 层级结构

```
应用 (APP) → 微服务 (MS)
```

- **应用目录**：按应用建目录（如 `APP-ORDER/`），存放该应用的注册 `{APP-ID}.yaml` 及集成关系图等。
- **应用**：对应代码仓库/部署单元，文件 `{APP-ID}/{APP-ID}.yaml`（如 `APP-ORDER/APP-ORDER-SERVICE.yaml`）。
- **微服务**：在应用 YAML 中通过 `service_ids` 列出，详细定义可在应用级仓库的 docs 中维护。

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

更多见仓库根目录 [INDEX.md](../../../INDEX.md) 与系统设计说明 [system/DESIGN.md](../../../system/DESIGN.md)。
