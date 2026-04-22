---
name: docs-archive
description: >
  Slash 命令：`/docs-archive`。输入指定 overview 文件（可含多视角章节）；
  归档目标默认取自 overview 各行副标题中的文件链接与对应章节，无需额外提供目标路径。
  从指定 overview 的各视角章节抽取可归档知识，映射并写入「各架构视角表」每行副标题文件链接对应章节；
  默认采用“剪切”模式：每行归档落盘后，从 overview 中删除该行已归档的知识片段，避免重复维护。
  补充后做一致性检查，冲突时分步向用户确认。
  工作流强制「先探索与澄清 → 给出 2～3 种方案与取舍 → 用户确认后再落盘」，禁止未经确认的批量改写。
  只要用户意图涉及知识归档、合并、补充、补全、增补，或从 overview/章节/多源材料写入架构视角文档或目录、
  需要结构对齐与冲突检查，就必须使用本技能，即使用户未说「归档」也未显式使用 `/docs-archive`。
---

# 知识归档（docs-archive）

将**overview 来源知识**按视角映射归档为与**目标载体**一致的业务表述，并在落盘前后做**结构遵从**与**冲突治理**。目标章节由 overview 行内副标题链接自动确定。闸门、索引与链接约定见 [reference/gates-and-links.md](reference/gates-and-links.md)。

## 与相近技能的分工

| 场景 | 优先技能 |
|------|----------|
| 从代码与四视角链提取实体 ID、刷新 `KNOWLEDGE_INDEX` | `docs-build` |
| 定向增改 Markdown 并链式同步引用 | `docs-upgrade` |
| SDD 各阶段标准产物（Solution/PRD/ADD/TDD 等） | `sdx-*` |
| 指定 overview 各视角 → 各架构视角表行副标题文件链接对应章节的归档补充 + 冲突检查 | **本技能** |

---

## HARD-GATE

在用户明确确认**方案确认书**（模板见 [assets/archive-template.md](assets/archive-template.md)）之前：

- **禁止**修改任何目标文档，**禁止**在目标目录下新增/覆盖终稿内容（草稿可先写在会话内或用户指定的临时路径）。
- **允许**：读取 overview 与链接目标章节、列出目录、做笔记、输出方案与对比、在用户同意的临时区生成对比稿。

若用户坚持「直接改」，仍须先用一句话概括将采用的方案与风险，并得到用户**明确同意**后再落盘。

---

## 输入与输出

| 类型 | 内容 |
| ---- | ---- |
| 硬输入 | overview 文件（可指定章节/锚点范围）；用户确认的**方案确认书** |
| 可选输入 | 术语表、冲突策略、来源清理策略（删除/保留/替换为空壳）、临时映射/冲突清单文件路径 |
| 固定产出 | 按目标体例增补后的 Markdown（重点为架构视角表行副标题链接对应章节）及用户要求同步的索引/README |
| 不产出 | 不经确认的批量覆盖；不代替 `docs-build` 生成实体 ID |

### overview 指定语法

用户可用一行紧凑形式直接指定 overview，执行步骤 0 时先解析 overview 路径与可选范围，再进入澄清与方案确认：

**模式**：`{overview}` 或 `{overview}#{章节/锚点}`

| 字段 | 含义 | 示例 |
| ---- | ---- | ---- |
| overview | 仓库内 overview 文件路径（必填） | `system/architecture/overview/billing-overview.md` |
| 章节/锚点 | 可选，仅归档该范围 | `#支付域`、`#refund-flow` |

**解析约定**：

1. **仅认 overview**：默认不接收额外目标路径；目标取自 overview 表格行内副标题链接与对应章节。
2. **路径含空格**：要求用户用引号包裹路径。
3. **缺失链接处理**：若某行无副标题链接或链接章节不存在，列入冲突清单并逐条请用户决策。
4. 解析结果须写入方案确认书中的来源清单与目标清单，不得仅停留在会话口头理解。

---

## 参数（会话内确认）

在进入归档落盘前，须与用户对齐下列维度（可一次性展示、分项确认）；细节问题**一次只问一个**，见 [reference/workflow-spec.md](reference/workflow-spec.md)。

| 参数 | 说明 |
| ---- | ---- |
| 来源范围 | 单文件 / 目录 / 指定章节或标题；是否含附件、脚注 |
| 归档范围 | 全文 / 指定章节；是否仅处理含副标题链接的行 |
| 来源清理 | 每行归档后对 overview 的处理：删除已归档片段 / 仅保留索引壳（推荐）/ 保留不动 |
| 抽象层级 | 摘录级 / 要点级 / 可对外宣讲级；是否保留出处 |
| 术语与风格 | 对齐的术语表或禁用词；语体 |
| 冲突策略 | 与目标已有内容不一致时：以来源为准 / 以目标为准 / 并列待裁决 |
| 产出物 | 是否同步目录导航、changelog 等 |

---

## 工作流（六步）

| 步骤 | 摘要 | 详见 |
|------|------|------|
| 0 | 探索上下文：读 overview 与行内副标题链接目标章节，确认归档边界 | [workflow-spec.md §0](reference/workflow-spec.md) |
| 1 | 澄清范围与约束（分步单问） | §1 |
| 2 | 提出 2～3 种方案与推荐 | §2 |
| 3 | 输出并确认**方案确认书** | §3 |
| 4 | 归档、改写、落盘；按行回写清理 overview | §4 |
| 5 | 文档检查与冲突处理 | §5、[quality-checklist.md](reference/quality-checklist.md) |
| 6 | 变更摘要；不自动 Git 提交 | §6 |

流程图与完整条款见 [reference/workflow-spec.md](reference/workflow-spec.md)。

---

## 核心约束

| 约束 | 原因 |
| ---- | ---- |
| 方案确认门禁 | 防止未经评审的批量改写与范围蔓延 |
| 证据与可追溯 | 归档结论应能在来源中对应；多出处合并须可说明 |
| 结构服从目标 | 标题层级与体例以目标文档/目录为准 |
| 冲突显式处理 | 来源或目标矛盾时不得静默合并；分步请用户裁决 |
| 闸门合规 | 受管路径须符合 [AGENTS.md](../../../AGENTS.md) 与 [CONVENTIONS.md](../../rules/CONVENTIONS.md) |

---

## 依赖关系

| 类型 | 技能/组件 | 说明 |
| ---- | --------- | ---- |
| 可选上游 | `docs-indexing` | 需要权威路径地图时查阅 `INDEX_GUIDE.md` |
| 相邻 | `docs-build` / `docs-upgrade` / `sdx-*` | 分工见上文表；勿混用职责 |
| 下游 | — | 无强制下游；可按需触发 `docs-change` 等 |

---

## 参考资源

| 资源 | 路径 | 何时读 |
| ---- | ---- | ------ |
| 步骤 0～6 全文、流程图 | [reference/workflow-spec.md](reference/workflow-spec.md) | 执行任意步骤时 |
| 闸门、INDEX、链接与 Git | [reference/gates-and-links.md](reference/gates-and-links.md) | 探索目标、自检链接时 |
| 质量与收口清单 | [reference/quality-checklist.md](reference/quality-checklist.md) | 步骤 5～6 |
| 方案确认书模板 | [assets/archive-template.md](assets/archive-template.md) | 步骤 3 落草稿时 |
| 常见陷阱 | [gotchas.md](gotchas.md) | 歧义、抢闸门、与相近技能混淆时 |
