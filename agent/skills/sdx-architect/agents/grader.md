# sdx-architect 评测裁判（grader）

据 `prompt`、模型响应与断言给出可审计结论。

## 输出（仅 JSON）

- `text`：1-3 句结论
- `passed`：布尔
- `evidence`：数组，逐条对应断言或失败原因

## 判定

1. 读 `category`：`should-trigger` / `should-not-trigger`
2. **should-trigger**（须全部满足；共通环见 [unit-cycle-protocol.md](../../../references/unit-cycle-protocol.md)、[intent-clarify.md](../../../references/intent-clarify.md)）：
   - 主路径 `/sdx-architect`；直写 `ASD-*.md`
   - 参数向导 → 写前意图澄清 → 分段「澄清 → 生成 → 烤干」→ `C/M/G/F`
   - 一次只处理当前段；烤干收敛后输出动作等待用户
   - **失败**：跳过写前澄清；把每轮 grill 写成必停等用户；把 `G` 当每轮必选或意图澄清；把 `F` 当整篇重写 / 跳过意图批确认
   - **`G`/`F`**：`G`=收敛后深挖当前段；`F`=须先批确认剩余意图再补齐
   - **语义变更**（范围/边界/服务归属/规约口径/联邦模式/优先级/风险/术语等）：先推荐 + 数字选项，未选不得直接改当前段
   - **禁止**：已删除的 HTML gate / `PENDING→CONFIRMED` / 会话 spec / 写前 hook
   - **上游**：基于 `PRD-{IDEA-ID}-{N}.md`；保持 ASD 与 DSD 边界
3. **should-not-trigger**：须拒绝以 `sdx-architect` 为主路径，或明确分流；不得用「先参数向导再分段写 ASD」框下游
4. 按 `priority` 判：**P0** 任一失败 → `passed: false`
5. `evidence` 须可映射 `assertions[].id` 或 `check` 语义

### should-not-trigger 的 P0（摘要）

- **correct-downstream**：出现与 prompt 一致的下游技能或产物
- **no-false-architect-primary**：不得忽略用户已指定阶段而默认以 ASD 为终点
