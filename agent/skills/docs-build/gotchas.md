# docs-build 常见陷阱

视角顺序、ID、API、README、归并、意图澄清问题时读本文。**错** vs **对**。

## 意图澄清

- **参数收口即写 knowledge** → 还须完成六项清单 + 写前 `C`；须标「当前阶段：意图澄清」
- **路径/容器缺批次信息** → 第 6 项须写明视角批次或实体批次 + `{DOC_DIR}/knowledge/` 下根相对路径
- **把写前澄清当 grilling** → 写前用 intent-clarify；写后才烤干
- **无横幅发 C/M/G/S/F** → 须区分意图澄清 `C` 与烤干 `C`
- **用 G 做写前澄清** → `G` 仅写后深挖
- **改实体 ID 不烤干** → 实体 ID 变更须强制烤干（默认本就必须）

## 初始化

- **INDEX 不可仍提取** → 无地图易幻觉；先 `/docs-indexing`
- **通读全仓再开工** → 以主 INDEX 导航，按需只读本视角相关文件

## 视角顺序与依赖

- **乱序提取** → 固定 技术→数据→业务→产品（产品依赖 MS/API，业务依赖 MS）
- **后序改前序 per-entity** → 后序只读前序 ID；修前序单跑该视角

## 实体 ID

- **MS-ID 用 Maven 模块名** → 按宿主类聚类；别名 SimpleName 去后缀
- **一表多 ENT** → 同 `physical_table` 合并一个 ENT
- **AGG 无 MS** → 无根则不造 AGG；标待补充
- **FT/UC 无 API** → 须绑 API；无则标待补充
- **未读文件造 ID** → 零幻觉；未读勿写已核实 evidence；可 `confidence: low` 并述因
- **concept 缺 full_id** → 每个 per-entity `{ID}.md` frontmatter 须非空 `full_id`；否则扫描无法纳入 KNOWLEDGE_INDEX

## API 四类

- **只提 Dubbo/HTTP** → 须含 MQ Consumer、Job；`api_type` 每条必填
- **Consumer 当 Provider** → 只提 Provider；Consumer 进 `external_dependencies`
- **MQ 多 Tag 不拆** → 一 Consumer 多 Tag → 多条 API，各 `tag`
- **Job 无 handler** → `job_handler` 必填；cron 拿不到可 `confidence: medium`
- **MQ/Job 无 MS** → 须归 MS；新 MS 或就近域并在 `merge_note` 说明

## 字段

- **无 evidence_chain** → 每实体 ≥1 条 `{source, confidence, type}`；high 须代码/配置直证
- **应用层仍写聚合表** → 须一 concept 一文件；`hierarchy` 写在 frontmatter，勿回退 `{perspective}-entities.md`
- **手写 INDEX 当 SSOT** → INDEX 由扫描/regen 生成；改实体先改 per-entity，再跑 [consolidation-spec.md](references/consolidation-spec.md) 或 `generate_knowledge_index.py`

## README 与归并

- **跳 README 直写 INDEX** → 必先阶段 3 再阶段 4
- **不归并前缀就开写** → 仅允许 `contains_prefixes`；冲突跳过并记
- **单改旧 ID** → 禁；改名须全链更新引用或重跑视角
- **模板占位当真索引** → 无内容标「待补充」；勿用非本应用模板 ID 填满

## 增量

- **skip-existing 漏变体** → 只对确认未变的跳过；变更文件牵涉实体强制重提
- **不写 changes_from_previous** → 增量须在报告或 meta 备注登记增删改与因（统计节可选）

## 速查（完整见 quality-checklist）

- [ ] INDEX 已就绪，未盲扫全仓
- [ ] 写前意图澄清六项 + knowledge 批次路径
- [ ] 顺序 技术→数据→业务→产品
- [ ] API 四类 + `api_type`；仅 Dubbo Provider
- [ ] 每实体一 `{ID}.md`；frontmatter 含 `full_id`
- [ ] 每实体有 evidence_chain
- [ ] 先 README 后 INDEX（扫描/regen）
- [ ] validate 通过后再烤干
- [ ] 写后烤干收敛再 C/M/G/S/F
- [ ] 无单独.rename 旧 ID

完整：[references/quality-checklist.md](references/quality-checklist.md)。
