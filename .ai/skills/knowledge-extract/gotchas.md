# knowledge-extract 常见陷阱（Gotchas）

本文记录执行 `knowledge-extract` Skill 时高频踩坑点，供 Agent 与人类开发者参考。

---

## 1. 初始化阶段

### 1.1 主 Index Guide 不可用时仍继续提取
**陷阱**：主 Index Guide 未落盘或路径错误，Agent 仍尝试从目录结构猜测实体。  
**后果**：无权威地图驱动，提取结果充斥幻觉 ID，证据链无法验证。  
**正确做法**：主 Index Guide 不可用时立即终止，提示用户先运行 `/document-indexing`。

### 1.2 通读全仓源码再开始提取
**陷阱**：为求「完整」，一次性打开全部源码文件再动笔。  
**后果**：上下文爆炸，耗时极长，且大量读取内容与本轮提取视角无关。  
**正确做法**：按需加载——仅在本轮任务需要时打开文件；以主 INDEX 为导航，只读与当前视角直接相关的文件。

---

## 2. 提取阶段：视角顺序与依赖

### 2.1 打乱四视角提取顺序
**陷阱**：先提取产品视角，再提取技术视角，或并行提取所有视角。  
**后果**：产品视角依赖技术视角的 MS-*、API-* ID，业务视角依赖技术视角的 MS-*；顺序错误导致跨视角引用为空或错误。  
**正确做法**：严格按固定顺序执行：技术 → 数据 → 业务 → 产品；后续视角只引用前序视角已提取的 ID，不修改前序输出。

### 2.2 后续视角修改前序视角的输出文件
**陷阱**：业务视角提取时发现技术视角某 MS-* 描述不准确，直接修改 `technical_knowledge.json`。  
**后果**：破坏视角分离原则，前序视角输出不再幂等，重跑时产生冲突。  
**正确做法**：后续视角只读前序视角 ID 作为引用，不写入前序视角文件；需修正前序视角时单独重跑该视角。

---

## 3. 提取阶段：实体 ID 生成

### 3.1 用 Maven 模块名作为 MS-ID
**陷阱**：把 `billing-appeal-service` 这样的 Maven 模块名直接作为 MS 别名。  
**后果**：一个模块可能包含多个宿主类，导致 MS-ID 粒度过粗，API 归属混乱。  
**正确做法**：MS-ID 按宿主类聚类，别名取宿主类 SimpleName 去后缀（如 `BillingAppealApiImpl` → `BillingAppeal`）。

### 3.2 同一张表对应多个 ENT-ID
**陷阱**：同一数据库表有多个 Java 实体类（如主表和历史表映射到同一物理表），分别生成多个 ENT-ID。  
**后果**：违反「同表合并」规则，跨视角引用时 `persisted_as_entity_ids` 出现重复指向。  
**正确做法**：相同 `physical_table` 的实体类合并为一个 ENT-ID，在 `logical_name` 中列出所有 Java 类名。

### 3.3 AGG-ID 无对应 MS-* 服务
**陷阱**：从文档描述或包名推断出一个聚合，但找不到对应的 MS-* 宿主类，仍生成 AGG-ID。  
**后果**：`implemented_by_service_ids` 为空，AGG 与技术实现断链，跨视角对称性检查失败。  
**正确做法**：AGG-ID 必须有对应的 MS-* 服务；无 MS-* 对应时标记为待补充，不生成无根 AGG-ID。

### 3.4 FT/UC 无 API 绑定
**陷阱**：从 PRD 或 README 描述中提取功能特性，但未找到对应 API-ID，仍生成 FT-ID 或 UC-ID。  
**后果**：`invokes_api_ids` 为空，功能特性与技术实现断链，产品视角失去可追溯性。  
**正确做法**：FT 和 UC 必须绑定至少一个 API-ID；无 API 对应时标记为待补充，不生成无根 FT/UC-ID。

### 3.5 编造未读文件中的实体
**陷阱**：未实际读取某源码文件，却根据类名猜测其方法签名或表结构，写入证据链。  
**后果**：证据链指向未读内容，验证时无法核实，产出含幻觉 ID。  
**正确做法**：零幻觉原则——只从已读文件提取 ID；未读路径不写成已核实证据，标注 `confidence: low` 并说明原因。

---

## 4. 提取阶段：字段完整性

### 4.1 缺少 evidence_chain 字段
**陷阱**：实体 ID 生成后未填写 `evidence_chain`，或只写 `"source": "推断"`。  
**后果**：归并阶段证据链验证失败；后续 Agent 无法核实 ID 来源，可信度为零。  
**正确做法**：每个实体必须有至少一条可验证证据，格式为 `{ source, confidence, type }`；`high` 置信度须来自代码或配置直接确认。

