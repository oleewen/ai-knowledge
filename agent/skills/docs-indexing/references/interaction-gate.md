# docs-indexing 交互闸门

路径契约：[session-spec-path.md](../../../references/session-spec-path.md)（本技能闸门 spec 在 `{DOC_DIR}/superpowers/specs/`，排除 `requirements/**/specs/`）。
spec → Qclose-1 → `CONFIRMED` → 写受管路径。[gates.md](gates.md)；[workflow.md](workflow.md)。

## spec

- `{DOC_DIR}/superpowers/specs/YYYY-MM-DD-<topic>-docs-indexing.md`
- [docs-indexing-session-spec-template.md](../assets/docs-indexing-session-spec-template.md)

## 节奏

1. 步骤 1–2：参数 **Qclose-1**（C/M/S）；摘要进 spec  
2. 写入前：**路径清单**（根相对）；`PENDING` → 用户再确认 → `CONFIRMED`  
3. 步骤 3–6：只对清单写 INDEX；先 INDEX、后 LOG（[indexing-log-spec.md](indexing-log-spec.md)）

## brainstorming 边界

主交付：`…-docs-indexing.md` + INDEX。九章元模型或全域策略大变先评审。见 [brainstorming-integration.md](brainstorming-integration.md)。
