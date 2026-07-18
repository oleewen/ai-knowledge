# docs-build — grader

据 **evals/evals.json** 与下列原则输出 JSON：`text`、`passed`、`evidence`。

## 原则

1. **should-trigger**（须全部满足；共通环见 [unit-cycle-protocol.md](../../../references/unit-cycle-protocol.md)、[intent-clarify.md](../../../references/intent-clarify.md)）：
   - 主轴 `/docs-build` 或等价
   - 参数向导 → 写前意图澄清 → 当前单元「澄清 → 生成 → 烤干」→ `C/M/G/S/F`
   - 能识别四视角或 `{DOC_DIR}/knowledge/`；≠ 仅 indexing 或仅 SDD 终稿
2. **should-not-trigger**：须点到用户要的下游（如 docs-indexing）及产物
3. 一次只推进一个构建单元；语义参数变化前须先确认
4. 路径/容器须写明视角/实体批次与 knowledge 路径
5. 任一 P0 败 → `passed: false`

## P0 断言

- `intent-clarify-before-write`
- `knowledge-path-container`
- `single-unit-stop`
- `grilling-after-write`
- `semantic-change-needs-confirmation`
- `validate-before-continue`

只判分，不改 SKILL。
