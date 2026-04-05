# docs-archive 常见陷阱

技能正文见上级 [SKILL.md](SKILL.md)；参考文档索引见 [reference/README.md](reference/README.md)。

---

## 归档锚点

**锚点文件不存在时直接跳过**：`archive-log.yaml` 不存在说明从未归档，应执行全量归档，不能跳过。首次归档后自动创建锚点文件。

**锚点 changelog_id 在 CHANGELOG.md 中找不到**：CHANGELOG.md 可能被重写或条目被删除。此时不能静默降级为全量归档，须警告并请用户确认，否则可能重复归档已归档内容。

**归档写入失败后仍更新锚点**：锚点必须在 **`system/` 下本次归档涉及的全部写入**（含 knowledge/、solutions/、analysis/、requirements/、specs/、changelogs/upstream-from-applications/ 及需更新的导航文件等）均成功，且批次归档文档已生成后，才更新。任一目标写入失败则不更新锚点，保证下次重试从同一位置开始。

**`--full` 参数误用**：`--full` 会忽略锚点重新归档所有内容，可能产生重复 ID 或覆盖系统库已有内容。使用前须确认系统库当前状态，或先备份。

---

## 联邦边界

**在应用库里重复定义全系统业务域**：应用知识库只放本应用的接口细节、Schema、部署参数；跨应用映射、系统边界、聚合与实体 ID 契约属于系统知识库。上行时提炼有效信息，不要把应用库内容整段复制到系统库。

**在系统库里粘贴 OpenAPI 全文**：系统库只保留 `docs_manifest_path` 与 ID 引用，API 细节以应用侧 manifest 为 SSOT。

**knowledge 与 SDD 文档混淆归档规则**：knowledge 归档遵循提炼原则（不整段复制，只写 ID 和摘要）；solutions/analysis/requirements 文档归档遵循直接归档原则（保持文档完整性）。两者规则不同，不要混用。

---

## SDD 文档归档

**归档草稿状态文档**：solutions/analysis 文档状态为 `draft` 时通常不归档；若用户明确要求归档草稿，须在批次归档文档中标注「草稿归档，待评审」。

**归档顺序错误**：同一批次归档多类型内容时，必须按 `knowledge → solutions → analysis → requirements` 顺序执行。analysis 的 `parent` 引用 solutions，requirements 的 `parent` 引用 analysis；顺序错误导致系统库中引用断链。

**requirements 需求包不完整**：归档 `REQUIREMENT-{IDEA-ID}/` 时须整包归档，不能只归档部分 MVP 阶段目录；若应用侧需求包不完整，在批次归档文档中标注「需求包不完整，已归档现有阶段」。

**solutions/analysis 索引表未更新**：归档文档后必须在 `system/solutions/README.md` 和 `system/analysis/README.md` 的索引表中追加对应行，否则导航断链。

---

## ID 与引用

**修改已有实体 ID**：已有实体禁止改 id。需重命名时必须同步更新全部跨视角引用（`implemented_by_app_id`、`persisted_as_entity_ids`、`invokes_api_ids` 等），否则引用链断裂。

**新增 ID 不检查全局唯一性**：新增实体 ID 须全局唯一，先读各视角 `*_meta.yaml` 确认现有 ID，再分配新编号。

**交叉引用写了重复长描述**：关联字段只写 ID，不写重复的名称或描述，避免两处维护失步。

---

## 上行时机与顺序

**未读系统文件就直接写入**：先读拟修改的系统文件与相邻 `*_meta.yaml`，确认现有 ID 和字段结构，再写入。

**应用侧与系统侧冲突时强行覆盖**：冲突时以代码与 manifest 为准，或标为待人工确认，不强行覆盖系统权威域定义。

**变更影响全局导航但未更新索引**：变更影响 `system/SYSTEM_INDEX.md` 或视角 `README.md` 时，必须同步更新，否则导航断链。

---

## 多应用归档

**未指定 `--app` 时通读全部应用**：扫描 `applications/app-*/` 时只做轻量检查（读 `archive-log.yaml` 和 `CHANGELOG.md` 条目数），不通读全部知识库内容，按需加载。

**多应用归档时锚点混淆**：每个应用独立维护 `changelogs/archive-log.yaml`，不共用锚点文件。

---

## 快速自查清单

- [ ] 归档锚点已读取，增量范围已确认（或全量归档已明确授权）
- [ ] 归档顺序正确：knowledge → solutions → analysis → requirements
- [ ] knowledge 归档：应用独有细节仍保留在应用库，未整段复制到系统库
- [ ] knowledge 归档：系统库无大段与 manifest 重复的冗余正文
- [ ] knowledge 归档：已有实体 ID 未被修改；新增 ID 已确认全局唯一
- [ ] knowledge 归档：关联字段只写 ID，无重复长描述
- [ ] knowledge 归档：新增/修改的 YAML 可被解析，无断链 ID
- [ ] SDD 文档归档：仅归档 approved/review 状态文档（或草稿已标注）
- [ ] SDD 文档归档：solutions/analysis 索引表已更新
- [ ] SDD 文档归档：requirements 需求包目录结构完整
- [ ] 变更影响导航时已同步更新 SYSTEM_INDEX 或视角 README
- [ ] 批次归档文档已写入 `system/changelogs/upstream-from-applications/`
- [ ] 归档锚点已在写入成功后更新（`archive-log.yaml` 已追加新记录）
