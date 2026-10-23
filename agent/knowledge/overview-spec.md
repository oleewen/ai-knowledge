# overview 缓冲表规范

> **职责**：overview 的表行结构、层级内容边界与归档章节。
> **边界**：文件路径见 [knowledge-layout.md](../references/knowledge-layout.md#overview)；第三列 A/U/D 与去重算法见 [federation-spec.md](../skills/docs-distill/references/federation-spec.md#第三列规则)；文件分型见 [okf-spec.md](okf-spec.md#6-叙事文件处理规则)。

## 表行与内容边界

- overview 为叙事缓冲区，不替代实体 `{ID}.md`。
- 表按「主标题 / 副标题 / 归档列」维护。**实际行序与锚点真源**是目标层 overview 模板及同层五视角 README 表行；必须逐行读取，不能用本文摘要替代。
- 第三列只存待归档 delta。公司只收 SLN 级共性；应用只收本应用实现要点。
- 元库 overview 与 README 只列必有章；按需章由安装后使用方添加，不补空文件。ADR 留在 `adr/`，不进 `chapters/`。

## 系统模板章节

必有章与 `system/knowledge/*/chapters/`、同层 README 章表一致；下表仅给模板结构，处理时仍读取目标表行。

| 视角 | 必有章顺序 | 安装后按需添加 |
| --- | --- | --- |
| 业务 | 概述、术语、能力地图 | 域划分、流程、业务规则与策略 |
| 产品 | 概述、产品架构、信息架构、产品功能、用户旅程与场景 | 版本管理与发布、产品运营支撑、多端策略 |
| 应用 | 系统概述、应用架构、领域模型、服务设计、集成架构 | 领域能力、服务间交互、接口管理、多租户多环境 |
| 技术 | 中间件、性能扩展、高可用 | 技术概述、基础设施、可观测性 |
| 数据 | 数据模型、数据存储 | 数据概述、数据分析、数据流转 |

## 其他层模板章节

| 层 | 章节约束 |
| --- | --- |
| 应用 | 业务/产品不建章节，README 仅作纯 ID 入口；应用：接口管理；技术：中间件、性能扩展；数据：数据模型。归档进本层 chapters |
| 解决方案 | 业务范围、应用与集成、数据主权、技术选型 |
| 公司 | 以 `company/knowledge/overview/` 模板与同层 README 为准 |

## 写入能力

| 操作 | 技能 |
| --- | --- |
| 槽位上行提炼（系统 / 解决方案 / 公司） | [docs-distill](../skills/docs-distill/SKILL.md)；应用 overview 不属于其目标 |
| 非槽位来源提炼（四层） | [docs-extract](../skills/docs-extract/SKILL.md) |
| 关键词标记 / 架构摘录 | [docs-tag](../skills/docs-tag/SKILL.md) |
| 归档与第三列回写 | [docs-archive](../skills/docs-archive/SKILL.md) |
