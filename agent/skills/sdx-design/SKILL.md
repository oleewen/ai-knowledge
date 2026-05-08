---
name: sdx-design
description: >
  详细设计与规约：以 /sdx-architect 产出的 **ASD** 与/或 **architect spec**（`{DOC_DIR}/specs/spec-{IDEA-ID}-{N}-{service-name}.md`，与 [dsd-template §3 表](assets/dsd-template.md) 同构；若该 Markdown 已由上游创建，可沿用 [asd-spec-template.md](../sdx-architect/assets/asd-spec-template.md)；**由本会话生成或扩写该路径下的实现级规约汇总稿时，正文骨架以 [spec-template.md](assets/spec-template.md) 为准**；路径段 `{service-name}` 与同库 `knowledge-links.yaml` 的 `service_name` 优先对齐，亦见 [asd-template §3 表](../sdx-architect/assets/asd-template.md)）为硬输入，**二者至少具备其一**，编写详细设计说明书 DSD。
  有 ASD 时：DSD **§1** 与 [asd-template §1](../sdx-architect/assets/asd-template.md) 对齐（可与 ASD §1 同源复制）；**§3 需求规约**继承 asd-template 与 **ASD §3** 表行并扩写。仅有需求规约 Markdown（`specs/spec-{IDEA-ID}-{N}-{service-name}.md`）时：§1/§3 以该文件 §1–4 与元数据 refs 为 SSOT，表结构仍遵循 dsd-template。详细设计正文从 §2 起编号（§2 详细设计、§3 需求规约、§4 附录），应用全量附带 **`{DOC_DIR}/specs/spec-{IDEA-ID}-{N}-{service-name}.md`**（[spec-template](assets/spec-template.md)）。
  不包含历史「单文档 ADD」：实现级契约以 **DSD** 与 **需求规约 Markdown（spec-template）** 为准。当用户需要 API/DDL、业务逻辑或未声明仅架构时务必使用本技能。
  本技能默认执行门禁：未完成「草稿用户总确认」前，禁止写入 {DOC_DIR}/requirements/**/DSD-*.md。
  若用户已明确要求只做 sdx-solution、sdx-analysis、sdx-prd、sdx-architect、sdx-test 的正文落盘，或执行 docs-distill/docs-extract/docs-archive/docs-indexing/docs-build，则不要以本技能为主路径，应分流到对应技能。
---

# 详细设计阶段（sdx-design）

本技能以「调度器」方式工作：先判定是否应由 `sdx-design` 处理，再按阶段读取规范文件，经会话 spec 与门禁后产出可校验的 **DSD** 与（应用全量时）**`{DOC_DIR}/specs/spec-{IDEA-ID}-{N}-{service-name}.md`**（骨架见 `assets/spec-template.md`）。

**不写 ASD**；上游 **至少其一**（**同 IDEA-ID / 同阶段 `{N}`** 可对齐）：

1. **`ASD-{IDEA-ID}-{N}.md`**（`/sdx-architect`），与/或  
2. **`{DOC_DIR}/specs/spec-{IDEA-ID}-{N}-{service-name}.md`**（需求规约 Markdown；**非**本会话闸门稿 `docs/superpowers/specs/...-sdx-design.md`。**落盘/扩写时**章节结构见 [assets/spec-template.md](assets/spec-template.md)；若文件已由 /sdx-architect 按 [asd-spec-template](../sdx-architect/assets/asd-spec-template.md) 创建，可在详设阶段按 `spec-template` 补齐或对齐实现级章节）

产出 **`DSD-{IDEA-ID}-{N}.md`**。**有 ASD 时** §3 须在 **ASD §3** 已有行上扩写，冲突以已确认 **ASD + PRD** 溯源为准。**仅有 architect spec 时** §3 以该文件 FR/UC（及 §5 可验收点）为表行基础，并标注 SSOT；与 PRD 冲突时须先收口上游。

**上游**：**`sdx-architect`（ASD 与/或 architect spec）**、`sdx-prd`、`sdx-analysis`。**下游**：`sdx-test`。

主要读者：**骨干开发、测试设计**。

---

## 适用边界

- **本技能负责**：DSD（§1–§4）、会话 spec（`...-sdx-design.md`）、Gd1–Gd4 与 Qclose-1、应用全量 **`{DOC_DIR}/specs/spec-{IDEA-ID}-{N}-{service-name}.md`** 规约汇总稿落盘与追溯。
- **本技能不负责**：`SOLUTION-*`、`ANALYSIS-*`、`PRD-*`、`ASD-*`、`TDD-*` 的「替代性」主产物；纯文档工程 **docs-*** 主流程。
- **边界分流**：用户只要共识方案、需求分析、PRD、ASD 或测试设计正文时，转对应 `sdx-*`；只要蒸馏/抽取/归档/索引时，转 **docs-***。

---

## 输入与前置检查

执行前最少确认：

- **IDEA-ID**、**上游至少其一的路径**（`ASD-*.md` 与/或 `{DOC_DIR}/specs/spec-{IDEA-ID}-{N}-{service-name}.md`）、与同包 **PRD** 一致（若已存在）。
- **`KNOWLEDGE_TYPE`**（见 `references/knowledge-type-modes.md` 索引链）。
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
9. **模板与骨架**：阶段二用 `assets/design-session-spec-template.md`；阶段三用 `assets/dsd-template.md`；**`./specs/spec-{IDEA-ID}-{N}-{service-name}.md` 规约汇总稿**用 `assets/spec-template.md`；上游 architect 初稿可参照 [../sdx-architect/assets/asd-spec-template.md](../sdx-architect/assets/asd-spec-template.md)

---

## 门禁要求（必须执行）

- 总确认前，禁止写 `{DOC_DIR}/requirements/**/DSD-*.md`；合法例外与标记见 `references/gates.md`。
- 建议在会话 spec 使用 `PENDING` / `CONFIRMED` 语义（HTML 注释形态见 `gates.md`）。

---

## 产出与校验

- **会话 spec**：`docs/superpowers/specs/YYYY-MM-DD-<topic>-sdx-design.md`（骨架见 `assets/design-session-spec-template.md`）。
- **正式产物**：`{DOC_DIR}/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/DSD-{IDEA-ID}-{N}.md`（结构见 `assets/dsd-template.md`）；应用全量时 **`{DOC_DIR}/specs/spec-{IDEA-ID}-{N}-{service-name}.md`**（见 `assets/spec-template.md`）与 DSD 同期。
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
| architect spec §1–6（上游可选用） | [../sdx-architect/assets/asd-spec-template.md](../sdx-architect/assets/asd-spec-template.md) |
| 需求规约 Markdown 骨架（`specs/spec-{IDEA-ID}-{N}-{service-name}.md`） | [assets/spec-template.md](assets/spec-template.md) |
| DSD 模板（§1+§2–§4） | [assets/dsd-template.md](assets/dsd-template.md) |
| 双轨输入设计说明（人类） | [../../../docs/superpowers/specs/2026-05-06-sdx-design-dual-input-design.md](../../../docs/superpowers/specs/2026-05-06-sdx-design-dual-input-design.md) |
