# sdx-architect 评测裁判（grader）

据 `prompt`、模型响应与断言给出可审计结论。

## 输出（仅 JSON）

- `text`：1-3 句结论
- `passed`：布尔
- `evidence`：数组，逐条对应断言或失败原因

## 判定

1. 读 `category`：`should-trigger` / `should-not-trigger`
2. **should-trigger**：
主路径须为 `/sdx-architect`；
须含参数向导、写前**意图澄清**、分段「澄清 → 生成 → 烤干」直写 `ASD-*.md`、
当前段自动 `grilling` 至收敛、`C/M/G/F` 或等价推进协议；
须体现一次只处理一个当前段，
并在自动 `grilling` 收敛后输出动作等待用户。
若跳过写前意图澄清直接写正文，判失败。
若表述成“每轮 grill 完都停下等待用户继续”，判失败。
若把 `G` 写成每轮必选动作或意图澄清，判失败。
`G` 仅表示当前段已收敛后的额外深挖。
`F` 须含剩余意图批确认后再补齐章节。
若把 `F` 写成整篇重生成、覆盖前文重写或跳过意图批确认，判失败。
若出现语义性结论/建议
（范围 / 边界 / 服务归属 / 规约口径 / 联邦模式 / 优先级 / 风险 / 术语等），
必须先给推荐方案与数字选项并等待选择。
不得退回已删除的 HTML gate、`PENDING→CONFIRMED`、会话 spec 或写前 hook 作为默认前置；主线见 unit-cycle-protocol。
须体现基于 `PRD-{IDEA-ID}-{N}.md` 承接，
并保持 ASD 与 DSD 的边界。
3. **should-not-trigger**：
须拒绝以 `sdx-architect` 为主路径，或明确分流至用户要的技能/产物。
不得用“先参数向导再分段写 ASD”作为对下游请求的统一框架。
4. 按 `priority` 判：**P0** 任一失败 → `passed: false`
5. `evidence` 须可映射 `assertions[].id` 或 `check` 语义

### should-not-trigger 的 P0（摘要）

- **correct-downstream**：出现与 prompt 一致的下游技能或产物
- **no-false-architect-primary**：不得忽略用户已指定阶段而默认以 ASD 为终点
