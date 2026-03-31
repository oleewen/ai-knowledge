# AI AGENTS 开发约定

## 适用范围

本文件是 `.ai/rules/` 的规则总入口，适用于本仓库的文档工程与知识库治理工作。  
本仓库核心形态为 **Markdown/YAML 知识库 + Bash 初始化脚本**，不应套用与当前仓库无关的业务代码约束。

---

## 一、规则索引

### 1) 编码与协作规则（coding/）

| 文件 | 说明 |
|------|------|
| [coding/git-guidelines.md](coding/git-guidelines.md) | Git 提交规范：Conventional Commits、原子提交、检查清单 |
| [coding/project-structure.md](coding/project-structure.md) | 项目结构与分层职责约定（用于组织文档与工程目录） |
| [coding/java-guidelines.md](coding/java-guidelines.md) | 语言专项参考（仅在对应技术栈项目落地时启用） |
| [coding/maven-guidelines.md](coding/maven-guidelines.md) | 构建专项参考（仅在 Maven 项目落地时启用） |

### 2) 设计规则（design/）

| 文件 | 说明 |
|------|------|
| [design/design-guidelines.md](design/design-guidelines.md) | 设计规则总纲：术语一致性、架构表达、评审基线 |
| [../skills/sdx-design/assets/add-template.md](../skills/sdx-design/assets/add-template.md) | ADD 模板：架构设计阶段标准产物 |

### 3) 测试规则（testing/）

| 文件 | 说明 |
|------|------|
| [testing/testing-guidelines.md](testing/testing-guidelines.md) | 测试策略与质量门槛总则 |
| [../skills/sdx-test/assets/tdd-template.md](../skills/sdx-test/assets/tdd-template.md) | TDD 模板：测试设计阶段标准产物 |

### 4) 文档规则（document/）

| 文件 | 说明 |
|------|------|
| [document/document-guidelines.md](document/document-guidelines.md) | 文档写作与注释规范（结构、可读性、可追溯） |

### 5) 阶段交付模板（skills assets）

| 文件 | 说明 |
|------|------|
| [../skills/sdx-solution/assets/solution-template.md](../skills/sdx-solution/assets/solution-template.md) | 解决方案模板（`system/solutions/`） |
| [../skills/sdx-analysis/assets/analysis-template.md](../skills/sdx-analysis/assets/analysis-template.md) | 需求分析模板（`system/analysis/`） |
| [../skills/sdx-prd/assets/prd-template.md](../skills/sdx-prd/assets/prd-template.md) | PRD 模板（`system/requirements/`） |
| [../skills/sdx-design/assets/add-template.md](../skills/sdx-design/assets/add-template.md) | ADD 模板（`system/requirements/`） |
| [../skills/sdx-test/assets/tdd-template.md](../skills/sdx-test/assets/tdd-template.md) | TDD 模板（`system/requirements/`） |
| [../skills/agent-guide/assets/agents-skeleton.md](../skills/agent-guide/assets/agents-skeleton.md) | `AGENTS.md` 推荐骨架 |

---

## 二、关键约定（摘要）

### 1) 路径与查阅顺序

- 修改前先读：`INDEX_GUIDE.md` -> `README.md` -> 子域索引（如 `system/SYSTEM_INDEX.md`）。
- 对未精读区域不得写成已核实事实；需补读或明确标注“待核实”。
- 所有站内链接必须可点击，显示文本建议使用仓库根相对路径。

### 2) 知识库一致性

- 保持跨视角 ID 引用稳定，禁止只改局部而不更新引用链。
- 涉及 `system/knowledge/` 实体新增或结构变更时，先对齐 `system/DESIGN.md` 与 `system/CONTRIBUTING.md`。
- 采用“单一事实源（SSOT）+ 联邦治理”原则，避免重复定义同一事实。

### 3) Skills 与脚本边界

- `skills/` 中 `SKILL.md` 是工作流定义，不是可执行脚本。
- `scripts/knowledge-init*.sh` 负责初始化与分发，不负责替代 Skill 语义。
- Slash 命令清单与用法以 `../skills/README.md` 为准，本文件不重复维护命令详情。

### 4) 变更与提交

- 默认最小化变更，避免无关重排与大面积格式漂移。
- 提交信息遵循 Conventional Commits，建议使用中文描述变更意图。
- 未获明确要求，不执行破坏性操作（删除历史、重置分支、强推等）。

---

## 三、项目特定规则

- 本仓库以文档与脚本为主，新增规则应优先覆盖文档结构、索引维护、链接有效性与引用一致性。
- 语言/框架专项规范（如 Java、Maven）仅在下游项目实际使用对应技术栈时启用。
- 若规则与仓库现状冲突，以 `AGENTS.md`、`INDEX_GUIDE.md`、`system/DESIGN.md` 的当前约束为准。

---

## 四、参考文档

- 项目总入口：`README.md`
- 路径级索引：`INDEX_GUIDE.md`
- 系统知识库入口：`system/README.md`、`system/SYSTEM_INDEX.md`
- 设计与贡献规范：`system/DESIGN.md`、`system/CONTRIBUTING.md`
- AI 协作说明：`.ai/README.md`
