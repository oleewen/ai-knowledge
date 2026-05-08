---
name: sdx-solution
description: >
  当用户执行 /sdx-solution、需要编写共识级解决方案文档、或收到模糊/矛盾业务需求需结构化分析与 MVP 里程碑时，必须使用本技能。
  从业务描述提取诉求、评估影响面、识别并化解冲突，产出供业务与产品评审的 SOLUTION；默认门禁：未完成「草稿用户总确认」前禁止写入 {DOC_DIR}/solutions/SOLUTION-*.md。
  即使用户只说「帮我写个方案」「分析一下这个需求」「整理一下业务目标」，也应触发本技能。
  若用户已明确要求仅做需求分析、PRD、ASD/DSD、或 docs-distill/docs-extract/docs-indexing，则不要以本技能为主路径，应分流到对应技能。
---

# 解决方案阶段（sdx-solution）

本技能以「调度器」方式工作：先判定是否应由 `sdx-solution` 处理，再按阶段读取规范文件，经会话 spec 与门禁后产出可校验的 `SOLUTION-*.md`。

主要读者：**解决方案工程师**（撰写与验收）；**产品与架构师参与评审**（可行性、范围）。架构与实现细化留给下游 **`sdx-architect`（ASD）** / **`sdx-design`（DSD）**。
---

## 适用边界

- **本技能负责**：共识级 `SOLUTION-*.md`（七章模板）、会话 spec（`...-sdx-solution.md`）、阶段一至三流程与门禁、影响面与冲突/MVP 共识表述（业务语言为主）。
- **本技能不负责**：`ANALYSIS-*`、`PRD-*`、`ASD-*`、`DSD-*`、`TDD-*` 的正式落盘；实现级 API/DDL/**specs/spec-{IDEA-ID}-{N}-{service-name}.md 规约**；`docs-distill` / `docs-extract` / `docs-indexing` / `docs-archive` 等文档工程技能的主流程。
- **边界分流**：用户明确只要下游产物时，转对应 `sdx-*` 或 `docs-*` 技能，不把「仅写 SOLUTION」当作替代路径。

---

## 输入与前置检查

执行前最少确认：

- 有可用的**原始业务描述**（会议纪要、工单、邮件等其一即可；过短则先补背景）。
- **IDEA-ID** 与门禁粒度、分析深度（可在阶段一与用户确认）。
- 目标工程中的 `{DOC_DIR}` 与 `docs/superpowers/specs/` 可写路径意识。

若用户仅要 ANALYSIS/PRD/ASD 等且已有明确下游指令，不强行套入本技能全流程。

---

## 执行路由（先读后写）

1. **门禁与例外**：先读 `references/gates.md`
2. **流程与阶段**：再读 `references/workflow.md`
3. **阶段二节奏与多方案**：读 `references/brainstorming-integration.md`
4. **IDEA-ID 与编号**：不确定时读 `references/core-concepts.md`
5. **原则与错误处理**：边界判断时读 `references/design-principles.md`
6. **反模式（概念层）**：收敛方案前读 `references/anti-patterns.md`
7. **操作层陷阱**：对话执行易错时读 `gotchas.md`
8. **受众与语言**：终检或语言审查时读 `references/audience-and-language.md`
9. **质量终检**：落盘前读 `references/quality-checklist.md`
10. **模板与骨架**：阶段二用 `assets/solution-session-spec-template.md`；阶段三用 `assets/solution-template.md`

---

## 门禁要求（必须执行）

- 总确认前，禁止写 `{DOC_DIR}/solutions/SOLUTION-*.md`；合法例外与标记见 `references/gates.md`。
- 建议在会话 spec 使用 `PENDING` / `CONFIRMED` 语义（HTML 注释形态见 `gates.md`）。

---

## 产出与校验

- **会话 spec**：`docs/superpowers/specs/YYYY-MM-DD-<topic>-sdx-solution.md`（骨架见会话模板）。
- **正式产物**：`{DOC_DIR}/solutions/SOLUTION-{IDEA-ID}.md`（七章，见 `assets/solution-template.md`）。
- 落盘后执行：

  ```bash
  agent/skills/sdx-solution/scripts/validate-solution.sh
  agent/skills/sdx-solution/scripts/validate-solution.sh --file path/to/SOLUTION-xxx.md --gate-check
  ```

---

## 评测与迭代（skill-creator 对齐）

- 评测样本：`evals/evals.json`（含 `expected_output` 与 `assertions`）
- 评测元模板：`evals/eval-metadata-template.json`
- 评分规则：`agents/grader.md`
- 失败分析：`agents/analyzer.md`

---

## 工程化支持

钩子：`python3 agent/hooks/sdx_gate_common.py --gate solution`，注册见 `agent/hooks.json`；需启用 Hooks 方生效。
