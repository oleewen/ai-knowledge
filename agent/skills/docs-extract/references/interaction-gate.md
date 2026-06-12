# docs-extract 交互与确认

路径契约：[session-spec-path.md](../../../references/session-spec-path.md)（`{DOC_DIR}/superpowers/specs/`，排除 `requirements/**/specs/`）。
与 docs-distill 同构：**中间会话 spec → 用户总确认 → 落盘**。差异：extract **无** `DISTILL-LOG`；按次扫 `--sources` **≠** `docs-distill --full`。

硬规则与表见 [gates.md](gates.md)；阶段见 [workflow.md](workflow.md)。

## 与 distill 对齐

| 概念 | 做法 |
|------|------|
| 会话 spec | `{DOC_DIR}/superpowers/specs/…-docs-extract.md` |
| 总确认 | `PENDING` → `CONFIRMED`（gates） |
| 例外 | 同会话明示 |
| 预览 | HARD-GATE 场景**先** `--dry-run` |

## 推荐节奏

1. 读关键词附录；枚举 `--sources`；对照 extract-spec / gotchas。
2. 触发 HARD-GATE → 先 `dry-run`，展示命中与 A/U/D。
3. **单次一个**待确认点；多方案见 [brainstorming-integration.md](brainstorming-integration.md)。
4. `CONFIRMED` 后执行阶段 4；失败整体回滚。

## 钩子

[hooks.json](../../../hooks.json) 已注册 `--gate extract`。证据与 spec `docs-extract-gate: CONFIRMED`、目标 overview basename 对齐；见 [hooks/README.md](../../../hooks/README.md)。
