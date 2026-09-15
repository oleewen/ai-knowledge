# 测试规范指南

> **结论**：按分层测领域到 API；门禁以覆盖率与安全零严重漏洞为准。  
> **范围**：按需启用的工程测试策略（非本仓 Markdown 知识库默认约束）。

## 质量门禁

| 指标 | 阈值 | 工具 | 说明 |
| --- | --- | --- | --- |
| 单元测试覆盖率 | ≥80% | Jacoco | 核心业务逻辑必须覆盖 |
| 代码重复率 | ≤5% | PMD/CPD | 避免重复 |
| 严重漏洞 | 0 | SonarQube | 安全零容忍 |
| 编译警告 | 0 | Maven/Compiler | 保持清洁 |
| 代码风格违规 | ≤10 | Checkstyle | 统一风格 |

## 测试分层

| 层 | 覆盖 |
| --- | --- |
| 单元 | 领域模型、领域服务 |
| 集成 | 应用服务、仓储实现 |
| 端到端 | API、业务流程 |
| 性能 | 关键业务路径 |

## 单元测试

| 项 | 约定 |
| --- | --- |
| 测试类 | `{ClassName}Test` |
| 测试方法 | `should{ExpectedBehavior}When{Condition}` |
| 包结构 | 与被测类同包路径 |
| 重点 | 领域模型行为与异常路径；领域服务用 Mock 隔离仓储等外部依赖 |

## 集成测试

| 项 | 约定 |
| --- | --- |
| 应用服务 | Spring 上下文 + 事务回滚；验命令→结果 |
| API / RPC | 验请求→响应与关键状态 |
| 后缀 | 集成类建议 `*IT`（与单元 `*Test` 区分） |

## 测试数据

- 用测试工厂构造合法/边界样例，避免用例内散落魔法值。
- 测试库可用内存库（如 H2）+ `ddl-auto` 适合测试的配置；勿污染共享环境。

## 执行

```bash
mvn test -Dtest=*Test          # 单元
mvn test -Dtest=*IT            # 集成
mvn test                       # 全部
mvn test -Dtest=com.example.*Test  # 包过滤
```

CI：检出 → JDK → `mvn clean test` → Jacoco 报告 →（可选）上传覆盖率。

## 原则与 Mock

| 原则 | 要点 |
| --- | --- |
| FIRST | Fast · Independent · Repeatable · Self-validating · Timely |
| AAA | Arrange → Act → Assert |
| 单一断言 | 每方法验一个行为 |
| 可读性 | 测试须易懂 |

| 场景 | Mock |
| --- | --- |
| 领域模型/领域计算 | 不 Mock 领域对象，用真实实例 |
| 应用服务 | Mock 外部依赖（支付、消息等），验编排结果 |

覆盖率：Jacoco 可排除 Application/Config/纯 Entity 等无业务逻辑类；阈值仍以门禁表为准。
