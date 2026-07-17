# ai-knowledge AI Agent 指南

> **契约定位**：本文件仅承载 Agent 角色定位、核心契约、文档索引、流程规范等关键索引和必读内容。

**最后更新**: 2026-07-03

---

## 角色定位

你是本项目的 AI 协作开发者，熟悉**文档工程与知识库治理**；以工程师标准理解仓库结构与约束，先读后写、最小变更。

---

## 项目概述（精要）

全局知识底座：Markdown/YAML + Bash 初始化脚本，无业务运行时。人类入口 [README.md](README.md)；九章地图 [INDEX-GUIDE.md](INDEX-GUIDE.md)；目录索引页 [index.md](index.md)；应用 / 系统 / 公司见 [application/README.md](application/README.md)、[system/README.md](system/README.md)、[company/README.md](company/README.md)。

---

## 核心契约

### 行为准则

- **先读后写**：修改任何文件前，先完整阅读本文件、`README.md` ，按需查阅 `index.md`，并细读其他相关文档。
- **最小变更**：只改该改的，不做未经要求的重构
- **保持一致**：遵循项目现有的代码风格、命名规范和架构模式
- **不假设，要验证**：不确定时读代码/文档，不编造 API、路径或配置
- **响应要求**：Agent输出尽量图形化、表格化、HTML格式化，有重点有突出的输出；下一步行动建议，必须提供数字编号快捷选项。
- **执行要求**：每次新开会话或 clear 上下文后，必须先自动执行一次 `/caveman` Skill。
- **提交前确认**：执行 `git commit` / `git push` 前须征得用户明确同意；说明变更摘要与建议提交说明后再请求确认。详见 [agent/rules/coding/git-guidelines.md](agent/rules/coding/git-guidelines.md)「提交前用户确认」；**任意 Skill 工作流**亦同。
- **SSH 优先**：执行 `git fetch` / `git pull` / `git push` 前，须遵循 [agent/rules/coding/git-guidelines.md](agent/rules/coding/git-guidelines.md)「远程传输：SSH 优先」；若 `origin` 为 HTTPS，Agent **静默**切换为 SSH 后继续操作，并在回复中说明。

### 沟通协议

- 方案有取舍时列出选项与利弊，由人决策。
- 非显而易见的决定需简短说明理由。
- 需求矛盾时暂停并确认，不猜测。

### 工作约定

