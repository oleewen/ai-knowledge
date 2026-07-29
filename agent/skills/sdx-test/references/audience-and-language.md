# 受众与语言（sdx-test）

> 公共维与烤干门禁：[audience-and-language.md](../../../references/audience-and-language.md)

## 主读者

**测试/质量**（策略与用例）；**研发**（可执行性、环境、与 **DSD**/**ASD** 一致）。TDD 不替代 PRD 产品表述或 DSD/specs 规格正文。

## 宜写 / 宜弱化

| 宜写 | 宜弱化 |
| --- | --- |
| 层次、范围、优先级、覆盖目标 | 断言代码、框架长篇 |
| 用例表（步骤、数据、预期、追溯） | 与 DSD 重复的完整 OpenAPI |
| 数据规模、准备、脱敏/Mock | 生产密钥 |
| 进出标准、回归顺序 | 把 TDD 写成测试报告/缺陷单 |

## 反例

| 避免 | 推荐 |
| --- | --- |
| 大段粘贴 OpenAPI 替代追溯 | 用 Method Path、错误码作锚点 |
| 写产品目标长文 | 产品以 PRD 为准；此处写测什么、如何验收 |

## 特殊允许区

骨架：[tdd-template.md](../assets/tdd-template.md)。产品目标与规则以 PRD 为准；接口与异常语义以 DSD/specs 为准。
