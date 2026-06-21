# docs-build — grader

据 **evals/evals.json** 与下列原则输出 JSON：`text`、`passed`、`evidence`。

## 原则

1. **should-trigger**：主轴 `/docs-build` 或等价；含 Qclose-1、`docs-build-gate`、例外、四视角或 `{DOC_DIR}/knowledge/`；≠ 仅 indexing 或仅 SDD 终稿。
2. **should-not-trigger**：须点到用户要的下游（如 docs-indexing）及产物。
3. 勿称 docs-build「无 spec/无 hook」（违 CONVENTIONS），除非 prompt 谈关钩等例外。
4. 任一 P0 败 → `passed: false`。

只判分，不改 SKILL。
