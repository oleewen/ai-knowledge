# docs-agent Grader

据 [evals.json](../evals/evals.json) 输出 JSON：`text`、`status`（pass/fail/not_run）、`evidence`。

## 判定

1. 读 `category`：`should-trigger` / `should-not-trigger`
2. **硬门**：以本 eval 的 `assertions`（按 `priority`）为准；`evidence` 逐条对应 `assertions[].id` 并包含可核对的实际证据
3. **协议释义**（仅当 assertions / prompt 覆盖时强制）：参数向导 → 写前意图澄清 → 单单元「澄清 → 生成 → 烤干」→ `C/M/G/S/F`；烤干须含受众维 A/B/C/E（见 [audience-and-language.md](../../../references/audience-and-language.md)）；INDEX 驱动且不包揽 docs-indexing。见 [unit-cycle-protocol.md](../../../references/unit-cycle-protocol.md)、[intent-clarify.md](../../../references/intent-clarify.md)
4. 任一适用断言失败则整例 fail；无失败但存在未执行或缺证据断言则 not_run；全部适用断言有证据通过才为 pass。

## 证据要求

`evidence` 使用字符串数组，每条写明断言 id、`pass` / `fail` / `not_run` 及依据。逐条覆盖当前 eval 的全部 assertions，不能用样例中的子集替代本场断言。

- 响应行为：引用实际响应短句，并标明响应或步骤位置。
- 执行行为：给出实际工具调用、退出状态及关键输出；只说“将运行”不证明已执行。
- 产物行为：给出实际文件路径与相关内容、差异或只读前后对照。
- 未取得所需响应、工具轨迹或产物时标 `not_run`；缺证据不能推定通过。不存在实际执行时，不编造日志或文件。

P1 也须逐条报告实际状态，不隐去未执行项。`must_not_conflict` 应核对完整响应和相关工具轨迹，不能仅凭某句话未出现判通过。独立评测隐藏评分预期，保存真实响应、命令及产物；目录访问约束不等同操作系统沙箱。

### should-not-trigger P0 摘要

- `correct-downstream`：点名下游技能/产物
- `no-false-indexing`：不以本技能重写九章 INDEX

**未运行例**（对齐 `docs-agent-trigger-001`）

```json
{
  "text": "未评测。尚无该场景的实际响应、工具轨迹或产物，不能判断通过。",
  "status": "not_run",
  "evidence": [
    "parameter-guidance | not_run | 未提供实际运行记录，暂无可核对证据。",
    "intent-clarify-before-write | not_run | 未提供实际运行记录，暂无可核对证据。",
    "single-unit-stop | not_run | 未提供实际运行记录，暂无可核对证据。",
    "audience-check | not_run | 未提供实际运行记录，暂无可核对证据。",
    "index-driven | not_run | 未提供实际运行记录，暂无可核对证据。",
    "semantic-change-gated | not_run | 未提供实际运行记录，暂无可核对证据。",
    "validate-script | not_run | 未提供实际运行记录，暂无可核对证据。"
  ]
}
```
