---
name: docs-archive
description: >
  将 overview 文件中的知识按视角归档到架构视角表各行副标题文件链接对应章节，归档后从 overview 清理已归档片段，补充后做一致性检查与冲突处理。
  只要用户意图涉及以下任一场景，就应立即触发本技能，不要等用户说出命令名：
  「知识归档」「把 overview 内容写进去」「补充架构视角文档」「把这些内容合并进去」「增补知识到目标文档」
  「从 overview 归档」「把章节内容归档」「知识补全」「把这段写入对应章节」「overview 内容落盘」
  「结构对齐」「冲突检查」「从多源材料写入架构文档」「把知识同步到视角文件」。
  即使用户只说「帮我把 billing-overview 的内容归档一下」或「把这几节补进架构文档」也应触发。
  工作流强制「探索 → 澄清 → 2～3 种方案 → 用户确认方案确认书 → 落盘」，禁止未经确认的批量改写。
  用户执行 /docs-archive 时必须触发。
---

# 知识归档（docs-archive）

将 **overview 来源知识**按视角映射归档为与**目标载体**一致的业务表述，并在落盘前后做**结构遵从**与**冲突治理**。目标章节由 overview 行内副标题链接自动确定。

## 快速定向

| 需要做什么 | 去读 | 何时打开 |
|-----------|------|---------|
| 工作流职责、HARD-GATE、输入输出 | 本文件（继续往下读） | 每次执行前 |
| 步骤 0～6 全文、流程图 | [reference/workflow-spec.md](reference/workflow-spec.md) | 执行任意步骤时 |
| 闸门、INDEX、链接与 Git | [reference/gates-and-links.md](reference/gates-and-links.md) | 探索目标路径、自检链接时 |
| 质量与收口清单 | [reference/quality-checklist.md](reference/quality-checklist.md) | 步骤 5～6 收口时 |
| 方案确认书模板 | [assets/archive-template.md](assets/archive-template.md) | 步骤 3 落草稿时 |
| 常见陷阱 | [gotchas.md](gotchas.md) | 遇到歧义、抢闸门、与相近技能混淆时 |

## 与相近技能的分工

| 场景 | 优先技能 |
|------|----------|
| 从代码与四视角链提取实体 ID、刷新 `KNOWLEDGE_INDEX` | `docs-build` |
| 定向增改 Markdown 并链式同步引用 | `docs-upgrade` |
| SDD 各阶段标准产物（Solution/PRD/ADD/TDD 等） | `sdx-*` |
| 指定 overview 各视角 → 各架构视角表行副标题文件链接对应章节的归档补充 + 冲突检查 | **本技能** |

---

## HARD-GATE

在用户明确确认**方案确认书**（模板见 [assets/archive-template.md](assets/archive-template.md)）之前，禁止写入任何目标文档。这个门禁的目的是防止未经评审的批量改写——overview 往往跨多个视角，一旦错误落盘很难回滚。

- **禁止**：修改目标文档、在目标目录下新增/覆盖终稿内容
- **允许**：读取 overview 与链接目标章节、列出目录、输出方案对比、在临时区生成对比稿

**门禁标记**：会话 spec 中使用 `<!-- docs-archive-gate: PENDING -->`，用户明确确认方案确认书后改为 `<!-- docs-archive-gate: CONFIRMED -->`，且正文须出现目标文件名（basename）。本 gate **无 bypass 环境变量**，须完整走确认流程；唯一例外是用户在同一对话中明示跳过。

若用户坚持「直接改」，仍须一句话概括方案与风险，得到**明确同意**后再落盘。

---

## 输入与输出

| 类型 | 内容 |
| ---- | ---- |
| 硬输入 | overview 文件（可指定章节/锚点范围）；用户确认的**方案确认书** |
| 可选输入 | 术语表、冲突策略、来源清理策略（删除/保留/替换为空壳）、临时映射/冲突清单路径 |
| 固定产出 | 按目标体例增补后的 Markdown（架构视角表行副标题链接对应章节）及用户要求同步的索引/README |
| 不产出 | 未经确认的批量覆盖；不代替 `docs-build` 生成实体 ID |

### overview 指定语法

**模式**：`{overview}` 或 `{overview}#{章节/锚点}`

