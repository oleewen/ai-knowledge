# AI AGENTS 开发指南

## 开发规范说明

本项目遵循 `.ai/rules/` 下的统一开发规范。本文档提供**规范索引**与**关键摘要**，便于快速定位与查阅。业务领域特定约束与项目非功能性指标见下文「项目特定规范」。

---

## 一、开发规范索引

### 1. 编码规范 (coding/)

| 文件 | 说明 |
|------|------|
| [java-guidelines.md](.ai/rules/coding/java-guidelines.md) | Java 开发规范：技术栈、命名、类设计、异常、Repository、日志 |
| [project-structure.md](.ai/rules/coding/project-structure.md) | 项目结构规范：DDD 六边形架构、分层与模块职责 |
| [git-guidelines.md](.ai/rules/coding/git-guidelines.md) | Git 提交规范：Conventional Commits、原子提交、检查清单 |
| [maven-guidelines.md](.ai/rules/coding/maven-guidelines.md) | Maven 规范：多模块结构、依赖管理、构建与质量门禁 |

### 2. 设计规范 (design/)

| 文件 | 说明 |
|------|------|
| [design-guidelines.md](.ai/rules/design/design-guidelines.md) | 设计规范总纲：DDD 原则、架构原则、评审标准、术语与文档规范 |
| [design-template.md](.ai/rules/design/design-template.md) | 详细设计模板：业务分析、应用架构、API/逻辑/数据模型 |
| [architecture-template.md](.ai/rules/design/architecture-template.md) | 概要设计模板：业务分析、系统架构、能力定义、VALET 技术选型 |
| [add-template.md](.ai/rules/design/add-template.md) | 架构设计说明书(ADD)：应用/技术/工程/数据架构、C4 与 mermaid |
| [api-readme-template.md](.ai/rules/design/api-readme-template.md) | API 文档索引模板：版本、认证、响应格式、错误码、模块索引 |

### 3. 测试规范 (testing/)

| 文件 | 说明 |
|------|------|
| [testing-guidelines.md](.ai/rules/testing/testing-guidelines.md) | 测试规范：覆盖率门禁、分层策略、单元/集成测试、Mock、Jacoco |
| [tdd-template.md](.ai/rules/testing/tdd-template.md) | 测试设计说明书(TDD)：现状分析、策略建议、用例清单、Mock 策略 |

### 4. 需求规范 (requirement/)

| 文件 | 说明 |
|------|------|
| [requirement-template.md](.ai/rules/requirement/requirement-template.md) | 需求文档规范：SCQA、产品/模块/菜单/功能组织、版本与格式 |
| [prd-template.md](.ai/rules/requirement/prd-template.md) | 产品需求说明书(PRD)：产品定位、功能清单、流程、业务规则、非功能需求 |
| [requirement-analyse.md](.ai/rules/requirement/requirement-analyse.md) | 需求分析 Prompt：输入输出规范、模板结构、质量控制与验证 |

### 5. 文档规范 (document/)

| 文件 | 说明 |
|------|------|
| [document-guidelines.md](.ai/rules/document/document-guidelines.md) | 文档与注释规范：JavaDoc、类/包文档、代码注释、TODO 约定 |

### 6. 根目录

| 文件 | 说明 |
|------|------|
| [agents-template.md](.ai/rules/agents-template.md) | AI Agents 开发指南模板：角色、关键路径、技术栈、命令、工作流与禁止事项 |

---

## 二、关键摘要

### 编码类

- **Java**：Java 17+、Spring Boot 2.7+、MyBatis、Dubbo；命名 PascalCase/camelCase；异常分 Business/System/Validation/DataNotFound；Repository 模式；日志 ERROR/WARN/INFO/DEBUG 使用规范。
- **项目结构**：api → service → application → domain ← infrastructure，common 共享；各层命名（如 `{Aggregate}Service`、`{Aggregate}ApplicationService`、`{Aggregate}Repository`）；禁止 API 暴露领域对象、领域层不依赖技术框架。
- **Git**：`<type>(<scope>): <subject>`，类型 feature/fix/docs/refactor/test/chore 等；原子提交、可回滚、关联需求；提交前测试与规范检查。
- **Maven**：父 POM 统一版本与 dependencyManagement；最小依赖、语义化版本；单元覆盖率≥80%、零高危漏洞、零编译警告。

