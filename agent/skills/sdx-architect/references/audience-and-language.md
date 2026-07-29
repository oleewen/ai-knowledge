# 受众与语言（sdx-architect）

> 公共维与烤干门禁：[audience-and-language.md](../../../references/audience-and-language.md)

## 主读者

**架构师**（主笔与验收）；**分析、产品、研发**参评可行性与范围。

## 宜写 / 宜弱化

| 宜写（ASD） | 宜弱化 |
| --- | --- |
| 系统边界、分层、关键组件与依赖 | 类/方法级实现与源码 |
| 接口协议级约定、领域/数据架构要点 | 完整 OpenAPI/DDL 正文（→ DSD） |
| 发布与演进约束、变更影响 | 单测代码、调优细节 |
| 规约摘要与待下游细化项 | 复述 PRD 故事全文 |

## 反例

| 避免 | 推荐 |
| --- | --- |
| 大段粘贴 PRD 用户故事 | 引用 US-n / FR-n，写架构决策 |
| 把 DSD 级 API/DDL 写满 ASD | ASD 给边界与协议级；细节进 DSD |
| 内部调用链当主叙述 | 系统间边界与责任 |

## 特殊允许区

结构与占位以 [asd-template.md](../assets/asd-template.md) 为准。有 PRD → 业务意图以 PRD 为准；接口/表结构细项留给 DSD。
