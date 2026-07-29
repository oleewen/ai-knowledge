# 受众与语言（docs-build）

> 公共维与烤干门禁：[audience-and-language.md](../../../references/audience-and-language.md)

## 主读者

知识实体维护者与 RAG/检索消费者；视角 README 为人类导航，`{ID}.md` 为机器+人可读实体卡。

## 宜写 / 宜弱化

| 宜写 | 宜弱化 |
| --- | --- |
| 与提取规则一致的 ID、字段、跨视角引用 | 擅自改实体 ID 不同步引用 |
| 视角 README 导航壳 | 在 README 塞长业务正文 |
| KNOWLEDGE_INDEX 可扫描条目 | 无校验失败静默继续 |

## 反例

| 避免 | 推荐 |
| --- | --- |
| 断跨视角 ID | 改 ID 须同步全部引用 |
| 实体卡口吻像 SOLUTION 业务方案长文 | 按实体字段与视角职责写 |

## 特殊允许区

无。须对齐 DESIGN/CONTRIBUTING；未读不得滥增实体。
