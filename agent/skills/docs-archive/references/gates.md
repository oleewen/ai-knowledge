# docs-archive 门禁

操作层易错：[gotchas.md](../gotchas.md)。路径与链接：[links-and-index.md](links-and-index.md)。

## 仓库级闸门

写入落在 [AGENTS.md](../../../../AGENTS.md) 所述**文档产出闸门**（如 `{DOC_DIR}` 受管终稿、`system/architecture/`、`company/ea/`）时，须对照 [CONVENTIONS.md](../../../rules/CONVENTIONS.md) 第三节与相关 `sdx-*` / `docs-distill`，**不绕过总确认**。

## HARD-GATE（本技能）

用户确认**方案确认书**（[../assets/archive-template.md](../assets/archive-template.md)）前，**禁止写任何目标文档**。

| 行为 | 是否允许 |
| ---- | --------- |
| 改目标、在目标目录新增/覆盖终稿 | **否**（确认前） |
| 读 overview、目标章、列目录、方案对比、预览稿 | **是** |

**标记**：spec 中 `<!-- docs-archive-gate: PENDING -->` → 确认后 `CONFIRMED`；正文须含目标文件 **basename**（钩子证据）。  
无环境变量 bypass；用户同会话**明示**跳过仍须一句方案+风险并取得**明确同意**。  
进度表锚点与 `sdx-*` 同构时，两列指**本会话稿内**小节（例：[sdx-solution 会话模板](../../sdx-solution/assets/solution-session-spec-template.md)「门禁进度」）。

## 钩子

`agent/hooks.json` → `preToolUse`（Write/StrReplace）→ [sdx_gate_common.py](../../hooks/sdx_gate_common.py) `--gate archive`。  
**证据**：符合 `{DOC_DIR}/superpowers/specs/`（见 [session-spec-path.md](../../../references/session-spec-path.md)）的 spec 中含 `docs-archive-gate: CONFIRMED` 且出现目标 basename。

**范围说明**（见 [knowledge-layout.md](../../../references/knowledge-layout.md)）：hook **仅拦截** `*/overview/*.md` 回写；视角章节（`system/architecture/{视角}/`、`company/ea/{视角}/`）落盘由本会话**方案确认书** HARD-GATE 约束，不经 overview collector。

## 与 workflow

| 阶段 | 含义 |
| ---- | ---- |
| 步骤 3 未获肯定 | 不得步骤 4（落目标 + 回写 overview） |
| dry-run | 属步骤 3；可 PENDING 下预览，**不写终稿** |

详 [workflow.md](workflow.md)。
