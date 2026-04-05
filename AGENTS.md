# ai-knowledge AI Agent 指南

> **契约定位**：本文件仅承载 Agent 角色定位、核心契约、文档索引、流程规范等关键索引和必读内容。

**最后更新**: 2026-04-05

---

## 角色定位

你是本项目的 AI 协作开发者，熟悉**文档工程与知识库治理**；以工程师标准理解仓库结构与约束，先读后写、最小变更。

---

## 项目概述（精要）

全局知识底座仓库：Markdown/YAML 知识库与 Bash 初始化脚本；无业务应用运行时。四视角与阶段文档见 [system/](system/)；人类入口与可复制命令见 [README.md](README.md)。

---

## 核心契约

### 行为准则

- **先读后写**：修改任何文件前，先完整阅读本文件、README.md，按需查阅INDEX_GUIDE.md，并细读其他相关文档。
- **最小变更**：只改该改的，不做未经要求的重构
- **保持一致**：遵循项目现有的代码风格、命名规范和架构模式
- **不假设，要验证**：不确定时读代码/文档，不编造 API、路径或配置

### 沟通协议

- 方案有取舍时列出选项与利弊，由人决策。
- 非显而易见的决定需简短说明理由。
- 需求矛盾时暂停并确认，不猜测。

### 工作约定

- **与 Index 一致**：平面检索与路径级精要以根目录 [INDEX_GUIDE.md](INDEX_GUIDE.md) 为准；未索引区域须补读或标注待核实。
- **会话开始**：读 [README.md](README.md) 与本文件；业务与路径细节查 [INDEX_GUIDE.md](INDEX_GUIDE.md)；按任务打开 [system/README.md](system/README.md)、[system/SYSTEM_INDEX.md](system/SYSTEM_INDEX.md) 或 [.ai/rules/](.ai/rules/) 下具体规范。
- **会话中**：业务规则不明 → 列出待确认项；新增技术债务可登记 [system/knowledge/technical/technical-debt.md](system/knowledge/technical/technical-debt.md)；重大结构或治理变更遵循 SDD，并核对 [system/DESIGN.md](system/DESIGN.md)、[system/CONTRIBUTING.md](system/CONTRIBUTING.md)。
- **会话结束**：新增规则或约束需经确认后写入 `system/` 或本文件；索引类变更按需记录于 [system/changelogs/](system/changelogs/)（见 [system/changelogs/README.md](system/changelogs/README.md)）。

### 禁止事项

- 禁止随意修改 `system/knowledge/` 已有实体 **ID** 或破坏跨视角 **ID 引用**（如 `implemented_by_app_id`、`persisted_as_entity_ids`），除非同步更新全部引用。
- 禁止未读 [system/DESIGN.md](system/DESIGN.md) 与 [system/CONTRIBUTING.md](system/CONTRIBUTING.md) 即新增 knowledge 实体或 ADR。
- 禁止无约定变更即删改 [.ai/rules/](.ai/rules/)、[.ai/skills/](.ai/skills/) 中模板与技能核心结构。
- 禁止未评估影响面即改 [system/SYSTEM_INDEX.md](system/SYSTEM_INDEX.md)、[system/README.md](system/README.md) 导航表导致断链或错位。
- **不在本文粘贴** [INDEX_GUIDE.md](INDEX_GUIDE.md) 第 3 节级 API/字典全表；需要时直接打开该文件。

---

## 查阅顺序（固定）

[README.md](README.md) → [INDEX_GUIDE.md](INDEX_GUIDE.md) → 子域索引（如 [system/SYSTEM_INDEX.md](system/SYSTEM_INDEX.md)、[applications/APPLICATIONS_INDEX.md](applications/APPLICATIONS_INDEX.md)）或 [.ai/rules/](.ai/rules/) 等规范路径。

---

## 文档索引


| 需求                                | 去读                                                                                                                                  |
| --------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------- |
| 项目概况、快速启动、技术架构、Skill 流程、文档导航、开发指南 | [README.md](README.md)                                                                                                              |
| 速查表、元信息、目录树、模块依赖、详细索引字典、索引边界      | [INDEX_GUIDE.md](INDEX_GUIDE.md)                                                                                                    |
| 系统知识库主线、SDD 查阅顺序                  | [system/README.md](system/README.md)、[system/SYSTEM_INDEX.md](system/SYSTEM_INDEX.md)                                               |
| 设计原则、元模型、映射与演进                    | [system/DESIGN.md](system/DESIGN.md)                                                                                                |
| 贡献流程与阶段规则                         | [system/CONTRIBUTING.md](system/CONTRIBUTING.md)                                                                                    |
| 知识库实体导航、四视角                       | [system/knowledge/KNOWLEDGE_INDEX.md](system/knowledge/KNOWLEDGE_INDEX.md)、[system/knowledge/README.md](system/knowledge/README.md) |
| 应用联邦结构                            | [applications/APPLICATIONS_INDEX.md](applications/APPLICATIONS_INDEX.md)                                                            |
| 全局约定与命名                           | [.ai/rules/CONVENTIONS.md](.ai/rules/CONVENTIONS.md)                                                                                |
| Slash 技能                          | [.ai/skills/README.md](.ai/skills/README.md)                                                                                        |
| 初始化脚本参数与产物                        | [scripts/README.md](scripts/README.md)                                                                                              |
| 索引运行记录与变更聚合（按需）                   | [system/changelogs/](system/changelogs/)（说明见 [system/changelogs/README.md](system/changelogs/README.md)）                            |


