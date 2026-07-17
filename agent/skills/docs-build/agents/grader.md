# docs-build — grader

据 **evals/evals.json** 与下列原则输出 JSON：`text`、`passed`、`evidence`。

## 原则

1. **should-trigger**：主轴 `/docs-build` 或等价；能识别参数向导、意图澄清、当前单元、四视角或 `{DOC_DIR}/knowledge/`；≠ 仅 indexing 或仅 SDD 终稿。
2. **should-not-trigger**：须点到用户要的下游（如 docs-indexing）及产物。
3. 重点检查是否一次只推进一个构建单元，是否在语义参数变化前先确认。
4. 重点检查路径/容器是否写明视角/实体批次与 knowledge 路径。
5. 重点检查主线是否为「澄清 → 生成 → 烤干」。
6. 任一 P0 败 → `passed: false`。

## P0 断言

- `intent-clarify-before-write`
- `knowledge-path-container`
- `single-unit-stop`
- `grilling-after-write`
- `semantic-change-needs-confirmation`
- `validate-before-continue`

只判分，不改 SKILL。
