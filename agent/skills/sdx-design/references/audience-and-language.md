# 受众与文档语言（sdx-design）

主要读者为**架构师、研发负责人与实现工程师**；PRD 侧读者以业务与验收为主，见 [agent/skills/sdx-prd/SKILL.md](../../sdx-prd/SKILL.md)。**DSD** 用技术语言写清可实现方案，业务意图通过 **US-n / FR-n** 等编号追溯，避免在 DSD 中复述长篇产品叙事。

## 正文宜写 / 宜弱化

| 宜写入 DSD | 宜弱化或迁出 |
|------------|----------------|
| 服务边界、接口契约、错误码、幂等策略 | 用户故事全文（改为引用 PRD） |
| DDL、索引、缓存键与一致性策略 | 未经验证的实现猜测（标为待澄清） |
| Mermaid 架构/时序/状态/ER/类图 | 可执行源码与单测（归开发与 sdx-test） |
| DD-n 的备选方案与决策理由 | 与本轮 MVP 无关的扩展设计 |

## 与 PRD 的分工

PRD 描述「做什么、如何验收」；**DSD** 与 **ASD 与/或** `{DOC_DIR}/specs/spec-{IDEA-ID}-{N}-{service-name}.md`（需求规约 Markdown，骨架见 [../assets/dsd-spec-template.md](../assets/dsd-spec-template.md)）共同描述「怎么做、依赖什么系统与数据」（**有 ASD** 时架构级以 **ASD** 为准；**仅有该 Markdown** 时架构/范围级以其 §1 与元数据为准；实现级以 **DSD §2** 为主）。接口名、表结构、消息格式等**属于 DSD 正文与上述汇总稿**；若 PRD 中已出现实现细节，设计时仍以 PRD 功能范围为约束，在 DSD 中给出**工程化**表述。

## 与模板的关系

章节结构与占位说明以 [../assets/dsd-template.md](../assets/dsd-template.md) 为准（**§1** 与 **ASD §1** 或 **仅有 `specs/spec-{IDEA-ID}-{N}-{service-name}.md` 时** 与该文件 §1–2 对齐，骨架见 `asd-template`）；本文件约束**语气与信息类型**，不替代模板中的必填小节。