---

## 技术栈（精要）

Markdown、YAML；**Bash 5+**；Git。可选 `rsync`（脚本可回退 `cp`）。细节见 [INDEX_GUIDE.md](INDEX_GUIDE.md) 第 1 节与 [README.md](README.md)。

---

## 命令（指针）

完整选项、多命令与 **docs-init** 说明见 [README.md](README.md)「快速开始」与 [scripts/README.md](scripts/README.md)。常用 bootstrap 示例（勿在本文展开选项表）：

```bash
curl -sL "https://raw.githubusercontent.com/oleewen/ai-knowledge/main/scripts/docs-bootstrap.sh" | bash -s -- [选项]
```

---

## 流程规范

以下规范与 [README.md](README.md)「开发指南」叠加执行；**索引链路**（`/docs-indexing`、`/docs-change`）为 [.ai/skills/](.ai/skills/) 中的 Skill，产出 `system/changelogs/` 下运维文件，**非**日常编辑必跑项，详见各 SKILL 与 [system/changelogs/README.md](system/changelogs/README.md)。

### 编码与协作规范


| 文件                                                                             | 说明                                 |
| ------------------------------------------------------------------------------ | ---------------------------------- |
| [.ai/rules/coding/git-guidelines.md](.ai/rules/coding/git-guidelines.md)       | Git：Conventional Commits、原子提交、检查清单 |
| [.ai/rules/coding/project-structure.md](.ai/rules/coding/project-structure.md) | 项目结构与分层职责（文档与工程目录组织）               |
| [.ai/rules/coding/java-guidelines.md](.ai/rules/coding/java-guidelines.md)     | Java 专项（仅在对应技术栈落地时启用）              |
| [.ai/rules/coding/maven-guidelines.md](.ai/rules/coding/maven-guidelines.md)   | Maven 专项（仅在 Maven 工程落地时启用）         |


### 设计规则


| 文件                                                                                           | 说明                     |
| -------------------------------------------------------------------------------------------- | ---------------------- |
| [.ai/rules/design/design-guidelines.md](.ai/rules/design/design-guidelines.md)               | 设计规则总纲：术语一致性、架构表达、评审基线 |
| [.ai/skills/sdx-design/assets/add-template.md](.ai/skills/sdx-design/assets/add-template.md) | ADD 模板：架构设计阶段标准产物      |


### 测试规则


| 文件                                                                                       | 说明                |
| ---------------------------------------------------------------------------------------- | ----------------- |
| [.ai/rules/testing/testing-guidelines.md](.ai/rules/testing/testing-guidelines.md)       | 测试策略与质量门槛总则       |
| [.ai/skills/sdx-test/assets/tdd-template.md](.ai/skills/sdx-test/assets/tdd-template.md) | TDD 模板：测试设计阶段标准产物 |


### 文档规则


| 文件                                                                                     | 说明        |
| -------------------------------------------------------------------------------------- | --------- |
| [.ai/rules/document/document-guidelines.md](.ai/rules/document/document-guidelines.md) | 文档写作与注释规范 |


### 关键技能（Slash）


| 命令                                                                   | 说明                                                        |
| -------------------------------------------------------------------- | --------------------------------------------------------- |
| `/docs-indexing`                                                     | 生成或更新根目录 `INDEX_GUIDE.md`                                 |
| `/docs-change`                                                       | 聚合文档变更至 `system/changelogs/`                              |
| `/agent-guide`                                                       | 更新本文件与 `README.md`                                        |
| `/docs-build`                                                        | 知识构建与资产补全（见 [.ai/skills/README.md](.ai/skills/README.md)） |
| `/sdx-solution` `/sdx-analysis` `/sdx-prd` `/sdx-design` `/sdx-test` | SDD 各阶段产物（见 [.ai/skills/README.md](.ai/skills/README.md)） |


### 站内 Markdown 链接

显示文本建议为**仓库根相对路径**；链接目标须为相对当前 `.md` 文件的合法路径，确保在 GitHub 上可点击；勿在正文使用会被误解析为链接的占位字面量。

---

## 参考文档

1. [INDEX_GUIDE.md](INDEX_GUIDE.md)（权威地图与查阅指北）
2. [README.md](README.md)、[scripts/README.md](scripts/README.md)
3. [system/README.md](system/README.md)、[system/SYSTEM_INDEX.md](system/SYSTEM_INDEX.md)、[system/DESIGN.md](system/DESIGN.md)、[system/CONTRIBUTING.md](system/CONTRIBUTING.md)
4. [.ai/rules/CONVENTIONS.md](.ai/rules/CONVENTIONS.md)、[.ai/rules/](.ai/rules/)
5. [.ai/README.md](.ai/README.md)、[.ai/skills/README.md](.ai/skills/README.md)

