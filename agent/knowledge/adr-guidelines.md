# ADR 编写约定

> **定位**：ADR 命名、落盘、章节、状态与决策台账的唯一真源。正文从 [ADR 模板](adr-template.md)起写；SDX 的触发、推进门禁与冲突处理见 [SDX ↔ ADR 协议](../references/sdx-adr-protocol.md)。

## 命名与落盘

文件名 `ADR-{序号}-{短标题}.md`，例如 `ADR-002-api-versioning.md`。按决策范围落盘于 `company/adr/`、`solution/adr/`、`system/adr/` 或 `application/adr/`；结合当前 `.docsconfig` 的 `KNOWLEDGE_TYPE` / `DOC_DIR` 选层。阶段目录见 [知识布局](../references/knowledge-layout.md)。

同目录 `CONTEXT.md` 是决策台账，`index.md` 仅导航。已有决策先查台账与正文，不建立同主题的平行 Accepted 记录；SDX 新 ADR 的初始状态与复用/冲突规则由运行时协议定义。

## 必备章节

| 章节 | 内容 |
| --- | --- |
| 状态 | 提议 (Proposed) / 已通过 (Accepted) / 已废弃 (Deprecated) / 已替代 (Superseded by ADR-YYY) |
| 上下文 | 背景、问题与约束 |
| 决策 | 明确的做法 |
| 后果 | 正面、负面与可选后续行动 |

## CONTEXT.md 台账

| 列 | 定义 |
| --- | --- |
| 分类 | 优先按模块；有 `PM-*` 等用 ID，否则用方案内模块/能力短名 |
| 决策编号 | `ADR-{序号}`，与文件名序号一致 |
| 决策要点 | 一行结论 |
| SSOT | 发起/主引的主要业务文档路径，如 `SOLUTION-*.md` 或 `ANALYSIS-*.md` |
| ADR锚点 | 相对链接到 `ADR-*.md` |

## 输入依赖

治理组件与阅读顺序见 [README.md](README.md)。