### 4.2 技术视角 entities 使用扁平数组
**陷阱**：技术视角输出时将 `entities` 写成扁平数组 `[...]`，与其他三视角格式一致。  
**后果**：归并阶段解析 `entities.systems`、`entities.services` 等字段时报错，索引更新失败。  
**正确做法**：技术视角 `entities` 必须是分类对象 `{ systems, applications, services, apis }`；其余三视角才使用扁平数组。

### 4.3 metadata 节缺失或字段不完整
**陷阱**：`*_knowledge.json` 尾部未包含 `metadata` 节，或缺少 `total_entities`、`extraction_basis` 等字段。  
**后果**：归并阶段统计数无法校验，`changes_from_previous` 缺失导致增量追踪断链。  
**正确做法**：每个 `*_knowledge.json` 必须包含完整 `metadata` 节，含各层级数量统计、`extraction_basis`、`schema_notes`、`changes_from_previous`。

---

## 5. 归并阶段

### 5.1 跳过前缀验证直接写入索引
**陷阱**：归并时未校验实体 ID 前缀是否在 `contains_prefixes` 定义范围内，直接写入 `KNOWLEDGE_INDEX.md`。  
**后果**：非法前缀（如 `SVC-`、`MOD-`）混入索引，破坏全知识库唯一性约束。  
**正确做法**：归并前必须执行前缀验证，仅接受内置 `contains_prefixes` 所列前缀；冲突项跳过并记录日志。

### 5.2 跳过对称性检查
**陷阱**：四视角提取完毕后直接更新 `KNOWLEDGE_INDEX.md`，未检查 §1～§4 是否同轮维护。  
**后果**：某视角（如产品视角）为空模板，其他视角已有实质内容，索引四节严重不对称。  
**正确做法**：归并前执行 `same_round_four_sections` 规则检查；`bc_agg_linkage` 规则要求 §1 已登记 BC/AGG 时 §3 或 §4 必须有证据行。

### 5.3 更改已有实体 ID 或破坏跨视角引用
**陷阱**：发现某 ID 命名不规范，直接在 `KNOWLEDGE_INDEX.md` 中改名，未同步更新所有 `cross_references`。  
**后果**：`implemented_by_service_ids`、`persisted_as_entity_ids`、`invokes_api_ids` 等引用字段指向已失效 ID，知识库引用链断裂。  
**正确做法**：禁止单独修改已有 ID；需重命名时必须同步更新全部跨视角引用，或重跑受影响视角。

### 5.4 以模板占位行作为索引唯一内容
**陷阱**：某视角无实质提取结果，直接将模板示例行（如 `SYS-EXAMPLE`）保留在 `KNOWLEDGE_INDEX.md` 中。  
**后果**：违反 `no_template_only` 规则，索引内容为虚假数据，误导后续 Agent。  
**正确做法**：无实质内容时该节留空并标注「待补充」，禁止以非本应用模板 ID 作为索引唯一内容。

---

## 6. 增量提取

### 6.1 `--skip-existing true` 时漏更新变更实体
**陷阱**：增量提取时跳过所有已有 ID，包括因代码重构而发生变化的实体。  
**后果**：已变更实体的 `method_signature`、`physical_table`、`cross_references` 等字段未更新，索引与代码不同步。  
**正确做法**：`--skip-existing` 仅跳过确认未变更的实体；基于 `document-change` 的变更文件列表，对变更文件涉及的实体强制重提取。

### 6.2 增量提取后未填写 `changes_from_previous`
**陷阱**：增量更新后 `metadata.changes_from_previous` 仍为空或写「无变化」。  
**后果**：无法追踪知识库演进历史，审计和回溯困难。  
**正确做法**：每次增量提取必须在 `metadata.changes_from_previous` 中描述新增、修改、删除的实体 ID 及原因。

---

## 快速检查清单

执行完毕后，对照以下项目快速自查：

- [ ] 主 Index Guide 已落盘且可用
- [ ] 四视角按技术 → 数据 → 业务 → 产品顺序执行
- [ ] 技术视角 `entities` 为分类对象，其余三视角为扁平数组
- [ ] 每个实体含完整 `evidence_chain`，无无证据写入
- [ ] MS-ID 按宿主类聚类，非 Maven 模块名
- [ ] 同一物理表只有一个 ENT-ID
- [ ] AGG-ID 均有对应 MS-* 服务
- [ ] FT/UC-ID 均绑定至少一个 API-ID
- [ ] 所有 ID 前缀在 `contains_prefixes` 范围内
- [ ] `KNOWLEDGE_INDEX.md` §1～§4 同轮维护，无模板占位行
- [ ] 已有 ID 未被单独改名（跨视角引用完整）
- [ ] 每个 `*_knowledge.json` 含完整 `metadata` 节
- [ ] 增量提取已填写 `changes_from_previous`
