# docs-build 常见陷阱

视角顺序、ID、API、README、归并问题时读本文。**错** vs **对**。

## 初始化

- **INDEX 不可仍提取** → 无地图易幻觉；先 `/docs-indexing`
- **通读全仓再开工** → 以主 INDEX 导航，按需只读本视角相关文件

## 视角顺序与依赖

- **乱序提取** → 固定 技术→数据→业务→产品（产品依赖 MS/API，业务依赖 MS）
- **后序改前序 JSON** → 后序只读前序 ID；修前序单跑该视角

## 实体 ID

- **MS-ID 用 Maven 模块名** → 按宿主类聚类；别名 SimpleName 去后缀
- **一表多 ENT** → 同 `physical_table` 合并一个 ENT
- **AGG 无 MS** → 无根则不造 AGG；标待补充
- **FT/UC 无 API** → 须绑 API；无则标待补充
- **未读文件造 ID** → 零幻觉；未读勿写已核实 evidence；可 `confidence: low` 并述因

## API 四类

- **只提 Dubbo/HTTP** → 须含 MQ Consumer、Job；`api_type` 每条必填
- **Consumer 当 Provider** → 只提 Provider；Consumer 进 `external_dependencies`
- **MQ 多 Tag 不拆** → 一 Consumer 多 Tag → 多条 API，各 `tag`
- **Job 无 handler** → `job_handler` 必填；cron 拿不到可 `confidence: medium`
- **MQ/Job 无 MS** → 须归 MS；新 MS 或就近域并在 `merge_note` 说明

## 字段

- **无 evidence_chain** → 每实体 ≥1 条 `{source, confidence, type}`；high 须代码/配置直证
- **技术 entities 用数组** → 须为 `{ systems, applications, services, apis }`；他视角才扁平
- **缺统计节** → 每 `{perspective}-entities.md` 含完整统计（计数、`extraction_basis`、`schema_notes`、`changes_from_previous`）

## README 与归并

- **跳 README 直写 INDEX** → 必先阶段 3 再阶段 4
- **不归并前缀就开写** → 仅允许 `contains_prefixes`；冲突跳过并记
- **单改旧 ID** → 禁；改名须全链更新引用或重跑视角
- **模板占位当真索引** → 无内容标「待补充」；勿用非本应用模板 ID 填满

## 增量

- **skip-existing 漏变体** → 只对确认未变的跳过；变更文件牵涉实体强制重提
- **不写 changes_from_previous** → 增量须在 `metadata` 登记增删改与因

## 速查（完整见 quality-checklist）

- [ ] INDEX 已就绪，未盲扫全仓
- [ ] 顺序 技术→数据→业务→产品
- [ ] API 四类 + `api_type`；仅 Dubbo Provider
- [ ] 技术 entities 分类；他视角扁平
- [ ] 每实体有 evidence_chain
- [ ] 先 README 后 INDEX
- [ ] 无单独.rename 旧 ID

完整：[references/quality-checklist.md](references/quality-checklist.md)。
