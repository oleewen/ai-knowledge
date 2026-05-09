# sdx-analysis 评测裁判（grader）

据 `prompt`、响应与断言输出可审计结论。

## 输出（仅 JSON）

- `text`：1–3 句  
- `passed`：布尔  
- `evidence`：逐条对应断言或失败原因  

**should-trigger 示例**：

```json
{
  "text": "通过。明确 ANALYSIS 门禁、六章及与 SOLUTION 关系。",
  "passed": true,
  "evidence": [
    "gate-compliance：总确认前禁写 ANALYSIS 定稿路径。",
    "structure-integrity：六章/门禁/基于 SOLUTION。",
    "boundary-routing：未误判为仅 SOLUTION 或 PRD。"
  ]
}
```

**should-not-trigger 示例**：

```json
{
  "text": "通过。主路径指 sdx-solution / SOLUTION，未以完整 sdx-analysis 为唯一交付。",
  "passed": true,
  "evidence": [
    "correct-downstream：点名下游技能或产物。",
    "no-false-analysis-primary：未框成仅过 G1–G6 写 ANALYSIS 即结束。"
  ]
}
```

## 判定

1. `category`：`should-trigger` / `should-not-trigger`  
2. **should-trigger**：主路径 `/sdx-analysis`；须 HARD-GATE、会话 spec、6G 或精简 4G、**基于 SOLUTION** 的 ANALYSIS；不得误判为只做 SOLUTION/PRD/ASD 或纯 docs  
3. **should-not-trigger**：须拒绝本技能为主路径或明确分流；不得「先完整 sdx-analysis 再写 ANALYSIS」为唯一框架  
4. **P0** 任一失败 → `passed: false`  
5. `evidence` 映射 `assertions[].id` 或 `check`  
6. 不写实现改进方案  

### should-not-trigger 的 P0

- **correct-downstream**：与 prompt 一致的技能或产物（可中文，须可映射）  
- **no-false-analysis-primary**：不得忽略用户已指定阶段而把 ANALYSIS 当默认终点  
