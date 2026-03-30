# 受众与文档语言（sdx-prd）

PRD **主要供产品经理**撰写、维护与验收对齐；**研发团队参与评审**（可行性、范围边界、依赖与风险），但不以研发实现说明替代产品表述。

与 [../../sdx-solution/reference/audience-and-language.md](../../sdx-solution/reference/audience-and-language.md) **同一原则**：正文写**角色/能力/旅程、用户故事与验收标准、信息架构与交互规则、业务规则与数据含义**；**实现向技术细节**（接口/表/中间件/模块名等）留在下游 **sdx-design（ADD）**。

Agent **可以**按需查阅 `knowledge/`、`requirements/.../specs/` 核对事实；写入 PRD 时须转写为业务/产品表述。PRD 侧重「谁能做什么、规则是什么、如何验收」，可保留故事/用例/IA 等产品侧常用词。

## 正文宜写 / 宜弱化

| 宜写入 PRD | 宜弱化或避免（留给 ADD） |
|------------|-------------------------|
| 业务流程、用户故事、用例、验收标准 | 类名、接口路径、具体协议 |
| 信息架构、操作路径、校验与反馈（产品侧） | 表名、字段名、缓存/队列选型 |
| 业务规则 BR-n、数据字典（业务语义） | 框架、中间件、服务拆分与部署 |
| 跨系统交互的业务边界与同步/异步语义（产品可读） | 实现方案与性能调优细节 |

## 与模板的关系

章节骨架见 [../assets/prd-template.md](../assets/prd-template.md)；模板内提示与本文件及解决方案侧 [audience-and-language.md](../../sdx-solution/reference/audience-and-language.md) 一致时，以规范层文件为准。
