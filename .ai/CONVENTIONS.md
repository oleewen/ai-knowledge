# AI AGENTS开发指南

## 开发规范

### 代码模式

- 所有对外接口（REST/RPC）使用 Request → Command → Domain → Result → DTO → Response 转换链路，禁止在 Controller/Provider 中直接使用领域对象。
- 使用仓储模式（Repository 接口在 domain，实现在 infrastructure/dao），禁止在应用层或表现层直接访问 Mapper/数据库。
- 金额一律使用 `MonetaryAmount`（common/domain），禁止使用 `double`/`float` 表示金额。
- 领域层（domain）不依赖 Spring 等框架；依赖方向为外层依赖内层，domain 仅依赖 common。
- 错误与异常：业务异常、参数校验异常、系统异常区分处理，参见 `~/ai/rules/coding/java-guidelines.md`。
- API 响应继承 `Result<T>`，JSON 使用 snake_case，见 `ApplicationStarter` 中 ObjectMapper 配置。

### 提交与分支

- 遵从 Conventional Commits 标准。
- 提交信息格式：`<type>(<scope>): <subject>`（例如：`feat(order): 实现订单取消接口`）。
- 类型：feat（功能）、fix（修复）、refactor（重构）、docs（文档）、test（测试）、chore（杂项）、revert（回退）。
- 从主分支创建功能分支开发，禁止直接推送到主分支。提交须原子、可追溯，关联需求/问题编号。

## 工作流规则

- 采用SDD 开发规范，澄清需求和设计优先于实现
- 测试驱动：实现或修改代码前先编写测试，遵循TDD原则
- 每次修改只做最小化、聚焦的变更，确保先行编写的测试通过后再回复和总结。
- 提交前必须通过编译与测试，遵循 Conventional Commits。
- 修改文件前必须先阅读相关源码与文档，不凭猜测修改。
- 保持现有代码风格与分层/模块边界不变，除非明确要求调整。

## 禁止事项

- 禁止修改 MyBatis Generator 等工具生成的代码（若在指定目录内），若需调整请改模板或生成配置。
- 禁止未经明确批准添加新依赖（新依赖需在父 POM 的 dependencyManagement 中统一管理）。
- 禁止在领域层使用 Spring 注解或直接依赖基础设施实现；禁止在 API 层暴露领域对象。
- 禁止删除或跳过已有测试；新增功能需同步补充测试
- 禁止未经讨论修改公共 API 签名\

## 参考文档

不要凭空猜测项目结构或配置，按需查阅以下文件：

- **项目概述与启动：** `../README.md`
- **文档结构：** `../docs/README.md`
- **开发规范：** `~/ai/rules/`
