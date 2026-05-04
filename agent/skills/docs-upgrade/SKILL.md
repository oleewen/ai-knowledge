---
name: docs-upgrade
description: >
  当用户执行 /docs-upgrade、需要定向增改仓库内 Markdown/注释/配置文本、统一术语并沿引用链与关键词做链式同步时，必须使用本技能。
  落盘后按默认规则沿引用链查找关联处，并辅以关键词检索（同义/近义/中英文）定位需对齐的内容后替换。
  只要用户提到以下任意场景，就应立即使用本技能，不要等用户明确说「/docs-upgrade」：
  改文档、改注释、统一术语、对齐表述、替换词语、更新说明、同步引用链、
  「帮我改一下这个文档」「把 X 统一成 Y」「更新一下注释」「这里的说法不一致」、
  「把这段改成…」「文档里有个错别字」「注释过时了」「把所有 X 改成 Y」。
  支持替换简写：a - b、a > b、a 2 b 均表示将 a 替换为 b。
  若用户已明确要求以 docs-archive、docs-change、docs-indexing、docs-build、仅写 CHANGE-LOG 或仅重建 INDEX_GUIDE 为主路径，则不要以本技能为唯一主流程，应分流到对应技能。
---

# docs-upgrade：定向文档与注释升级

本技能以「调度器」方式工作：先判定是否应由 `docs-upgrade` 处理，再按 `references/` 规范完成主修改、关联同步与校验。

可控范围内的文本一致化：先完成主目标文件的增改，再按默认规则把关联处与同类表述对齐。

---

## 适用边界

- **本技能负责**：文档、纯文本、代码与配置中的注释、字符串内文档路径；链式引用检索 + 关键词检索（同义/近义/中英文对应）；会话内**范围确认书**（见 `references/gates.md`）。
- **本技能不负责**：变更索引聚合（**docs-change**）、全库索引重建（**docs-indexing**）、overview 视角归档（**docs-archive**）、实体与 `KNOWLEDGE_INDEX`（**docs-build**），除非用户明确列为附加任务。
- **不包含**（除非用户明确要求）：纯业务逻辑重构、与文档无关的大规模代码改写。

---

## 输入与输出

| 类型 | 内容 |
|------|------|
| 硬输入 | 用户给出的文件路径、粘贴片段或替换指令 |
| 可选输入 | 替换简写（`a - b` / `a > b` / `a 2 b`）、范围限定（「只改本文件」） |
| 固定输出 | 修改后的目标文件；关联文件（链式/关键词检索命中且需对齐时） |
| 不产出 | 变更索引（`docs-change`）、全库索引重建（`docs-indexing`） |

---

## 执行路由（先读后写）

1. **门禁与范围确认**：先读 `references/gates.md`（含可复制模板 [assets/docs-upgrade-scope-ack-template.md](assets/docs-upgrade-scope-ack-template.md)）
2. **主流程步骤**：再读 `references/workflow.md`
3. **预检与同步前闸门**：意图不清或步骤 3 前读 `references/brainstorming-integration.md`
4. **引用链细则**：步骤 3 读 `references/related-doc-discovery.md`
5. **关键词与语义**：步骤 3 读 `references/semantic-keyword-discovery.md`
6. **替换简写与概念**：不确定时读 `references/core-concepts.md`
7. **原则层**：读 `references/design-principles.md`
8. **反模式**：收敛前读 `references/anti-patterns.md`
9. **验证**：落盘后读 `references/quality-checklist.md`
10. **操作层陷阱**：读 `gotchas.md`
11. **全目录索引**：按需读 `references/README.md`

---

## 门禁要求（必须执行）

- **在执行任何写入前**完成范围确认书与用户明确同意（`C` / `S`；快路径见 `references/gates.md`）。
- **禁止**未确认即批量写入多个文件。

---

## 产出与校验

- **产出**：已修改的主文件与已确认的关联文件；链接与结构校验见 `references/quality-checklist.md`。
- **可选集成元数据**：`agents/openai.yaml` 供 Cursor/Agent 展示用，**非**执行本技能的必读输入。

---

## 评测与迭代（skill-creator 对齐）

- 评测样本：`evals/evals.json`（含 `expected_output` 与 `assertions`）
- 评测元模板：`evals/eval-metadata-template.json`
- 评分规则：`agents/grader.md`
- 失败分析：`agents/analyzer.md`

---

## 工程化支持

本仓库 **未** 为 `docs-upgrade` 注册 `preToolUse` 钩子；合规依赖范围确认书与执行纪律。

---

## 须由用户决策的情形

下列情况不得编造，输出编号选项（可附简短推荐与理由），待用户选择后再写入：

- 业务规则、指标数字、日期、责任人、合规/政策结论、架构决策陈述
- 是否删除过时段落、是否保留兼容说明、标题层级或文档结构取舍
- 多文件同名、多段相似但语义可能不同的文本、或链式/关键词检索下「是否视为同一概念」存疑时

---

## 依赖关系

| 类型 | 技能/组件 | 说明 |
|------|-----------|------|
| 协作 | `docs-change` | 变更聚合与时间线索引 |
| 协作 | `docs-indexing` | 重建 `INDEX_GUIDE.md` |
