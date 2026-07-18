# sdx-test 评测裁判（grader）

据 `prompt`、模型响应与断言给出可审计结论。

## 输出（仅 JSON）

- `text`：1-3 句结论
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
    "section-cycle：体现分段直写 TDD-*.md 与当前段收口。",
    "grilling-loop：体现当前段烤干与用户动作协议。",
    "single-section-stop：明确一次只处理当前段并等待用户动作。",
    "upstream-input：体现基于 PRD 与 DSD/ASD 承接。"
  ]
}
```

**should-not-trigger 示例**：

```json
{
  "text": "通过。主路径指向 sdx-prd / PRD，未把当前请求错误框成 sdx-test 的分段写作流程。",
  "passed": true,
  "evidence": [
    "correct-downstream：点名下游技能或产物。",
    "no-false-test-primary：未框成参数向导 + 分段直写 TDD 的主路径。"
  ]
}
```

## 判定

1. 读 `category`：`should-trigger` / `should-not-trigger`
2. **should-trigger**（须全部满足；共通环见 [unit-cycle-protocol.md](../../../references/unit-cycle-protocol.md)、[intent-clarify.md](../../../references/intent-clarify.md)）：
   - 主路径 `/sdx-test`；直写 `TDD-*.md`
   - 参数向导 → 写前意图澄清 → 分段「澄清 → 生成 → 烤干」→ `C/M/G/F`
   - 一次只处理当前段；烤干收敛后输出动作等待用户
   - **失败**：跳过写前澄清；把每轮 grill 写成必停等用户；把 `G` 当每轮必选或意图澄清；把 `F` 当提前结束 / 整篇重写 / 跳过意图批确认
   - **`G`/`F`**：`G`=收敛后深挖当前段；`F`=须先批确认剩余意图再补齐
   - **语义变更**（测试范围/优先级/回归边界/数据或环境约束/退出标准/术语等）：先推荐 + 数字选项，未选不得直接改当前段
   - **禁止**：已删除的 HTML gate / `PENDING→CONFIRMED` / 会话 spec / 写前 hook
   - **上游**：基于 `PRD-{IDEA-ID}-{N}.md` 与 `DSD/ASD`；保持 TDD 与 PRD/DSD/ASD/docs-* 边界
3. **should-not-trigger**：须拒绝以 `sdx-test` 为主路径，或明确分流；不得用「先参数向导再分段写 TDD」框下游；不得把 `F` 整篇重写认作合法主路径
4. 按 `priority` 判：**P0** 任一失败 → `passed: false`
5. `evidence` 须可映射 `assertions[].id` 或 `check` 语义
6. 不输出实现方案；仅评判

### should-not-trigger 的 P0（摘要）

- **correct-downstream**：出现与 prompt 一致的下游技能或产物
- **no-false-test-primary**：不得忽略用户已指定阶段而默认以 TDD 为终点
- **no-false-f-rewrite**：不得把 `F` 解释为覆盖已确认前文的整篇重写
