# AI AGENTS开发指南

## 开发规范说明

本项目遵循 `.ai/rules` 下的统一开发规范。本文档主要记录业务领域特定的约束与不变量，以及项目特定的非功能性指标。
通用技术实现（如代码风格、分层架构、异常处理、Git提交等）请直接参考：

- [Java开发规范](.ai/rules/coding/java-guidelines.md)
- [设计规范指南](.ai/rules/design/design-guidelines.md)
- [项目结构规范](.ai/rules/coding/project-structure.md)
- [Git提交规范](.ai/rules/coding/git-guidelines.md)
- [Maven管理规范](.ai/rules/coding/maven-guidelines.md)
- [测试开发规范](.ai/rules/coding/testing-guidelines.md)

## 项目特定规范

### 核心实现约束

- **金额处理**: 一律使用 `MonetaryAmount`（common/domain），禁止使用 `double`/`float` 表示金额。
- **API响应**: 统一继承 `Result<T>`，JSON 序列化使用 snake_case（参考 `ApplicationStarter` 配置）。
- **工具代码**: 禁止修改 MyBatis Generator 等工具生成的代码（若在指定目录内），需通过调整模板或配置实现。

### 依赖与构建

- **依赖管理**: 禁止未经明确批准添加新依赖（新依赖需在父 POM 的 dependencyManagement 中统一管理）。
- **构建检查**: 提交前必须通过编译与测试。

## 工作流与质量要求

- **SDD开发**: 澄清需求和设计优先于实现。
- **测试驱动(TDD)**: 实现或修改代码前先编写测试；禁止删除或跳过已有测试。
- **最小化变更**: 每次修改只做最小化、聚焦的变更，确保先行编写的测试通过后再回复。
- **API兼容性**: 禁止未经讨论修改公共 API 签名。

## 参考文档

不要凭空猜测项目结构或配置，按需查阅以下文件：

- **项目概述与启动：** `README.md`
- **文档结构：** `docs/README.md`
- **开发规范：** `.ai/rules/`