- **与 Index Guide 一致**：九章索引指南以根目录 [INDEX-GUIDE.md](INDEX-GUIDE.md) 为准；目录与渐进披露入口见根目录 [index.md](index.md)；未索引区域须补读或标注待核实。
- **会话开始**：读 [README.md](README.md) 与本文件；业务与路径细节查 [INDEX-GUIDE.md](INDEX-GUIDE.md)；目录下钻与 OKF 渐进披露查 [index.md](index.md)；按需读取各级知识库下的 README、`INDEX-GUIDE.md`、`index.md` 或 [agent/rules/](agent/rules/) 下具体规范。
- **会话中**：业务规则不明 → 列出待确认项；新增技术债务可登记 [application/knowledge/technical-debt.md](application/knowledge/technical-debt.md)；重大结构或治理变更遵循 SDD，并核对 DESIGN.md、CONTRIBUTING.md。
- **OKF RAG 消费**（`application/` bundle）：(1) 先读目录 `index.md` 渐进下钻，禁止默认批量加载全树；(2) 按 frontmatter `type` / `tags` 过滤后再打开单 concept；(3) 跨概念导航使用 bundle-relative 链接（如 `/knowledge/.../{ID}.md`）；(4) 九章机器地图读 `INDEX-GUIDE.md`，OKF 浏览入口为各级 `index.md`。
- **文档产出协议（SDD + docs-*）**：执行 `/sdx-solution`、`/sdx-analysis`、`/sdx-prd`、`/sdx-architect`、`/sdx-design`、`/sdx-test`、`/docs-distill`、`/docs-extract`、`/docs-archive`、`/docs-build`、`/docs-indexing`、`/docs-upgrade`、`/docs-agent` 时，目标主线为“参数向导 → **澄清 → 生成 → 烤干** → 用户动作推进”；上述技能均已绑定写前[意图澄清](agent/references/intent-clarify.md)。语义性变更须先确认。`/docs-okf`、`/docs-change`、`/docs-tag`、`/docs-pull`、`/docs-push` 保持各自独立轻流程。规则总表见 [agent/rules/CONVENTIONS.md](agent/rules/CONVENTIONS.md#artifact-gates) 第三节；各阶段技能见 `agent/skills/sdx-*/SKILL.md`、[agent/skills/docs-distill/SKILL.md](agent/skills/docs-distill/SKILL.md)、[agent/skills/docs-extract/SKILL.md](agent/skills/docs-extract/SKILL.md)、[agent/skills/docs-archive/SKILL.md](agent/skills/docs-archive/SKILL.md)、[agent/skills/docs-build/SKILL.md](agent/skills/docs-build/SKILL.md)、[agent/skills/docs-indexing/SKILL.md](agent/skills/docs-indexing/SKILL.md)、[agent/skills/docs-upgrade/SKILL.md](agent/skills/docs-upgrade/SKILL.md) 与 [agent/skills/docs-okf/SKILL.md](agent/skills/docs-okf/SKILL.md)。
- **会话结束**：新增规则或约束需经确认后写入 `application/`、`system/`、`company/` 或本文件；索引类变更按需记录于 [application/changelogs/](application/changelogs/)（见 [application/changelogs/README.md](application/changelogs/README.md)）。

### 禁止事项

- 禁止随意修改 `application/knowledge/` 已有实体 **ID** 或破坏跨视角 **ID 引用**（如 `implemented_by_app_id`、`persisted_as_entity_ids`），除非同步更新全部引用。
- 禁止未读 DESIGN.md、CONTRIBUTING.md 即新增 knowledge 实体或 ADR。
- 禁止无约定变更即删改 [agent/rules/](agent/rules/)、[agent/skills/](agent/skills/) 中模板与技能核心结构。
- 禁止未评估影响面即改 index.md、README.md 导航表导致断链或错位。
- **不在本文粘贴** [index.md](index.md) 第 3 节级 API/字典全表；需要时直接打开该文件。
- **禁止库外引用 superpowers 具名文件**：除 `{docroot}/superpowers/**` 内部外，不得出现 `…/superpowers/(specs|plans)/YYYY-MM-DD-*.md` 字面量或 Markdown 链接；目录契约与占位符允许。验收见 [agent/rules/CONVENTIONS.md](agent/rules/CONVENTIONS.md#superpowers-ref-isolation)。
- **禁止未经用户确认即提交代码**：不得自动执行 `git commit`（含 Skill 步骤中的「Commit」）；须经用户确认后提交。例外：用户在同一会话中明确指令可以提交并认可说明。细则见 [agent/rules/coding/git-guidelines.md](agent/rules/coding/git-guidelines.md)。

---

## 查阅顺序（固定）

[INDEX-GUIDE.md](INDEX-GUIDE.md) → [README.md](README.md) → 子域索引（如 [application/index.md](application/index.md)、[system/README.md](system/README.md)、[company/README.md](company/README.md)）或 [agent/rules/](agent/rules/) 等规范路径。

---

## 文档索引

| 需求 | 去读 |
| --- | --- |
| 概况、快速启动、工作流总览 | [README.md](README.md) |
| 从零落地（场景 A–D） | [quick-start.md](quick-start.md) |
| 九章地图、目录树、Skill 路径索引 | [INDEX-GUIDE.md](INDEX-GUIDE.md) |
| 目录索引与渐进披露 | [index.md](index.md) |
| 应用 / 系统 / 公司知识库 | [application/README.md](application/README.md)、[system/README.md](system/README.md)、[company/README.md](company/README.md) |
| 元模型与贡献 | [application/DESIGN.md](application/DESIGN.md)、[application/CONTRIBUTING.md](application/CONTRIBUTING.md) |
| 全局约定、Slash 技能 | [agent/rules/CONVENTIONS.md](agent/rules/CONVENTIONS.md)、[agent/skills/README.md](agent/skills/README.md) |
| 初始化脚本、`.docsconfig` | [scripts/README.md](scripts/README.md) |
| OKF 迁移与校验 | [agent/skills/docs-okf/SKILL.md](agent/skills/docs-okf/SKILL.md) |
| 变更与索引运维（按需） | [application/changelogs/](application/changelogs/) |

---

## 技术栈（精要）

Markdown、YAML；**Bash 5+**；Git；可选 `rsync`。详 [INDEX-GUIDE.md](INDEX-GUIDE.md) §1.2、[README.md](README.md)。

---

## 命令（指针）

完整命令见 [README.md](README.md)「快速开始」与 [scripts/README.md](scripts/README.md)；勿在本文展开选项表。

---

## 流程规范

以下与 [README.md](README.md) 叠加；索引链路（`/docs-indexing`、`/docs-change`、`/docs-tag`）与 OKF 维护（`/docs-okf`）产出 `application/changelogs/` 等运维文件，**非**日常必跑，见各 SKILL。

Slash 技能见 [agent/skills/README.md](agent/skills/README.md)；产出协议见 [agent/rules/CONVENTIONS.md](agent/rules/CONVENTIONS.md#artifact-gates)。

### 编码与协作规范

| 文件 | 说明 |
| --- | --- |
| [agent/rules/coding/git-guidelines.md](agent/rules/coding/git-guidelines.md) | Git：Conventional Commits、提交前确认、**SSH 优先** |
| [agent/rules/coding/project-structure.md](agent/rules/coding/project-structure.md) | 项目结构与分层职责 |
| [agent/rules/coding/java-guidelines.md](agent/rules/coding/java-guidelines.md) | Java 专项（按需） |
| [agent/rules/coding/maven-guidelines.md](agent/rules/coding/maven-guidelines.md) | Maven 专项（按需） |

### 设计 / 测试 / 文档规则

| 文件 | 说明 |
| --- | --- |
| [agent/rules/design/design-guidelines.md](agent/rules/design/design-guidelines.md) | 设计规则总纲 |
| [agent/skills/sdx-architect/assets/asd-template.md](agent/skills/sdx-architect/assets/asd-template.md) \| [agent/skills/sdx-design/assets/dsd-template.md](agent/skills/sdx-design/assets/dsd-template.md) | ASD / DSD 模板 |
| [agent/rules/testing/testing-guidelines.md](agent/rules/testing/testing-guidelines.md) | 测试策略总则 |
| [agent/skills/sdx-test/assets/tdd-template.md](agent/skills/sdx-test/assets/tdd-template.md) | TDD 模板 |
| [agent/rules/document/document-guidelines.md](agent/rules/document/document-guidelines.md) | 文档写作规范 |

### 站内 Markdown 链接

显示文本建议为**仓库根相对路径**；链接目标须为相对当前 `.md` 文件的合法路径；勿在正文使用会被误解析为链接的占位字面量。

---

## 参考文档

1. [INDEX-GUIDE.md](INDEX-GUIDE.md) — 九章路径地图与 Skill 路径索引
2. [README.md](README.md)、[scripts/README.md](scripts/README.md) — 人类入口与初始化
3. [agent/rules/CONVENTIONS.md](agent/rules/CONVENTIONS.md)、[agent/skills/README.md](agent/skills/README.md) — 约定与 Slash 技能
