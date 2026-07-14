# docs-extract 评测裁判（grader）

据 **evals/evals.json** 与下列原则输出 JSON：`text`、`passed`、`evidence`。

## 输出（仅此结构）

- `text`：1～3 句
- `passed`：布尔
- `evidence`：对应断言或失败原因

## 判定

1. `should-trigger` / `should-not-trigger`
2. **should-trigger**：主路径 `/docs-extract`；能识别参数向导、当前单元、关键词附录、`--sources`/`--overview`、`--dry-run`、自动 grilling 与 `C/M/G/S/F`；勿误判为 distill/archive/indexing
3. **should-not-trigger**：按用户声明分流；勿把 docs-distill 或 docs-archive 混成 extract 主答
4. **P0** 任一失败 → `passed: false`
5. 只评测，不提技能改写

## P0 断言

- `single-unit-stop`：一次只处理一个 overview 当前单元，并在收敛后停下等待动作
- `semantic-change-needs-confirmation`：来源范围、overview 目标、关键词口径等语义变更必须先确认
- `dry-run-no-write`：`--dry-run` 只预览，不宣称已写第三列
- `no-empty-write`：4.1 无命中时不能空写入

**should-trigger**

```json
{
  "text": "通过。识别当前单元、关键词附录与 dry-run，停在动作选择前。",
  "passed": true,
  "evidence": [
    "single-unit-stop",
    "dry-run-no-write",
    "extract-scope：--sources、关键词附录、A/U/D"
  ]
}
```

**should-not-trigger**

```json
{
  "text": "通过。主路径指向 docs-distill 等，未假主 extract。",
  "passed": true,
  "evidence": [
    "correct-downstream：点名 distill 或应用路径",
    "no-false-extract-primary：未仅索引式替代五阶段 extract"
  ]
}
```
