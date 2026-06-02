# 与 brainstorming / SDD

## 会话 spec 路径

闸门中间稿须落在 **`{DOC_DIR}/superpower/specs/`**（不含 `requirements/**/specs/`）。契约：[session-spec-path.md](../../../references/session-spec-path.md)。

本技能为低风险，无落盘 spec 闸门；若自写中间确认稿，仍须符合 `{DOC_DIR}/superpower/specs/`。

docs-pull 预检是 **高风险参数与写盘事实确认**，≠ `/brainstorming` 设计链，也 ≠ `sdx-solution` 的 G 系列门禁。

## 何时离开本技能

- 重组 `applications/`、多远端合并、联邦契约变更 → **先**方案/ADR。  
- 写 `system/architecture/overview/` 第三列 → **docs-extract** / **docs-distill**。  
- `SOLUTION-*`、`ASD-*`… → **sdx-***。

可借「单次一确认」「先 dry-run」等形式；但**不要求** `*-design.md` 等为门槛。[gates.md](gates.md)。
