# docs-archive 常见陷阱

---

## 联邦边界

**在应用库里重复定义全系统业务域**：应用知识库只放本应用的接口细节、Schema、部署参数；跨应用映射、系统边界、聚合与实体 ID 契约属于系统知识库。上行时提炼有效信息，不要把应用库内容整段复制到系统库。

**在系统库里粘贴 OpenAPI 全文**：系统库只保留 `docs_manifest_path` 与 ID 引用，API 细节以应用侧 manifest 为 SSOT。

---

## ID 与引用

**修改已有实体 ID**：已有实体禁止改 id。需重命名时必须同步更新全部跨视角引用（`implemented_by_app_id`、`persisted_as_entity_ids`、`invokes_api_ids` 等），否则引用链断裂。

**用 Maven 模块名作为 MS-ID**：MS-* 须按 APIs 宿主聚类，不用 Maven 模块名。与 docs-build 的 MS 生成规则保持一致。

**新增 ID 不检查全局唯一性**：新增实体 ID 须全局唯一，先读各视角 `*_meta.yaml` 确认现有 ID，再分配新编号。

**交叉引用写了重复长描述**：关联字段只写 ID，不写重复的名称或描述，避免两处维护失步。

---

## 上行时机与顺序

**未读系统文件就直接写入**：先读拟修改的系统文件与相邻 `*_meta.yaml`，确认现有 ID 和字段结构，再写入。

**应用侧与系统侧冲突时强行覆盖**：冲突时以代码与 manifest 为准，或标为待人工确认，不强行覆盖系统权威域定义。

**变更影响全局导航但未更新索引**：变更影响 `system/SYSTEM_INDEX.md` 或视角 `README.md` 时，必须同步更新，否则导航断链。

---

## 归档产物

**归档路径与项目约定不一致**：批次归档写入 `system/changelogs/upstream-from-applications/`，不要写到其他路径，保持与 `system/changelogs/` 约定一致。

**全量快照时通读全仓**：无基线时只做轻量索引（文件清单 + 哈希/行数摘要），不通读全部文档内容。

---

## 快速自查清单

- [ ] 应用独有细节仍保留在应用库，未整段复制到系统库
- [ ] 系统库无大段与 manifest 重复的冗余正文
- [ ] 已有实体 ID 未被修改
- [ ] 新增 ID 已确认全局唯一
- [ ] 关联字段只写 ID，无重复长描述
- [ ] 新增/修改的 YAML 可被解析，无断链 ID
- [ ] 变更影响导航时已同步更新 SYSTEM_INDEX 或视角 README
- [ ] 批次归档已写入 `system/changelogs/upstream-from-applications/`
