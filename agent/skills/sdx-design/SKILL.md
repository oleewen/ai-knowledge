---
name: sdx-design
description: >
  详细设计与规约：以 /sdx-architect 产出的 ASD 为硬输入，编写详细设计说明书 DSD。
  DSD **§1 设计概述**与 [asd-template §1](../sdx-architect/assets/asd-template.md) 对齐（可与 ASD §1 同源复制）；**§3 需求规约**继承 [asd-template §3](../sdx-architect/assets/asd-template.md) 与上游 ASD §3 表行并扩写；**详细设计正文从 §2 起编号**（§2 详细设计、§3 需求规约、§4 附录），应用全量附带 specs/*.yaml。
  不包含历史「单文档 ADD」：实现级契约仅以 DSD+规约为准。当用户需要 API/DDL、业务逻辑、规约 YAML 或未声明仅架构时务必使用本技能。
  本技能默认执行门禁：未完成「草稿用户总确认」前，禁止写入 {DOC_DIR}/requirements/**/DSD-*.md。
  若用户已明确要求只做 sdx-solution、sdx-analysis、sdx-prd、sdx-architect、sdx-test 的正文落盘，或执行 docs-distill/docs-extract/docs-archive/docs-indexing/docs-build，则不要以本技能为主路径，应分流到对应技能。
---

# 详细设计阶段（sdx-design）

本技能以「调度器」方式工作：先判定是否应由 `sdx-design` 处理，再按阶段读取规范文件，经会话 spec 与门禁后产出可校验的 **DSD** 与（应用全量时）**`specs/**/*.yaml`**。

**不写 ASD**；必须以 **`ASD-{IDEA-ID}-{N}.md`**（`/sdx-architect`）为输入主干。产出 **`DSD-{IDEA-ID}-{N}.md`**；**§3** 须在 **ASD §3** 已有行上扩写，冲突时以已确认 **ASD + PRD** 溯源为准。

**上游**：**`sdx-architect`（ASD，必选同 IDEA-ID）**、`sdx-prd`、`sdx-analysis`。**下游**：`sdx-test`。

主要读者：**骨干开发、测试设计**。

---

## 适用边界

- **本技能负责**：DSD（§1–§4）、会话 spec（`...-sdx-design.md`）、Gd1–Gd4 与 Qclose-1、应用全量 **`specs/`** 规约落盘与追溯。
- **本技能不负责**：`SOLUTION-*`、`ANALYSIS-*`、`PRD-*`、`ASD-*`、`TDD-*` 的「替代性」主产物；纯文档工程 **docs-*** 主流程。
- **边界分流**：用户只要共识方案、需求分析、PRD、ASD 或测试设计正文时，转对应 `sdx-*`；只要蒸馏/抽取/归档/索引时，转 **docs-***。

---

## 输入与前置检查

执行前最少确认：

- **IDEA-ID**、**ASD 路径**（与同包 PRD 一致）、**`KNOWLEDGE_TYPE`**（见 `references/knowledge-type-modes.md` 索引链）。
- **`--depth`**（与 workflow 中详设粒度一致）。
- 目标工程中 **`{DOC_DIR}`** 与 **`docs/superpowers/specs/`** 可写路径意识。

若用户仅要上游或 docs 产物且指令明确，不强行套入本技能全流程。

---

## 知识与库类型

见 **[references/knowledge-type-modes.md](references/knowledge-type-modes.md)**（权威分工见链入的 `sdx-architect/references/knowledge-type-modes.md`）。

---

## 执行路由（先读后写）

1. **门禁与例外**：先读 `references/gates.md`
2. **流程与阶段**：再读 `references/workflow.md`
3. **阶段二节奏与多方案**：读 `references/brainstorming-integration.md`
4. **原则与错误处理**：边界判断时读 `references/design-principles.md`
5. **反模式（概念层）**：收敛方案前读 `references/anti-patterns.md`
6. **操作层陷阱**：对话执行易错时读 `gotchas.md`
7. **受众与语言**：终检或语言审查时读 `references/audience-and-language.md`
8. **质量终检**：落盘前读 `references/quality-checklist.md`
9. **模板与骨架**：阶段二用 `assets/design-session-spec-template.md`；阶段三用 `assets/dsd-template.md`

---

## 门禁要求（必须执行）

- 总确认前，禁止写 `{DOC_DIR}/requirements/**/DSD-*.md`；合法例外与标记见 `references/gates.md`。
- 建议在会话 spec 使用 `PENDING` / `CONFIRMED` 语义（HTML 注释形态见 `gates.md`）。

---

## 产出与校验

- **会话 spec**：`docs/superpowers/specs/YYYY-MM-DD-<topic>-sdx-design.md`（骨架见 `assets/design-session-spec-template.md`）。
- **正式产物**：`{DOC_DIR}/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/DSD-{IDEA-ID}-{N}.md`（结构见 `assets/dsd-template.md`）；应用全量时 **`specs/{service}/{type}/`** 与 DSD 同期。
- 落盘后执行：

  ```bash
  agent/skills/sdx-design/scripts/validate-dsd.sh
  agent/skills/sdx-design/scripts/validate-dsd.sh --file path/to/DSD-xxx.md --gate-check
  ```

`validate-design.sh` 等价于 `validate-dsd.sh`。

---

## 评测与迭代（skill-creator 对齐）

- 评测样本：`evals/evals.json`（含 `expected_output` 与 `assertions`）
- 评测元模板：`evals/eval-metadata-template.json`
- 评分规则：`agents/grader.md`
- 失败分析：`agents/analyzer.md`

---

## 工程化支持

钩子：`python3 agent/hooks/sdx_gate_common.py --gate design`，注册见 `agent/hooks.json`；需启用 Hooks 方生效（拦截 **`DSD-*`** 写入）。

---

## 参考资源（跨技能）

| 资源 | 路径 |
|------|------|
| ASD §1 / 上游结构 | [../sdx-architect/assets/asd-template.md](../sdx-architect/assets/asd-template.md) |
| DSD 模板（§1+§2–§4） | [assets/dsd-template.md](assets/dsd-template.md) |
