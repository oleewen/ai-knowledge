# AI Agent 使用指南

## 本知识库的设计目的

本知识库专为 AI Agent（如 Cursor、Copilot Workspace、Claude Code 等）设计，
旨在为 AI 提供充足的项目上下文，使其能够：

1. **理解业务**：通过产品文档了解系统做什么、为谁做
2. **理解领域**：通过领域模型了解核心概念和业务规则
3. **理解架构**：通过架构文档了解系统如何构建
4. **评估影响**：通过依赖矩阵了解变更的波及范围

## 文档导航

### 我要理解一个业务需求

1. 先看 [GLOSSARY.md](../domain/GLOSSARY.md) 理解术语
2. 再看 [BUSINESS-RULES.md](../product/BUSINESS-RULES.md) 理解规则
3. 查看 [CONSTRAINTS.md](../product/CONSTRAINTS.md) 了解约束

### 我要开发一个新功能

1. 确认功能属于哪个上下文 → [DOMAIN-MODEL.md](../domain/DOMAIN-MODEL.md)
2. 了解涉及的服务 → [SYSTEM-ARCHITECTURE.md](../architecture/SYSTEM-ARCHITECTURE.md)
3. 检查依赖关系 → [DEPENDENCY-MATRIX.md](../dependency/DEPENDENCY-MATRIX.md)
4. 查看集成方式 → [INTEGRATION-MAP.md](../architecture/INTEGRATION-MAP.md)

### 我要修改一个已有接口

1. 查看谁在调用此接口 → [INTEGRATION-MAP.md](../architecture/INTEGRATION-MAP.md)
2. 确认影响范围 → [DEPENDENCY-MATRIX.md](../dependency/DEPENDENCY-MATRIX.md)
3. 检查是否违反约束 → [CONSTRAINTS.md](../product/CONSTRAINTS.md)

### 我要做架构决策

1. 查看已有决策 → [DECISION-RECORDS/](../architecture/DECISION-RECORDS/)
2. 参考架构约束 → [CONSTRAINTS.md](../product/CONSTRAINTS.md) 性能/安全约束部分
3. 使用ADR模板记录新决策

## AI Agent 行为准则

### 必须做的

- ✅ 每次生成代码前，先查阅相关领域模型和业务规则
- ✅ 涉及状态变更时，对照状态机(INV-002)验证合法性
- ✅ 涉及金额计算时，遵循金额精度约束(DC-001)
- ✅ 修改接口时，检查依赖矩阵确认影响范围
- ✅ 新增领域概念时，先更新术语表

### 禁止做的

- ❌ 不可跳过业务规则验证直接实现功能
- ❌ 不可在服务间直接访问数据库（违反ADR-002）
- ❌ 不可使用浮点数存储金额
- ❌ 不可硬编码业务规则中的阈值参数
- ❌ 不可忽略幂等性设计（尤其是事件消费和支付回调）

## 知识库维护规范

### 何时更新知识库

| 触发事件 | 需更新的文档 |
|---------|------------|
| 新增业务规则 | BUSINESS-RULES.md |
| 新增/修改领域概念 | GLOSSARY.md, DOMAIN-MODEL.md |
| 新增服务 | SYSTEM-ARCHITECTURE.md, DEPENDENCY-MATRIX.md, INTEGRATION-MAP.md |
| 新增服务间调用 | INTEGRATION-MAP.md, DEPENDENCY-MATRIX.md |
| 架构决策 | DECISION-RECORDS/ 新增ADR |
| 数据表结构变更 | DATA-ARCHITECTURE.md |
| 任何文档变更 | CHANGELOG.md |

### 文档质量检查清单

- [ ] 所有业务规则有唯一ID
- [ ] 所有约束有违反后果说明
- [ ] 依赖矩阵与集成关系图一致
- [ ] 术语表覆盖所有领域文档中的专业术语
- [ ] ADR记录了备选方案和决策理由
- [ ] CHANGELOG记录了本次变更