| 字段 | 含义 | 示例 |
| ---- | ---- | ---- |
| overview | 仓库内 overview 文件路径（必填） | `system/architecture/overview/billing-overview.md` |
| 章节/锚点 | 可选，仅归档该范围 | `#支付域`、`#refund-flow` |

解析约定：目标取自 overview 表格行内副标题链接，不接收额外目标路径；路径含空格须加引号；缺失链接列入冲突清单逐条请用户决策；解析结果须写入方案确认书，不得仅停留在口头理解。

---

## 参数（会话内确认）

阶段 2 CLARIFY 中须与用户对齐下列维度，**一次只问一个**（选择题优先）：

| 参数 | 说明 |
| ---- | ---- |
| 来源范围 | 单文件 / 目录 / 指定章节；是否含附件、脚注 |
| 归档范围 | 全文 / 指定章节；是否仅处理含副标题链接的行 |
| 来源清理 | 归档后对 overview 的处理：删除已归档片段 / 仅保留索引壳（推荐）/ 保留不动 |
| 抽象层级 | 摘录级 / 要点级 / 可对外宣讲级 |
| 术语与风格 | 对齐的术语表或禁用词；语体 |
| 冲突策略 | 与目标已有内容不一致时：以来源为准 / 以目标为准 / 并列待裁决 |
| 产出物 | 是否同步目录导航、changelog 等 |

---

## 工作流（五阶段）

| 阶段 | 名称 | 摘要 | 详见 |
|------|------|------|------|
| 1 | EXPLORE | 读 overview 与行内副标题链接目标章节，确认归档边界 | [workflow-spec.md](reference/workflow-spec.md) §1 |
| 2 | CLARIFY | 逐项确认范围与约束，单次一问 | §2 |
| 3 | CONFIRM（HARD-GATE）| 输出方案确认书；可选 dry-run；用户明确同意后解锁阶段 4 | §3 |
| 4 | EXECUTE | 4.1 按行归档写入目标章节 → 4.2 回写清理 overview | §4 |
| 5 | CLOSE | 一致性检查 + 冲突处理；变更摘要；CHANGE-LOG 倒序插入；不自动 git commit | §5–6 |

> **HARD-GATE**：阶段 3 用户确认前，禁止执行阶段 4。dry-run 属于阶段 3，不单独占阶段。

流程图与完整步骤细则见 [reference/workflow-spec.md](reference/workflow-spec.md)。

---

## 核心约束

| 约束 | 原因 |
| ---- | ---- |
| 方案确认门禁 | 防止未经评审的批量改写与范围蔓延 |
| 来源不入正文 | 归档后目标正文不写来源标注；来源清单仅保留在方案确认书与冲突清单中 |
| 结构服从目标 | 标题层级与体例以目标文档/目录为准，不强行保留来源章节顺序 |
| 冲突显式处理 | 来源或目标矛盾时不得静默合并；分步请用户裁决 |
| 闸门合规 | 受管路径须符合 [AGENTS.md](../../../AGENTS.md) 与 [CONVENTIONS.md](../../rules/CONVENTIONS.md) |

---

## 工程化支持

仓库 [agent/hooks.json](../../hooks.json) 注册了 `preToolUse` 钩子（`Write` / `StrReplace`），脚本见 [agent/hooks/sdx_gate_common.py](../../hooks/sdx_gate_common.py)（`python3 agent/hooks/sdx_gate_common.py --gate archive`）；需启用 Hooks 方生效。

钩子证据校验逻辑：检查 `docs/superpowers/specs/` 下是否存在包含 `<!-- docs-archive-gate: CONFIRMED -->` 且引用目标文件名的 spec 文件；未通过则拒绝写入。**本 gate 无 bypass 环境变量。**

---

## 依赖关系

| 类型 | 技能/组件 | 说明 |
| ---- | --------- | ---- |
| 可选上游 | `docs-indexing` | 需要权威路径地图时查阅 `INDEX_GUIDE.md` |
| 相邻 | `docs-build` / `docs-upgrade` / `sdx-*` | 分工见上文表；勿混用职责 |
| 下游 | — | 无强制下游；可按需触发 `docs-change` 等 |
