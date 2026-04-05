# 联邦原则与映射规范

docs-archive 的联邦层级约定、上行映射规则与质量自检标准。

---

## 联邦层级约定

| 层级 | 适合放什么 | 不适合 |
|------|-----------|--------|
| **应用知识库** | 接口细节、本仓 Schema、部署参数、manifest、应用内四视角实例 | 把全系统业务域在应用里当唯一权威重复定义 |
| **系统知识库** | 跨应用映射、系统边界、应用注册（`technical/{SYS}/{APP}.yaml`）、聚合与实体 ID 契约、产品/API 关联字段 | 大段复制应用内 OpenAPI 全文（应保留 `docs_manifest_path` 与 ID 引用） |

上行时：**提炼有效信息**（新服务 ID、新 API 契约摘要、归属 `app_id`、与 product/business 的 ID 链接），改写为系统文件要求的字段与结构，禁止破坏已有 ID 与引用链。

---

## 应用侧 → 系统侧映射表

| 应用侧信息 | 系统侧落点 |
|-----------|-----------|
| 应用身份、仓库、manifest 路径 | `knowledge/technical/{SYS}/{APP-ID}.yaml`：`repo_url`、`docs_manifest_path`、`service_ids` |
| 新 MS-*（入口簇）、API 清单（摘要级） | 更新 `{APP-ID}.yaml` 的 `service_ids`；MS-* 须按 APIs 宿主聚类（非 Maven 模块名）；API 细节以 manifest 为 SSOT |
| 限界上下文由本应用实现 | `knowledge/business/business_meta.yaml` → `layers[key=bc].fields.implemented_by_app_id` |
| 数据实体归属应用 | `knowledge/data/data_meta.yaml` → `layers[key=ds/ent]` 中 `owned_by_app_id`；与聚合的 `persisted_as_entity_ids` |
| 产品功能调用本应用 API | `knowledge/product/product_meta.yaml` → `layers[key=ft].invokes_api_ids` |
| 跨域架构决策 | 必要时新增 `knowledge/constitution/adr/ADR-*.md` |

---

## 撰写规则

- **先读再写**：打开拟修改的系统文件与相邻元数据 YAML（各视角 `*_meta.yaml`），确认现有 ID
- **只增不改 ID**：已有实体禁止改 id；新增实体 ID 须全局唯一且符合命名规范（见 `system/knowledge/constitution/standards/NAMING-CONVENTIONS.md`）
- **交叉引用仅 ID**：正文与 YAML 关联字段只写 ID，不写重复长描述
- **更新索引**：变更影响全局导航时，同步 `system/SYSTEM_INDEX.md` 或对应视角 `README.md`

---

## 质量自检

- 新增/修改的 YAML 可被解析；无断链 ID
- 应用独有细节仍保留在应用库；系统库无大段与 manifest 重复的冗余正文
- 若应用侧与系统侧冲突，以代码与 manifest 为准，或标为待人工确认，不强行覆盖系统权威域定义
