---
name: sdx-test
description: >
  测试方案设计：基于 PRD 与详细设计 **DSD**（及上游 **ASD**）制定测试策略与计划，设计测试用例、测试数据与回归范围，输出测试设计文档（TDD）。
  当用户执行 /sdx-test、需要编写测试设计文档、制定测试策略与用例、设计回归测试范围、
  需要测试进出标准、需要将 PRD/DSD 转化为可执行的测试方案、或需要覆盖功能/接口/业务规则/异常/性能测试时，务必使用本技能。
  即使用户只说「帮我写个测试方案」「设计一下测试用例」「出一份 TDD」「把 PRD 转成测试用例」、
  「设计一下回归范围」「制定一下进出标准」，也应触发本技能。
  本技能默认执行门禁：未完成「草稿用户总确认」前，禁止写入 {DOC_DIR}/requirements/**/TDD-*.md。
  若用户已明确要求只做 sdx-solution、sdx-analysis、sdx-prd、sdx-architect、sdx-design 的正文落盘，或执行 docs-distill/docs-extract/docs-archive/docs-indexing/docs-build，则不要以本技能为主路径，应分流到对应技能。
---

# 测试设计阶段（sdx-test）

本技能以「调度器」方式工作：先判定是否应由 `sdx-test` 处理，再按阶段读取规范文件，经会话 spec 与门禁后产出可校验的 **`TDD-{IDEA-ID}-{N}.md`**。

基于 PRD、**ASD**（架构）与 **DSD**（详细设计及规约），制定当前 MVP 的测试策略与计划，设计测试用例、测试数据与回归范围。**不产出**：自动化测试代码、测试报告。

**上游**：`sdx-prd`（必需）、**`sdx-architect`、`sdx-design`**（均推荐）。

主要读者：**测试/质量角色**（制定策略与用例）；**研发参与评审**（可执行性、数据与环境、与 **DSD** 一致性）。

---

## 适用边界

- **本技能负责**：`TDD-*.md`（六章模板）、会话 spec（`...-sdx-test.md`）、G1–G6（或精简 4G）、进出标准与回归范围表述。
- **本技能不负责**：可执行自动化测试、测试执行报告、**SOLUTION/ANALYSIS/PRD/ASD/DSD** 的替代性主产物；**docs-*** 主流程。
- **边界分流**：用户只要上游 SDX 正文或文档工程技能时，转对应 `sdx-*` 或 **docs-***。

---

## 输入与前置检查

执行前最少确认：

- **IDEA-ID / MVP 阶段**（与 PRD/DSD/ASD 同目录命名一致）。
- **门禁粒度**（全量 6G 或精简 4G）与 **`--depth`**（`quick` / `standard` / `deep`）。
- **`{DOC_DIR}`** 与 **`docs/superpowers/specs/`** 可写路径意识。

若用户仅要上游产物或 docs 类指令明确，不强行套入本技能全流程。

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
10. **模板与骨架**：阶段二用 `assets/test-session-spec-template.md`；阶段三用 `assets/tdd-template.md`

---

## 门禁要求（必须执行）

- 总确认前，禁止写 `{DOC_DIR}/requirements/**/TDD-*.md`；合法例外与标记见 `references/gates.md`。
- 建议在会话 spec 使用 `PENDING` / `CONFIRMED` 语义（HTML 注释形态见 `gates.md`）。

---

## 阶段节奏（摘要）

- **阶段一**：确认 IDEA-ID、门禁粒度（6G / 精简 4G）、`--depth`（详见 `workflow.md` 与 `core-concepts.md`）。
- **阶段二**：`docs/superpowers/specs/YYYY-MM-DD-<topic>-sdx-test.md`，骨架见 `assets/test-session-spec-template.md`；每次只呈现一段草案或一个待确认点，末尾附 **C/M/S/F**（见 `gates.md`）。
- **阶段三**：在同目录 **`TDD-{IDEA-ID}-{N}.md`** 按 `assets/tdd-template.md` 分块填充与终检。

---

## 产出与校验

- **会话 spec**：`docs/superpowers/specs/YYYY-MM-DD-<topic>-sdx-test.md`（骨架见会话模板）。
- **正式产物**：`{DOC_DIR}/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/TDD-{IDEA-ID}-{N}.md`（六章，见 `assets/tdd-template.md`）。
- 落盘后执行：

  ```bash
  agent/skills/sdx-test/scripts/validate-test.sh
  agent/skills/sdx-test/scripts/validate-test.sh --file path/to/TDD-xxx.md --gate-check
  ```

---

## 评测与迭代（skill-creator 对齐）

- 评测样本：`evals/evals.json`（含 `expected_output` 与 `assertions`）
- 评测元模板：`evals/eval-metadata-template.json`
- 评分规则：`agents/grader.md`
- 失败分析：`agents/analyzer.md`

---

## 工程化支持

钩子：`python3 agent/hooks/sdx_gate_common.py --gate test`，注册见 `agent/hooks.json`；需启用 Hooks 方生效。

---

## 参考资源（按需打开）

| 资源 | 路径 |
|------|------|
| TDD 文档模板（六章） | [assets/tdd-template.md](assets/tdd-template.md) |
| 会话草稿骨架 | [assets/test-session-spec-template.md](assets/test-session-spec-template.md) |