### 设计类

- **设计指南**：DDD 统一语言、限界上下文、聚合根、领域事件；六边形/整洁架构、CQRS；SOLID/KISS/DRY/YAGNI；术语编码（业务流程 a.b → 业务活动 a.b.c → 任务 a.b.c.d）；图表用 Mermaid。
- **详细设计模板**：名词定义 → 业务流程(编码 a.b) → 领域模型(聚合根/实体/值对象/事件) → 能力定义 → 应用架构(C4) → API 设计 → 逻辑模型(类图/状态机/时序) → 数据模型(ER/表结构)。
- **概要设计模板**：主流程/子流程编码、领域对象表、系统 C4、能力与 SLA、VALET 技术选型（Volume/Availability/Latency/Error/Ticket）。
- **ADD**：应用/技术/工程/数据架构；C4 + mermaid；职责边界表、核心组件、API 清单、数据库选型决策图。

### 测试类

- **测试指南**：单元覆盖率≥80%、重复率≤5%、严重漏洞 0、编译警告 0；分层为单元(领域)、集成(应用/仓储)、E2E(API)；命名 `{ClassName}Test`、`should{Expected}When{Condition}`；FIRST、AAA、Given-When-Then；领域测试少 Mock、应用层 Mock 外部依赖；Jacoco 配置与排除项。
- **TDD 模板**：测试现状、框架表、单元/集成/E2E 策略、用例清单(ID/描述/前置/步骤/期望)、测试数据与 Mock 策略。

### 需求类

- **需求模板**：原则为产品说明书而非纯需求说明；组织为产品/模块/菜单/功能/操作；版本变动带版本号；表达 SCQA；含背景目标、产品方案、流程设计、用户旅程、功能清单、非功能与权限。
- **PRD 模板**：产品定位(5W)、目标用户、OKR、产品架构、用户旅程(mermaid journey)、功能清单表、主/子流程(mermaid flowchart)、业务规则表、非功能与权限表。
- **需求分析**：严格按 requirement-template 小节顺序；场景化、可执行、可验证；禁止空泛描述与缺失章节；可结合业务过程/旅程/业务逻辑等提示词。

### 文档与 Agents

- **文档规范**：公共 API 必有 JavaDoc（参数、返回值、异常）；类文档说明职责与注意事项；包文档用 package-info.java；复杂逻辑须注释；TODO 标注优先级与负责人。
- **Agents 模板**：先思考后编码、先阅读再改；关键路径(src/tests/config/docs/CI)、技术栈、常用命令；遵从 `.ai/rules/`、Conventional Commits、OpenSpec SDD、TDD；禁止改生成文件、随意加依赖、删测例、改公共 API。

---

## 三、项目特定规范

### 核心实现约束

- **金额处理**：一律使用 `MonetaryAmount`（common/domain），禁止使用 `double`/`float` 表示金额。
- **API 响应**：统一继承 `Result<T>`，JSON 序列化使用 snake_case（参考 `ApplicationStarter` 配置）。
- **工具代码**：禁止修改 MyBatis Generator 等工具生成的代码（若在指定目录内），需通过调整模板或配置实现。

### 依赖与构建

- **依赖管理**：禁止未经明确批准添加新依赖（新依赖需在父 POM 的 dependencyManagement 中统一管理）。
- **构建检查**：提交前必须通过编译与测试。

---

## 四、工作流与质量要求

- **SDD 开发**：澄清需求和设计优先于实现。
- **测试驱动(TDD)**：实现或修改代码前先编写测试；禁止删除或跳过已有测试。
- **最小化变更**：每次修改只做最小化、聚焦的变更，确保先行编写的测试通过后再回复。
- **API 兼容性**：禁止未经讨论修改公共 API 签名。

---

## 五、参考文档

不要凭空猜测项目结构或配置，按需查阅：

- **项目概述与启动**：`README.md`
- **文档结构**：`docs/README.md`
- **开发规范索引与摘要**：本文档（`.ai/CONVENTIONS.md`）
- **规范源文件**：`.ai/rules/`（详见上文索引）
