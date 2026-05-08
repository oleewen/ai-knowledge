---
name: sdx-design
description: >
  详细设计技能：产出 DSD（§1–§4，assets/dsd-template.md）及应用全量时 `{DOC_DIR}/specs/spec-{IDEA-ID}-{N}-{service-name}.md`（assets/dsd-spec-template.md）。
  触发：编写或修改 DSD；将 ASD §3 或需求表扩写到实现级（API、DDL、错误码、幂等）；详设门禁（Gd、Qclose、validate-dsd）；具备 ASD/architect spec 与 PRD 且目标是 DSD 终稿。
  上游至少其一（同 IDEA-ID、同 N）：`ASD-*.md` 或 `{DOC_DIR}/specs/spec-{IDEA-ID}-{N}-{service-name}.md`；与会话门禁稿 `docs/superpowers/specs/*-sdx-design.md` 不同路径。不写 ASD。
  门禁：未完成「草稿用户总确认」前禁止写入 `{DOC_DIR}/requirements/**/DSD-*.md`（例外见 references/gates.md）。
  分流：以 docs-distill / docs-extract / docs-archive / docs-indexing / docs-build 为主，或仅需 SOLUTION/ANALYSIS/PRD/ASD/TDD，或仅限 sdx-architect、PRD、测试时。
compatibility: 本仓库 Bash 5+，仓库根下 `scripts/config-bootstrap.sh` 可解析 `DOC_ROOT`；详设钩子见 `agent/hooks/sdx_gate_common.py --gate design`（路径均相对仓库根）。
---

# 详细设计阶段（sdx-design）

调度式工作：**先判断是否由本技能主责**，按需读 `references/`，维护会话 spec → 门禁 `CONFIRMED` → 落盘 **DSD**；应用全量时 **`{DOC_DIR}/specs/spec-{IDEA-ID}-{N}-{service-name}.md`** 与 DSD 同期（骨架 `assets/dsd-spec-template.md`）。

**不写 ASD**。上游至少其一（**同 IDEA-ID、同 `{N}`**）：`ASD-{IDEA-ID}-{N}.md`（`/sdx-architect`）或 `{DOC_DIR}/specs/spec-{IDEA-ID}-{N}-{service-name}.md`（需求规约 Markdown；章节见 [assets/dsd-spec-template.md](assets/dsd-spec-template.md)；若已由 `/sdx-architect` 按 [asd-spec-template](../sdx-architect/assets/asd-spec-template.md) 建稿，详设阶段补齐实现级章节）。

**路径区分**：`docs/superpowers/specs/*-sdx-design.md` 仅为会话闸门稿；**规约汇总稿**在 `{DOC_DIR}/specs/`，勿混写。

产出 **`DSD-{IDEA-ID}-{N}.md`**（[assets/dsd-template.md](assets/dsd-template.md)）。**有 ASD** 时 §3 在 ASD §3 已有行上扩写，冲突以已确认 **ASD + PRD** 为准。**仅有 architect spec** 时以 FR/UC 与 §5 可验收点为表行基础并标 SSOT；与 PRD 冲突须先收口上游。

**链路**：`sdx-architect`、`sdx-prd`、`sdx-analysis` → `sdx-test`。**读者**：骨干开发、测试设计。

---

## 技能包结构

| 层级 | 路径 | 说明 |
|------|------|------|
| 本文 | `SKILL.md` | 调度入口 |
| 参考 | `references/` | [references/README.md](references/README.md) |
| 模板 | `assets/` | DSD、会话 spec、规约骨架 |
| 脚本 | `scripts/` | `validate-dsd.sh` |
| 评测 | `evals/`、[schemas.md](references/schemas.md) | 样本、断言、grading |
| 子代理 | `agents/` | `grader.md`、`analyzer.md` |
| 陷阱 | `gotchas.md` | 执行易错 |

## 最短工作路径

1. 确认 **IDEA-ID**、上游（`ASD-*` 或 `{DOC_DIR}/specs/spec-{IDEA-ID}-{N}-{service-name}.md`）、**PRD**、`KNOWLEDGE_TYPE`、`--depth`
2. 读 [references/gates.md](references/gates.md) → [references/workflow.md](references/workflow.md)
3. 用 [design-session-spec-template.md](assets/design-session-spec-template.md) 维护会话 spec，逐 Gd1–Gd4，Qclose-1 后 `CONFIRMED`
4. 写 **DSD**（[dsd-template.md](assets/dsd-template.md)）；应用全量时写规约汇总稿（[dsd-spec-template.md](assets/dsd-spec-template.md)）
5. 落盘后校验（**当前工作目录为仓库根**）：`agent/skills/sdx-design/scripts/validate-dsd.sh`（可选 `--gate-check`）；或在 `agent/skills/sdx-design/` 下执行 `./scripts/validate-dsd.sh`

