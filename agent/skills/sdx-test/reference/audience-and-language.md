# 受众与文档语言（sdx-test）

TDD **主要供测试/质量角色**制定策略、用例与进出标准；**研发参与评审**（可执行性、数据与环境、与 ADD 一致性），但不以 TDD 替代 PRD 的产品表述或 ADD 的实现规格。

与 [../../sdx-solution/reference/audience-and-language.md](../../sdx-solution/reference/audience-and-language.md) **同一原则**：正文写**测什么、如何验收、数据与环境前提、回归与风险**；**产品目标与业务规则**以 PRD（US-n、BR-n）为准，**接口与异常语义**以 ADD 为准。Agent 可引用 `Method Path`、错误码、影响面等**技术锚点**，便于开发与自动化对齐，但避免在 TDD 中展开大段实现代码或替代 ADD 的 API 详设。

## 正文宜写 / 宜弱化

| 宜写入 TDD | 宜弱化或避免 |
|------------|--------------|
| 测试层次、范围、优先级与覆盖目标 | 具体断言代码、框架选型长篇论证 |
| 用例表（步骤、数据、预期、追溯 US/API/BR） | 与 ADD 重复的完整 OpenAPI 粘贴 |
| 测试数据规模、准备方式、脱敏/Mock 策略 | 生产配置密码、真实密钥 |
| 进入/退出标准、回归范围与执行顺序 | 将 TDD 写成测试报告或缺陷清单 |

## 与模板的关系

章节骨架见 [../assets/tdd-template.md](../assets/tdd-template.md)；模板内提示与本文件冲突时，以规范层文件为准。
