# AI AGENTS 开发约定

## 适用范围

本文件是 `.agent/rules/` 的规则总入口，适用于本仓库的文档工程与知识库治理工作。  
本仓库核心形态为 **Markdown/YAML 知识库 + Bash 初始化脚本**，不应套用与当前仓库无关的业务代码约束。

---

## 一、规则索引

| 分类 | 文件 | 说明 |
| --- | --- | --- |
| 编码与协作（`coding/`） | [coding/git-guidelines.md](coding/git-guidelines.md) | Git 提交规范：Conventional Commits、原子提交、检查清单 |
| 编码与协作（`coding/`） | [coding/project-structure.md](coding/project-structure.md) | 项目结构与分层职责约定（用于组织文档与工程目录） |
| 编码与协作（`coding/`） | [coding/java-guidelines.md](coding/java-guidelines.md) | 语言专项参考（仅在对应技术栈项目落地时启用） |
| 编码与协作（`coding/`） | [coding/maven-guidelines.md](coding/maven-guidelines.md) | 构建专项参考（仅在 Maven 项目落地时启用） |
| 设计（`design/`） | [design/design-guidelines.md](design/design-guidelines.md) | 设计规则总纲：术语一致性、架构表达、评审基线 |
| 测试（`testing/`） | [testing/testing-guidelines.md](testing/testing-guidelines.md) | 测试策略与质量门槛总则 |
| 文档（`document/`） | [document/document-guidelines.md](document/document-guidelines.md) | 文档写作与注释规范（结构、可读性、可追溯） |

---

## 二、关键约定（摘要）

### 1) 文件引用强校验
- `.agent` 内文件引用，避免误用仅能在根目录解析的短链：
    - Agent 语义可达
    - `.agent/` 内文件引用，须以相对当前文件为准。
    - `.agent/` 外文件引用，须用仓库根 `REPO_ROOT` 相对路径。
    - 仓库根执行自检：`bash .agent/scripts/validate-agent-md-links.sh`。

### 2) Skills 与脚本边界

- `skills/` 中 `SKILL.md` 是工作流定义，不是可执行脚本。
- Slash 命令清单与用法以 `../skills/README.md` 为准，本文件不重复维护命令详情。

---

## 三、参考文档

- AI 协作说明：`.agent/README.md`