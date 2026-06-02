---
name: sdx-design
description: >
  产出 **DSD（详细设计说明书，§1–§3，`assets/dsd-template.md`）**：唯一正式详设交付。
  用于编写/修改 DSD、把 ASD §3 或 **spec-asd-*.md** 扩写到实现级（API、DDL、错误码、幂等）、门禁 G/Qclose/validate-dsd；上游须有 **ASD-* 或 spec-asd-***（同 IDEA-ID、`{N}`）与 PRD 可对齐。**不写 ASD**。
  主路径为 docs-distill/extract/archive/indexing/build、仅需 SOLUTION/ANALYSIS/PRD/ASD/TDD，或明示仅 architect/PRD/测试 → 对应技能；非本技能主责。
  门禁：未完成「草稿用户总确认」不得写 `{DOC_DIR}/requirements/**/DSD-*.md`（例外见 references/gates.md）。
compatibility: Bash 5+；`scripts/config-bootstrap.sh` 解析 `DOC_ROOT`；钩子 `agent/hooks/sdx_gate_common.py --gate design`。
---

# 详细设计（sdx-design）

判定主责 → 读 `references/` → 会话 **`...-sdx-design.md`** → **CONFIRMED** → 落盘 **DSD**。**不写 ASD**。

**上游**（同 IDEA-ID、`{N}`）：`ASD-*`（`/sdx-architect`）与/或 **`{DOC_DIR}/specs/spec-asd-*.md`**（[asd-spec-template](../sdx-architect/assets/asd-spec-template.md)）。详设正文以 **DSD** 为唯一载体。**会话闸门稿**：`{DOC_DIR}/superpower/specs/*-sdx-design.md`；勿与 **`spec-asd`**（`{DOC_DIR}/specs/`）路径混淆。

有 **ASD**：DSD §1 与 ASD §1 对齐；**§2** 在 ASD §3 与服务边界基础上扩写到实现级；冲突以已确认 **ASD + PRD** 为准。**仅有 architect spec**：以 FR/UC 等与 spec §5 为范围基础并标 SSOT；与 PRD 冲突先收口上游。

**链路**：`sdx-architect` · `sdx-prd` · `sdx-analysis` → **本技能** → `sdx-test`。读者：研发骨干、测试设计。

---

## 技能包

| 路径 | 说明 |
|------|------|
| `references/` | [references/README.md](references/README.md) |
| `assets/` | DSD 模板、会话门禁模板 |
| `scripts/` | `validate-dsd.sh` |
| `evals/` + [schemas.md](references/schemas.md) | 评测契约与样本 |
| `agents/` | `grader.md`、`analyzer.md` |
| `gotchas.md` | 执行易错 |

---

## 路由


| 主路径 | 技能 |
|--------|------|
| 会话 spec 路径 | [session-spec-path.md](../../references/session-spec-path.md) |
| docs-distill / extract / archive / indexing / build | **docs-*** |
| 只要 SOLUTION / ANALYSIS / PRD / ASD / TDD，不要 DSD | 对应 **sdx-*** |
| 明示仅 `/sdx-architect` / PRD / 测试 | 不以本技能为主 |
| **DSD**、Gd、Qclose、validate-dsd | **本技能** |

**负责**：DSD §1–§3、会话 G/Qclose、§2 内实现级契约与追溯表达。  
**不负责**：用 ASD/PRD/TDD 顶替详设主产物；纯 docs-* 主线。

---

## 最短路径

1. **IDEA-ID**、上游（`ASD-*` 与/或 **`spec-asd-*`**）、**PRD**、`KNOWLEDGE_TYPE`、`--depth`。  
2. [gates.md](references/gates.md) → [workflow.md](references/workflow.md)。  
3. [design-session-spec-template.md](assets/design-session-spec-template.md)：G1–G3 → Qclose-1 → `CONFIRMED`。  
4. 写 **DSD**（[dsd-template.md](assets/dsd-template.md)）。  
5. 仓库根：`agent/skills/sdx-design/scripts/validate-dsd.sh`（可选 `--gate-check`）；或在 `agent/skills/sdx-design/` 下 `./scripts/validate-dsd.sh`。

---

## 前置

**PRD**（硬）；**ASD 与/或 spec-asd**（缺一则须澄清或用户明示例外）；`KNOWLEDGE_TYPE`、`{DOC_DIR}`、`{DOC_DIR}/superpower/specs/` 位置。指令只要上游或 docs 主线时不要强行套全流程。

**KNOWLEDGE_TYPE**： [references/knowledge-type-modes.md](references/knowledge-type-modes.md)（正文权威在 `sdx-architect`）。

---

## 执行路由（先读后写）

0. 可选：[references/README.md](references/README.md)。  
1. [gates.md](references/gates.md)  
2. [workflow.md](references/workflow.md)  
3. [brainstorming-integration.md](references/brainstorming-integration.md)  
4. [design-principles.md](references/design-principles.md)  
5. [anti-patterns.md](references/anti-patterns.md)  
6. [gotchas.md](gotchas.md)  
7. [audience-and-language.md](references/audience-and-language.md)  
8. [quality-checklist.md](references/quality-checklist.md)  
9. 模板：会话 `assets/design-session-spec-template.md`；DSD `assets/dsd-template.md`；**spec-asd** 对齐 [asd-spec-template](../sdx-architect/assets/asd-spec-template.md)。

---

## 门禁

总确认前禁止 **`{DOC_DIR}/requirements/**/DSD-*.md`**；HTML 注释与例外见 [gates.md](references/gates.md)。

---

## 产出与校验

- **会话 spec**：`{DOC_DIR}/superpower/specs/YYYY-MM-DD-<topic>-sdx-design.md`  
- **DSD**：`{DOC_DIR}/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/DSD-{IDEA-ID}-{N}.md`  

```bash
agent/skills/sdx-design/scripts/validate-dsd.sh
agent/skills/sdx-design/scripts/validate-dsd.sh --file path/to/DSD-xxx.md --gate-check
```

---

## 评测与工程化

[schemas.md](references/schemas.md)、`evals/evals.json`、`evals/eval-metadata-template.json`、`agents/grader.md`、`agents/analyzer.md`。钩子（仓库根）：`python3 agent/hooks/sdx_gate_common.py --gate design`。

**ASD 模板**：[asd-template.md](../sdx-architect/assets/asd-template.md) · [asd-spec-template.md](../sdx-architect/assets/asd-spec-template.md)