---

## 适用边界

### 何时使用

- 编写或修改 **DSD**，或把 **ASD §3** / 需求表扩写到实现级。
- 落盘 **`{DOC_DIR}/specs/spec-*.md`**（与 DSD 互指；应用全量与 DSD 同期）。
- 用户提及 **详设、Gd、Qclose、validate-dsd、未确认不写 DSD**，或同时具备 **ASD/spec 上游 + PRD** 且要 **DSD 终稿**。

### 何时不用（分流）

- 主目标是 **docs-distill / docs-extract / docs-archive / docs-indexing / docs-build** → 对应 **docs-***。
- 主产出是 **SOLUTION / ANALYSIS / PRD / ASD / TDD**、不要 DSD → 对应 **sdx-***。
- 指令已限定 **仅 sdx-architect、仅 PRD、仅测试** → 不以本技能为主路径。

### 职责

- **负责**：DSD（§1–§4）、`...-sdx-design.md` 会话流程（Gd/Qclose）、应用全量规约汇总稿与追溯。
- **不负责**：以 **ASD/PRD/TDD…** 等替代详设作主产物；纯 **docs-*** 文档工程主线。

---

## 前置检查（执行前）

- **IDEA-ID**；上游 **`ASD-*` 与/或 `{DOC_DIR}/specs/spec-*.md`**；与 **PRD** 可追溯一致（若 PRD 已存在）。
- **`KNOWLEDGE_TYPE`**（[references/knowledge-type-modes.md](references/knowledge-type-modes.md)）。
- **`--depth`** 与 workflow 详设粒度一致；知晓 **`{DOC_DIR}`**、`docs/superpowers/specs/` 写入位置。

指令已明确只做上游或文档工程主线时，不强行套全流程。

---

## 知识与库类型

详见 [references/knowledge-type-modes.md](references/knowledge-type-modes.md)（链至 `sdx-architect` 权威说明）。

---

## 执行路由（先读后写）

0. 可选：[references/README.md](references/README.md) 鸟瞰 `references/`。
1. **门禁**：`references/gates.md`
2. **流程**：`references/workflow.md`
3. **阶段二 / 多方案**：`references/brainstorming-integration.md`
4. **原则**：`references/design-principles.md`
5. **反模式**：`references/anti-patterns.md`
6. **执行陷阱**：`gotchas.md`
7. **语气**：`references/audience-and-language.md`
8. **终检**：`references/quality-checklist.md`
9. **模板**：会话 `assets/design-session-spec-template.md`；DSD `assets/dsd-template.md`；规约 **`{DOC_DIR}/specs/...`** 用 `assets/dsd-spec-template.md`；architect 稿对齐 [asd-spec-template](../sdx-architect/assets/asd-spec-template.md)。

---

## 门禁

- **总确认前**禁止 `{DOC_DIR}/requirements/**/DSD-*.md`；例外与 HTML 注释形态见 `references/gates.md`。

---

## 产出与校验

- **会话 spec**：`docs/superpowers/specs/YYYY-MM-DD-<topic>-sdx-design.md`（骨架 `assets/design-session-spec-template.md`）。
- **DSD**：`{DOC_DIR}/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/DSD-{IDEA-ID}-{N}.md`（`assets/dsd-template.md`）。
- **规约汇总稿**（应用全量、`assets/dsd-spec-template.md`）：`{DOC_DIR}/specs/spec-{IDEA-ID}-{N}-{service-name}.md`，与 DSD 同期。

落盘校验（**在仓库根执行**；`path/to/` 相对于仓库根或与脚本解析后的 `{DOC_ROOT}` 一致时可按需调整）：

```bash
agent/skills/sdx-design/scripts/validate-dsd.sh
agent/skills/sdx-design/scripts/validate-dsd.sh --file path/to/DSD-xxx.md --gate-check
```

---

## 评测与迭代

契约 [references/schemas.md](references/schemas.md)；样本 `evals/evals.json`；元数据 `evals/eval-metadata-template.json`；评分 `agents/grader.md`；复盘 `agents/analyzer.md`。跑分流水线见 skill-creator；断言与 grader 输出须与 schemas 一致。

---

## 工程化支持

Hooks 启用时，在**仓库根**执行：`python3 agent/hooks/sdx_gate_common.py --gate design`（登记于 `agent/hooks.json`，拦截 **`DSD-*`** 写入）。

---

## 跨技能链接

上游 **ASD 结构**与 **architect spec**：[asd-template.md](../sdx-architect/assets/asd-template.md) · [asd-spec-template.md](../sdx-architect/assets/asd-spec-template.md)。  
本包 `references/` 索引、`assets/` 模板、`evals/` 与 [schemas.md](references/schemas.md) 见上文「执行路由」「技能包结构」「评测与迭代」。
