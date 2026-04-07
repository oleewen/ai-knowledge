# docs-build 常见陷阱

---

## 初始化

**主 Index Guide 不可用时仍继续**：无权威地图驱动时提取结果充斥幻觉 ID，证据链无法验证。主 Index Guide 不可用时立即终止，提示用户先运行 `/docs-indexing`。

**通读全仓源码再开始提取**：以主 INDEX 为导航，按需加载——仅在本轮任务需要时打开文件，只读与当前视角直接相关的内容。

---

## 视角顺序与依赖

**打乱四视角提取顺序**：产品视角依赖技术视角的 MS-*/API-* ID，业务视角依赖技术视角的 MS-*。必须严格按固定顺序：技术 → 数据 → 业务 → 产品。

**后续视角修改前序视角的输出文件**：后续视角只读前序视角 ID 作为引用，不写入前序视角文件。需修正前序视角时单独重跑该视角。

---

## 实体 ID 生成

**用 Maven 模块名作为 MS-ID**：MS-ID 按宿主类聚类，别名取宿主类 SimpleName 去后缀（如 `BillingAppealApiImpl` → `BillingAppeal`），不用模块名。

**同一张表对应多个 ENT-ID**：相同 `physical_table` 的实体类合并为一个 ENT-ID，在 `logical_name` 中列出所有 Java 类名。

**AGG-ID 无对应 MS-* 服务**：AGG-ID 必须有对应的 MS-* 服务；无 MS-* 对应时标记为待补充，不生成无根 AGG-ID。

**FT/UC 无 API 绑定**：FT 和 UC 必须绑定至少一个 API-ID；无 API 对应时标记为待补充，不生成无根 FT/UC-ID。

**编造未读文件中的实体**：零幻觉原则——只从已读文件提取 ID；未读路径不写成已核实证据，标注 `confidence: low` 并说明原因。

---

## API 四类入口覆盖

**只提取 Dubbo/HTTP，遗漏 MQ 和 Job**：API 层级必须覆盖 Dubbo、HTTP、MQ Consumer、Job 四类，每条标注 `api_type`（`DUBBO` / `HTTP` / `MQ_CONSUMER` / `JOB`）。

**将 Dubbo Consumer 引用误提取为 Provider 接口**：只提取 Provider 端（`@DubboService` / `@Service`），Consumer 端引用记为 `external_dependencies`，不生成 API-ID。

**MQ Consumer 未按 Tag 拆分**：同一 Consumer 监听多个 Tag 时，按 Tag 拆分为多条 API，每条标注独立的 `tag` 字段和业务描述。

**Job 缺少 handler 名称**：Job 类型 API 必须填写 `job_handler`；`cron_expression` 若可从注解或配置获取则填写，否则标注 `confidence: medium`。

**MQ/Job 入口未关联 MS-ID**：MQ Consumer 和 Job 必须归属到一个 MS-ID；若宿主类与现有 MS 宿主类不同，可新建 MS-ID 或归入同业务域最近的 MS-ID，并在 `merge_note` 中说明。

---

## 字段完整性

**缺少 evidence_chain**：每个实体必须有至少一条可验证证据，格式为 `{ source, confidence, type }`；`high` 置信度须来自代码或配置直接确认。

**技术视角 entities 使用扁平数组**：技术视角 `entities` 必须是分类对象 `{ systems, applications, services, apis }`；其余三视角才使用扁平数组。

**metadata 节缺失或不完整**：每个 `*_knowledge.json` 必须包含完整 `metadata` 节，含各层级数量统计、`extraction_basis`、`schema_notes`、`changes_from_previous`。

---

## README 填充与归并

**跳过 README 填充直接写 KNOWLEDGE_INDEX**：必须先执行阶段 3（README 填充），再执行阶段 4（归并），保证 README、JSON、主索引三者一致。

**跳过前缀验证直接写入索引**：归并前必须执行前缀验证，仅接受内置 `contains_prefixes` 所列前缀；冲突项跳过并记录日志。

**更改已有实体 ID 或破坏跨视角引用**：禁止单独修改已有 ID；需重命名时必须同步更新全部跨视角引用（`implemented_by_service_ids`、`persisted_as_entity_ids`、`invokes_api_ids` 等），或重跑受影响视角。

**以模板占位行作为索引唯一内容**：无实质内容时该节留空并标注「待补充」，禁止以非本应用模板 ID 作为索引唯一内容。

---

## 增量提取

**`--skip-existing true` 时漏更新变更实体**：`--skip-existing` 仅跳过确认未变更的实体；基于 `docs-change` 的变更文件列表，对变更文件涉及的实体强制重提取。

**增量提取后未填写 `changes_from_previous`**：每次增量提取必须在 `metadata.changes_from_previous` 中描述新增、修改、删除的实体 ID 及原因。

---

## 快速自查清单

完整清单见 [reference/quality-checklist.md](reference/quality-checklist.md)，以下为高频失误项：

- [ ] 主 Index Guide 已落盘，未通读全仓
- [ ] 四视角按技术 → 数据 → 业务 → 产品顺序执行
- [ ] API 覆盖 Dubbo / HTTP / MQ Consumer / Job 四类，每条含 `api_type`
- [ ] 仅提取 Dubbo Provider 端
- [ ] 技术视角 `entities` 为分类对象，其余三视角为扁平数组
- [ ] 每个实体含完整 `evidence_chain`
- [ ] 先 README 填充，再归并 KNOWLEDGE_INDEX
- [ ] 已有 ID 未被单独改名
