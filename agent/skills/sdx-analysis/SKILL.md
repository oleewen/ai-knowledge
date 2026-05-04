---
name: sdx-analysis
description: >
  当用户执行 /sdx-analysis、需要把已共识的 SOLUTION 细化为可排期的需求分析、拆 MVP 与依赖/风险并产出 ANALYSIS 时，必须使用本技能。
  默认门禁：未完成「草稿用户总确认」前禁止写入 {DOC_DIR}/analysis/ANALYSIS-*.md。
  即使用户只说「帮我分析一下需求」「拆一下 MVP」「细化一下方案」，若上下文已指向共识方案之后的需求细化，也应触发本技能。
  若用户仅有会议纪要尚无 SOLUTION、或明确要求只写 SOLUTION/PRD/ASD/DSD、或执行 docs-distill/docs-extract/docs-indexing，则不要以本技能为主路径，应分流到对应技能。
---

# 需求分析阶段（sdx-analysis）

本技能以「调度器」方式工作：先判定是否应由 `sdx-analysis` 处理，再按阶段读取规范文件，经会话 spec 与门禁后产出可校验的 `ANALYSIS-*.md`（六章，见 `assets/analysis-template.md`）。

---

## 适用边界

- **本技能负责**：`ANALYSIS-*.md`（六章）、会话 spec（`...-sdx-analysis.md`）、基于 **`SOLUTION-{IDEA-ID}.md`** 的 FR/MVP/依赖/风险细化、门禁与校验。
- **本技能不负责**：共识级 `SOLUTION-*` 初稿；`PRD-*`、`ASD-*`、`DSD-*` 正式落盘；`docs-distill` / `docs-extract` / `docs-indexing` / `docs-archive` 等文档工程主流程。
- **边界分流**：无方案输入时引导 `sdx-solution`；用户只要 PRD/架构/docs 技能时转对应技能，不把「写 ANALYSIS」当作替代路径。

---

## 输入与前置检查

执行前最少确认：

- 存在可对齐的 **`SOLUTION-{IDEA-ID}.md`**（或用户确认的不完整方案及风险标注策略）。
- **IDEA-ID** 与上游方案文件一致；门禁粒度（6G / 精简 4G）与分析深度。
- `{DOC_DIR}/analysis/` 与 `docs/superpowers/specs/` 可写路径意识。

若仅有会议纪要、用户明确要求先出 SOLUTION，则不强行套入本技能全流程。

---

## 执行路由（先读后写）

1. **门禁与例外**：先读 `references/gates.md`
2. **流程与阶段**：再读 `references/workflow.md`
3. **阶段二节奏与多方案**：读 `references/brainstorming-integration.md`
4. **IDEA-ID 与上游对齐**：不确定时读 `references/core-concepts.md`
5. **原则与错误处理**：边界判断时读 `references/design-principles.md`
6. **反模式（概念层）**：收敛方案前读 `references/anti-patterns.md`
7. **操作层陷阱**：MVP、依赖与风险表述易错时读 `gotchas.md`
8. **受众与语言**：终检或语言审查时读 `references/audience-and-language.md`
9. **质量终检**：落盘前读 `references/quality-checklist.md`
10. **模板、骨架与形态参考**：阶段二用 `assets/analysis-session-spec-template.md`；阶段三用 `assets/analysis-template.md`；需要「一行级」形态对齐时读 `assets/samples/mini-analysis-example.md`

---

## 门禁要求（必须执行）

- 总确认前，禁止写 `{DOC_DIR}/analysis/ANALYSIS-*.md`；合法例外与标记见 `references/gates.md`。
- 建议在会话 spec 使用 `PENDING` / `CONFIRMED` 语义（HTML 注释形态见 `gates.md`）。

---

## 产出与校验

- **会话 spec**：`docs/superpowers/specs/YYYY-MM-DD-<topic>-sdx-analysis.md`（骨架见会话模板）。
- **正式产物**：`{DOC_DIR}/analysis/ANALYSIS-{IDEA-ID}.md`（六章，见 `assets/analysis-template.md`）。
- 落盘后执行：

  ```bash
  agent/skills/sdx-analysis/scripts/validate-analysis.sh
  agent/skills/sdx-analysis/scripts/validate-analysis.sh --file path/to/ANALYSIS-xxx.md --gate-check
  ```

---

## 评测与迭代（skill-creator 对齐）

- 评测样本：`evals/evals.json`（含 `expected_output` 与 `assertions`）
- 评测元模板：`evals/eval-metadata-template.json`
- 评分规则：`agents/grader.md`
- 失败分析：`agents/analyzer.md`

---

## 工程化支持

钩子：`python3 agent/hooks/sdx_gate_common.py --gate analysis`，注册见 `agent/hooks.json`；需启用 Hooks 方生效。
