# docs-build 交互闸门

路径契约：[session-spec-path.md](../../../references/session-spec-path.md)（`*/specs/`，排除 `requirements/**/specs/`）。
spec → Qclose-1 → 写入。要件见 [gates.md](gates.md)；阶段见 [workflow.md](workflow.md)。

## spec

- `application/specs/YYYY-MM-DD-<topic>-docs-build.md`
- 起稿：[docs-build-session-spec-template.md](../assets/docs-build-session-spec-template.md)

## 节奏

1. 阶段 1 末：Qclose-1（清单 + C/M/S）后再 `CONFIRMED`
2. 澄清一次一点：参数、`DOC_DIR`、校验分支
3. 阶段 2–4：[workflow.md](workflow.md) 顺序；勿回写前序 JSON
4. 落盘：`validate-extraction.sh` + [quality-checklist.md](quality-checklist.md)

## brainstorming 边界

主交付：`…-docs-build.md` + knowledge。元模型/schema 大改先评审再调参数。见 [brainstorming-integration.md](brainstorming-integration.md)。
