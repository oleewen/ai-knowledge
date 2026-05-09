# 门禁

五阶段：[workflow.md](workflow.md)；节奏：[interaction-gate.md](interaction-gate.md)。

## 总则

阶段 3 **`CONFIRMED`**（或合法例外）前，禁止阶段 4：写 `system/architecture/` 受管 overview 内容、追加 `DISTILL-LOG`。  
阶段 1–3 可读、算范围、`--dry-run`（dry-run **不落**上述两处）。

**合法例外**（须在对话留痕）：① 同会话**明示**跳过/仅预览/授权直写；② `DOCS_DISTILL_ALLOW_WRITE=1`（人工知情）。

## Spec

- 路径：`docs/superpowers/specs/YYYY-MM-DD-<topic>-docs-distill.md`
- 文末 `<!-- docs-distill-gate: PENDING -->` → 确认后 `CONFIRMED`
- 正文须含目标 **`{APPNAME}-overview.md` basename**，并写明：`--app`/`--full`/`--since`、是否 `--dry-run`、新建或更新概述

进度表锚点与 `sdx-*` 同构时指向**本会话**小节（例：[sdx-solution 会话模板](../../sdx-solution/assets/solution-session-spec-template.md)）。

## HARD-GATE（须先 preview 或总确认）

| 条件 | 动作 |
| ---- | ----- |
| `--full` | 警告；默认先 `dry-run`；确认后写 | [gotchas.md](../gotchas.md) |
| 锚点 `changelog_id` 在应用 CHANGE-LOG **找不到** | 勿静默全量 → 让用户修锚/`--since`/授权全量 | gotchas |
| **首次**建 `{APPNAME}-overview.md` | 先 `dry-run` 看结构 → 确认后建 | |
| 应用侧与系统侧冲突且规则无法消解 | 不硬盖 → 待定或仅更无争议块 | gotchas |
| 多应用且未 `--app` | 列候选与各锚点 → 建议分 `--app` preview | gotchas |
| **4.3 失败** | **禁止** 4.4 | [workflow.md](workflow.md) |

未列入但 gotchas 要求「警告+确认」的，**视同** HARD-GATE 精神。

## 钩子

[hooks.json](../../../hooks.json)：preToolUse → `sdx_gate_common.py --gate distill`。未启用仍以本文 + [SKILL.md](../SKILL.md) 为准。详 [hooks/README.md](../../../hooks/README.md)。
