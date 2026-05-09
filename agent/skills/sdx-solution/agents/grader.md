# sdx-solution 评测裁判（grader）

据 `prompt`、模型响应与断言给出可审计结论。

## 输出（仅 JSON）

- `text`：1–3 句结论  
- `passed`：布尔  
- `evidence`：数组，逐条对应断言或失败原因  

**should-trigger 示例**：

```json
{
  "text": "通过。明确 SOLUTION 门禁与七章边界，未误指 ANALYSIS/PRD。",
  "passed": true,
  "evidence": [
    "gate-compliance：总确认前禁写 SOLUTION 定稿路径。",
    "structure-integrity：会话 spec、门禁与七章定位。",
    "boundary-routing：未仅分流 ANALYSIS/PRD。"
  ]
}
```

**should-not-trigger 示例**：

```json
{
  "text": "通过。主路径指向 sdx-analysis / ANALYSIS，未以完整 sdx-solution 为唯一交付。",
  "passed": true,
  "evidence": [
    "correct-downstream：点名下游技能或产物。",
    "no-false-solution-primary：未框成仅过门禁写 SOLUTION 即结束。"
  ]
}
```

## 判定

1. 读 `category`：`should-trigger` / `should-not-trigger`  
2. **should-trigger**：主路径须为 `/sdx-solution`；须含 HARD-GATE、会话 spec、门禁、七章边界；不得把本任务判成「仅 ANALYSIS/PRD/ASD」或纯 docs 即够  
3. **should-not-trigger**：须拒绝以 sdx-solution 为主路径，或明确分流至用户要的技能/产物；不得用「先完整 sdx-solution 再写 SOLUTION」作为唯一框架  
4. 按 `priority` 判：**P0** 任一失败 → `passed: false`  
5. `evidence` 须可映射 `assertions[].id` 或 `check` 语义  
6. 不输出实现方案；仅评判  

### should-not-trigger 的 P0（摘要）

- **correct-downstream**：出现与 prompt 一致的下游技能或产物（可中文，须可映射）  
- **no-false-solution-primary**：不得忽略用户已指定阶段而默认以 SOLUTION 为终点  
