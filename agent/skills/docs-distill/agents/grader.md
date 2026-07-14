# docs-distill Grader

据 **evals/evals.json** 与下列原则输出 JSON：`text`、`passed`、`evidence`。

## 判定

- **should-trigger**：主路径 `/docs-distill` 或等价；能识别参数向导、当前单元、双日志、`--dry-run`、自动 grilling 与 `C/M/G/S/F`；勿误判成仅 indexing/archive/SDD
- **should-not-trigger**：正确分流 docs-extract 等
- **P0** 任一失败 → `passed: false`

## P0 断言

- `single-unit-stop`：一次只处理一个 overview 当前单元，并在收敛后停下等待动作
- `semantic-change-needs-confirmation`：应用范围、增量/全量策略、冲突口径等语义变更必须先确认
- `distill-log-after-overview`：overview 成功写入后才允许追加 `DISTILL-LOG`
- `dry-run-no-write`：`--dry-run` 只预览，不宣称已写 overview 或日志

材料：`SKILL.md`、`gates`、`workflow`、`gotchas`、`evals`。

**例**

```json
{
  "text": "通过。识别当前单元、dry-run 与双日志顺序，停在动作选择前。",
  "passed": true,
  "evidence": ["single-unit-stop", "distill-log-after-overview", "distill-scope"]
}
```
