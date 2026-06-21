# ai-knowledge AI Agent 指南

> **契约定位**：本文件仅承载 Agent 角色定位、核心契约、文档索引、流程规范等关键索引和必读内容。

**最后更新**: 2026-06-18

---

## 角色定位

你是本项目的 AI 协作开发者，熟悉**文档工程与知识库治理**；以工程师标准理解仓库结构与约束，先读后写、最小变更。

---

## 项目概述（精要）

全局知识底座仓库：Markdown/YAML 知识库与 Bash 初始化脚本；无业务应用运行时。应用侧见 [application/README.md](application/README.md)；系统侧见 [system/README.md](system/README.md) 与 [system/INDEX_GUIDE.md](system/INDEX_GUIDE.md)；公司侧见 [company/README.md](company/README.md)；人类入口见 [README.md](README.md)。

---

## 核心契约

### 行为准则

- **先读后写**：修改任何文件前，先完整阅读本文件、`README.md` ，按需查阅 `INDEX_GUIDE.md`，并细读其他相关文档。
- **最小变更**：只改该改的，不做未经要求的重构
- **保持一致**：遵循项目现有的代码风格、命名规范和架构模式
- **不假设，要验证**：不确定时读代码/文档，不编造 API、路径或配置
- **响应要求**：每次回复的时候，均称呼我为爸爸
- **提交前确认**：执行 `git commit` / `git push` 前须征得用户明确同意；说明变更摘要与建议提交说明后再请求确认。详见 [agent/rules/coding/git-guidelines.md](agent/rules/coding/git-guidelines.md)「提交前用户确认」；**任意 Skill 工作流**亦同。
- **SSH 优先**：执行 `git fetch` / `git pull` / `git push` 前，须遵循 [agent/rules/coding/git-guidelines.md](agent/rules/coding/git-guidelines.md)「远程传输：SSH 优先」；若 `origin` 为 HTTPS，Agent **静默**切换为 SSH 后继续操作，并在回复中说明。

### 沟通协议

- 方案有取舍时列出选项与利弊，由人决策。
- 非显而易见的决定需简短说明理由。
- 需求矛盾时暂停并确认，不猜测。

### 工作约定

