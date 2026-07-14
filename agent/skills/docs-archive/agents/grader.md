# docs-archive Grader

据 **evals/evals.json** 与下列原则输出 JSON：`text`、`passed`、`evidence`。

## 判定

- `should-trigger`：主路径须为 `/docs-archive` 或等价；能识别参数向导、当前确认书、overview -> 目标章节、自动 grilling 与 `C/M/G/S/F`
- `should-not-trigger`：须正确分流，不误判为纯 extract/distill/upgrade/build
- **P0** 任一失败 → `passed: false`

## P0 断言

- `single-unit-stop`：一次只处理一个目标章节或一个 overview 行块，并在收敛后停下等待动作
- `confirmation-book-first`：当前确认书未收口前，不得写目标章节或回写 overview
- `semantic-change-needs-confirmation`：来源范围、目标章节、冲突策略、来源清理策略等语义变更必须先确认
- `overview-link-preserved`：overview 回写后保留行内副标题链接，不得静默断链

只评测，不改写技能。

材料：`SKILL.md`、`gates`、`workflow`、`anti-patterns`、`gotchas`、本条 `expected_output`、`evals.json`。

**例**

```json
{
  "text": "通过。识别当前确认书与单个归档单元，停在动作选择前。",
  "passed": true,
  "evidence": ["confirmation-book-first", "single-unit-stop", "structure-integrity"]
}
```

```json
{
  "text": "通过。主路径指向 docs-build；未把本任务当完整 archive。",
  "passed": true,
  "evidence": ["correct-downstream", "no-false-archive-primary"]
}
```
