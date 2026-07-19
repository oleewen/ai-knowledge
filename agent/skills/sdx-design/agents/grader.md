# sdx-design 评测裁判（grader）

据 `prompt`、模型响应与断言给出可审计结论。

## 输出（仅 JSON）

- `text`：1–3 句结论  
- `passed`：布尔  
- `evidence`：数组，逐条对应断言或失败原因  

**should-trigger 示例**（对齐 `design-trigger-001` 的 P0）：

```json
{
  "text": "通过。明确参数向导、意图澄清、分段「澄清 → 生成 → 烤干」与单段停住，未误回到集中式前置收口主线。",
  "passed": true,
  "evidence": [
    "parameter-guidance：体现逐项确认或快捷组合。",
    "section-cycle：体现分段直写终稿与当前段收口。",
    "intent-clarify：体现写前意图澄清。",
    "single-section-stop：明确一次只处理当前段并等待用户动作。",
    "upstream-input：体现基于 PRD 与 ASD/spec-asd 承接。"
  ]
}
```

**should-not-trigger 示例**：

```json
{
  "text": "通过。主路径指向 sdx-architect / ASD，未把当前请求错误框成 sdx-design 的分段写作流程。",
  "passed": true,
  "evidence": [
    "correct-downstream：点名下游技能或产物。",
    "no-false-design-primary：未框成参数向导 + 分段直写 DSD 的主路径。"
  ]
}
```

## 判定

1. 读 `category`：`should-trigger` / `should-not-trigger`
2. **硬门**：以本 eval 的 `assertions`（按 `priority`）为准；`evidence` 须可映射 `assertions[].id` 或 `check` 语义。
3. **协议释义**（仅当 assertions 或 prompt 覆盖时强制；共通环见 [unit-cycle-protocol.md](../../../references/unit-cycle-protocol.md)、[intent-clarify.md](../../../references/intent-clarify.md)）：
   - 主路径 `/sdx-design`；直写 `DSD-*.md`
   - 参数向导 → 写前意图澄清 → 分段「澄清 → 生成 → 烤干」→ `C/M/G/F`（无 `S`）
   - 一次只处理当前段；烤干收敛后输出动作等待用户
   - **`G`/`F`**：`G`=收敛后深挖当前段；`F`=须先批确认剩余意图再补齐
   - **语义变更**（接口语义/数据模型/错误码口径/幂等策略/事务边界/非功能取舍/术语等）：先推荐 + 数字选项，未选不得直接改当前段
   - **上游**：基于 `PRD-{IDEA-ID}-{N}.md` 与 `ASD/spec-asd`；保持 DSD 与 ASD/TDD/docs-* 边界
   - **禁止**：前置草稿 + 集中收口；已删除的 HTML gate / `PENDING→CONFIRMED` / 会话 spec / 写前 hook
4. **should-not-trigger**：须拒绝以 sdx-design 为主路径，或明确分流至用户要的技能/产物；不得用「先参数向导再分段写 DSD」框下游请求；不得把 `F` 整篇重写认作合法主路径
5. **P0** 任一失败 → `passed: false`
6. 不输出实现方案；仅评判

### should-not-trigger 的 P0（摘要）

- **correct-downstream**：出现与 prompt 一致的下游技能或产物（可中文，须可映射）
- **no-false-design-primary**：不得忽略用户已指定阶段而默认以 DSD 为终点
- **no-false-f-rewrite**：不得把 `F` 解释为覆盖已确认前文的整篇重写
