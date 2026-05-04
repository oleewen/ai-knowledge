---
name: sdx-prd
description: >
  当用户执行 /sdx-prd、需要把 ANALYSIS 中当前 MVP 细化为可评审可验收的 PRD（用户故事、用例、流程、验收）时，必须使用本技能。
  默认门禁：未完成「草稿用户总确认」前禁止写入 {DOC_DIR}/requirements/**/PRD-*.md。
  即使用户只说「帮我写个 PRD」「细化用户故事」「设计业务流程」「把需求分析转成 PRD」，在已具备或可指向上游 ANALYSIS 时也应触发本技能。
  若用户仅有会议纪要尚无 SOLUTION/ANALYSIS、或明确要求只做 sdx-solution/sdx-analysis/sdx-architect/sdx-design、或执行 docs-distill/docs-extract/docs-indexing，则不要以本技能为主路径，应分流到对应技能。
---

# 产品需求阶段（sdx-prd）

本技能以「调度器」方式工作：先判定是否应由 `sdx-prd` 处理，再按阶段读取规范文件，经会话 spec 与门禁后产出可校验的 **PRD-{IDEA-ID}-{N}.md**（十一章，见 `assets/prd-template.md`）。

主要读者：**产品**（撰写与验收）；**需求分析师、架构师、研发**参与评审**（可行性、范围）。架构与实现细化留给下游 **`sdx-architect`（ASD）** / **`sdx-design`（DSD）**。

---

## 适用边界

- **本技能负责**：`PRD-*.md`（十一章）、会话 spec（`...-sdx-prd.md`）、当前 **MVP-Phase-{N}** 范围内的流程/用例/故事/规则/验收、门禁与校验。
- **本技能不负责**：共识 `SOLUTION-*`、需求分析 `ANALYSIS-*` 初稿；`ASD-*` / `DSD-*` 正式落盘；`docs-distill` / `docs-extract` / `docs-indexing` / `docs-archive` 主流程。
- **边界分流**：无 ANALYSIS 或用户只要上游/下游产物时，引导或转对应 `sdx-*` / `docs-*` 技能。

---

## 输入与前置检查

执行前最少确认：

- **`ANALYSIS-{IDEA-ID}.md`** 存在且含目标 MVP 材料（缺失则先 `sdx-analysis`）。
- **IDEA-ID** 与 **`N`（MVP-Phase）** 与终稿路径一致。
- `{DOC_DIR}/requirements/.../MVP-Phase-{N}/` 与 `docs/superpowers/specs/` 可写路径意识。

若用户明确要求先做方案或需求分析，不强行套入本技能全流程。

---

## 执行路由（先读后写）

1. **门禁与例外**：先读 `references/gates.md`
2. **流程与阶段**：再读 `references/workflow.md`
3. **阶段二节奏与多方案**：读 `references/brainstorming-integration.md`
4. **IDEA-ID 与路径口径**：不确定时读 `references/core-concepts.md`
5. **原则、编号与表格级反模式**：边界判断时读 `references/design-principles.md`
6. **反模式（叙事级）**：收敛方案前读 `references/anti-patterns.md`
7. **操作层陷阱**：流程/故事/MVP 易错时读 `gotchas.md`
8. **受众与语言**：终检或语言审查时读 `references/audience-and-language.md`
9. **质量终检**：落盘前读 `references/quality-checklist.md`
10. **模板、骨架与形态参考**：阶段二用 `assets/prd-session-spec-template.md`；阶段三用 `assets/prd-template.md`；需「一行级」形态对齐时读 `assets/samples/mini-prd-example.md`

---

## 门禁要求（必须执行）

- 总确认前，禁止写 `{DOC_DIR}/requirements/**/PRD-*.md`；合法例外与标记见 `references/gates.md`。
- 建议在会话 spec 使用 `PENDING` / `CONFIRMED` 语义（HTML 注释形态见 `gates.md`）。

---

## 产出与校验

- **会话 spec**：`docs/superpowers/specs/YYYY-MM-DD-<topic>-sdx-prd.md`（骨架见会话模板）。
- **正式产物**：`{DOC_DIR}/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/PRD-{IDEA-ID}-{N}.md`（十一章，见 `assets/prd-template.md`）。
- 落盘后执行：

  ```bash
  agent/skills/sdx-prd/scripts/validate-prd.sh
  agent/skills/sdx-prd/scripts/validate-prd.sh --file path/to/PRD-xxx.md --gate-check
  ```

---

## 评测与迭代（skill-creator 对齐）

- 评测样本：`evals/evals.json`（含 `expected_output` 与 `assertions`）
- 评测元模板：`evals/eval-metadata-template.json`
- 评分规则：`agents/grader.md`
- 失败分析：`agents/analyzer.md`

---

## 工程化支持

钩子：`python3 agent/hooks/sdx_gate_common.py --gate prd`，注册见 `agent/hooks.json`；需启用 Hooks 方生效。
