---
name: docs-distill
description: >
  Slash 命令：`/docs-distill`。从指定来源（单文件、目录、或文档内选定章节/锚点范围）提炼、抽象、总结业务知识，并按目标文档或目标目录的体例与结构要求补充写入；
  补充后做一致性检查，发现与既有内容或来源冲突时分步向用户提问确认后再解决。
  工作流强制「先探索与澄清 → 给出 2～3 种方案与取舍 → 用户确认后再落盘」，禁止未经确认的批量改写。
  只要用户提到：知识蒸馏、从文档/章节提炼业务知识、把材料摘要合并进某份目标文档、按模板补全业务说明、
  多源合并到统一知识库文档、或「从 A 文档吸收内容写到 B」且需要结构对齐与冲突检查，就必须使用本技能，
  即使用户未说「蒸馏」二字。
---

# 知识蒸馏（docs-distill）

将**来源知识**压缩为与**目标载体**一致的业务表述，并在落盘前后做**结构遵从**与**冲突治理**。闸门、索引与链接约定见 [reference/gates-and-links.md](reference/gates-and-links.md)。

## 与相近技能的分工

| 场景 | 优先技能 |
|------|----------|
| 从代码与四视角链提取实体 ID、刷新 `KNOWLEDGE_INDEX` | `docs-build` |
| 定向增改 Markdown 并链式同步引用 | `docs-upgrade` |
| SDD 各阶段标准产物（Solution/PRD/ADD/TDD 等） | `sdx-*` |
| 多源业务叙述 → 目标文档/目录的结构化补充 + 冲突检查 | **本技能** |

---

## HARD-GATE

在用户明确确认**方案确认书**（模板见 [assets/distill-scheme-template.md](assets/distill-scheme-template.md)）之前：

- **禁止**修改任何目标文档，**禁止**在目标目录下新增/覆盖终稿内容（草稿可先写在会话内或用户指定的临时路径）。
- **允许**：读取来源与目标、列出目录、做笔记、输出方案与对比、在用户同意的临时区生成对比稿。

若用户坚持「直接改」，仍须先用一句话概括将采用的方案与风险，并得到用户**明确同意**后再落盘。

---

## 输入与输出

| 类型 | 内容 |
| ---- | ---- |
| 硬输入 | 来源（文件/目录/章节或锚点范围）、目标（文件或目录）；用户确认的**方案确认书** |
| 可选输入 | 术语表、冲突策略、临时映射/冲突清单文件路径 |
| 固定产出 | 按目标体例增补后的 Markdown（及用户要求同步的索引/README） |
| 不产出 | 不经确认的批量覆盖；不代替 `docs-build` 生成实体 ID |

---

## 参数（会话内确认）

在进入蒸馏落盘前，须与用户对齐下列维度（可一次性展示、分项确认）；细节问题**一次只问一个**，见 [reference/workflow-spec.md](reference/workflow-spec.md)。

| 参数 | 说明 |
| ---- | ---- |
| 来源范围 | 单文件 / 目录 / 指定章节或标题；是否含附件、脚注 |
| 目标形态 | 单文件追加或替换节 / 多文件拆分 / 新建并更新索引 |
| 抽象层级 | 摘录级 / 要点级 / 可对外宣讲级；是否保留出处 |
| 术语与风格 | 对齐的术语表或禁用词；语体 |
| 冲突策略 | 与目标已有内容不一致时：以来源为准 / 以目标为准 / 并列待裁决 |
| 产出物 | 是否同步目录导航、changelog 等 |

---

## 工作流（六步）

| 步骤 | 摘要 | 详见 |
|------|------|------|
| 0 | 探索上下文：读来源与目标体例，确认「从哪来、到哪去」 | [workflow-spec.md §0](reference/workflow-spec.md) |
| 1 | 澄清范围与约束（分步单问） | §1 |
| 2 | 提出 2～3 种方案与推荐 | §2 |
| 3 | 输出并确认**方案确认书** | §3 |
| 4 | 蒸馏、改写、落盘 | §4 |
| 5 | 文档检查与冲突处理 | §5、[quality-checklist.md](reference/quality-checklist.md) |
| 6 | 变更摘要；不自动 Git 提交 | §6 |

流程图与完整条款见 [reference/workflow-spec.md](reference/workflow-spec.md)。

---

## 核心约束

| 约束 | 原因 |
| ---- | ---- |
| 方案确认门禁 | 防止未经评审的批量改写与范围蔓延 |
| 证据与可追溯 | 蒸馏结论应能在来源中对应；多出处合并须可说明 |
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
| 方案确认书模板 | [assets/distill-scheme-template.md](assets/distill-scheme-template.md) | 步骤 3 落草稿时 |
| 常见陷阱 | [gotchas.md](gotchas.md) | 歧义、抢闸门、与相近技能混淆时 |
