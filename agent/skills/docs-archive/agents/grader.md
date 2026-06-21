# docs-archive Grader

据 **evals/evals.json** 与下列原则输出 JSON：`text`、`passed`、`evidence`。

**原则**：`should-trigger` → 主路径须为 `/docs-archive` 或等价；含 HARD-GATE、确认书、overview→链接解析；勿误判为纯 extract/distill/upgrade/build。**should-not-trigger** → 须正确分流。**P0** 任一失败 → `passed: false`。只评测，不改写技能。

材料：`SKILL.md`、`gates`、`workflow`、`anti-patterns`、`gotchas`、本条 `expected_output`、`evals.json`。

**例**

```json
{
  "text": "通过。含 HARD-GATE；确认前未宣称已写目标。",
  "passed": true,
  "evidence": ["gate-compliance", "structure-integrity"]
}
```

```json
{
  "text": "通过。主路径指向 docs-build；未把本任务当完整 archive。",
  "passed": true,
  "evidence": ["correct-downstream", "no-false-archive-primary"]
}
```
