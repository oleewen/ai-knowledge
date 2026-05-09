---
name: sdx-architect
description: >
  架构设计技能：基于 PRD/ANALYSIS 产出架构设计说明书 ASD（§1/§2/§3）；可选 **`{DOC_DIR}/specs/spec-asd-*.md`** **概设需求规约**（asd-spec-template）。
  触发：服务边界、架构图、服务变更表、系统级联邦概要（KNOWLEDGE_TYPE=system/company）；目标产物为 ASD 终稿或架构阶段会话。
  分流：实现级 API/DDL、**spec-dsd-*.md** **详设需求规约**全文、DSD → /sdx-design；仅 sdx-solution / sdx-analysis / sdx-prd / sdx-test 正文落盘，或仅 docs-distill / docs-extract / docs-archive / docs-indexing → 对应技能，不以本技能为主路径。
  门禁：未完成「用户总确认」前禁止写入 `{DOC_DIR}/requirements/**/ASD-*.md`（例外见 references/gates.md）。
compatibility: 本仓库 Bash 5+，仓库根下 `scripts/config-bootstrap.sh` 可解析 `DOC_ROOT`；校验与钩子命令见正文（路径均相对仓库根）。
---

# 架构设计阶段（sdx-architect）

调度式工作：**先判断是否由本技能主责**，按需读 `references/`，经会话草稿与用户总确认后产出可校验的 **ASD**。

---

## 适用边界

### 何时使用

- 需要 **ASD**（`§1/§2/§3`）、架构边界、服务变更、规约**摘要**行与门禁。
- 用户讨论 **服务边界、架构图、服务变更表、联邦概要**（`KNOWLEDGE_TYPE=system|company`）等，且主交付为架构阶段产物。

### 何时不以本技能为主路径

- 主目标是 **docs-distill / docs-extract / docs-archive / docs-indexing** → 用对应 **docs-*** 技能。
- 主产出是 **SOLUTION / ANALYSIS / PRD / TDD** 正文、**不要** ASD → 用对应 **sdx-*** 阶段技能。
- 诉求为实现级 **API/DDL、spec-dsd-*.md（详设需求规约）全文、DSD** → **[sdx-design](../sdx-design/SKILL.md)**。

### 职责摘要

- **负责**：ASD、架构边界、服务变更、规约摘要、（可选）**`{DOC_DIR}/specs/spec-asd-*.md`** **概设需求规约**（`assets/asd-spec-template.md`）、门禁与会话草稿（见 `assets/architect-session-spec-template.md`）。
- **不负责**：DSD、实现级契约、**spec-dsd-*.md**（**详设需求规约**）完整落盘（属详设阶段）。本技能可维护 **`spec-asd-*.md`**（`asd-spec-template.md`）**概设需求规约**。

---

## 输入与前置检查

执行前最少确认：

- `PRD`（必需）
- `ANALYSIS`（推荐）
- `.docsconfig` 的 `KNOWLEDGE_TYPE`（建议）

若输入不全，先补澄清，不直接进入正式 ASD 落盘。

---

## 执行路由（先读后写）

1. **门禁与例外**：先读 `references/gates.md`
2. **流程与阶段**：再读 `references/workflow.md`
3. **质量检查**：落盘前读 `references/quality-checklist.md`
4. **反模式规避**：遇到歧义时读 `references/anti-patterns.md`
5. **知识库类型与联邦分工**（`KNOWLEDGE_TYPE` / system|company）：读 `references/knowledge-type-modes.md`
6. **输出样式**：参考 `assets/asd-template.md` 与 `assets/samples/mini-asd-example.md`

---

## 门禁要求（必须执行）

- 总确认前，禁止写 `{DOC_DIR}/requirements/**/ASD-*.md`。
- 合法例外仅限：
  - 用户明确要求跳过
  - `SDX_ARCHITECT_ALLOW_ASD_WRITE=1`
- 会话草稿中的状态标记与 HTML 注释形态见 `references/gates.md`（与 `validate-asd.sh --gate-check` 一致）。

会话草稿模板：`assets/architect-session-spec-template.md`。

---

## 产出与校验

- 正式产物：`{DOC_DIR}/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/ASD-{IDEA-ID}-{N}.md`
- 模板：`assets/asd-template.md`；联邦补充：`assets/asd-stub-sections-federated.md`

落盘校验（**当前工作目录为仓库根**；`--file` 路径相对仓库根或与 `{DOC_ROOT}` 解析一致）：

```bash
agent/skills/sdx-architect/scripts/validate-asd.sh
agent/skills/sdx-architect/scripts/validate-asd.sh --file path/to/ASD-xxx.md --gate-check
```

或在 `agent/skills/sdx-architect/` 下执行：`./scripts/validate-asd.sh`（参数同上）。

---

## 评测与迭代（skill-creator 对齐）

- 评测样本：`evals/evals.json`（含 `expected_output` 与 `assertions`）
- 评测元模板：`evals/eval-metadata-template.json`
- 评分规则：`agents/grader.md`
- 失败分析：`agents/analyzer.md`

---

## 工程化支持

Hooks 启用时，在**仓库根**执行：`python3 agent/hooks/sdx_gate_common.py --gate architect`（登记于 `agent/hooks.json`）。

---

## 跨技能链接

详设 / 规约全文：**[sdx-design](../sdx-design/SKILL.md)**。
