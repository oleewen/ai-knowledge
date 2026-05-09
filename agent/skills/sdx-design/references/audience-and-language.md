# 受众与语气（sdx-design）

读者：**架构师、研发负责人、实现工程师**。PRD 读者见 [sdx-prd/SKILL.md](../../sdx-prd/SKILL.md)。**DSD** 用可实现的技术表述；业务意图靠 **US-n / FR-n** 追溯，避免长篇复述 PRD。

## 宜写 / 宜弱化

| 宜写入 DSD | 宜弱化或迁出 |
|------------|----------------|
| 边界、契约、错误码、幂等 | PRD 故事全文→引用编号 |
| DDL、索引、缓存与一致性 | 未验证猜测→待澄清 |
| Mermaid（架构/时序/状态/ER/类） | 源码与单测→开发 / sdx-test |
| DD-n 备选与理由 | 与 MVP 无关的扩展 |

## 与 PRD 分工

PRD：**做什么、如何验收**。DSD +（**ASD / spec-asd / spec-dsd**）：**怎么做、依赖何种系统与数据**。有 ASD → 架构级以 ASD 为准；仅有 spec-asd → §1 与范围以其为准；接口/表结构归 **DSD** 与 **spec-dsd**；PRD 中若已有实现细节，仍以功能范围为约束并在 DSD 工程化表述。

## 与模板关系

结构与占位以 [dsd-template.md](../assets/dsd-template.md) 为准；本文件只约束**语气与信息类型**。
