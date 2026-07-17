# docs-archive Grader

据 **evals/evals.json** 与下列原则输出 JSON：`text`、`passed`、`evidence`。

## 判定

- `should-trigger`：主路径须为 `/docs-archive` 或等价；能识别参数向导、确认书（= 意图澄清）、当前单元「澄清→落盘→烤干」与 `C/M/G/S/F`
- `should-not-trigger`：须正确分流，不误判为纯 extract/distill/upgrade/build
- **P0** 任一失败 → `passed: false`

## P0 断言

- `intent-clarify-via-confirmation-book`：确认书 = 写前意图澄清门禁；未获写前 `C` 不得落盘
- `unit-cycle`：主线含澄清→落盘→烤干；一次只处理一个当前单元
- `grilling-loop`：各当前单元默认必须烤干；落盘后须自动 grilling 至收敛
- `single-unit-stop`：烤干收敛后停下等待动作，不得自动推进下一单元
- `semantic-change-needs-confirmation`：来源范围、目标章节、冲突策略、来源清理策略等语义变更必须先确认
- `overview-link-preserved`：overview 回写后保留行内副标题链接，不得静默断链

只评测，不改写技能。

材料：`SKILL.md`、`gates`、`workflow`、`anti-patterns`、`gotchas`、本条 `expected_output`、`evals.json`。

**例**

```json
{
  "text": "通过。确认书即意图澄清，单单元落盘→烤干，停在动作选择前。",
  "passed": true,
  "evidence": ["intent-clarify-via-confirmation-book", "unit-cycle", "grilling-loop", "single-unit-stop"]
}
```

```json
{
  "text": "通过。主路径指向 docs-build；未把本任务当完整 archive。",
  "passed": true,
  "evidence": ["correct-downstream", "no-false-archive-primary"]
}
```
