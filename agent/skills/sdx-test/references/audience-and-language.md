# sdx-test 受众与语言

读者：**测试/质量**（策略与用例）；**研发**（可执行性、环境、与 **DSD**/**ASD** 一致）。TDD 不替代 PRD 产品表述或 DSD/specs 的规格正文。

总则与转写方向可与 [../../sdx-solution/references/audience-and-language.md](../../sdx-solution/references/audience-and-language.md) 对齐：写**测什么、如何验收、数据环境前提、回归**；产品目标与规则以 **PRD** 为准，接口与异常语义以 **DSD**/specs 为准。可用 `Method Path`、错误码等作**追溯锚点**，勿大段粘贴 OpenAPI 或替代 DSD。

## 宜写 / 宜弱化

| 宜写 | 宜弱化 |
|------|--------|
| 层次、范围、优先级、覆盖目标 | 断言代码、框架长篇 |
| 用例表（步骤、数据、预期、追溯） | 与 DSD 重复的完整 OpenAPI |
| 数据规模、准备、脱敏/Mock | 生产密钥 |
| 进出标准、回归顺序 | 把 TDD 写成测试报告/缺陷单 |

骨架：[tdd-template.md](../assets/tdd-template.md)；与规范文件冲突时以 references 为准。
