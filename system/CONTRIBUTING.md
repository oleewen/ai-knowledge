# 贡献指南

欢迎参与维护全局软件系统知识文档库。请遵循以下约定，以保持单一事实源与映射一致性。

---

## 一、业务知识 (knowledge)

知识库主体（宪法层与四视角）的新增、修改与治理约定。各视角的**目录结构、索引表与字段约定**以对应 README 为准：

- `knowledge/business/README.md`（BD/BSD/BC/AGG 与映射字段）
- `knowledge/product/README.md`（PL/PM/FT/UC 与映射字段）
- `knowledge/technical/README.md`（SYS/APP/MS 与应用注册约定）
- `knowledge/data/README.md`（DS/ENT 与数据映射字段）

### 1.1 架构决策记录 (ADR)

- 涉及跨域、跨系统或影响深远的架构变更，请在 **knowledge/constitution/adr/** 下新增 ADR。
- 文件名：`ADR-{序号}-{短标题}.md`，例如 `ADR-002-api-versioning.md`。
- 内容结构参考 [knowledge/constitution/standards/adr-template.md](./knowledge/constitution/standards/adr-template.md)：状态、上下文、决策、后果（正面/负面）。

### 1.2 ID 引用规则

- 所有跨文件、跨视角的关联**只写 ID**，不重复写名称或描述。
- 引用的 ID 必须在对应视角中存在对应文件或 `_meta` 定义；后续将提供 CLI 校验。

### 1.3 提交与评审

- 提交前请确认：新增 YAML 可被正常解析；ID 无拼写错误；映射关系与 DESIGN.md 中的约定一致。
- 修改已有实体时，注意检查是否有其他文件通过 ID 引用该实体，避免断链。

---

## 二、解决方案 (solutions)

业务诉求的解决方案文档的新增与维护。

- 在 **solutions/**（与 knowledge 平级）下创建 `SOLUTION-{ID}.md`，ID 建议为 `{YYYYMMDD}-{SEQ}` 或项目约定编号。
- 参考模板 [.ai/rules/solution/solution-template.md](./.ai/rules/solution/solution-template.md)，阶段规范见 [.ai/skills/sdx-solution/SKILL.md](./.ai/skills/sdx-solution/SKILL.md)。
- 已完结或废弃的解决方案可移入 **solutions/archive/**。

---

## 三、需求分析 (analysis)

需求分析文档的新增与维护。

- 在 **analysis/**（与 knowledge 平级）下创建 `REQUIREMENT-{ID}.md`，文档 frontmatter 中 `parent` 指向对应的 SOLUTION。
- 参考模板 [.ai/rules/analysis/requirement-template.md](./.ai/rules/analysis/requirement-template.md)，阶段规范见 [.ai/skills/sdx-analysis/SKILL.md](./.ai/skills/sdx-analysis/SKILL.md)。

---

## 四、需求交付 (requirements)

需求交付文档的新增与维护。

- 在 **requirements/** 下以 `REQUIREMENT-{ID}/` 创建目录，每个需求一个目录。
- 目录下按阶段（如 `MVP-Phase-1/`）新建子目录，子目录内可包含 PRD.md、ADD.md、TDD.md 等交付文档。
- 各文档应遵循项目约定的模板，确保与分析、解决方案等环节一致。

---

## 五、需求规约 (specs)

需求/服务规格文档的新增与维护。

- 在 **specs/** 目录下，按服务或规约类型创建子目录（如 `example-service/`）。
- 子目录内可维护接口说明、契约、数据字典等，具体结构和命名根据实际项目约定。
- 需求分析与解决方案文档可引用此处的规格以避免重复定义。

---

更多设计约定见 [DESIGN.md](./DESIGN.md)，索引与示例见 [INDEX.md](./INDEX.md)。
