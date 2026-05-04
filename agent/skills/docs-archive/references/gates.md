# docs-archive 门禁

与 [links-and-index.md](links-and-index.md)（索引与链接）互补；**操作层易错点**见上级 [gotchas.md](../gotchas.md)。

---

## 文档产出闸门（仓库级）

若写入路径落在仓库 [AGENTS.md](../../../../AGENTS.md) 所述**文档产出闸门**（如 `{DOC_DIR}` 下受管终稿、`system/architecture/` 等），须先核对 [agent/rules/CONVENTIONS.md](../../../rules/CONVENTIONS.md) 第三节与相关 `sdx-*`、`docs-distill` 规则，**不得绕过既有总确认流程**。

---

## HARD-GATE（本技能）

在用户明确确认**方案确认书**（模板见 [../assets/archive-template.md](../assets/archive-template.md)）之前，**禁止写入任何目标文档**。防止未经评审的批量改写；overview 常跨多视角，错误落盘难回滚。

| 行为 | 是否允许 |
|------|----------|
| 修改目标文档、在目标目录新增/覆盖终稿 | **禁止**（确认前） |
| 读取 overview 与链接目标章节、列目录、输出方案对比、临时区对比稿 | **允许** |

**门禁标记**：会话 spec 中使用 `<!-- docs-archive-gate: PENDING -->`；用户明确确认方案确认书后改为 `<!-- docs-archive-gate: CONFIRMED -->`，且正文须出现目标文件名（**basename**）。

- 本 gate **无 bypass 环境变量**，须完整走确认流程；唯一例外是用户在同一对话中**明示**跳过。
- 若用户坚持「直接改」，仍须一句话概括方案与风险，取得**明确同意**后再落盘。

**门禁进度表锚点（与 sdx-* 对齐）**：若 `docs/superpowers/specs/` 会话草稿中出现与 `sdx-*` 会话 spec 同构的进度表，两列均应使用指向**本会话稿内**小节锚点。示例见 [sdx-solution 会话模板](../../sdx-solution/assets/solution-session-spec-template.md)「门禁进度」。

---

## 钩子与证据

仓库 [agent/hooks.json](../../hooks.json) 注册 `preToolUse`（`Write` / `StrReplace`），脚本 [agent/hooks/sdx_gate_common.py](../../hooks/sdx_gate_common.py)：`python3 agent/hooks/sdx_gate_common.py --gate archive`。需启用 Hooks 方可能拦截。

**证据**：`docs/superpowers/specs/` 下存在包含 `<!-- docs-archive-gate: CONFIRMED -->` 且引用目标文件名的 spec；未通过则拒绝写入。

---

## 阶段对应（与 workflow 对齐）

| 阶段 | 门禁含义 |
|------|----------|
| 步骤 3 结束且用户肯定前 | 不得执行步骤 4（落盘目标与回写 overview） |
| dry-run | 属步骤 3，不单独占阶段；可在 PENDING 下产出预览，不得写终稿 |

详见 [workflow.md](workflow.md)。
