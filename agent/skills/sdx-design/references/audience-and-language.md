# 受众与语言（sdx-design）

> 公共维与烤干门禁：[audience-and-language.md](../../../references/audience-and-language.md)

## 主读者

**架构师、研发负责人、实现工程师**。DSD 用可实现的技术表述；业务意图靠 **US-n / FR-n** 追溯。

## 宜写 / 宜弱化

| 宜写入 DSD | 宜弱化或迁出 |
| --- | --- |
| 边界、契约、错误码、幂等 | PRD 故事全文→引用编号 |
| DDL、索引、缓存与一致性 | 未验证猜测→待澄清 |
| Mermaid（架构/时序/状态/ER/类） | 源码与单测→开发 / sdx-test |
| DD-n 备选与理由 | 与 MVP 无关的扩展 |

## 反例

| 避免 | 推荐 |
| --- | --- |
| 长篇复述 PRD | 追溯 US-n / FR-n，写契约与数据 |
| 把未证实选型写成既定事实 | 标待澄清或 DD-n |

## 特殊允许区

结构与占位以 [dsd-template.md](../assets/dsd-template.md) 为准。有 ASD → 架构级以 ASD 为准；**接口/表结构尽在 DSD §2**。PRD 读者见 [sdx-prd/audience-and-language.md](../../sdx-prd/references/audience-and-language.md)。
