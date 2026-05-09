# docs-extract 门禁

五阶段与参数见 [workflow.md](workflow.md)；交互见 [interaction-gate.md](interaction-gate.md)。

## 核心

- **未总确认 → 禁止阶段 4 落盘**（目标 overview 第三列）。阶段 1–3 允许路径校验、读附录、筛选、**`--dry-run`**（dry-run 不落盘第三列）。
- **例外**：同会话用户**明示**跳过闸门、仅预览、或授权直写。无环境变量 bypass（与 [agent/rules/CONVENTIONS.md](../../../rules/CONVENTIONS.md#artifact-gates) 一致）。

## Spec

- 路径：`docs/superpowers/specs/YYYY-MM-DD-<topic>-docs-extract.md`
- 文末：`<!-- docs-extract-gate: PENDING -->` → 确认后 `CONFIRMED`
- 正文须出现目标 `XX-overview.md` basename（与 `--overview` 一致）
- 至少含：`--sources` 列表、`--overview`、命中数与章节摘要、是否 `dry-run` 及结论
- 若含与 `sdx-*` 同构进度表，锚点指向**本会话稿**内小节（示例见 [sdx-solution 会话模板](../../sdx-solution/assets/solution-session-spec-template.md)「门禁进度」）

## HARD-GATE（须 dry-run 或总确认后再写）

| 条件 | 动作 |
|------|------|
| 首次实质写第三列（原全空/`—`） | 先 `--dry-run`；确认后写 |
| 命中异常多（如 >50） | 警告收窄关键词 |
| 源含敏感名（`.env`、`credentials` 等） | 警告并确认 |
| 第三列已有大量内容且本次大量 `[U]`（如 >10） | 先 `dry-run` |
| 4.3 写入失败 | **整体回滚**（见 workflow） |

gotchas 要求「须警告并确认」的情形，**同等**按 HARD-GATE 处理。

## 钩子

[hooks.json](../../../hooks.json) 注册 `sdx_gate_common.py --gate extract`（`Write` / `StrReplace`）。放行与会话 spec、`CONFIRMED`、目标文件名一致；见 [hooks/README.md](../../../hooks/README.md)。**规范真源**在本目录与 `SKILL.md`；钩子未启用时对话中同等遵守。
