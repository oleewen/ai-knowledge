# ADR 编写约定

架构决策记录（ADR）的结构、状态与文件命名约定。正文按决策范围落盘于 `application/adr/`、`system/adr/` 或 `company/adr/`。

决策台账：各层 `adr/CONTEXT.md`（与导航用 `index.md` 并存）。  
**SDX 运行时**（何时写、与 SOLUTION/ANALYSIS 如何引用）：[sdx-adr-protocol.md](../references/sdx-adr-protocol.md)。

## 文件命名

- 格式：`ADR-{序号}-{短标题}.md`
- 示例：`ADR-002-api-versioning.md`
- 模板：[adr-template.md](adr-template.md)

## 必备章节

| 章节 | 说明 |
| --- | --- |
| 状态 | Proposed / Accepted / Deprecated / Superseded |
| 上下文 | 背景、问题与约束 |
| 决策 | 明确的做法 |
| 后果 | 正面、负面与可选后续行动 |

## 输入依赖

编写或评审 ADR 前建议查阅：

- [naming-conventions.md](naming-conventions.md) — 实体 ID 与 IDEA-ID
- [glossary.md](glossary.md) — 术语一致性
- [architecture-principles.md](architecture-principles.md) — 原则基线

完整使用顺序见 [README.md](README.md)。