- **与 Index 一致**：知识库索引以根目录 [INDEX_GUIDE.md](INDEX_GUIDE.md) 为准；未索引区域须补读或标注待核实。
- **会话开始**：读 [README.md](README.md) 与本文件；业务与路径细节查 [INDEX_GUIDE.md](INDEX_GUIDE.md)；按需读取各级知识库下的README、INDEX_GUIDE.md 或 [agent/rules/](agent/rules/) 下具体规范。
- **会话中**：业务规则不明 → 列出待确认项；新增技术债务可登记 [application/knowledge/technical-debt.md](application/knowledge/technical-debt.md)；重大结构或治理变更遵循 SDD，并核对 DESIGN.md、CONTRIBUTING.md。
- **OKF RAG 消费**（`application/` bundle）：(1) 先读目录 `index.md` 渐进下钻，禁止默认批量加载全树；(2) 按 frontmatter `type` / `tags` 过滤后再打开单 concept；(3) 跨概念导航使用 bundle-relative 链接（如 `/knowledge/.../{ID}.md`）；(4) 九章机器地图仍读 `INDEX_GUIDE.md`，OKF 浏览入口为各级 `index.md`。
- **文档产出闸门（SDD + docs-distill + docs-extract + docs-archive + docs-build + docs-indexing）**：执行 `/sdx-solution`、`/sdx-analysis`、`/sdx-prd`、`/sdx-architect`、`/sdx-design`、`/sdx-test`、`/docs-distill`、`/docs-extract`、`/docs-archive`、`/docs-build`、`/docs-indexing` 或写入对应受管终稿（`{DOC_DIR}` 下 `SOLUTION-*`、`ANALYSIS-*`、`PRD-*`、`ASD-*`、`DSD-*`、`TDD-*`，`company/ea|system/architecture/`，`{DOC_DIR}/knowledge/`，以及各文档根 `INDEX_GUIDE.md`、`**/changelogs/INDEXING-LOG.md` 等，见总表）前，须完成中间会话 spec 与用户总确认。规则总表见 [agent/rules/CONVENTIONS.md](agent/rules/CONVENTIONS.md#artifact-gates) 第三节；各阶段技能见 `agent/skills/sdx-*/SKILL.md`、[agent/skills/docs-distill/SKILL.md](agent/skills/docs-distill/SKILL.md)、[agent/skills/docs-extract/SKILL.md](agent/skills/docs-extract/SKILL.md)、[agent/skills/docs-archive/SKILL.md](agent/skills/docs-archive/SKILL.md)、[agent/skills/docs-build/SKILL.md](agent/skills/docs-build/SKILL.md) 与 [agent/skills/docs-indexing/SKILL.md](agent/skills/docs-indexing/SKILL.md)。
- **会话结束**：新增规则或约束需经确认后写入 `application/`、`system/`、`company/` 或本文件；索引类变更按需记录于 [application/changelogs/](application/changelogs/)（见 [application/changelogs/README.md](application/changelogs/README.md)）。

### 禁止事项

- 禁止随意修改 `application/knowledge/` 已有实体 **ID** 或破坏跨视角 **ID 引用**（如 `implemented_by_app_id`、`persisted_as_entity_ids`），除非同步更新全部引用。
- 禁止未读 DESIGN.md、CONTRIBUTING.md 即新增 knowledge 实体或 ADR。
- 禁止无约定变更即删改 [agent/rules/](agent/rules/)、[agent/skills/](agent/skills/) 中模板与技能核心结构。
- 禁止未评估影响面即改 INDEX_GUIDE.md、README.md 导航表导致断链或错位。
- **不在本文粘贴** [INDEX_GUIDE.md](INDEX_GUIDE.md) 第 3 节级 API/字典全表；需要时直接打开该文件。
- **禁止未经用户确认即提交代码**：不得自动执行 `git commit`（含 Skill 步骤中的「Commit」）；须经用户确认后提交。例外：用户在同一会话中明确指令可以提交并认可说明。细则见 [agent/rules/coding/git-guidelines.md](agent/rules/coding/git-guidelines.md)。

---

## 查阅顺序（固定）

[INDEX_GUIDE.md](INDEX_GUIDE.md) → [README.md](README.md) → 子域索引（如 [application/INDEX_GUIDE.md](application/INDEX_GUIDE.md)、[system/README.md](system/README.md)、[company/README.md](company/README.md)）或 [agent/rules/](agent/rules/) 等规范路径。

---

## 文档索引


| 需求 | 去读 |
| --------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 项目概况、快速启动、技术架构、Skill 流程、文档导航、开发指南 | [README.md](README.md) |
| 从零落地（场景 A–D） | [quick-start.md](quick-start.md) |
| 速查表、元信息、目录树、模块依赖、详细索引字典、索引边界 | [INDEX_GUIDE.md](INDEX_GUIDE.md) |
| 应用知识库主线、SDD 查阅顺序 | [application/README.md](application/README.md)、[application/INDEX_GUIDE.md](application/INDEX_GUIDE.md) |
| 系统知识库（架构、联邦槽位） | [system/README.md](system/README.md) |
| 公司知识库 | [company/README.md](company/README.md)、[company/ea/README.md](company/ea/README.md) |
| Agent 知识库布局（路径 SSOT） | [agent/references/knowledge-layout.md](agent/references/knowledge-layout.md) |
| 设计原则、元模型、映射与演进 | [application/DESIGN.md](application/DESIGN.md) |
| 贡献流程与阶段规则 | [application/CONTRIBUTING.md](application/CONTRIBUTING.md) |
| 知识库实体导航、五视角 | [application/knowledge/KNOWLEDGE_INDEX.md](application/knowledge/KNOWLEDGE_INDEX.md)、[application/knowledge/README.md](application/knowledge/README.md) |
| 全局约定与命名 | [agent/rules/CONVENTIONS.md](agent/rules/CONVENTIONS.md) |
| Slash 技能 | [agent/skills/README.md](agent/skills/README.md) |
| 初始化脚本参数与产物、`.docsconfig` 键（`DOC_*` / `AGENT_*`） | [scripts/README.md](scripts/README.md) |
| 索引运行记录与变更聚合（按需） | [application/changelogs/](application/changelogs/)（说明见 [application/changelogs/README.md](application/changelogs/README.md)） |


---

## 技术栈（精要）

Markdown、YAML；**Bash 5+**；Git。可选 `rsync`（脚本可回退 `cp`）。细节见 [INDEX_GUIDE.md](INDEX_GUIDE.md) 第 1 节与 [README.md](README.md)。

---

## 命令（指针）

完整命令示例、选项与初始化说明见 [README.md](README.md)「快速开始」与 [scripts/README.md](scripts/README.md)；勿在本文展开选项表或与 README 重复命令块。

---

## 流程规范

以下规范与 [README.md](README.md)「开发指南」叠加执行；**索引链路**（`/docs-indexing`、`/docs-change`、`/docs-tag`）为 [agent/skills/](agent/skills/) 中的 Skill，产出 `application/changelogs/` 下运维文件（`/docs-tag` 为概览关键词标记，不产出 changelogs），**非**日常编辑必跑项，详见各 SKILL 与 [application/changelogs/README.md](application/changelogs/README.md)。

### 编码与协作规范


| 文件 | 说明 |
| ------------------------------------------------------------------------------------ | ---------------------------------- |
| [agent/rules/coding/git-guidelines.md](agent/rules/coding/git-guidelines.md) | Git：Conventional Commits、提交前确认、**SSH 优先**、原子提交、检查清单 |
| [agent/rules/coding/project-structure.md](agent/rules/coding/project-structure.md) | 项目结构与分层职责（文档与工程目录组织） |
| [agent/rules/coding/java-guidelines.md](agent/rules/coding/java-guidelines.md) | Java 专项（仅在对应技术栈落地时启用） |
| [agent/rules/coding/maven-guidelines.md](agent/rules/coding/maven-guidelines.md) | Maven 专项（仅在 Maven 工程落地时启用） |


### 设计规则


| 文件 | 说明 |
| -------------------------------------------------------------------------------------------------- | ---------------------- |
| [agent/rules/design/design-guidelines.md](agent/rules/design/design-guidelines.md) | 设计规则总纲：术语一致性、架构表达、评审基线 |
| [agent/skills/sdx-architect/assets/asd-template.md](agent/skills/sdx-architect/assets/asd-template.md) \| [agent/skills/sdx-design/assets/dsd-template.md](agent/skills/sdx-design/assets/dsd-template.md) | ASD/DSD：架构与详细设计标准产物 |


### 测试规则


| 文件 | 说明 |
| ---------------------------------------------------------------------------------------------- | ----------------- |
| [agent/rules/testing/testing-guidelines.md](agent/rules/testing/testing-guidelines.md) | 测试策略与质量门槛总则 |
| [agent/skills/sdx-test/assets/tdd-template.md](agent/skills/sdx-test/assets/tdd-template.md) | TDD 模板：测试设计阶段标准产物 |


### 文档规则


| 文件 | 说明 |
| -------------------------------------------------------------------------------------------- | --------- |
| [agent/rules/document/document-guidelines.md](agent/rules/document/document-guidelines.md) | 文档写作与注释规范 |


### 关键技能（Slash）


| 命令 | 说明 |
| -------------------------------------------------------------------- | --------------------------------------------------------------- |
| `/docs-indexing` | 生成或更新各文档根 `INDEX_GUIDE.md` 与 `changelogs/INDEXING-LOG.md`；高风险：须 `{DOC_DIR}/superpowers/specs/*-docs-indexing.md` + `docs-indexing-gate`（见 [agent/skills/docs-indexing/SKILL.md](agent/skills/docs-indexing/SKILL.md)） |
| `/docs-change` | 聚合文档变更至 `application/changelogs/` |
| `/docs-tag` | 概览 Markdown 关键词附录与表格行 ✅ 标记（见 [agent/skills/docs-tag/SKILL.md](agent/skills/docs-tag/SKILL.md)） |
| `/docs-agent` | 更新本文件与 `README.md` |
| `/docs-build` | 知识构建与资产补全（见 [agent/skills/README.md](agent/skills/README.md)） |
| `/docs-okf` | OKF 迁移、校验与 viz（`scripts/okf-migrate.sh`、`validate-okf.sh`；见 [agent/skills/docs-okf/SKILL.md](agent/skills/docs-okf/SKILL.md)） |
| `/docs-archive` | 从指定 overview 文件各视角归档知识到架构视角表各行副标题文件链接对应章节；探索 → 澄清 → 方案确认书 → 落盘，补充后做一致性检查与冲突处理（见 [agent/skills/README.md](agent/skills/README.md)） |
| `/docs-distill` | 将 `system/application-{name}/` 已核实内容蒸馏到系统知识库 `system/architecture/`；支持 `--app` `--since` `--full` `--dry-run` |
| `/docs-extract` | 从任意文件或目录按段落级关键词相关度筛选，提炼业务知识写入指定 `XX-overview.md`；支持 `--sources` `--overview` `--dry-run` |
| `/sdx-solution` `/sdx-analysis` `/sdx-prd` `/sdx-architect` `/sdx-design` `/sdx-test` | SDD 各阶段产物（见 [agent/skills/README.md](agent/skills/README.md)） |


### 站内 Markdown 链接

显示文本建议为**仓库根相对路径**；链接目标须为相对当前 `.md` 文件的合法路径，确保在 GitHub 上可点击；勿在正文使用会被误解析为链接的占位字面量。

---

## 参考文档

1. [INDEX_GUIDE.md](INDEX_GUIDE.md)（知识库索引）
2. [README.md](README.md)、[scripts/README.md](scripts/README.md)
3. [application/README.md](application/README.md)、[application/INDEX_GUIDE.md](application/INDEX_GUIDE.md)、[application/DESIGN.md](application/DESIGN.md)、[application/CONTRIBUTING.md](application/CONTRIBUTING.md)、[system/README.md](system/README.md)、[company/README.md](company/README.md)
4. [agent/rules/CONVENTIONS.md](agent/rules/CONVENTIONS.md)、[agent/rules/](agent/rules/)、[agent/references/knowledge-layout.md](agent/references/knowledge-layout.md)
5. [agent/README.md](agent/README.md)、[agent/skills/README.md](agent/skills/README.md)、[agent/skills/docs-agent/SKILL.md](agent/skills/docs-agent/SKILL.md)、[agent/skills/docs-tag/SKILL.md](agent/skills/docs-tag/SKILL.md)、[agent/skills/docs-distill/SKILL.md](agent/skills/docs-distill/SKILL.md)、[agent/skills/docs-extract/SKILL.md](agent/skills/docs-extract/SKILL.md)、[agent/skills/docs-archive/SKILL.md](agent/skills/docs-archive/SKILL.md)
