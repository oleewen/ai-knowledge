---
name: docs-archive
description: >
  当用户执行 /docs-archive、需要把 overview 中知识按视角归档到架构视角表各行副标题链接对应章节、并在归档后清理 overview 与做冲突检查时，必须使用本技能。
  只要用户意图涉及以下任一场景，就应立即触发本技能，不要等用户说出命令名：
  「知识归档」「把 overview 内容写进去」「补充架构视角文档」「把这些内容合并进去」「增补知识到目标文档」
  「从 overview 归档」「把章节内容归档」「知识补全」「把这段写入对应章节」「overview 内容落盘」
  「结构对齐」「冲突检查」「从多源材料写入架构文档」「把知识同步到视角文件」。
  即使用户只说「帮我把 billing-overview 的内容归档一下」或「把这几节补进架构文档」也应触发。
  工作流强制「探索 → 澄清 → 2～3 种方案 → 用户确认方案确认书 → 落盘」，禁止未经确认的批量改写。
  若用户已明确要求以 docs-extract、docs-distill、docs-build、docs-upgrade、仅写 SDD 终稿或仅刷新 KNOWLEDGE_INDEX 为主路径，则不要以本技能为唯一主流程，应分流到对应技能。
---

# docs-archive：从 overview 归档到架构视角文档

本技能以「调度器」方式工作：先判定是否应由 `docs-archive` 处理，再按阶段读取 `references/` 下规范文件，经**方案确认书**与门禁后写入目标章节并可选回写 overview。

将 **overview 来源知识**按视角映射为与**目标载体**一致的业务表述，并在落盘前后做**结构遵从**与**冲突治理**。目标章节由 overview 行内副标题链接确定（见 [references/core-concepts.md](references/core-concepts.md)）。

---

## 适用边界

- **本技能负责**：overview（可选章节锚点）→ 表格行内链接指向的架构视角章节；方案确认书；来源清理（删除/索引壳/保留）；步骤 5～6 质量与变更摘要。
- **本技能不负责**：从任意 `--sources` 提炼写入 overview 第三列（**docs-extract**）；应用知识上行蒸馏（**docs-distill**）；实体 ID 与 `KNOWLEDGE_INDEX` 链（**docs-build**）；全库术语替换与引用链同步（**docs-upgrade**）；`{DOC_DIR}` 下 SDD 标准终稿代写（**sdx-***）。
- **分流**：用户明确只要上述下游时，转对应 `docs-*` 或 `sdx-*` 技能。

---

## 输入与前置检查

- 有可用的 **overview 路径**（及可选 `#锚点`）；知晓目标由**行内副标题链接**解析。
- 知晓会话 spec 目录 `docs/superpowers/specs/` 与钩子对 `CONFIRMED` + 目标 **basename** 的证据要求。

---

## 执行路由（先读后写）

1. **门禁与例外**：先读 `references/gates.md`
2. **步骤 0～6 与流程图**：再读 `references/workflow.md`
3. **索引与链接、Git**：探索路径或步骤 6 时读 `references/links-and-index.md`
4. **overview 语法与链接解析**：不确定时读 `references/core-concepts.md`
5. **原则层**：边界判断时读 `references/design-principles.md`
6. **反模式（概念层）**：收敛方案前读 `references/anti-patterns.md`
7. **多方案节奏**：长澄清链时读 `references/brainstorming-integration.md`
8. **落盘前/后验收**：步骤 5～6 读 `references/quality-checklist.md`
9. **操作层陷阱**：异常或抢闸门时读 `gotchas.md`
10. **全目录索引**：按需读 `references/README.md`
11. **方案确认书成稿**：步骤 3 用 `assets/archive-template.md`
12. **会话 spec 起稿**：可复用 `assets/docs-archive-session-spec-template.md`

---

## 门禁要求（必须执行）

- 用户明确确认**方案确认书**前，禁止写入任何目标文档。标记、例外与钩子见 `references/gates.md` 与 [agent/rules/CONVENTIONS.md](../../rules/CONVENTIONS.md#artifact-gates)。

---

## 产出与校验

- **会话 spec**：`docs/superpowers/specs/YYYY-MM-DD-<topic>-docs-archive.md`（可选从 `assets/docs-archive-session-spec-template.md` 起稿）。
- **正式产物**：按目标体例增补后的 Markdown（链接指向的章节）及用户要求同步的索引/README；overview 按确认策略回写。

---

## 评测与迭代（skill-creator 对齐）

- 评测样本：`evals/evals.json`（含 `expected_output` 与 `assertions`）
- 评测元模板：`evals/eval-metadata-template.json`
- 评分规则：`agents/grader.md`
- 失败分析：`agents/analyzer.md`

---

## 工程化支持

钩子：`python3 agent/hooks/sdx_gate_common.py --gate archive`，注册见 `agent/hooks.json`；需启用 Hooks 方生效。详见 `references/gates.md` 与 `agent/hooks/README.md`。

---

## 与相近技能的分工

| 场景 | 优先技能 |
|------|----------|
| 从代码与四视角链提取实体 ID、刷新 `KNOWLEDGE_INDEX` | `docs-build` |
| 定向增改 Markdown 并链式同步引用 | `docs-upgrade` |
| 从任意源提炼到 overview 第三列 | `docs-extract` |
| SDD 各阶段标准产物（Solution/PRD/ASD/DSD/TDD 等） | `sdx-*` |
| overview 各视角 → 架构视角表行副标题链接对应章节的归档与冲突处理 | **本技能** |

---

## 参数（会话内确认）

步骤 1～2 中须与用户对齐下列维度，**一次只问一个**（选择题优先）；已确认项跳过。

| 参数 | 说明 |
|------|------|
| 来源范围 | 单文件 / 目录 / 指定章节；是否含附件、脚注 |
| 归档范围 | 全文 / 指定章节；是否仅处理含副标题链接的行 |
| 来源清理 | 归档后对 overview：删除已归档片段 / 仅保留索引壳（推荐）/ 保留不动 |
| 抽象层级 | 摘录级 / 要点级 / 可对外宣讲级 |
| 术语与风格 | 对齐的术语表或禁用词；语体 |
| 冲突策略 | 与目标已有内容不一致时：以来源为准 / 以目标为准 / 并列待裁决 |
| 产出物 | 是否同步目录导航、changelog 等 |

### overview 指定语法

见 [references/core-concepts.md](references/core-concepts.md)。

---

## 工作流阶段索引

| 阶段 | 名称 | 摘要 | 详见 |
|------|------|------|------|
| 1 | EXPLORE | 读 overview 与行内链接目标章节，确认边界 | [references/workflow.md](references/workflow.md) 步骤 0 |
| 2 | CLARIFY | 逐项确认范围与约束，单次一问 | 步骤 1 |
| 3 | CONFIRM | 方案确认书；用户明确同意后解锁落盘 | 步骤 2～3 |
| 4 | EXECUTE | 写入目标章节；回写清理 overview | 步骤 4 |
| 5 | CLOSE | 一致性检查、冲突处理、变更摘要 | 步骤 5～6 |

> **HARD-GATE**：步骤 3 用户确认前，禁止执行步骤 4。

---

## 依赖关系

| 类型 | 技能/组件 | 说明 |
|------|-----------|------|
| 可选上游 | `docs-indexing` | 需要权威路径地图时查阅 `INDEX_GUIDE.md` |
| 相邻 | `docs-build` / `docs-upgrade` / `docs-extract` / `sdx-*` | 分工见上表 |
| 下游 | — | 可按需触发 `docs-change` 等 |
