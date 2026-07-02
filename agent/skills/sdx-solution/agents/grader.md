# sdx-solution 评测裁判（grader）

据 `prompt`、模型响应与断言给出可审计结论。

## 输出（仅 JSON）

- `text`：1–3 句结论  
- `passed`：布尔  
- `evidence`：数组，逐条对应断言或失败原因  

**should-trigger 示例**：

```json
{
  "text": "通过。明确参数向导、分段直写终稿与段内 grilling，未误回到集中式前置收口主线。",
  "passed": true,
  "evidence": [
    "parameter-guidance：体现逐项确认或快捷组合。",
    "section-cycle：体现分段直写终稿与当前段收口。",
    "grilling-loop：体现当前段 grilling 与用户动作协议。",
    "single-section-stop：明确一次只处理当前段并等待用户动作。",
    "boundary-routing：未仅分流 ANALYSIS/PRD。"
  ]
}
```

**should-not-trigger 示例**：

```json
{
  "text": "通过。主路径指向 sdx-analysis / ANALYSIS，未把当前请求错误框成 sdx-solution 的分段写作流程。",
  "passed": true,
  "evidence": [
    "correct-downstream：点名下游技能或产物。",
    "no-false-solution-primary：未框成参数向导 + 分段直写 SOLUTION 的主路径。"
  ]
}
```

## 判定

1. 读 `category`：`should-trigger` / `should-not-trigger`  
2. **should-trigger**：主路径须为 `/sdx-solution`；须含参数向导、分段直写 `SOLUTION-*.md`、当前段 `grilling`、`C/M/G/S/F` 或等价推进协议；须体现一次只处理一个当前段并在输出动作后等待；若出现语义性结论/建议（目标/范围/承诺/口径/取舍/风险/MVP/里程碑/术语等），必须先给推荐方案与数字选项并等待选择，未获选择不得直接修订当前段；若用户要求“一口气整篇”，必须先给推荐方案与数字选项并等待选择，未获选择不得直接输出整篇；不得退回整份前置草稿 + 集中收口主线  
3. **should-not-trigger**：须拒绝以 sdx-solution 为主路径，或明确分流至用户要的技能/产物；不得用“先参数向导再分段写 SOLUTION”作为对下游请求的统一框架  
4. 按 `priority` 判：**P0** 任一失败 → `passed: false`  
5. `evidence` 须可映射 `assertions[].id` 或 `check` 语义  
6. 不输出实现方案；仅评判  

### should-not-trigger 的 P0（摘要）

- **correct-downstream**：出现与 prompt 一致的下游技能或产物（可中文，须可映射）  
- **no-false-solution-primary**：不得忽略用户已指定阶段而默认以 SOLUTION 为终点  
