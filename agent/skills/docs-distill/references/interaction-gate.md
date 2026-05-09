# 交互闸门

硬规则与条件表：[gates.md](gates.md)；阶段：[workflow.md](workflow.md)。

## 与 sdx-*-gate 对齐

| 概念 | 做法 |
| ---- | ----- |
| 中间会话 spec | `docs/superpowers/specs/…-docs-distill.md` |
| 总确认 | `PENDING` → `CONFIRMED`（[gates.md](gates.md)） |
| 例外 | 同会话明示 或 `DOCS_DISTILL_ALLOW_WRITE=1` |
| 预览 | HARD-GATE 场景优先 **`--dry-run`** |

## 推荐节奏

1. 探索：读应用 `CHANGE-LOG.md`、`ARCHIVE-LOG.md`（参见 [distill-log-spec.md](distill-log-spec.md)、[gotchas.md](../gotchas.md)）。  
2. 触发 HARD-GATE → 先 `--dry-run`，展示区间、受影响路径、拟写 DISTILL。  
3. **一次一问**（选择题为佳）；长链见 [brainstorming-integration.md](brainstorming-integration.md)。  
4. **`CONFIRMED`** 后再阶段 4；失败按 gotchas，**前移锚点前**须成功写 overview。

## 钩子

[hooks.json](../../../hooks.json) → `--gate distill`；与会话 **`CONFIRMED`** + basename 对齐。钩子未命中仍遵守 [gates.md](gates.md)。
