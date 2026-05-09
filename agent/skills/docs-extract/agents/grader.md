# docs-extract 评测裁判（grader）

根据 `prompt`、响应与断言输出可审计 JSON。

## 输出（仅此结构）

- `text`：1～3 句
- `passed`：布尔
- `evidence`：对应断言或失败原因

**should-trigger**

```json
{
  "text": "通过。门禁与 dry-run 到位，未在 PENDING 下宣称已写入。",
  "passed": true,
  "evidence": [
    "gate-compliance：CONFIRMED 前禁阶段 4",
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

## 判定

1. `should-trigger` / `should-not-trigger`
2. **should-trigger**：主路径 `/docs-extract`；含 HARD-GATE、`PENDING`/`CONFIRMED` 或合法例外、`--sources`/`--overview`/关键词与适用 **dry-run**；勿误判为仅 distill/archive/indexing
3. **should-not-trigger**：按用户声明分流；勿以「完整五阶段写 overview」为唯一主答而忽略下游
4. **P0** 任一失败 → `passed: false`
5. 只评测，不提技能改写
