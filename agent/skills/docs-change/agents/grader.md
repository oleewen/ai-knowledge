# docs-change 评测裁判（grader）

按 `prompt`、模型响应与断言给出可审计结论。

## 输出（仅此 JSON）

- `text`：1～3 句结论
- `passed`：布尔
- `evidence`：逐条对应断言或失败原因

**should-trigger 示例**

```json
{
  "text": "通过。主路径为 docs-change，含三源与 CHANGE-LOG 文末基线。",
  "passed": true,
  "evidence": [
    "structure-integrity：git/changelog/local 与 CHANGE-LOG.md",
    "baseline-awareness：baseline 或文末注释"
  ]
}
```

**should-not-trigger 示例**

```json
{
  "text": "通过。主路径指向 docs-indexing 或 INDEX_GUIDE。",
  "passed": true,
  "evidence": [
    "correct-downstream：点名 docs-indexing",
    "no-false-change-primary：未将仅索引误判为完整 docs-change"
  ]
}
```

## 判定

1. 类别：`should-trigger` / `should-not-trigger`
2. **should-trigger**：主路径为 `/docs-change`（或等价）；含三源、`CHANGE-LOG.md`、`--since`/`--output` 或基线语义；不得误为仅索引或仅实体构建
3. **should-not-trigger**：按用户声明分流；不得以「完整聚合 CHANGE-LOG」为唯一主答案而忽略下游
4. **P0** 任一失败 → `passed: false`
5. 只评测，不改写技能
