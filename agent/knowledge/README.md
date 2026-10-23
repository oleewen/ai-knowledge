# agent/knowledge — 知识库治理 SSOT

本目录维护知识语义与正文规范；[references/](../references/)维护跨技能运行协议，技能只保存本地差额。四层 `DESIGN.md` 是人类短入口，不复制本目录全文。

## 组件

| 决策 / 规范 | 唯一正文 |
| --- | --- |
| 四层职责、实体首次定义、层间基数 | [knowledge-governance.md](knowledge-governance.md) |
| 词义、实体缩写、精确 type/perspective 登记 | [glossary.md](glossary.md) |
| 实体 ID / IDEA-ID 字面语法 | [naming-conventions.md](naming-conventions.md) |
| 关系动词、允许边、双向同步与例外、废弃字段 | [entity-relations.md](entity-relations.md) |
| 业务 knowledge 允许引用的目标与形式 | [knowledge-reference-rules.md](knowledge-reference-rules.md) |
| 联邦清单、工作区路径、HTTP 生成与离线校验 | [federation-config.md](federation-config.md) |
| 文件分型、实体 frontmatter 与正文结构 | [okf-spec.md](okf-spec.md) |
| 业务实体字段必填性与属性 | [business-meta.md](business-meta.md) |
| 产品实体字段必填性与属性 | [product-meta.md](product-meta.md) |
| 应用实体字段必填性与属性 | [application-meta.md](application-meta.md) |
| 数据实体字段必填性与属性 | [data-meta.md](data-meta.md) |
| 技术实体字段必填性与属性 | [technical-meta.md](technical-meta.md) |
| overview 行序、列职责与归档接口 | [overview-spec.md](overview-spec.md) |
| 架构原则条目 | [architecture-principles.md](architecture-principles.md) |
| ADR 命名、落盘、章节、状态与 CONTEXT 台账 | [adr-guidelines.md](adr-guidelines.md) |
| ADR 四节正文模板 | [adr-template.md](adr-template.md) |

## 使用顺序

1. 查 [治理规则](knowledge-governance.md)判断实体在哪层首次定义；查 [术语表](glossary.md)和 [命名规范](naming-conventions.md)确定类型与 ID。
2. 写实体时读所属视角 meta，按 [关系模型](entity-relations.md)填写合法关系，再按 [OKF](okf-spec.md)组织文件。
3. 跨文件或跨层引用先查 [引用规范](knowledge-reference-rules.md)；需要 parent 解析或 HTTP 时再查 [联邦配置](federation-config.md)。
4. 维护 overview 时查 [overview 规范](overview-spec.md)；确认目录、宿主、阶段与流水线时查 [知识布局](../references/knowledge-layout.md)。
5. 持久架构决策使用 [ADR 规范](adr-guidelines.md)和 [模板](adr-template.md)；SDX 触发与推进见 [SDX ↔ ADR 协议](../references/sdx-adr-protocol.md)。

## 相关入口

- 协作闸门：[CONVENTIONS.md](../rules/CONVENTIONS.md)；根地图：[INDEX-GUIDE.md](../../INDEX-GUIDE.md)、[index.md](../../index.md)、[AGENTS.md](../../AGENTS.md)。
- 层根设计：[公司](../../company/DESIGN.md)、[解决方案](../../solution/DESIGN.md)、[系统](../../system/DESIGN.md)、[应用](../../application/DESIGN.md)。
- ADR 正文：[公司](../../company/adr/README.md)、[解决方案](../../solution/adr/README.md)、[系统](../../system/adr/README.md)、[应用](../../application/adr/README.md)。
