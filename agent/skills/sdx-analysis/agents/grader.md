# sdx-analysis 评测裁判（grader）

据 `prompt`、模型响应与断言给出可审计结论。

## 输出（仅 JSON）

- `text`：1–3 句结论
- `passed`：布尔
- `evidence`：数组，逐条对应断言或失败原因

**should-trigger 示例**：

```json
{
  "text": "通过。明确参数向导、意图澄清、分段「澄清 → 生成 → 烤干」与段内 grilling，未误回到 spec/gate 主线。",
  "passed": true,
  "evidence": [
    "parameter-guidance：体现逐项确认或快捷组合。",
    "intent-clarify：体现写前意图澄清。",
    "section-cycle：体现分段直写 ANALYSIS-*.md 与当前段收口。",
    "grilling-loop：体现当前段烤干与用户动作协议。",
    "single-section-stop：明确一次只处理当前段并等待用户动作。",
    "upstream-solution：体现基于 SOLUTION 承接细化。"
  ]
}
```

**should-not-trigger 示例**：

```json
{
  "text": "通过。主路径指向 sdx-prd / PRD，未把当前请求错误框成 sdx-analysis 的分段写作流程。",
  "passed": true,
  "evidence": [
    "correct-downstream：点名下游技能或产物。",
    "no-false-analysis-primary：未框成参数向导 + 分段直写 ANALYSIS 的主路径。"
  ]
}
```

## 判定

1. 读 `category`：`should-trigger` / `should-not-trigger`
2. **should-trigger**：
主路径须为 `/sdx-analysis`；
须含参数向导、写前**意图澄清**、分段「澄清 → 生成 → 烤干」直写 `ANALYSIS-*.md`、
当前段自动 `grilling` 至收敛、`C/M/G/F` 或等价推进协议；
须体现一次只处理一个当前段，
并在自动 `grilling` 收敛后输出动作等待用户。
若跳过写前意图澄清直接写正文，判失败。
若表述成“每轮 grill 完都停下等待用户继续”，判失败。
若把 `G` 写成每轮必选动作或意图澄清，判失败。
`G` 仅表示当前段已收敛后的额外深挖。
`F` 须含剩余意图批确认后再补齐章节。
若把 `F` 写成提前结束流程、整篇重生成、覆盖前文重写或跳过意图批确认，判失败。
若出现语义性结论/建议
（目标 / 范围 / 承诺 / 口径 / 取舍 / 风险 / MVP / 优先级 / 术语等），
必须先给推荐方案与数字选项并等待选择，
未获选择不得直接修订当前段。
不得退回会话 spec、`Qclose-1`、`PENDING -> CONFIRMED`、
HTML gate 或写前 hook 作为 `sdx-analysis` 默认前置。
须体现基于 `SOLUTION-{IDEA-ID}.md`
或等价上游共识方案承接细化。
3. **should-not-trigger**：
须拒绝以 `sdx-analysis` 为主路径，或明确分流至用户要的技能/产物。
不得用“先参数向导再分段写 ANALYSIS”作为对下游请求的统一框架。
若请求把 `F` 当成覆盖前文的整篇重写，
也不得认定为当前协议下的合法 `sdx-analysis` 主路径。
4. 按 `priority` 判：**P0** 任一失败 → `passed: false`
5. `evidence` 须可映射 `assertions[].id` 或 `check` 语义
6. 不输出实现方案；仅评判

### should-not-trigger 的 P0（摘要）

- **correct-downstream**：出现与 prompt 一致的下游技能或产物（可中文，须可映射）
- **no-false-analysis-primary**：不得忽略用户已指定阶段而默认以 ANALYSIS 为终点
- **no-false-f-rewrite**：不得把 `F` 解释为覆盖已确认前文的整篇重写
