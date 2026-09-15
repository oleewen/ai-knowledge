# Java开发规范指南

> **按需启用**：目标工程为 Java 时使用；**非本仓默认约束**。

**结论**：Java 17+ / Spring Boot 2.7+ 栈；命名与分层对象对齐 [project-structure.md](project-structure.md)；异常分业务/系统/参数/数据；日志按级别、占位符、异常带栈。

## 技术栈

| 类别 | 选型 | 版本底线 |
| --- | --- | --- |
| 语言 | Java | 17+（LTS 特性可用） |
| 框架 | Spring Boot | 2.7.10+ |
| 构建 | Maven | 3.6+ |
| ORM | MyBatis + tk.mybatis | — |
| RPC | Dubbo | 2.7.x |
| DB | MySQL | 8.0+ |
| 映射 | MapStruct | 1.5+ |
| 样板 | Lombok | 1.18+ |
| 测试 | JUnit 5 + Mockito | — |
| API 文档 | Swagger | 3.0+ |
| 校验 | Bean Validation | 2.0+ |

## 编码规范

### 命名

| 对象 | 规则 | 例 |
| --- | --- | --- |
| 类 | PascalCase | `OrderService` |
| 方法 / 变量 | camelCase | `createOrder()` / `orderAmount` |
| 常量 | `UPPER_SNAKE` | `MAX_ORDER_AMOUNT` |
| 包 | 全小写、域名反写 | `com.ai.master.order.domain` |

分层类型命名（`{Aggregate}Service`、Command/Result 等）见 [project-structure.md](project-structure.md)，本文不重复。

### 类与接口

- 领域行为写在聚合/实体方法内；状态流转失败抛明确异常（如 `IllegalStateException`）。
- API 接口方法须完整 JavaDoc（含 `@param` / `@return` / `@throws`）；入参用 `@Valid`。
- 不在 API 层直接暴露领域对象（同 project-structure 约束）。

### 异常

| 类型 | 类名 | 语义 |
| --- | --- | --- |
| 业务 | `BusinessException` | 规则不满足 |
| 系统 | `SystemException` | 系统级错误 |
| 参数 | `ValidationException` | 校验失败 |
| 数据 | `DataNotFoundException` | 资源不存在 |

**处理**：`@RestControllerAdvice` 统一映射；校验 → 400 + `INVALID_PARAMETER`；业务 → 409 + `BUSINESS_ERROR`（可按项目统一错误体扩展）。

### 数据访问

- 领域侧定 `Repository` 接口（`save` / `findById` / 查询 / `exists`）；实现落 infrastructure。
- MyBatis：`@Mapper`；注解 SQL 或 XML 均可；更新/查询参数用 `@Param`。
- 持久化实体与领域模型分离（见 project-structure infrastructure）。

## 日志

| 级别 | 用途 |
| --- | --- |
| ERROR | 系统异常、须立即处理 |
| WARN | 潜在问题、业务异常 |
| INFO | 关键路径、重要状态变更 |
| DEBUG | 调试细节 |
| TRACE | 极细；默认关 |

**格式**：`@Slf4j`；消息用 `{}` 占位，禁字符串拼接；失败日志带业务键（如 `userId`）且 `log.error(..., e)` 传异常对象。
