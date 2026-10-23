# docs-push Grader

据 **evals/evals.json** 输出 JSON：`text`、`passed`、`evidence`。

## 判定

1. 读 `category`：`should-trigger` / `should-not-trigger`（缺省按 should-trigger）
2. **硬门**：以本 eval 的 `assertions`（按 `priority`）为准；`evidence` 逐条对应 `assertions[].id` 并包含可核对的实际证据
3. **协议释义**（仅当 assertions / prompt 覆盖时强制）：轻流程参数向导 → dry-run/风险校核 → `C/M/S/F`（无 `G`、不绑意图澄清）。写后受众 A/B。见 [light-flow-actions.md](../../../references/light-flow-actions.md)、[audience-and-language.md](../../../references/audience-and-language.md)
4. **P0** 任一失败 → `passed: false`

## 证据要求

保留 `text`、`passed`、`evidence` 字段；`evidence` 继续使用字符串数组，每条写明断言 id、`pass` / `fail` / `not_run` 及依据。逐条覆盖当前 eval 的全部 assertions，不能用样例中的子集替代本场断言。

- 响应行为：引用实际响应短句，并标明响应或步骤位置。
- 执行行为：给出实际工具调用、退出状态及关键输出；只说“将运行”不证明已执行。
- 产物行为：给出实际文件路径与相关内容、差异或只读前后对照。
- 未取得所需响应、工具轨迹或产物时标 `not_run`；缺证据不能推定通过。不存在实际执行时，不编造日志或文件。

任一 P0 为 `fail` 或 `not_run`，`passed` 均为 `false`；`text` 区分失败和未评测。只有全部 P0 有证据通过才可填 `true`。P1 也须逐条报告实际状态，不隐去未执行项。`must_not_conflict` 应核对完整响应和相关工具轨迹，不能仅凭某句话未出现判通过。

### 常见 P0 摘要

- `single-target-stop`：单目标停顿
- `dry-run-route-confirmation`：dry-run 后先核路由
- `git-op-must-confirm`：git push / message 须显式授权

**未运行例**（对齐 eval id 1）

```json
{
  "text": "未评测。尚无该场景的实际响应、工具轨迹或产物，不能判断通过。",
  "passed": false,
  "evidence": [
    "single-target-stop | not_run | 未提供实际运行记录，暂无可核对证据。",
    "dry-run-route-confirmation | not_run | 未提供实际运行记录，暂无可核对证据。",
    "audience-check-ab | not_run | 未提供实际运行记录，暂无可核对证据。"
  ]
}
```
